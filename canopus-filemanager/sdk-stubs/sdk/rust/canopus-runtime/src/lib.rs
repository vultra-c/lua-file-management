//! OFFLINE STUB — canopus-runtime（真实 crate 闭源）。见 canopus-abi 说明。
#![no_std]

use canopus_abi::StatusWriterV1;

/// 向状态写入器追加一个 u32；失败返回 false。
pub fn status_put_u32(writer: &mut StatusWriterV1, _value: u32) -> bool {
    let _ = writer;
    true
}

/// 发布状态记录（真实实现写 /dev/canopus 的 CPC1 响应缓冲）。
pub fn status_writer_publish(writer: &mut StatusWriterV1) {
    let _ = writer;
}
