#!/bin/sh
# 构建文件管理器安装表盘：把「签名过的模块 + CMI1 收据 + 图标」放进
# watchfaces/filemanager/，跑 Lua 冒烟测试，并用 Python 校验全部产物。
# 单 target：xiaomi-band-9-pro-3.1.175。
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CANOPUS=${CANOPUS_ROOT:-"$ROOT/../Canopus"}
WATCHFACE="$ROOT/watchfaces/filemanager"
TARGET_ID=xiaomi-band-9-pro-3.1.175
mkdir -p "$WATCHFACE"

cargo fmt --manifest-path "$ROOT/Cargo.toml" --all -- --check
cargo test --manifest-path "$ROOT/Cargo.toml" --workspace
lua5.4 "$ROOT/scripts/smoke-watchface.lua" >/dev/null

OUT="$ROOT/build/install/$TARGET_ID"
"$ROOT/scripts/build-install-payload.sh" "$TARGET_ID" "$OUT"
STEM="$WATCHFACE/filemanager-$TARGET_ID"
cp "$OUT/filemanager.elf" "$STEM.bin"
cp "$OUT/receipt.bin" "$STEM.cmi.bin"

python3 - "$ROOT" "$CANOPUS" "$WATCHFACE" "$TARGET_ID" <<'PY'
import hashlib, pathlib, struct, sys, tomllib
root = pathlib.Path(sys.argv[1])
canopus = pathlib.Path(sys.argv[2])
watchface = pathlib.Path(sys.argv[3])
target = sys.argv[4]
stem = watchface / f"filemanager-{target}"
module_path = pathlib.Path(str(stem) + ".bin")
receipt_path = pathlib.Path(str(stem) + ".cmi.bin")
module = module_path.read_bytes()
receipt = receipt_path.read_bytes()
assert len(module) >= 512 and len(module) <= 262144
assert module[:7] == b"\x7fELF\x01\x01\x01"
assert struct.unpack_from("<HH", module, 16) == (1, 40)
assert len(receipt) == 256 and receipt[:4] == b"CMI1"
magic, version, header, _flags, lifecycle, module_version, artifact_size, _reserved = struct.unpack(
    "<8I", receipt[:32]
)
assert magic == 0x31494D43 and version == 1 and header == 256
assert lifecycle in range(4) and module_version == 1
assert artifact_size == len(module), (target, artifact_size, len(module))
module_id = receipt[32:64].split(b"\0", 1)[0]
receipt_target = receipt[64:112].split(b"\0", 1)[0].decode("ascii")
receipt_firmware = receipt[112:144].hex()
profile = tomllib.loads((canopus / "targets" / target / "target.toml").read_text())
assert profile["target_id"] == target
assert module_id == b"file_manager", module_id
assert receipt_target == target, (receipt_target, target)
assert receipt_firmware == profile["firmware_sha256"]
module_digest = hashlib.sha256(module).digest()
assert receipt[144:176] == module_digest
appicon = (watchface / "appicon_filemanager.bin").read_bytes()
assert len(appicon) == 54768 and appicon[:4] == b"\x19\x10\0\0"
icon_width, icon_height, icon_stride, icon_reserved = struct.unpack_from("<4H", appicon, 4)
assert (icon_width, icon_height, icon_stride, icon_reserved) == (117, 117, 468, 0)
assert len(appicon) == 12 + icon_height * icon_stride
actual_files = set(watchface.glob("filemanager-*.bin"))
assert actual_files == {module_path, receipt_path}, sorted(map(str, actual_files))
assert not (watchface / "module.bin").exists()
assert not (watchface / "receipt.bin").exists()
print(f"watchface staged OK: {target} module={len(module)}B receipt={len(receipt)}B")
PY

echo "watchfaces/filemanager is ready to install"