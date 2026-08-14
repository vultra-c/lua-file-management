# payload/ — 原生应用注入载荷

## 构建最小原生模块（本仓库自带，无需交叉编译器）

本环境没有 ARM 交叉编译器（`arm-none-eabi-gcc`/Rust 均不可用），因此仓库内置了一个
**逐字节手工编码 ARM Thumb-2 ET_REL ELF** 的模块构建器：

```bash
bun scripts/build-module.mjs   # → payload/module.ko（366 字节）
```

模块内容（`module_main`，纯 `.text`、零重定位、零外部符号，与朋友实机验证的闭环完全兼容）：

```
push {r7, lr}
movw/movt r1, #0x20001000   → *(0x20001000) = 0x5EED0001   （标记1，同朋友探针地址）
movw/movt r3, #0x20001004   → *(0x20001004) = 1             （标记2 = 版本号）
movs r0, #0 / pop {r7, pc}  → 干净返回（LR 由 exec 设置）
```

脚本内置字节级自校验（ELF 头、e_machine=EM_ARM、e_type=ET_REL、段表、符号表布局），
产物可用 `readelf -h/-s/-S payload/module.ko` 复核。

> 注意：本模块只写验证标记，是「注入闭环能不能跑通」的最小探针；
> 要真正渲染原生 UI / 注册应用列表，需要进一步逆向 `vela_ap.bin` 的
> LVX 渲染层与 `app_install`/`launcher_add`（见 `re/README.md` 的运行时采集路径）。

## 打包与使用

把编译好的 NuttX/Vela `modlib` 内核模块放到这里，命名为 **`module.ko`**，然后重新打包：

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

### 实测：insmod exit 65280（2026-08-14）

`write OK` 但 `insmod FAIL (exit 65280)`。65280 正是 insmod 拒绝该文件为
非法 ELF / 打不开文件的返回码。排查结论：

- ✅ face 内嵌 PAYLOAD 与 `payload/module.ko` **逐字节一致**（`scripts/verify-payload.mjs` 自校验）。
- ✅ 模块结构符合 openvela `libc/elf` 加载器要求（ET_REL / EM_ARM / `.text` / `.symtab` / 无重定位 OK）。
- ⚠️ **最大嫌疑：写入路径按 C 字符串处理**。旧版 `injectWritePayload` 优先用
  `lvgl.fs.open_file(path, "w")`，某些固件该 API 按 C 字符串写，遇到 ELF 头里的
  `\0`（第 7 字节起连续 9 个 `\0`）就会截断文件 → insmod 看到的是残缺文件。
  朋友验证链用的是 `io.open` 写 .ko。

新版表盘已改为：**二进制写优先 `io.open(path, "wb")`**，并在 write 后新增
**`readback`** 步骤（显示磁盘上文件真实大小 + 前 16 字节 hex），一次点击就能
确认设备上的字节是否完好：

- 头部显示 `7F 45 4C 46 01 01 01 00 ...` 且大小 366 → 写盘完好，问题在加载器，继续查。
- 头部只有 `7F 45 4C 46 01 01 01` 就没了 / 大小 < 366 → 写入被截断，实锤。
- 也可用表盘文件管理器直接看 `/data/deepscan_module.ko` 的大小核对。

## 关键机制（实机验证结论）

- **insmod 只加载不执行**：`insmod <path> <name>` 返回 `true, exit, 0` 表示成功；
  模块文本被分配到 **0x3D PSRAM 可执行区**，地址每次动态变化。
- **lsmod 现场解析基址**：输出列为 `NAME INIT UNINIT ARG NEXPORTS TEXT SIZE DATA SIZE`，
  第 5 列（`NEXPORTS` 列）就是模块文本基址（textalloc）。表盘里的 `lsmodBase()` 据此解析。
- **exec 以函数调用跳转**：`exec <base+1>`（+1 为 Thumb 位），模块 `pop{r7,pc}` 干净返回。
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
- `scripts/build-module.mjs` —— 手工编码最小模块的构建器（见上文，替代交叉编译器）。
