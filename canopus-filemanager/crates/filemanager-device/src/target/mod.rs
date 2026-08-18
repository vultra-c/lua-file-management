//! Target-selected private backend（文件管理器版）。
//!
//! 激活顺序（module-owner 线程）：
//!   1. identity guard 校验固件身份；
//!   2. native app 注册（独立两阶段发布，见 native_app.rs）。
//! 文件浏览/删除全部在 page owner 线程（LVX 事件/定时器回调）执行，无后台线程，
//! 因此不需要锁 —— 与蓝牙模块的“回调进 core”不同，本模块天然单线程。
//!
//! 页面：PAGE_LIST（文件列表）+ PAGE_DETAIL（文件详情/删除）。

use core::sync::atomic::Ordering;

use canopus_target_private::*;

use super::native_app::{PAGE_COUNT, PAGE_DETAIL, PAGE_LIST};
use super::runtime::{self, EVENT_BACK, EVENT_DELETE, EVENT_ENTER_DIR, EVENT_OPEN_DETAIL, EVENT_REFRESH};
use super::ui;
use super::ui_backend;

pub mod fs;
pub mod native_app;
pub mod runtime;
pub mod ui;
pub mod ui_backend;

/// 模块构造器每次加载时调用一次：重置状态机。
pub fn prepare(_generation: u32) {
    runtime::prepare();
}

/// 校验身份并完成激活。native app 注册走独立的两阶段发布，不在此处做，
/// 避免在 Manager 页面已运行时 re-enter miwear 注册表。
pub fn activate() -> i32 {
    let guard = canopus_identity_guard();
    if guard != 0 {
        runtime::fm().last_error = guard;
        return guard;
    }
    0
}

/// 模块查询状态（canopus_mod_query 使用）。
pub fn query_status() -> [u32; 4] {
    let fm = runtime::fm();
    [
        fm.generation,
        fm.entry_count as u32,
        fm.page_offset as u32,
        fm.last_error as u32,
    ]
}

/// 重建 `page_index` 页并应用快照。只在 page owner 线程调用。
pub fn rebuild(page_index: usize) -> i32 {
    let snapshot = if page_index == PAGE_DETAIL {
        ui::detail_snapshot()
    } else {
        ui::list_snapshot()
    };
    ui_backend::apply_snapshot(page_index, &snapshot)
}

/// 定时器驱动：仅当 generation 变化时重绘。
pub fn rebuild_if_changed(page_index: usize, rendered_generation: u32) -> i32 {
    let fm = runtime::fm();
    if fm.generation == rendered_generation {
        return 0;
    }
    rebuild(page_index)
}

/// 分发 generation 校验过的 LVX 事件到状态机并重绘。只在 page owner 线程调用。
pub fn handle_ui_event(page_index: usize, generation: u32, key: u32, event_id: u32) {
    if !ui::event_valid(page_index, generation, key, event_id) {
        return;
    }
    if page_index == PAGE_DETAIL {
        if event_id == EVENT_DELETE {
            if runtime::delete_detail() != 0 {
                // 删除失败：重绘详情页显示错误（last_error 已记录）
                rebuild(PAGE_DETAIL);
                return;
            }
            ui_backend::back(PAGE_DETAIL);
            rebuild(PAGE_LIST);
        } else if event_id == EVENT_BACK {
            ui_backend::back(PAGE_DETAIL);
            rebuild(PAGE_LIST);
        }
        return;
    }
    // PAGE_LIST
    match event_id {
        EVENT_ENTER_DIR => {
            runtime::enter(key as usize);
            rebuild(PAGE_LIST);
        }
        EVENT_OPEN_DETAIL => {
            if runtime::open_detail(key as usize) >= 0 {
                ui_backend::navigate(PAGE_DETAIL);
            }
        }
        EVENT_REFRESH => {
            runtime::list_current();
            rebuild(PAGE_LIST);
        }
        _ => {}
    }
}

/// 供外部（暂未用）读取发布状态。
pub fn _publish_state() -> [u32; 4] {
    native_app::publish_state()
}

// 保留：确保 PAGE_COUNT 等常量被引用（避免未用告警）。
pub const _PAGE_COUNT: usize = PAGE_COUNT;
pub const _PAGE_LIST: usize = PAGE_LIST;
pub const _PAGE_DETAIL: usize = PAGE_DETAIL;
pub const _EVENT_REFRESH: u32 = EVENT_REFRESH;
pub const _ORDERING: Ordering = Ordering::Relaxed;
