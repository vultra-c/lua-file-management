//! Native app registration：固定 app id、launcher 条目、两个页面描述符
//! （列表 + 详情）以及页面生命周期回调。
//!
//! 结构与 `bluetooth-audio-device/src/target/native_app.rs` 一致：
//! app/page 注册与 Launcher 发布分两次调用（stage 1 / stage 2），
//! 让 miwear 先处理 app-registry 事件再持久化 Launcher 条目。

use core::sync::atomic::Ordering;

use canopus_target_private::*;

use super::runtime;
use super::ui_backend;

pub const APP_ID: u16 = 0x00D1; // 文件管理器固定 id（避开蓝牙示例 0x00CB）
pub const PAGE_COUNT: usize = 2;
pub const PAGE_LIST: usize = 0;
pub const PAGE_DETAIL: usize = 1;

pub const PACKAGE_NAME: &[u8] = b"com.canopus.filemanager\0";
pub const DISPLAY_NAME: &[u8] = b"Files\0";
// 图标由安装表盘在 install 前 stage 到 /data/canopus/appicon_filemanager.bin
// （117×117 ARGB4444，与蓝牙示例的 appicon_headphones.bin 同格式同流程）。
pub const LAUNCHER_ICON: &[u8] = b"/data/canopus/appicon_filemanager.bin\0";
const PAGE_NAME_LIST: &[u8] = b"files\0";
const PAGE_NAME_DETAIL: &[u8] = b"file_detail\0";

const APP_REGISTERED: u32 = 1;
const APP_OK: u32 = 2;
const APP_FAILED: u32 = 3;

static mut APP_DESCRIPTOR: core::mem::MaybeUninit<launcher_app_descriptor> =
    core::mem::MaybeUninit::uninit();
static mut PAGE_DESCRIPTORS: core::mem::MaybeUninit<[firmware_page_descriptor; PAGE_COUNT]> =
    core::mem::MaybeUninit::uninit();

pub fn page_descriptor_ptr(index: usize) -> *mut firmware_page_descriptor {
    // SAFETY: PAGE_DESCRIPTORS 由 `install_stage` 在任何页面回调可运行前初始化；
    // 固件只在 install 返回后读这些描述符。
    unsafe {
        core::ptr::addr_of_mut!(PAGE_DESCRIPTORS)
            .cast::<firmware_page_descriptor>()
            .add(index)
    }
}

extern "C" fn launcher_display_name() -> *const u8 {
    DISPLAY_NAME.as_ptr()
}

fn c_str_equal(a: *const u8, expected: &[u8]) -> bool {
    if a.is_null() || expected.last() != Some(&0) {
        return false;
    }
    let mut i = 0usize;
    while i < expected.len() {
        if unsafe { *a.add(i) } != expected[i] {
            return false;
        }
        i += 1;
    }
    true
}

fn app_descriptor_init() {
    // SAFETY: APP_DESCRIPTOR 是模块私有 static，在 `app_install` 发布前恰好初始化一次。
    unsafe {
        core::ptr::write_bytes(
            core::ptr::addr_of_mut!(APP_DESCRIPTOR).cast::<u8>(),
            0,
            core::mem::size_of::<launcher_app_descriptor>(),
        );
    }
    // SAFETY: 写入刚清零的 static。
    unsafe {
        let app = &mut *core::ptr::addr_of_mut!(APP_DESCRIPTOR).cast::<launcher_app_descriptor>();
        app.package_name = PACKAGE_NAME.as_ptr() as *mut core::ffi::c_void;
        app.launcher_icon_resource = LAUNCHER_ICON.as_ptr() as *mut core::ffi::c_void;
        app.app_id = APP_ID;
        app.launcher_metadata_callback = launcher_display_name as *const () as *mut core::ffi::c_void;
    }
}

fn descriptor_init(index: usize, name: &[u8], page_id: u16) {
    let descriptor = page_descriptor_ptr(index);
    // SAFETY: descriptor 指向 static 数组中的零值区域；`app_install` 前固件不读它。
    unsafe {
        core::ptr::write_bytes(
            descriptor.cast::<u8>(),
            0,
            core::mem::size_of::<firmware_page_descriptor>(),
        );
        (*descriptor).page_name = name.as_ptr() as *mut core::ffi::c_void;
        (*descriptor).page_id = page_id;
        (*descriptor).app_id = APP_ID;
        (*descriptor).on_signal = page_on_signal as *const () as *mut core::ffi::c_void;
        (*descriptor).on_create = page_on_create as *const () as *mut core::ffi::c_void;
        (*descriptor).on_resume = page_on_resume as *const () as *mut core::ffi::c_void;
        (*descriptor).on_pause = page_on_pause as *const () as *mut core::ffi::c_void;
        (*descriptor).on_destroy = page_on_destroy as *const () as *mut core::ffi::c_void;
    }
}

/// 执行一个 native-app 发布阶段。stage 1 注册 app + 页面；stage 2 在
/// miwear 处理完 app-registry 事件后把 Launcher 条目写进去。
pub fn install_stage(stage: u32) -> Result<(), i32> {
    let existing = unsafe { app_lookup(APP_ID) };

    if stage == 1 {
        if !existing.is_null() {
            // 已安装 app 对象的包名指针在 +0x8。
            let package: *const u8 =
                unsafe { core::ptr::read(existing.cast::<u8>().add(8) as *const *const u8) };
            if !c_str_equal(package, PACKAGE_NAME) {
                return Err(-101);
            }
            return Ok(());
        }

        app_descriptor_init();
        descriptor_init(PAGE_LIST, PAGE_NAME_LIST, PAGE_LIST as u16);
        descriptor_init(PAGE_DETAIL, PAGE_NAME_DETAIL, PAGE_DETAIL as u16);

        // SAFETY: 描述符已清零并完整初始化；app_install 同步消费本地指针数组并保留描述符。
        let pages: [*mut firmware_page_descriptor; PAGE_COUNT] =
            [page_descriptor_ptr(0), page_descriptor_ptr(1)];
        let install_result = unsafe {
            app_install(
                core::ptr::addr_of_mut!(APP_DESCRIPTOR).cast::<launcher_app_descriptor>(),
                pages.as_ptr(),
                PAGE_COUNT as u32,
            )
        };
        let _ = install_result;
        let installed = unsafe { app_lookup(APP_ID) };
        if installed.is_null() {
            return Err(-100);
        }
        let package: *const u8 =
            unsafe { core::ptr::read(installed.cast::<u8>().add(8) as *const *const u8) };
        if !c_str_equal(package, PACKAGE_NAME) {
            return Err(-101);
        }
        return Ok(());
    }

    if stage == 2 {
        if existing.is_null() {
            return Err(-102);
        }
        let package: *const u8 =
            unsafe { core::ptr::read(existing.cast::<u8>().add(8) as *const *const u8) };
        if !c_str_equal(package, PACKAGE_NAME) {
            return Err(-101);
        }
        // `launcher_add` 返回的是实现定义的簿记结果，不是 0=成功；
        // 成功判据是上面的 app_lookup 校验通过。
        unsafe { launcher_add(APP_ID) };
        return Ok(());
    }

    Err(-103)
}

// ---------------------------------------------------------------------------
// 页面生命周期（固件 → 模块）。渲染只在 page owner 线程；LVX 绝不在
// 定时器/其它回调里碰。
// ---------------------------------------------------------------------------

fn page_id_of(page: *mut firmware_page_descriptor) -> usize {
    if page.is_null() {
        return usize::MAX;
    }
    // SAFETY: 固件传入的是我们注册的描述符之一。
    usize::from(unsafe { (*page).page_id })
}

extern "C" fn page_on_signal(
    _page: *mut firmware_page_descriptor,
    _event: u32,
    _payload: *mut core::ffi::c_void,
) -> i32 {
    0
}

extern "C" fn page_on_create(
    page: *mut firmware_page_descriptor,
    root: *mut core::ffi::c_void,
    _start_data: *mut core::ffi::c_void,
) -> i32 {
    let index = page_id_of(page);
    if index >= PAGE_COUNT {
        return -1;
    }
    ui_backend::page_create(index, root)
}

extern "C" fn page_on_resume(page: *mut firmware_page_descriptor) -> i32 {
    let index = page_id_of(page);
    if index >= PAGE_COUNT {
        return -1;
    }
    ui_backend::page_resume(index)
}

extern "C" fn page_on_pause(page: *mut firmware_page_descriptor) -> i32 {
    let index = page_id_of(page);
    if index >= PAGE_COUNT {
        return -1;
    }
    ui_backend::page_pause(index)
}

extern "C" fn page_on_destroy(page: *mut firmware_page_descriptor) -> i32 {
    let index = page_id_of(page);
    if index >= PAGE_COUNT {
        return -1;
    }
    ui_backend::page_destroy(index)
}

/// 供 target/mod.rs 记录发布状态（MVP 不强制）。
pub fn publish_state() -> [u32; 4] {
    [APP_REGISTERED, APP_OK, APP_FAILED, runtime::fm().last_error as u32]
}
