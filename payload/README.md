# payload/ — 原生应用注入载荷

## 构建原生模块（真实 ARM 交叉工具链）

仓库内置 **GCC arm-none-eabi 工具链**构建流程（不再手工编码 ELF），产出与
NuttX/Vela 加载器实测过的格式完全一致的标准 ET_REL 模块：

```bash
apt-get install -y gcc-arm-none-eabi     # 一次性
bash scripts/build-ko.sh                 # → payload/module.ko（1264 字节）
```

构建细节（`scripts/build-ko.sh`）：

1. `arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mfloat-abi=soft -Os ... -c payload/src/module.c`
2. `arm-none-eabi-ld -r -T payload/gnu-elf.ld module.o -o payload/module.ko`

`payload/gnu-elf.ld` 是 **NuttX 10.3.0 官方 `binfmt/libelf/gnu-elf.ld`**（原样收录），
把 `.text/.rodata/.data/.ctors/.dtors/.bss` 排成 modlib 期望的顺序。

模块内容（`payload/src/module.c` 的 `module_main`，零重定位、零外部符号）：

```c
void module_main(void) {
    *(volatile uint32_t *)0x20001000 = 0x5EED0001;  /* 标记1：注入闭环验证魔数 */
    *(volatile uint32_t *)0x20001004 = 1;           /* 标记2：版本号 */
}
```

产物结构（`arm-none-eabi-readelf` 复核）：

```
Type: REL  Machine: ARM  Flags: 0x05000000 (Version5 EABI)
[ 1] .text     PROGBITS  AX    （20 字节：ldr/str 直写两个标记后 bx lr）
[ 2] .rodata   PROGBITS
[ 3] .data     PROGBITS  WA    （size 0，段存在）
[ 4] .ctors / [5] .dtors
[ 6] .bss      NOBITS    WA    （size 0，段存在）
[ 7] .comment / [8] .ARM.attributes
[ 9] .symtab（含 _stext/_sdata/_sbss 等链接器标签 + module_main GLOBAL FUNC）
[10] .strtab / [11] .shstrtab
```

> 注意：本模块只写验证标记，是「注入闭环能不能跑通」的最小探针；
> 要真正渲染原生 UI / 注册应用列表，需要进一步逆向设备上已解密挂载的
> LVX 渲染层与 `app_install`/`launcher_add`（见 `re/README.md` 的运行时采集路径）。

## 打包与使用

把编译好的 NuttX/Vela `modlib` 内核模块放到 `payload/module.ko`，然后重新打包：

```bash
bun scripts/build-face.mjs
```

打包脚本 `scripts/build-face.mjs` 会读取 `payload/module.ko`，把它的字节内容以
`PAYLOAD` 全局字符串（逐字节 `\xNN` 转义）嵌入到 `.face` 的入口 Lua 脚本头部。
表盘顶栏 `i` 弹出的能力面板里有一个 **`INJECT`** 按钮，点击后按**已实机验证的
ELF 注入闭环**执行：

```
write    → 把 PAYLOAD 写到 /data/deepscan_module.ko（优先 io.open("wb")，二进制安全）
readback → 回读文件前 16 字节 hex + 文件大小，确认设备磁盘上是完整 ELF
insmod   → os.execute("insmod <path> <name>")；失败自动重试 1 参数形式   # modlib 加载
lsmod    → os.execute("lsmod") 解析模块基址（第 5 列 = textalloc）
exec     → os.execute("exec <base+1>")                               # Thumb 位跳入入口
verify   → 可选：mw 读取模块写入的标记地址
```

每步结果实时显示在表盘上，哪一步失败一目了然。

### 实测记录（2026-08-14）

**第一轮**：`write OK`（366 字节）但 `insmod FAIL (exit 65280)`。65280 正是 insmod
拒绝该文件为非法 ELF / 打不开文件的返回码。当时模块是**手工编码的最小 ELF**，
只有 `.text/.symtab/.strtab/.shstrtab` 四个段。排查确认：

- ✅ face 内嵌 PAYLOAD 与 `payload/module.ko` **逐字节一致**（`scripts/verify-payload.mjs`）。
- ✅ 写入路径已实机验证完好：`readback` 显示磁盘上 366 字节、头部
  `7F 45 4C 46 01 01 01 00 ...` 完整（未被 C 字符串截断）。
- ⚠️ 结论：**问题在模块文件本身** —— 手工编码产物缺 `.data`/`.bss` 等段，
  与加载器实测过的真实工具链输出不一致。

**第二轮**：改用**真实 GCC 工具链**按 NuttX 官方 `gnu-elf.ld` 构建，
产出与朋友实机验证通过的模块同构的标准 ET_REL（含 `.text/.data/.bss/.symtab`、
`.ARM.attributes`、`_stext/_sdata/_sbss` 链接器标签、`module_main` GLOBAL FUNC）。

**第三轮**：对照 openvela 加载器源码（`binfmt/elf.c`：
`entrypt = textalloc + e_entry`；`libs/libc/elf/*`：verify → load → bind → symtab）
逐条核对后，把 **`e_entry` 从 0 改为 `module_main` 符号值（0x00000001，Thumb 位）**，
与朋友实机验证通过的模块（`e_entry=module_main`）完全一致。同时 INJECT 面板升级：
`insmod` 的 **stderr 会被捕获回读**（失败时直接显示固件打印的错误码，如
`insmod failed: 8`），`lsmod` 解析不到基址时显示原始输出首行。

**第四轮（本轮，加载器源码级核对）**：把两套参考实现的 modlib 源码逐条拉下来核对：

- **NuttX 10.3.0 官方**（`libs/libc/modlib/*`，与本机固件版本串 `NuttX.10.3.0.86ac2747e4` 同源）：
  - `modlib_verify`：只查 **ELF 魔数 + `e_type==ET_REL` + `up_checkarch`**（e_machine=EM_ARM、
    ELFCLASS32、小端），**不查 e_flags / 段名 / .data 是否存在**；
  - `modlib_loadshdrs`：`e_shnum >= 1` 且 `e_shoff + e_shentsize*e_shnum <= 文件长度`；
  - `modlib_loadfile`：只处理 `SHF_ALLOC` 段，**size=0 的段直接跳过**（所以空的
    `.data/.bss` 无碍），`SHT_NOBITS` 段 memset；
  - `modlib_bind`：要求存在 **`.symtab`**；本模块零重定位、零未定义符号，必然通过。
- **openvela 分支**（`libs/libc/elf/*`）：`libelf_verifyheader` 只查魔数 +
  `e_type ∈ {ET_REL, ET_DYN, ET_EXEC}` + `up_checkarch`；加载逻辑同上。

结论：**当前 GCC 构建的 `module.ko` 通过两套加载器的全部静态检查**（可复现：
`bash scripts/build-ko.sh` 产物与仓库内 `payload/module.ko` 逐字节一致）。
之前 366 字节手工模块的 65280 失败，差异点在于：缺 `.data/.bss` 等段、段表未
4 字节对齐、符号表结构不完整——与真实工具链产物不同构。

同时 INJECT 面板再加一层**设备端 ELF 结构预检（`elf` 步）**：写盘后用 Lua 解码
52 字节 ELF 头，逐条对照上面的 verify 条件（魔数/class/endian/e_type/e_machine/
shentsize/shnum/shstrndx/段表范围）。全过 → 文件静态上必然能过 insmod 的
verify；若 insmod 仍报 65280，`insmod` 行的 stderr 捕获会给出固件侧具体错误码，
据此即可定位被拒环节。

**第五轮（实机结果 + shell 探针）**：实机复测结果：`write OK 1264 B`、`readback OK`
（ELF 头完整）、**`elf OK (ET_REL/ARM entry=0x1)`** —— 文件静态上完全合格；但
`insmod FAIL exit 65280` 且 **stderr 捕获为空**，`lsmod` 也**无任何输出**（连表头
都没有）。这个组合强烈指向：**表盘 `os.execute` 的 shell 里根本没有 `insmod`/
`lsmod` 命令**（命令不存在时 shell 直接返回 255，且不打印 stderr）。

因此本轮加了三个单行探针（`probe echo` / `probe redir` / `probe insmod`）：

- `probe echo`：`os.execute("echo ok")` 是否真的执行（exit 0 + 有输出）；
- `probe redir`：`echo ok > 文件` 后回读，验证重定向/捕获机制是否生效
  （决定 stderr 捕获可不可信）；
- `probe insmod`：无参数跑 `insmod`——能打出 usage 文本 = 命令存在（拒绝是
  模块/加载器问题）；exit 255 且无输出 = **命令不存在**。

同时把模块的 `.data`/`.bss` 从「size=0 空段」改成 **`__attribute__((used))` 的
真实 4 字节内容**（1356 字节，仍零重定位、零外部符号、e_entry=1），排除「定制
modlib 要求数据段必须有真实内容」这一类拒绝。`DUMP` 面板也新增了 `echo_test`/
`insmod_usage`/`cmd_insmod`/`ls_bin` 等诊断文件，能看到系统命令实际放在哪个目录。

请重新下载 `bin/DeepScan.face` 安装后再次点击 `INJECT`，**把面板全文发回**。
判读：

1. `probe echo` FAIL → `os.execute` 本身不可用，整条 insmod 路线在本机跑不通；
2. `probe echo` OK 但 `probe insmod` FAIL（无输出）→ 该 shell 没有 insmod，
   需要换执行通道（见 `re/README.md` 的 P0，或从 `ls_bin.txt` 找命令目录补 PATH）；
3. `probe insmod` OK（有 usage 文本）→ 命令存在，但拒绝我们的模块：把
   `insmod` 行 stderr 发回即可定位具体 errno。

> 排查依据（openvela 加载器源码，仓库 `re/` 已记录结论）：
> - `libelf_verifyheader` 只检查 ELF 魔数 / e_type(REL) / `up_checkarch`（e_machine=EM_ARM、
>   EI_CLASS=32、小端），**不检查 e_flags**；
> - `libelf_insert` 流程：打开文件 → verify → load 各 SHF_ALLOC 段 → bind（本模块零重定位、
>   零未定义符号，必然通过）→ 导入自身 symtab → 注册。
> - 因此只要文件不是被截断的非法 ELF，静态上必然能过；若实机仍报 65280，
>   新面板的 stderr 捕获会直接给出固件侧的 errno，据此即可定位是哪个环节被拒。

## 关键机制（实机验证结论）

- **insmod 只加载不执行**：`insmod <path> <name>` 返回 `true, exit, 0` 表示成功；
  模块文本被分配到 **0x3D PSRAM 可执行区**，地址每次动态变化。
- **lsmod 现场解析基址**：输出列为 `NAME INIT UNINIT ARG NEXPORTS TEXT SIZE DATA SIZE`，
  第 5 列（`NEXPORTS` 列）就是模块文本基址（textalloc）。表盘里的 `lsmodBase()` 据此解析。
- **exec 以函数调用跳转**：`exec <base+1>`（+1 为 Thumb 位），模块 `bx lr` 干净返回。
- **固件 Lua 5.4 `tonumber` 不认 `0x` 前缀**：代码里用 `tonumber(s:sub(3), 16)` 手动剥离。

## 设备/固件相关参数

这些值集中在 `lua/main.lua` 顶部的 `INJECT` 表，按你的固件微调即可（大多有安全默认值）：

| 字段 | 默认值 | 说明 |
| --- | --- | --- |
| `ko_path` | `/data/deepscan_module.ko` | 写 .ko 的位置（/data 可写） |
| `mod_name` | `deepscan` | insmod 模块名，lsmod 按此名解析基址 |
| `entry_offset` | `1` | exec 的 Thumb 位偏移（`base + offset`） |
| `marker_addr` | `0x20001000` | 模块写入标记的地址，`mw` 验证（设为 `nil` 跳过） |

> 模块**入口地址无需手填**：表盘启动后现场从 `lsmod` 解析，自动 `exec <base+1>`。

## 目录约定

- `module.ko` —— 要加载的 ELF/`.ko` 模块（ET_REL，NuttX modlib 格式）。不存在时
  打包脚本注入 `PAYLOAD = nil`，INJECT 面板会显示 `write FAIL: no embedded payload`。
- `src/module.c` —— 模块 C 源码（`module_main` 写两个验证标记）。
- `gnu-elf.ld` —— NuttX 10.3.0 官方模块链接脚本（`arm-none-eabi-ld -r -T`）。
- `scripts/build-ko.sh` —— 真实工具链构建脚本（需 `gcc-arm-none-eabi`）。
- `scripts/build-module.mjs` —— 旧版手工编码构建器（保留作无工具链环境兜底）。
