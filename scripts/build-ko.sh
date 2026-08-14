#!/usr/bin/env bash
# scripts/build-ko.sh
# 用真实 ARM 交叉工具链构建 NuttX/Vela modlib 内核模块 → payload/module.ko。
# 这是加载器实际测试过的格式：标准 ET_REL + .text/.data/.bss + .symtab。
#
# 依赖（一次性）：
#   apt-get install -y gcc-arm-none-eabi
#
# 用法：
#   bash scripts/build-ko.sh
set -euo pipefail
cd "$(dirname "$0")/.."

CC=arm-none-eabi-gcc
LD=arm-none-eabi-ld
SRC=payload/src/module.c
LDSCRIPT=payload/gnu-elf.ld
OUT=payload/module.ko
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if ! command -v "$CC" >/dev/null 2>&1; then
  echo "error: $CC not found. Install with: apt-get install -y gcc-arm-none-eabi" >&2
  exit 1
fi

# -mcpu=cortex-m4：Thumb-2 基线（v7-M 全系兼容；本模块无任何架构特有指令）。
# 若目标 SoC 是 Cortex-A（ARMv7-A），同样的 Thumb-2 指令也可执行。
"$CC" -mcpu=cortex-m4 -mthumb -mfloat-abi=soft \
  -Os -ffreestanding -fno-common -fno-builtin -fno-stack-protector \
  -fno-unwind-tables -fno-asynchronous-unwind-tables \
  -fno-pic -fno-pie -nostdlib \
  -c "$SRC" -o "$TMP/module.o"

# 部分链接（-r 保持 ET_REL），用 NuttX 官方 gnu-elf.ld 排列 .text/.data/.bss。
"$LD" -r -T "$LDSCRIPT" "$TMP/module.o" -o "$OUT"

# e_entry = module_main 符号值（0x00000001，即 .text 偏移 0 + Thumb 位）：
# openvela 加载器按 entrypt = textalloc + e_entry 计算模块入口（binfmt/elf.c），
# 与朋友实机验证通过的模块（e_entry=module_main）保持一致；对 insmod 本身无副作用。
ENTRY_HEX=$(arm-none-eabi-readelf -s "$OUT" | awk '$8 == "module_main" && $5 == "GLOBAL" { print $2; exit; }')
ENTRY_HEX=${ENTRY_HEX:-00000000}
ENTRY_NUM=$((16#$ENTRY_HEX))
printf "\\x$(printf '%02x' $((ENTRY_NUM & 0xff)))\\x$(printf '%02x' $(((ENTRY_NUM >> 8) & 0xff)))\\x$(printf '%02x' $(((ENTRY_NUM >> 16) & 0xff)))\\x$(printf '%02x' $(((ENTRY_NUM >> 24) & 0xff)))" \
  | dd of="$OUT" bs=1 seek=$((0x18)) conv=notrunc 2>/dev/null

echo "built: $OUT ($(wc -c < "$OUT") bytes)"
echo "---"
arm-none-eabi-readelf -h "$OUT" | grep -E "Type:|Machine:|Flags:|Entry point"
arm-none-eabi-readelf -S "$OUT" | grep -E "\.text|\.data|\.bss|\.symtab|\.strtab|\.shstrtab|Nr"
arm-none-eabi-readelf -s "$OUT" | grep -E "module_main|Num:"
