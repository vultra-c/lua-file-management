//! File system layer for the file manager.
//!
//! The module is full-trust native code; it accesses the device filesystem
//! through the NuttX-style file APIs exposed by `canopus-target-private`
//! (the per-firmware recovered-address facade). The BluetoothAudio reference
//! already proves `nuttx_open / nuttx_write / nuttx_close` exist in the
//! facade; directory/stat/remove calls below follow the same naming
//! convention.
//!
//! ⚠️ 需要确认（ACTION_PLAN 第 2 步）：以下函数的**确切名字与签名**必须与
//! `canopus-target-private` 的 band-9-pro-3.1.175 后端一致。若该后端尚未
//! 导出 `nuttx_opendir/readdir/stat/remove`，请 AstroBox 在 target pack 里
//! 补上（或按实际导出名修改本文件——只改这一处，业务层不动）。

use core::ffi::c_void;

/// NuttX `struct dirent` 布局（v7.x/10.x 通用：1 字节类型 + 对齐 + 名称）。
#[repr(C)]
pub struct Dirent {
    pub d_type: u8,
    pub d_name: [u8; 64],
}

pub const DT_DIR: u8 = 4;
pub const DT_REG: u8 = 8;

/// NuttX `struct stat` 布局（32 位 ARM 小端，与 NuttX 10.3.0 include/nuttx/fs/fs.h 一致）。
#[repr(C)]
pub struct Stat {
    pub st_dev: u32,       // dev_t
    pub st_ino: u16,       // ino_t
    pub st_mode: u32,      // mode_t
    pub st_nlink: u16,     // nlink_t
    pub st_uid: u16,       // uid_t
    pub st_gid: u16,       // gid_t
    pub st_size: i32,      // off_t
    pub st_blksize: i32,   // blksize_t
    pub st_blocks: i32,    // blkcnt_t
    pub st_atime: i32,     // time_t
    pub st_mtime: i32,     // time_t
    pub st_ctime: i32,     // time_t
}

pub const S_IFMT: u32 = 0o170000;
pub const S_IFDIR: u32 = 0o040000;
pub const S_IFREG: u32 = 0o100000;

/// Expected `canopus-target-private` surface (NuttX-style; see file header).
#[link(name = "canopus_target_private")]
extern "C" {
    pub fn nuttx_opendir(path: *const u8) -> i32;
    pub fn nuttx_readdir(dir: i32, entry: *mut Dirent) -> i32;
    pub fn nuttx_closedir(dir: i32) -> i32;
    pub fn nuttx_stat(path: *const u8, buf: *mut Stat) -> i32;
    pub fn nuttx_remove(path: *const u8) -> i32;
}

/// 列出 `path`（NUL 结尾）下的目录项，写入 `out`（容量 cap），
/// 返回条目数；失败返回负 errno。
///
/// # Safety
/// `path` 必须指向有效的 NUL 结尾 C 字符串；`out` 必须指向容量为 `cap` 的数组。
pub unsafe fn list_dir(path: *const u8, out: *mut Dirent, cap: usize) -> i32 {
    let dir = unsafe { nuttx_opendir(path) };
    if dir < 0 {
        return dir;
    }
    let mut count: i32 = 0;
    loop {
        if (count as usize) >= cap {
            break;
        }
        let entry = unsafe { &mut *out.add(count as usize) };
        let rc = unsafe { nuttx_readdir(dir, entry) };
        if rc < 0 {
            let err = rc;
            unsafe { nuttx_closedir(dir) };
            return if count > 0 { count } else { err };
        }
        if rc == 0 {
            break; // 读完
        }
        count += 1;
    }
    unsafe { nuttx_closedir(dir) };
    count
}

/// stat `path`；成功返回 0 并把结果写入 `buf`，失败返回负 errno。
///
/// # Safety
/// `path` 必须指向有效的 NUL 结尾 C 字符串；`buf` 必须指向有效的 `Stat`。
pub unsafe fn stat_path(path: *const u8, buf: *mut Stat) -> i32 {
    unsafe { nuttx_stat(path, buf) }
}

/// 删除 `path`（文件或空目录）；成功返回 0，失败返回负 errno。
///
/// # Safety
/// `path` 必须指向有效的 NUL 结尾 C 字符串。
pub unsafe fn remove_path(path: *const u8) -> i32 {
    unsafe { nuttx_remove(path) }
}

/// 由 `Stat` 判断是否为目录。
pub fn is_dir(st: &Stat) -> bool {
    (st.st_mode & S_IFMT) == S_IFDIR
}

/// 保留给 host 测试用的空实现（feature=device 关闭时编译通过即可）。
#[cfg(not(feature = "device"))]
pub fn _unused(_: *mut c_void) {}
