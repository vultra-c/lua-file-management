//! Semantic page model → LVX 渲染快照。
//!
//! 文件管理器只有两种页面：列表页（PAGE_LIST）与文件详情页（PAGE_DETAIL）。
//! 快照里的字符串指针全部指向 runtime / 本模块的固定缓冲（NUL 结尾），
//! 渲染层只读。大小文本在渲染前格式化到本模块的固定缓冲。

use super::native_app::{PAGE_DETAIL, PAGE_LIST};
use super::runtime::{self, EVENT_DELETE, EVENT_ENTER_DIR, EVENT_OPEN_DETAIL};
use super::ui_backend::{UI_MAX_LABELS, UI_MAX_ROWS};

pub const ROW_ACTION: u8 = 1;
pub const ROW_STATUS: u8 = 0;

#[derive(Copy, Clone)]
pub struct RowSpec {
    pub primary: *const u8,
    pub secondary: *const u8,
    pub kind: u8, // ROW_ACTION / ROW_STATUS
    pub key: u32,
    pub event_id: u32,
    pub enabled: bool,
}

#[derive(Copy, Clone)]
pub struct LabelSpec {
    pub text: *const u8,
    pub title_style: bool,
}

#[derive(Copy, Clone)]
pub struct PageSnapshot {
    pub title: *const u8,
    pub title_mode: u32, // 1=画返回键（详情页），0=不画（列表页）
    pub rows: [RowSpec; UI_MAX_ROWS],
    pub row_count: usize,
    pub labels: [LabelSpec; UI_MAX_LABELS],
    pub label_count: usize,
    pub generation: u32,
}

const EMPTY: [u8; 1] = [0];

// 列表页每行的大小文本缓冲（人类可读：512B / 1.2K / 34M）
static mut ROW_SIZE_BUF: [[u8; 10]; UI_MAX_ROWS] = [[0; 10]; UI_MAX_ROWS];
// 详情页 "Size: <n> B" 标签文本缓冲
static mut DETAIL_LABEL_BUF: [u8; 40] = [0; 40];

fn empty_snapshot() -> PageSnapshot {
    PageSnapshot {
        title: EMPTY.as_ptr(),
        title_mode: 0,
        rows: [RowSpec {
            primary: EMPTY.as_ptr(),
            secondary: EMPTY.as_ptr(),
            kind: ROW_STATUS,
            key: 0,
            event_id: 0,
            enabled: false,
        }; UI_MAX_ROWS],
        row_count: 0,
        labels: [LabelSpec {
            text: EMPTY.as_ptr(),
            title_style: false,
        }; UI_MAX_LABELS],
        label_count: 0,
        generation: 0,
    }
}

/// 人类可读大小 → NUL 结尾文本，返回长度。
fn format_human_size(value: u32, out: &mut [u8]) -> usize {
    const K: u64 = 1024;
    const M: u64 = 1024 * 1024;
    let v = value as u64;
    let (num, unit): (u64, u8) = if v >= M {
        (v / M, b'M')
    } else if v >= K {
        (v / K, b'K')
    } else {
        (v, b'B')
    };
    let mut buf = [0u8; 6];
    let mut i = buf.len();
    let mut n = num;
    loop {
        i -= 1;
        buf[i] = b'0' + (n % 10) as u8;
        n /= 10;
        if n == 0 {
            break;
        }
    }
    let mut len = 0usize;
    while i < buf.len() && len + 1 < out.len() {
        out[len] = buf[i];
        len += 1;
        i += 1;
    }
    if unit != b'B' && len + 1 < out.len() {
        out[len] = unit;
        len += 1;
    }
    out[len] = 0;
    len
}

/// 列表页快照：标题 "Files"，每行一个目录/文件。
/// 目录行 event=EVENT_ENTER_DIR；文件行 event=EVENT_OPEN_DETAIL（进详情）。
/// 行 key = 目录项下标（0..entry_count）；分页由 runtime.page_offset 决定。
pub fn list_snapshot() -> PageSnapshot {
    let mut snap = empty_snapshot();
    let fm = runtime::fm();
    snap.title = b"Files\0".as_ptr();
    snap.title_mode = 0;
    snap.generation = fm.generation;

    let start = fm.page_offset as usize;
    let mut n = 0usize;
    let mut i = start;
    while i < fm.entry_count as usize && n < UI_MAX_ROWS {
        let entry = &fm.entries[i];
        let secondary: *const u8 = if entry.is_dir {
            EMPTY.as_ptr()
        } else {
            // SAFETY: ROW_SIZE_BUF[n] 是固定缓冲，格式化后 NUL 结尾。
            let slot: &mut [u8; 10] = unsafe { &mut core::ptr::addr_of_mut!(ROW_SIZE_BUF)[n] };
            format_human_size(entry.size, slot);
            unsafe { core::ptr::addr_of!(ROW_SIZE_BUF)[n].as_ptr() }
        };
        snap.rows[n] = RowSpec {
            primary: entry.name.as_ptr(),
            secondary,
            kind: ROW_ACTION,
            key: i as u32,
            event_id: if entry.is_dir { EVENT_ENTER_DIR } else { EVENT_OPEN_DETAIL },
            enabled: true,
        };
        n += 1;
        i += 1;
    }
    snap.row_count = n;
    snap
}

/// 详情页快照：标题=文件名，正文=大小，一行 "Delete"（event=EVENT_DELETE）。
pub fn detail_snapshot() -> PageSnapshot {
    let mut snap = empty_snapshot();
    let fm = runtime::fm();
    snap.title = runtime::detail_name_ptr();
    snap.title_mode = 1;
    snap.generation = fm.generation;

    // "Size: <n> B"（n 来自 runtime 的数字缓冲）
    // SAFETY: DETAIL_LABEL_BUF 是固定缓冲。
    unsafe {
        let buf = core::ptr::addr_of_mut!(DETAIL_LABEL_BUF);
        let mut len = 0usize;
        for &b in b"Size: " {
            if len + 1 < DETAIL_LABEL_BUF.len() {
                (*buf)[len] = b;
                len += 1;
            }
        }
        let num = &fm.detail_size_buf[..fm.detail_size_len as usize];
        for &b in num {
            if len + 1 < DETAIL_LABEL_BUF.len() {
                (*buf)[len] = b;
                len += 1;
            }
        }
        for &b in b" B" {
            if len + 1 < DETAIL_LABEL_BUF.len() {
                (*buf)[len] = b;
                len += 1;
            }
        }
        (*buf)[len] = 0;
        snap.labels[0] = LabelSpec {
            text: core::ptr::addr_of!(DETAIL_LABEL_BUF).cast::<u8>(),
            title_style: false,
        };
    }
    snap.label_count = 1;

    snap.rows[0] = RowSpec {
        primary: b"Delete\0".as_ptr(),
        secondary: EMPTY.as_ptr(),
        kind: ROW_ACTION,
        key: 0,
        event_id: EVENT_DELETE,
        enabled: true,
    };
    snap.row_count = 1;
    snap
}

/// 供渲染层读取当前页标题。
pub fn page_title(page_index: usize) -> *const u8 {
    if page_index == PAGE_LIST {
        b"Files\0".as_ptr()
    } else if page_index == PAGE_DETAIL {
        runtime::detail_name_ptr()
    } else {
        b"\0".as_ptr()
    }
}

/// 事件合法性与 generation 校验（由 target/mod.rs 的 handle_ui_event 调用）。
pub fn event_valid(page_index: usize, generation: u32, key: u32, event_id: u32) -> bool {
    let fm = runtime::fm();
    if generation != fm.generation {
        return false;
    }
    if page_index == PAGE_LIST {
        matches!(event_id, EVENT_ENTER_DIR | EVENT_OPEN_DETAIL)
            && (key as usize) < fm.entry_count as usize
    } else if page_index == PAGE_DETAIL {
        matches!(event_id, EVENT_DELETE)
    } else {
        false
    }
}
