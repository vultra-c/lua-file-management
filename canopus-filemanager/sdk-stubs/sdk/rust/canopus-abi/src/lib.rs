//! OFFLINE STUB — canopus-abi（真实 crate 闭源）。
//!
//! 仅用于在无 Canopus SDK 的机器上跑 `cargo check` 验证模块代码类型正确。
//! 结构按 Searchstars/Canopus-Module-BluetoothAudio 公开用法还原；
//! 真机构建时请使用真实 SDK（本 stub 不会被链接，设备端只用真 crate）。
#![no_std]

pub const ABI_MAJOR: u32 = 1;
pub const ABI_MINOR: u32 = 0;

pub const RESULT_REBOOT_REQUIRED: i32 = 0x0100;

pub const FLAG_HAS_NATIVE_APP: u32 = 1 << 0;
pub const FLAG_NATIVE_APP_STANDALONE: u32 = 1 << 1;
pub const FLAG_REGISTERS_LAUNCHER_ENTRY: u32 = 1 << 2;
pub const FLAG_REQUIRES_UI_DISPATCHER: u32 = 1 << 3;
pub const FLAG_APP_UNREGISTER_REBOOT_REQUIRED: u32 = 1 << 4;

#[repr(C)]
pub struct ContextV1 {
    pub reserved: u32,
}

#[repr(C)]
pub struct StatusWriterV1 {
    pub reserved: u32,
}

/// 模块描述符（布局见 re/canopus/SPEC.md §1）。
#[repr(C)]
pub struct ModuleDescriptorV1 {
    pub struct_size: u32,
    pub abi_major: u32,
    pub abi_minor: u32,
    pub flags: u32,
    pub module_id: [u8; 32],
    pub module_version: [u8; 32],
    pub build_id: [u8; 32],
    pub target_id: [u8; 32],
    pub prepare: Option<extern "C" fn(*const ContextV1) -> i32>,
    pub activate: Option<extern "C" fn(*const ContextV1) -> i32>,
    pub deactivate: Option<extern "C" fn(*const ContextV1) -> i32>,
    pub stop: Option<extern "C" fn(*const ContextV1) -> i32>,
    pub query: Option<extern "C" fn(*mut StatusWriterV1) -> i32>,
    pub publish_native_app: Option<extern "C" fn(*const ContextV1) -> i32>,
    pub publish_native_app_stage: Option<extern "C" fn(*const ContextV1, u32) -> i32>,
}
