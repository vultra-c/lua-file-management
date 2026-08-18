//! Exact-target device archive for the Canopus file manager module.
//!
//! Structure mirrors `Searchstars/Canopus-Module-BluetoothAudio` (AGPL-3.0):
//! the module exports `canopus_module_descriptor` + CMR1 registration, and the
//! target backend performs identity guard, native-app registration, launcher
//! publication, and LVX rendering through the target-private ABI.
#![no_std]
#![deny(unsafe_op_in_unsafe_fn)]

mod module;

#[cfg(feature = "device")]
pub mod target;

pub use module::*;

#[cfg(not(test))]
#[panic_handler]
fn canopus_panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
