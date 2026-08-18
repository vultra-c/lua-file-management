//! File manager state machine (static, no_std, no heap).
//!
//! 持有：当前目录路径、目录列表缓存、分页游标、详情页目标、错误状态。
//! 所有字符串存固定缓冲区（NUL 结尾），渲染层直接取指针，不复制。

use core::sync::atomic::{AtomicU32, Ordering};

use super::fs::{self, Dirent, Stat, DT_DIR};

pub const MAX_ENTRIES: usize = 64;
pub const ENTRY_NAME_CAP: usize = 48;
pub const CWD_CAP: usize = 128;
pub const SIZE_BUF_CAP: usize = 12; // "4294967295\0" = 11 字符 + NUL

// ---- 事件 id（key 编码：(page_index<<8)|row_index）----
pub const EVENT_ENTER_DIR: u32 = 1; // 点目录行 → 进入
pub const EVENT_OPEN_DETAIL: u32 = 2; // 点文件行 → 详情页
pub const EVENT_DELETE: u32 = 3; // 详情页点 Delete
pub const EVENT_REFRESH: u32 = 4; // 刷新当前目录
pub const EVENT_BACK: u32 = 5; // 返回（详情页回列表）

#[derive(Copy, Clone)]
pub struct DirEntry {
    pub name: [u8; ENTRY_NAME_CAP],
    pub name_len: u8,
    pub size: u32,
    pub is_dir: bool,
}

pub struct FileManager {
    pub cwd: [u8; CWD_CAP],
    pub cwd_len: u16,
    pub entries: [DirEntry; MAX_ENTRIES],
    pub entry_count: u16,
    pub page_offset: u16, // 分页游标（每页 UI_MAX_ROWS 行）
    pub generation: u32,
    pub last_error: i32,
    // 详情页目标（entry 下标）
    pub detail_index: u16,
    // 详情页展示用：文件大小文本（NUL 结尾）
    pub detail_size_buf: [u8; SIZE_BUF_CAP],
    pub detail_size_len: u8,
}

static GENERATION: AtomicU32 = AtomicU32::new(0);

pub static mut FM: FileManager = FileManager {
    cwd: *b"/data\0",
    cwd_len: 5,
    entries: [DirEntry {
        name: [0; ENTRY_NAME_CAP],
        name_len: 0,
        size: 0,
        is_dir: false,
    }; MAX_ENTRIES],
    entry_count: 0,
    page_offset: 0,
    generation: 0,
    last_error: 0,
    detail_index: 0,
    detail_size_buf: [0; SIZE_BUF_CAP],
    detail_size_len: 0,
};

/// 模块每次加载时重置状态（构造器调用）。
pub fn prepare() {
    // SAFETY: 模块构造器单线程调用，且尚未发布任何页面回调。
    unsafe {
        let fm = &mut *core::ptr::addr_of_mut!(FM);
        fm.cwd = *b"/data\0";
        fm.cwd_len = 5;
        fm.entry_count = 0;
        fm.page_offset = 0;
        fm.last_error = 0;
        fm.detail_index = 0;
        fm.detail_size_len = 0;
        fm.generation = GENERATION.fetch_add(1, Ordering::AcqRel);
    }
}

pub fn fm() -> &'static mut FileManager {
    // SAFETY: 所有访问都在 page owner 线程（LVX 事件/定时器回调），
    // 与 BluetoothAudio 的 ui_backend 同一线程模型。
    unsafe { &mut *core::ptr::addr_of_mut!(FM) }
}

/// 格式化 u32 大小（裸数字，B 单位由 UI 文案承担）。
fn format_size(value: u32, out: &mut [u8; SIZE_BUF_CAP]) -> u8 {
    let mut buf = [0u8; 10];
    let mut n = value;
    let mut i = 10usize;
    loop {
        i -= 1;
        buf[i] = b'0' + (n % 10) as u8;
        n /= 10;
        if n == 0 {
            break;
        }
    }
    let len = 10 - i;
    out[..len].copy_from_slice(&buf[i..]);
    out[len] = 0;
    len as u8
}

/// 重新列出当前目录（cwd）。成功返回条目数，失败返回负 errno。
pub fn list_current() -> i32 {
    let fm = fm();
    // 暂存旧 cwd 指针内容：list_dir 期间 entries 与 cwd 无别名冲突。
    let mut raw: [Dirent; MAX_ENTRIES] = unsafe { core::mem::zeroed() };
    // SAFETY: cwd 是 NUL 结尾固定缓冲；raw 容量 MAX_ENTRIES。
    let count = unsafe { fs::list_dir(fm.cwd.as_ptr(), raw.as_mut_ptr(), MAX_ENTRIES) };
    if count < 0 {
        fm.last_error = count;
        return count;
    }
    let mut n = 0usize;
    for i in 0..(count as usize) {
        if n >= MAX_ENTRIES {
            break;
        }
        let raw_entry = &raw[i];
        // 跳过 "." 与 ".."
        let name = &raw_entry.d_name;
        if name[0] == b'.' && (name[1] == 0 || (name[1] == b'.' && name[2] == 0)) {
            continue;
        }
        let mut name_len = 0usize;
        while name_len < ENTRY_NAME_CAP - 1 && name[name_len] != 0 {
            name_len += 1;
        }
        if name_len == 0 {
            continue;
        }
        let mut entry = DirEntry {
            name: [0; ENTRY_NAME_CAP],
            name_len: name_len as u8,
            size: 0,
            is_dir: raw_entry.d_type == DT_DIR,
        };
        entry.name[..name_len].copy_from_slice(&name[..name_len]);
        // 目录项没给大小 → 逐项 stat（目录递归深、量大时可改为惰性，MVP 直取）
        if !entry.is_dir {
            let mut full: [u8; CWD_CAP + ENTRY_NAME_CAP] = [0; CWD_CAP + ENTRY_NAME_CAP];
            let fl = build_path(fm.cwd.as_ptr(), fm.cwd_len as usize, &name[..name_len], &mut full);
            let mut st: Stat = unsafe { core::mem::zeroed() };
            // SAFETY: full 是 NUL 结尾路径缓冲。
            if unsafe { fs::stat_path(full.as_ptr(), &mut st) } == 0 {
                entry.size = st.st_size.max(0) as u32;
            }
        }
        fm.entries[n] = entry;
        n += 1;
    }
    fm.entry_count = n as u16;
    fm.page_offset = 0;
    fm.generation = GENERATION.fetch_add(1, Ordering::AcqRel);
    fm.last_error = 0;
    n as i32
}

/// 拼接 `cwd + "/" + name"` 到 `out`（NUL 结尾）。返回总长（不含 NUL）。
pub fn build_path(
    cwd: *const u8,
    cwd_len: usize,
    name: &[u8],
    out: &mut [u8],
) -> usize {
    let mut i = 0usize;
    // cwd
    let mut j = 0usize;
    while j < cwd_len && i + 1 < out.len() {
        // SAFETY: cwd 指向固定缓冲，长度由调用方保证。
        let b = unsafe { *cwd.add(j) };
        if b == 0 {
            break;
        }
        out[i] = b;
        i += 1;
        j += 1;
    }
    // 分隔符（根目录除外）
    if i > 1 && out[i - 1] != b'/' && i + 1 < out.len() {
        out[i] = b'/';
        i += 1;
    }
    // name
    for &b in name {
        if i + 1 >= out.len() {
            break;
        }
        out[i] = b;
        i += 1;
    }
    out[i] = 0;
    i
}

/// 进入第 `index` 个目录项（必须是目录）。
pub fn enter(index: usize) -> i32 {
    let fm = fm();
    if index >= fm.entry_count as usize {
        return -1;
    }
    let entry = &fm.entries[index];
    if !entry.is_dir {
        return -1;
    }
    let mut full: [u8; CWD_CAP + ENTRY_NAME_CAP] = [0; CWD_CAP + ENTRY_NAME_CAP];
    let len = build_path(
        fm.cwd.as_ptr(),
        fm.cwd_len as usize,
        &entry.name[..entry.name_len as usize],
        &mut full,
    );
    // 更新 cwd
    fm.cwd[..len].copy_from_slice(&full[..len]);
    fm.cwd_len = len as u16;
    list_current()
}

/// 返回上一级目录。
pub fn up() -> i32 {
    let fm = fm();
    let mut len = fm.cwd_len as usize;
    while len > 1 && fm.cwd[len - 1] != b'/' {
        len -= 1;
    }
    if len <= 1 {
        return 0; // 已在根
    }
    // 去掉尾斜杠（若存在）
    let mut end = len;
    if fm.cwd[end - 1] == b'/' {
        end -= 1;
    }
    if end == 0 {
        end = 1;
    }
    fm.cwd[end] = 0;
    fm.cwd_len = end as u16;
    list_current()
}

/// 打开第 `index` 个文件项的详情（同时准备大小文本）。返回该条目下标或 -1。
pub fn open_detail(index: usize) -> i32 {
    let fm = fm();
    if index >= fm.entry_count as usize {
        return -1;
    }
    let entry = &fm.entries[index];
    if entry.is_dir {
        return -1;
    }
    fm.detail_index = index as u16;
    fm.detail_size_len = format_size(entry.size, &mut fm.detail_size_buf);
    index as i32
}

/// 删除当前详情页目标；成功返回 0，失败返回负 errno。成功后自动回到列表并刷新。
pub fn delete_detail() -> i32 {
    let fm = fm();
    let index = fm.detail_index as usize;
    if index >= fm.entry_count as usize {
        return -1;
    }
    let entry = &fm.entries[index];
    let mut full: [u8; CWD_CAP + ENTRY_NAME_CAP] = [0; CWD_CAP + ENTRY_NAME_CAP];
    let _ = build_path(
        fm.cwd.as_ptr(),
        fm.cwd_len as usize,
        &entry.name[..entry.name_len as usize],
        &mut full,
    );
    // SAFETY: full 是 NUL 结尾路径缓冲。
    let rc = unsafe { fs::remove_path(full.as_ptr()) };
    if rc != 0 {
        fm.last_error = rc;
        return rc;
    }
    fm.last_error = 0;
    list_current()
}

/// 详情页展示的文件名（NUL 结尾）。
pub fn detail_name_ptr() -> *const u8 {
    let fm = fm();
    let index = fm.detail_index as usize;
    if index < fm.entry_count as usize {
        fm.entries[index].name.as_ptr()
    } else {
        b"\0".as_ptr()
    }
}
