# payload/ — 原生应用注入载荷

把编译好的 NuttX/Vela `modlib` 内核模块放到这里，命名为 **`module.ko`**，然后重新打包：

```bash
bun scripts/build-face.mjs
```

打包脚本 `scripts/build-face.mjs` 会读取 `payload/module.ko`，把它的字节内容以
`PAYLOAD` 全局字符串（逐字节 `\xNN` 转义）嵌入到 `.face` 的入口 Lua 脚本头部。
表盘顶栏 `i` 弹出的能力面板里有一个 **`INJECT`** 按钮，点击后按**已实机验证的
ELF 注入闭环**执行：

```
write  → 把 PAYLOAD 写到 /data/deepscan_module.ko
insmod → os.execute("insmod /data/deepscan_module.ko deepscan")   # modlib 加载
lsmod  → os.execute("lsmod") 解析模块基址（第 5 列 = textalloc）
exec   → os.execute("exec <base+1>")                               # Thumb 位跳入入口
verify → 可选：mw 读取模块写入的标记地址
```

每步结果实时显示在表盘上，哪一步失败一目了然。

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
