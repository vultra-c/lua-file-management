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

echo "built: $OUT ($(wc -c < "$OUT") bytes)"
echo "---"
arm-none-eabi-readelf -h "$OUT" | grep -E "Type:|Machine:|Flags:|Entry point"
arm-none-eabi-readelf -S "$OUT" | grep -E "\.text|\.data|\.bss|\.symtab|\.strtab|\.shstrtab|Nr"
arm-none-eabi-readelf -s "$OUT" | grep -E "module_main|Num:"
