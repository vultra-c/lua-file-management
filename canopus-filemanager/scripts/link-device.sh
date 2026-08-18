#!/bin/sh
# 单遍链接：canopus_ctor.o + Rust staticlib → ET_REL 可加载模块。
# 文件管理器没有 SBC codec 的 rodata 表，不需要参考仓库的 codec-fixups 两遍链接。
set -eu

OUT=${1:?usage: link-device.sh out cc cpu canopus target-id root triple}
CC=${2:?usage: link-device.sh out cc cpu canopus target-id root triple}
CPU=${3:?usage: link-device.sh out cc cpu canopus target-id root triple}
CANOPUS=${4:?usage: link-device.sh out cc cpu canopus target-id root triple}
TARGET_ID=${5:?usage: link-device.sh out cc cpu canopus target-id root triple}
ROOT=${6:?usage: link-device.sh out cc cpu canopus target-id root triple}
TRIPLE=${7:?usage: link-device.sh out cc cpu canopus target-id root triple}

FINAL="$OUT/filemanager.elf"
RUSTLIB="$ROOT/target/$TRIPLE/release/libcanopus_filemanager_device.a"

ld.lld -r --gc-sections -u canopus_module_descriptor \
  "$OUT/canopus_ctor.o" "$RUSTLIB" -o "$FINAL"

echo "linked $FINAL"
