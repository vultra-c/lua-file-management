#!/bin/sh
# 校验模块 ELF：加载映像大小 + 未定义符号。与参考仓库 scripts/verify-device.sh 同构。
set -eu
ELF=${1:?usage: verify-device.sh path/to/module.elf [max-loaded-size]}
MAX_SIZE=${2:-65536}

# 固件加载器只把 SHF_ALLOC 段映射进模块内存（加载映像）；文件里还有 symtab/
# strtab/shstrtab/relocations 从不加载。量加载映像，而不是文件大小。
LOADED=$(python3 - "$ELF" <<'PY'
import struct, sys
data = open(sys.argv[1], 'rb').read()
e_shoff = struct.unpack_from('<I', data, 0x20)[0]
e_shentsize = struct.unpack_from('<H', data, 0x2e)[0]
e_shnum = struct.unpack_from('<H', data, 0x30)[0]
loaded = 0
for i in range(e_shnum):
    off = e_shoff + i * e_shentsize
    flags = struct.unpack_from('<I', data, off + 0x8)[0]
    size = struct.unpack_from('<I', data, off + 0x14)[0]
    if flags & 0x2:  # SHF_ALLOC
        loaded += size
print(loaded)
PY
)

if [ "$MAX_SIZE" -ne 0 ] && [ "$LOADED" -gt "$MAX_SIZE" ]; then
  echo "module exceeds target max_size: $LOADED > $MAX_SIZE (loaded image)" >&2
  exit 1
fi

NM=${NM:-nm}
if "$NM" -u "$ELF" | grep -q .; then
  echo "module has undefined imports:" >&2
  "$NM" -u "$ELF" >&2
  exit 1
fi
file "$ELF"
if [ "$MAX_SIZE" -eq 0 ]; then
  echo "verified module loaded size: $LOADED bytes (no project limit)"
else
  echo "verified module loaded size: $LOADED bytes (limit $MAX_SIZE)"
fi
