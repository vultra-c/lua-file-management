#!/bin/sh
# 构建并签名一份文件管理器安装载荷（模块 + CMI1 收据）。
# 与参考仓库 scripts/build-install-payload.sh 同构，单 target 无额外 features。
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CANOPUS=${CANOPUS_ROOT:-"$ROOT/../Canopus"}
TARGET_ID=${1:-xiaomi-band-9-pro-3.1.175}
OUT=${2:-"$ROOT/build/install/$TARGET_ID"}
TARGET_PROFILE="$ROOT/targets/$TARGET_ID.env"
[ -f "$TARGET_PROFILE" ] || {
  echo "error: unsupported module target: $TARGET_ID" >&2
  exit 1
}
. "$TARGET_PROFILE"

TARGET_FIRMWARE_SHA256=$(python3 - "$CANOPUS/targets/$TARGET_ID/target.toml" "$TARGET_ID" <<'PY'
import pathlib, sys, tomllib
profile = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())
if profile.get("target_id") != sys.argv[2]:
    raise SystemExit("target profile identity does not match requested target")
digest = profile.get("firmware_sha256", "")
if len(digest) != 64:
    raise SystemExit("target profile has no valid firmware_sha256")
try:
    bytes.fromhex(digest)
except ValueError as error:
    raise SystemExit("target profile firmware_sha256 is not hexadecimal") from error
print(digest)
PY
)
LIFECYCLE=$(python3 - "$ROOT/Canopus.toml" <<'PY'
import pathlib, sys, tomllib
value = tomllib.loads(pathlib.Path(sys.argv[1]).read_text())["module"]["lifecycle"]
classes = {
    "removable": 0,
    "resident-after-activation": 1,
    "always-resident": 2,
    "patch-reboot-required": 3,
}
if value not in classes:
    raise SystemExit(f"unsupported module lifecycle: {value}")
print(classes[value])
PY
)

TRIPLE=$RUST_TARGET_TRIPLE
CC=${CC:-clang}
KEY=${MODULE_INSTALL_KEY:-"$CANOPUS/.canopus-local/module-installer-ed25519.pem"}
TOKEN=file_manager
mkdir -p "$OUT"

NIGHTLY=${NIGHTLY_CARGO:-cargo +nightly}
LEAN_RUSTFLAGS="-C panic=abort -C target-cpu=$RUST_TARGET_CPU -Z unstable-options \
  -Z function-sections=no -C symbol-mangling-version=hashed \
  -Z location-detail=none -Z fmt-debug=none"

echo "[payload 1/3] cross-build Rust staticlib for $TARGET_ID"
# 默认值故意不加引号，让 rustup 代理能收到独立的 +nightly 参数。
RUSTFLAGS="$LEAN_RUSTFLAGS" $NIGHTLY build \
  --manifest-path "$ROOT/Cargo.toml" --release --target "$TRIPLE" \
  -p canopus-filemanager-device --no-default-features \
  --features "$RUST_TARGET_FEATURE"

echo "[payload 2/3] link, strip, and verify $TARGET_ID"
"$CC" --target=arm-none-eabi -mcpu="$RUST_TARGET_CPU" -mthumb -mfloat-abi=soft \
  -ffreestanding -fno-common -fno-builtin -fno-stack-protector \
  -fno-unwind-tables -fno-asynchronous-unwind-tables \
  -fdata-sections -ffunction-sections -Os -Wall -Wextra -Werror \
  -I"$CANOPUS/sdk/c" \
  -c "$ROOT/crates/filemanager-device/c_shim/canopus_ctor.c" \
  -o "$OUT/canopus_ctor.o"
"$ROOT/scripts/link-device.sh" \
  "$OUT" "$CC" "$RUST_TARGET_CPU" "$CANOPUS" "$TARGET_ID" "$ROOT" "$TRIPLE"
OBJCOPY=${RUST_OBJCOPY:-$(command -v rust-objcopy || find "$HOME/.rustup" -name rust-objcopy 2>/dev/null | head -1)}
if [ -n "$OBJCOPY" ]; then
  "$OBJCOPY" --remove-section=.llvmbc --strip-debug \
    "$OUT/filemanager.elf" "$OUT/filemanager.elf.strip"
  mv "$OUT/filemanager.elf.strip" "$OUT/filemanager.elf"
fi
"$CANOPUS/target/debug/canopus" verify "$OUT/filemanager.elf" \
  --target "$TARGET_ID" --targets-dir "$CANOPUS/targets"
"$ROOT/scripts/verify-device.sh" "$OUT/filemanager.elf" "$MODULE_MAX_SIZE"

echo "[payload 3/3] sign and validate CMI1 receipt for $TARGET_ID"
[ -f "$KEY" ] || {
  echo "error: module installer key not found: $KEY" >&2
  exit 1
}
python3 "$CANOPUS/scripts/build-module-installer-receipt.py" \
  --module "$OUT/filemanager.elf" \
  --module-id "$TOKEN" \
  --version 1 \
  --lifecycle "$LIFECYCLE" \
  --target-id "$TARGET_ID" \
  --firmware-sha256 "$TARGET_FIRMWARE_SHA256" \
  --private-key "$KEY" \
  --output "$OUT/receipt.bin"
python3 - "$OUT" "$LIFECYCLE" "$TARGET_ID" "$TARGET_FIRMWARE_SHA256" <<'PY'
import hashlib, pathlib, struct, sys
out = pathlib.Path(sys.argv[1])
expected_lifecycle = int(sys.argv[2])
expected_target = sys.argv[3]
expected_firmware = sys.argv[4]
module = (out / "filemanager.elf").read_bytes()
receipt = (out / "receipt.bin").read_bytes()
assert module[:4] == b"\x7fELF" and 512 <= len(module) <= 262144
assert len(receipt) == 256 and receipt[:4] == b"CMI1"
magic, version, header, _flags, lifecycle, module_version, artifact_size, _reserved = struct.unpack(
    "<8I", receipt[:32]
)
assert magic == 0x31494D43 and version == 1 and header == 256
assert lifecycle == expected_lifecycle and module_version == 1
assert artifact_size == len(module), (artifact_size, len(module))
module_id = receipt[32:64].split(b"\0", 1)[0]
target_id = receipt[64:112].split(b"\0", 1)[0].decode("ascii")
firmware = receipt[112:144].hex()
module_sha = hashlib.sha256(module).digest()
assert module_id == b"file_manager", module_id
assert target_id == expected_target, (target_id, expected_target)
assert firmware == expected_firmware, (firmware, expected_firmware)
assert receipt[144:176] == module_sha, (receipt[144:176].hex(), module_sha.hex())
print(
    f"payload OK: target={target_id} module={len(module)}B receipt={len(receipt)}B "
    f"sha256={module_sha.hex()}"
)
PY
