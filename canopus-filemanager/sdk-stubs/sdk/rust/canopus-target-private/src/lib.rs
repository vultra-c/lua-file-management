//! OFFLINE STUB — canopus-target-private（真实 crate 闭源，含每个固件的符号地址表）。
//!
//! 仅用于无 Canopus SDK 时对模块做 `cargo check`。所有 extern "C" 声明无函数体，
//! `cargo check` 不做链接，故可过；真机构建时用真实 SDK 替换（符号地址由 target pack 提供）。
#![no_std]

use core::ffi::c_void;

pub const TARGET_ID: &str = "xiaomi-band-9-pro-3.1.175";

// ---------------------------------------------------------------------------
// 固件身份 / NuttX 基础
// ---------------------------------------------------------------------------
extern "C" {
    pub fn canopus_identity_guard() -> i32;
    pub fn nuttx_open(path: *const u8, flags: i32) -> i32;
    pub fn nuttx_write(fd: i32, buf: *const c_void, len: u32) -> i32;
    pub fn nuttx_close(fd: i32) -> i32;
}

// ---------------------------------------------------------------------------
// 原生应用注册（re/canopus/SPEC.md §2）
// ---------------------------------------------------------------------------
/// Provisional 9 Pro layout recovered from `app_install` in the bundled AP.
///
/// This is intentionally a raw, target-specific layout rather than the older
/// four-field public sketch: the 3.1.175 image reads the package/name pointer
/// at +0x08, the icon/pointer field at +0x0c, and the u16 app id at +0x10;
/// it copies 0x3c bytes and later owns +0x00/+0x04 as registry links.
/// Fields after +0x10 remain provisional until a real target-private SDK or a
/// read-only device probe confirms their meaning.
#[repr(C)]
pub struct launcher_app_descriptor {
    pub registry_prev: *mut c_void, // +0x00, firmware-owned after install
    pub registry_next: *mut c_void, // +0x04, firmware-owned after install
    pub package_name: *mut c_void, // +0x08
    pub launcher_icon_resource: *mut c_void, // +0x0c
    pub app_id: u16, // +0x10
    pub app_id_padding: u16,
    pub launcher_metadata_callback: *mut c_void, // +0x14, role still provisional
    pub field_18: *mut c_void, // +0x18, role still provisional
    pub lifecycle_callback: *mut c_void, // +0x1c, callback-like in teardown
    pub reserved: [u32; 7], // +0x20..+0x3b; copied by app_install
}

#[repr(C)]
pub struct firmware_page_descriptor {
    pub page_name: *mut c_void,
    pub page_id: u16,
    pub app_id: u16,
    pub on_signal: *mut c_void,
    pub on_create: *mut c_void,
    pub on_resume: *mut c_void,
    pub on_pause: *mut c_void,
    pub on_destroy: *mut c_void,
}

extern "C" {
    pub fn app_install(
        app: *mut launcher_app_descriptor,
        pages: *const *mut firmware_page_descriptor,
        page_count: u32,
    ) -> i32;
    pub fn app_lookup(app_id: u16) -> *mut c_void;
    pub fn launcher_add(app_id: u16) -> i32;
}

// ---------------------------------------------------------------------------
// LVX 渲染（re/canopus/SPEC.md §3，band-9 分支）
// ---------------------------------------------------------------------------
pub const EVENT_CLICKED: u32 = 6;
pub const EVENT_VALUE_CHANGED: u32 = 7;
pub const EVENT_ALL: u32 = 0xFFFF;

pub const ALIGN_TOP_MID: u32 = 1;
pub const ALIGN_OUT_BOTTOM_MID: u32 = 2;

#[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
pub const TRAILING_B9_SWITCH: u8 = 1;
#[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
pub const TRAILING_B9_FORWARD: u8 = 12;

#[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
pub const TRAILING_NONE: u8 = 0;
#[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
pub const TRAILING_SWITCH: u8 = 1;
#[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
pub const TRAILING_FORWARD: u8 = 12;

pub const STYLE_MISANS_DEMIBOLD_32: u32 = 0;

extern "C" {
    pub fn lvx_page_title_create(
        parent: *mut c_void,
        title: *const u8,
        mode: u32,
        back_cb: *const (),
        back_ctx: *mut c_void,
    ) -> *mut c_void;
    pub fn lvx_content_create(parent: *mut c_void) -> *mut c_void;
    pub fn lvx_label_create(parent: *mut c_void) -> *mut c_void;
    pub fn lvx_label_set_text(obj: *mut c_void, text: *const u8);
    pub fn lvx_style_apply(obj: *mut c_void, style: *const c_void, sel: u32, part: u32);
    #[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
    pub fn lvx_list_row_create(parent: *mut c_void, primary: *const u8) -> *mut c_void;
    #[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
    pub fn lvx_list_row_create(
        parent: *mut c_void,
        primary: *const u8,
        secondary: *const u8,
        trailing: u8,
    ) -> *mut c_void;
    pub fn lvx_list_row_set_trailing(row: *mut c_void, kind: u8, arg: u32);
    pub fn lvx_list_row_update(
        row: *mut c_void,
        icon: *mut c_void,
        primary: *const u8,
        secondary: *const u8,
        trailing: u32,
        selected: u8,
    );
    pub fn lvx_list_row_trailing(row: *mut c_void) -> *mut c_void;
    pub fn lvx_set_hidden(obj: *mut c_void, hidden: u8);
    pub fn lvx_align_to(obj: *mut c_void, base: *mut c_void, align: u32, x: i32, y: i32);
    pub fn lvx_object_set_size(obj: *mut c_void, w: u32, h: u32);
    pub fn lvx_object_align(obj: *mut c_void, align: u32, x: i32, y: i32);
    pub fn lvx_event_add(obj: *mut c_void, cb: extern "C" fn(*mut c_void), code: u32, user_data: *mut c_void);
    pub fn lvx_event_get_code(event: *mut c_void) -> u32;
    pub fn lvx_event_get_user_data(event: *mut c_void) -> usize;
    pub fn lvx_timer_create(cb: extern "C" fn(*mut c_void), period_ms: u32, user_data: *mut c_void) -> *mut c_void;
    pub fn lvx_timer_delete(timer: *mut c_void);
}

// ---------------------------------------------------------------------------
// 导航
// ---------------------------------------------------------------------------
extern "C" {
    pub fn activity_navigate(key: u32, a: u32, b: u32, c: u32);
    pub fn activity_finish(page: *mut firmware_page_descriptor);
}
