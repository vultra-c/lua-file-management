#!/bin/sh
# 构建文件管理器模块（ET_REL ELF，xiaomi-band-9-pro-3.1.175）。
# 与参考仓库 scripts/build-device.sh 同构，去掉了 SBC codec 步骤。
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CANOPUS=${CANOPUS_ROOT:-"$ROOT/../Canopus"}
TARGET_ID=${CANOPUS_TARGET:-xiaomi-band-9-pro-3.1.175}
TARGET_PROFILE="$ROOT/targets/$TARGET_ID.env"
[ -f "$TARGET_PROFILE" ] || {
  echo "error: unsupported module target: $TARGET_ID" >&2
  exit 1
}
# Repository-owned profile: Rust feature, LLVM target, CPU, and loader bound.
. "$TARGET_PROFILE"
OUT=${CANOPUS_BUILD_OUT:-"$ROOT/build/$TARGET_ID"}
TRIPLE=$RUST_TARGET_TRIPLE
CC=${CC:-clang}
mkdir -p "$OUT"

# 模块在 nightly 工具链上交叉构建，两个开关保持可重定位 ELF 紧凑：
#   - hashed symbol mangling（需要 -Z unstable-options）缩短长 Rust 符号/段名。
#   - function-sections=no 把几百个 per-function 段合并成少数几个。
# RUSTFLAGS 会覆盖 .cargo/config.toml 里 [target.*] 的 flags，所以 panic=abort
# 和 target-cpu 在这里重复。
NIGHTLY=${NIGHTLY_CARGO:-cargo +nightly}
LEAN_RUSTFLAGS="-C panic=abort -C target-cpu=$RUST_TARGET_CPU -Z unstable-options \
  -Z function-sections=no -C symbol-mangling-version=hashed \
  -Z location-detail=none -Z fmt-debug=none"

cargo fmt --manifest-path "$ROOT/Cargo.toml" --all -- --check
cargo clippy --manifest-path "$ROOT/Cargo.toml" --workspace --all-targets -- -D warnings
cargo test --manifest-path "$ROOT/Cargo.toml" --workspace
# `$NIGHTLY` 故意不加引号：默认 "cargo +nightly" 必须按词拆分，把 +nightly 传给 rustup 代理。
RUSTFLAGS="$LEAN_RUSTFLAGS" $NIGHTLY clippy \
  --manifest-path "$ROOT/Cargo.toml" --release --target "$TRIPLE" \
  -p canopus-filemanager-device --no-default-features \
  --features "$RUST_TARGET_FEATURE" -- -D warnings
RUSTFLAGS="$LEAN_RUSTFLAGS" $NIGHTLY build \
  --manifest-path "$ROOT/Cargo.toml" --release --target "$TRIPLE" \
  -p canopus-filemanager-device --no-default-features \
  --features "$RUST_TARGET_FEATURE"

"$CC" --target=arm-none-eabi -mcpu="$RUST_TARGET_CPU" -mthumb -mfloat-abi=soft \
  -ffreestanding -fno-common -fno-builtin -fno-stack-protector \
  -fno-unwind-tables -fno-asynchronous-unwind-tables \
  -fdata-sections -ffunction-sections -Os -Wall -Wextra -Werror \
  -I"$CANOPUS/sdk/c" \
  -c "$ROOT/crates/filemanager-device/c_shim/canopus_ctor.c" \
  -o "$OUT/canopus_ctor.o"

"$ROOT/scripts/link-device.sh" \
  "$OUT" "$CC" "$RUST_TARGET_CPU" "$CANOPUS" "$TARGET_ID" "$ROOT" "$TRIPLE"

# 去掉没被消费的 thin-LTO bitcode (.llvmbc) 和调试元数据；它们不属于加载映像。
# objcopy 不能原地写，写临时文件再 mv。
OBJCOPY=${RUST_OBJCOPY:-$(command -v rust-objcopy || find "$HOME/.rustup" -name rust-objcopy 2>/dev/null | head -1)}
if [ -n "$OBJCOPY" ]; then
  "$OBJCOPY" --remove-section=.llvmbc --strip-debug \
    "$OUT/filemanager.elf" "$OUT/filemanager.elf.strip"
  mv "$OUT/filemanager.elf.strip" "$OUT/filemanager.elf"
fi

"$CANOPUS/target/debug/canopus" verify "$OUT/filemanager.elf" \
  --target "$TARGET_ID" --targets-dir "$CANOPUS/targets"
"$ROOT/scripts/verify-device.sh" "$OUT/filemanager.elf" "$MODULE_MAX_SIZE"
