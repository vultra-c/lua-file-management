//! Stock LVX renderer：把 `ui::PageSnapshot` 映射到固件列表行 / 标签 / 页标题，
//! 并分发行/返回事件（带 generation 校验的绑定）。
//!
//! 结构与 `bluetooth-audio-device/src/target/ui_backend.rs` 一致，含 band-9
//! 专属分支（无 `lvx_content_create`；行工厂两参数 + `lvx_list_row_set_trailing`）。
//! 固件控件指针只存在这里，页面销毁时清空。LVX 只在 page owner 线程碰。

use canopus_target_private::*;

use super::native_app::{APP_ID, PAGE_COUNT, PAGE_DETAIL, PAGE_LIST, page_descriptor_ptr};
use super::ui::{PageSnapshot, ROW_ACTION, ROW_STATUS, detail_size_len, detail_size_ptr, page_title};

pub const UI_MAX_ROWS: usize = 8;
pub const UI_MAX_LABELS: usize = 4;

const REFRESH_PERIOD_MS: u32 = 250;

static EMPTY_TEXT: [u8; 1] = [0];

#[derive(Copy, Clone)]
#[repr(C)]
struct Binding {
    generation: u32,
    key: u32,
    event_id: u32,
    enabled: bool,
}

#[derive(Copy, Clone)]
struct PageBackend {
    root: *mut core::ffi::c_void,
    content_root: *mut core::ffi::c_void,
    page_title: *mut core::ffi::c_void,
    refresh_timer: *mut core::ffi::c_void,
    rows: [*mut core::ffi::c_void; UI_MAX_ROWS],
    labels: [*mut core::ffi::c_void; UI_MAX_LABELS],
    row_kinds: [u8; UI_MAX_ROWS],
    row_hashes: [u32; UI_MAX_ROWS],
    label_hashes: [u32; UI_MAX_LABELS],
    bindings: [Binding; UI_MAX_ROWS],
    row_count: u32,
    label_count: u32,
    rendered_generation: u32,
    layout_hash: u32,
    layout_count: u32,
    page_index: u8,
    layout_valid: bool,
    active: bool,
    interactive: bool,
    refresh_failed: bool,
}

const fn empty_backend() -> PageBackend {
    PageBackend {
        root: core::ptr::null_mut(),
        content_root: core::ptr::null_mut(),
        page_title: core::ptr::null_mut(),
        refresh_timer: core::ptr::null_mut(),
        rows: [core::ptr::null_mut(); UI_MAX_ROWS],
        labels: [core::ptr::null_mut(); UI_MAX_LABELS],
        row_kinds: [0; UI_MAX_ROWS],
        row_hashes: [0; UI_MAX_ROWS],
        label_hashes: [0; UI_MAX_LABELS],
        bindings: [Binding {
            generation: 0,
            key: 0,
            event_id: 0,
            enabled: false,
        }; UI_MAX_ROWS],
        row_count: 0,
        label_count: 0,
        rendered_generation: 0,
        layout_hash: 0,
        layout_count: 0,
        page_index: 0,
        layout_valid: false,
        active: false,
        interactive: false,
        refresh_failed: false,
    }
}

static mut PAGES: [PageBackend; PAGE_COUNT] = [empty_backend(); PAGE_COUNT];

fn page_backend(index: usize) -> &'static mut PageBackend {
    // SAFETY: 所有调用方都校验 index < PAGE_COUNT；固件在 UI 线程串行化
    // 页面生命周期回调。
    unsafe { &mut *core::ptr::addr_of_mut!(PAGES).cast::<PageBackend>().add(index) }
}

extern "C" fn refresh_timer(timer: *mut core::ffi::c_void) {
    if timer.is_null() {
        return;
    }
    for page_index in 0..PAGE_COUNT {
        let backend = page_backend(page_index);
        if backend.refresh_timer != timer {
            continue;
        }
        if backend.active && backend.interactive && !backend.refresh_failed {
            let rendered_generation = backend.rendered_generation;
            if super::rebuild_if_changed(page_index, rendered_generation) != 0 {
                backend.refresh_failed = true;
            }
        }
        return;
    }
}

// ---------------------------------------------------------------------------
// 页面生命周期（由 native_app 委托）
// ---------------------------------------------------------------------------

pub fn page_create(page_index: usize, root: *mut core::ffi::c_void) -> i32 {
    if page_index >= PAGE_COUNT || root.is_null() {
        return -1;
    }
    let backend = page_backend(page_index);
    backend.root = root;
    backend.page_index = page_index as u8;
    backend.active = true;
    backend.interactive = true;
    let result = super::rebuild(page_index);
    if result != 0 {
        *page_backend(page_index) = empty_backend();
        return result;
    }
    let timer = unsafe {
        lvx_timer_create(refresh_timer, REFRESH_PERIOD_MS, page_index as *mut core::ffi::c_void)
    };
    if timer.is_null() {
        *page_backend(page_index) = empty_backend();
        return -1;
    }
    page_backend(page_index).refresh_timer = timer;
    0
}

pub fn page_resume(page_index: usize) -> i32 {
    if page_index >= PAGE_COUNT {
        return -1;
    }
    let backend = page_backend(page_index);
    if !backend.active {
        return -1;
    }
    backend.interactive = true;
    backend.refresh_failed = false;
    super::rebuild(page_index)
}

pub fn page_pause(page_index: usize) -> i32 {
    if page_index >= PAGE_COUNT {
        return -1;
    }
    page_backend(page_index).interactive = false;
    0
}

pub fn page_destroy(page_index: usize) -> i32 {
    if page_index >= PAGE_COUNT {
        return -1;
    }
    let backend = page_backend(page_index);
    backend.active = false;
    backend.interactive = false;
    if !backend.refresh_timer.is_null() {
        unsafe { lvx_timer_delete(backend.refresh_timer) };
        backend.refresh_timer = core::ptr::null_mut();
    }
    *backend = empty_backend();
    0
}

// ---------------------------------------------------------------------------
// 导航
// ---------------------------------------------------------------------------

pub fn navigate(page_index: usize) {
    let key = ((APP_ID as u32) << 16) | page_index as u32;
    unsafe { activity_navigate(key, 0, 0, 0) };
}

pub fn back(page_index: usize) {
    unsafe { activity_finish(page_descriptor_ptr(page_index)) };
}

// ---------------------------------------------------------------------------
// 事件分发（固件 LVX 事件 → 模块动作）
// ---------------------------------------------------------------------------

fn encoded_cookie(page_index: usize, slot: usize) -> usize {
    (page_index << 8) | slot
}

extern "C" fn row_event(event: *mut core::ffi::c_void) {
    if event.is_null() {
        return;
    }
    // SAFETY: `event` 是 page owner 线程的固件 LVX 事件对象。
    let code = unsafe { lvx_event_get_code(event) };
    let encoded = unsafe { lvx_event_get_user_data(event) };
    let page_index = encoded >> 8;
    let row_index = encoded & 0xFF;
    if page_index >= PAGE_COUNT || row_index >= UI_MAX_ROWS {
        return;
    }
    let backend = page_backend(page_index);
    if !backend.active || !backend.interactive {
        return;
    }
    if code != EVENT_CLICKED {
        return;
    }
    let binding = backend.bindings[row_index];
    if binding.event_id == 0 || !binding.enabled {
        return;
    }
    super::handle_ui_event(page_index, binding.generation, binding.key, binding.event_id);
}

extern "C" fn page_title_back(event: *mut core::ffi::c_void) {
    if event.is_null() {
        return;
    }
    // SAFETY: 标题返回回调以页面上下文 cookie (page_index<<8) 注册。
    let encoded = unsafe { lvx_event_get_user_data(event) };
    let page_index = encoded >> 8;
    if page_index >= PAGE_COUNT || page_index == PAGE_LIST {
        return;
    }
    let backend = page_backend(page_index);
    if !backend.active || !backend.interactive {
        return;
    }
    backend.interactive = false;
    back(page_index);
}

// ---------------------------------------------------------------------------
// 渲染
// ---------------------------------------------------------------------------

fn hash_bytes(mut hash: u32, text: *const u8) -> u32 {
    // SAFETY: text 指向 NUL 结尾的固定缓冲。
    let mut i = 0usize;
    loop {
        let b = unsafe { *text.add(i) };
        if b == 0 {
            break;
        }
        hash = (hash ^ u32::from(b)).wrapping_mul(0x0100_0193);
        i += 1;
    }
    hash
}

fn layout_fingerprint(snapshot: &PageSnapshot) -> (u32, u32) {
    let mut hash = 0x811C_9DC5u32;
    let mut count = 0u32;
    for i in 0..snapshot.row_count {
        hash = hash_bytes(hash, snapshot.rows[i].primary);
        hash = (hash ^ snapshot.rows[i].key).wrapping_mul(0x0100_0193);
        hash = (hash ^ u32::from(snapshot.rows[i].kind)).wrapping_mul(0x0100_0193);
        count += 1;
    }
    for i in 0..snapshot.label_count {
        hash = hash_bytes(hash, snapshot.labels[i].text);
        count += 1;
    }
    (hash, count)
}

/// Band-9 (LVGL v8) trailing-kind：1=switch、12=forward、0=none。
#[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
fn b9_row_trailing(row_kind: u8) -> u8 {
    match row_kind {
        ROW_ACTION => TRAILING_B9_FORWARD,
        _ => 0,
    }
}

/// 把快照应用到固件 LVX 页面。成功返回 0。
pub fn apply_snapshot(page_index: usize, snapshot: &PageSnapshot) -> i32 {
    if page_index >= PAGE_COUNT {
        return -1;
    }
    let backend = page_backend(page_index);
    if backend.root.is_null() {
        return -1;
    }
    if backend.content_root.is_null() {
        #[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
        {
            // Band-9 无 lvx_content_create：页面根就是内容父节点，
            // 尺寸/位置由系统页面壳固定。
            backend.content_root = backend.root;
        }
        #[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
        {
            backend.content_root = unsafe { lvx_content_create(backend.root) };
            if backend.content_root.is_null() {
                return -1;
            }
        }
        if backend.content_root.is_null() {
            return -1;
        }
    }

    if snapshot.row_count > UI_MAX_ROWS || snapshot.label_count > UI_MAX_LABELS {
        return -1;
    }

    let (next_layout_hash, next_layout_count) = layout_fingerprint(snapshot);
    let layout_changed = !backend.layout_valid
        || backend.layout_hash != next_layout_hash
        || backend.layout_count != next_layout_count;

    // 页标题
    if backend.page_title.is_null() {
        let back_callback = if snapshot.title_mode != 0 {
            page_title_back as *const ()
        } else {
            core::ptr::null()
        };
        let back_context = (page_index << 8) as *mut core::ffi::c_void;
        backend.page_title = unsafe {
            lvx_page_title_create(
                backend.root,
                snapshot.title,
                snapshot.title_mode,
                back_callback,
                back_context,
            )
        };
        if backend.page_title.is_null() {
            return -1;
        }
    }
    unsafe { lvx_set_hidden(backend.page_title, 0) };

    let mut previous: *mut core::ffi::c_void = backend.page_title;

    // 标签（详情页大小等）
    let mut label_used = 0usize;
    for i in 0..snapshot.label_count {
        let spec = &snapshot.labels[i];
        let mut object = backend.labels[label_used];
        let created_now = object.is_null();
        if created_now {
            let created = unsafe { lvx_label_create(backend.content_root) };
            if created.is_null() {
                return -1;
            }
            backend.labels[label_used] = created;
            backend.label_count += 1;
            object = created;
        }
        let label_hash = hash_bytes(0x811C_9DC5, spec.text);
        if created_now || backend.label_hashes[label_used] != label_hash {
            unsafe { lvx_label_set_text(object, spec.text) };
            backend.label_hashes[label_used] = label_hash;
        }
        unsafe { lvx_set_hidden(object, 0) };
        if layout_changed {
            if previous.is_null() {
                unsafe { lvx_align_to(object, backend.content_root, ALIGN_TOP_MID, 0, 0) };
            } else {
                unsafe { lvx_align_to(object, previous, ALIGN_OUT_BOTTOM_MID, 0, 4) };
            }
        }
        previous = object;
        label_used += 1;
    }
    for i in label_used..UI_MAX_LABELS {
        if !backend.labels[i].is_null() {
            unsafe { lvx_set_hidden(backend.labels[i], 1) };
        }
    }

    // 行
    let mut used_mask = 0u32;
    for i in 0..snapshot.row_count {
        let spec = &snapshot.rows[i];
        let slot = match find_row(backend, spec, used_mask) {
            Some(slot) => slot,
            None => return -1,
        };
        let mut object = backend.rows[slot];
        let created_now = object.is_null();
        if created_now {
            #[cfg(not(feature = "target-xiaomi-band-9-pro-3-1-175"))]
            let created = unsafe {
                lvx_list_row_create(backend.content_root, spec.primary, spec.secondary, TRAILING_FORWARD)
            };
            #[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]
            let created = unsafe {
                let row = lvx_list_row_create(backend.content_root, spec.primary);
                if !row.is_null() {
                    lvx_list_row_set_trailing(row, b9_row_trailing(spec.kind), 0);
                }
                row
            };
            if created.is_null() {
                return -1;
            }
            backend.rows[slot] = created;
            backend.row_kinds[slot] = spec.kind;
            object = created;
            unsafe {
                lvx_event_add(
                    object,
                    row_event,
                    EVENT_CLICKED,
                    encoded_cookie(page_index, slot) as *mut core::ffi::c_void,
                );
            }
            backend.row_count += 1;
        }
        let content_hash = {
            let mut h = hash_bytes(0x811C_9DC5, spec.primary);
            h = hash_bytes(h, spec.secondary);
            h
        };
        if created_now || backend.row_hashes[slot] != content_hash {
            unsafe {
                lvx_list_row_update(
                    object,
                    core::ptr::null(),
                    spec.primary,
                    spec.secondary,
                    0,
                    1,
                );
            }
            backend.row_hashes[slot] = content_hash;
        }
        unsafe { lvx_set_hidden(object, 0) };
        if layout_changed {
            if previous.is_null() {
                unsafe { lvx_align_to(object, backend.content_root, ALIGN_TOP_MID, 0, 0) };
            } else {
                unsafe { lvx_align_to(object, previous, ALIGN_OUT_BOTTOM_MID, 0, 4) };
            }
        }
        previous = object;
        backend.bindings[slot] = Binding {
            generation: snapshot.generation,
            key: spec.key,
            event_id: spec.event_id,
            enabled: spec.enabled,
        };
        used_mask |= 1 << slot;
    }

    for i in 0..UI_MAX_ROWS {
        if !backend.rows[i].is_null() && (used_mask & (1 << i)) == 0 {
            unsafe { lvx_set_hidden(backend.rows[i], 1) };
            backend.bindings[i] = Binding {
                generation: 0,
                key: 0,
                event_id: 0,
                enabled: false,
            };
        }
    }

    backend.layout_hash = next_layout_hash;
    backend.layout_count = next_layout_count;
    backend.layout_valid = true;
    backend.rendered_generation = snapshot.generation;
    backend.refresh_failed = false;
    0
}

fn find_row(backend: &PageBackend, spec: &super::ui::RowSpec, used_mask: u32) -> Option<usize> {
    let mut reusable = None;
    let mut empty = None;
    for i in 0..UI_MAX_ROWS {
        if backend.rows[i].is_null() {
            if empty.is_none() {
                empty = Some(i);
            }
        } else if backend.row_kinds[i] == spec.kind && (used_mask & (1 << i)) == 0 {
            if backend.bindings[i].key == spec.key {
                return Some(i);
            }
            if reusable.is_none() {
                reusable = Some(i);
            }
        }
    }
    reusable.or(empty)
}

/// 供 target/mod.rs 读取详情页大小文本（渲染前格式化到 ui.rs 缓冲）。
pub fn detail_size_ptr_for_render() -> *const u8 {
    detail_size_ptr()
}

pub fn detail_size_len_for_render() -> usize {
    detail_size_len()
}

pub fn page_title_for_render(page_index: usize) -> *const u8 {
    page_title(page_index)
}
