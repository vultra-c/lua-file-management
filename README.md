# DEEP_SCAN — 小米手环 9 Pro 文件管理器表盘

一款运行在 **小米手环 9 Pro（Vela / MiWear Lua 5.4，336×480）** 上的**简洁浅色文件管理器表盘**。

安装后**直接进入文件管理器**（无时钟表盘界面），可浏览系统文件并删除：

- **浏览**：逐层进入任意目录，目录/文件分行显示；
- **查看**：点文件行弹出详情（大小 + 文本预览）；
- **删除**：每行右侧 DEL 按钮，二次确认后调用 `os.remove()` 删除；
- **能力探测**：顶栏 `i` 按钮列出当前运行时实际暴露的“原生能力”（详见下文）。

## 目录结构

```
lua/main.lua                 # 入口（单文件自包含文件管理器）
bin/DeepScan.face            # 已构建的实机安装包（产物，可直接刷入）
bin/resource.bin             # 同内容副本（模拟器/LuaDevTemplate 安装用）
watchface.config.json        # 项目配置（projectName / watchfaceId）
watchface/fprj/DeepScan.fprj # EasyFace 兼容项目文件（DeviceType=367）
watchface/fprj/images/preview.png  # EasyFace 预览图（336×480，与界面一致）
scripts/face-lib.mjs         # .face 容器格式库（构建/解析共用）
scripts/build-face.mjs       # 打包器：lua/main.lua → bin/DeepScan.face（含自校验）
scripts/unpack-face.mjs      # 解包/校验器：.face → 记录清单/文件
scripts/smoke-test.lua       # Lua 冒烟测试（打桩 lvgl，桌面 Lua 5.4 可跑）
scripts/gen-preview.mjs      # 预览图生成脚本（纯 Node，无依赖）
```

## 入口约定（重要）

与真实 9 Pro 表盘一致，`main.lua` 采用：

- **顶层直接构建 UI**（不依赖 `ui.init` 被运行时调用）；
- 导出 `ScreenStateChangedCB(pre, now, reason)` 处理熄屏/亮屏；
- 仅使用已验证可用的 API：`lvgl.Object/Label`、`lvgl.BUILTIN_FONT`、`lvgl.fs`、`os.remove`；
- 字体仅用已验证尺寸（montserrat 14/16/18/24/32），界面文案使用英文（内置 montserrat 无中文字形）。

## 功能说明

### 界面布局

- **顶栏**：`<` 返回上一级、路径显示（**点按路径可跳回根目录 `/`**）、`i` 能力信息；
- **列表**：每行白色圆角卡片，左侧彩色圆点 + 名称（文件夹蓝色带 `/` 后缀、文件深色），右侧红色 DEL 删除按钮；
- **底部**：`<` / `>` 分页、页码、状态栏。

### 操作

| 操作 | 说明 |
| --- | --- |
| 点目录行 | 进入该目录 |
| 点文件行 | 弹出文件详情（名称、大小、前 64 字节文本预览） |
| 行右侧 DEL | 弹出删除确认（CANCEL / DELETE） |
| 顶栏 `<` | 进入上一级目录 |
| 点按顶栏路径 | 回到根目录 `/` |
| 顶栏 `i` | 显示系统能力探测结果 |
| 底部 `<` / `>` | 分页浏览（每页 6 行） |

### 删除

- 点击 DELETE 调用 `os.remove()`（`pcall` 包裹，失败在状态栏显示错误）；
- 只能删除文件或**空目录**，非空目录删除失败；
- 删除成功时尝试振动反馈（若固件支持 `vibrator`，否则静默忽略）。

## 原生应用注入（Native App Injection）

“表盘原生应用注入”是米坛/社区里的一种研究思路：**把表盘的 Lua 运行时当作一个“原生应用”的注入/执行载体**，借助它超出普通表盘的系统访问能力去实现文件管理、Shell 执行、蓝牙等原生功能。

关键事实（来自官方文档 <https://docs.luoxe.cn/docs/vela/lua/> 与社区逆向）：

- 表盘运行在独立 Lua 5.4 进程里，但可通过 `lvgl.fs` / `io` 访问部分真实文件系统（如 `/data/`、`/data/app/watchface/`、`/tmp/`、`/resource/`、`/etc/` 等），这正是本表盘“文件管理器”能成立的原因；
- `os.remove()` 可删除可写分区内的文件；
- **受限项**：`io.popen()` 不可用、`package.loadlib()` 被禁用（无法从表盘加载 `.so` 原生库）、`os.execute()` 通常被裁剪——所以纯表盘无法直接执行原生二进制/Shell；
- 真正的“原生应用注入/提权”需要外部配合：如 **VelaSU（root daemon）+ Vela-Shell-Bridge**（让 QuickApp 通过 Lua daemon 执行受控的系统级 Shell 命令），或 QuickApp/AstroBox 插件的 `native` 权限。

### 本项目的落地方式

本表盘本身就是“用表盘做原生应用”的最小落地（文件浏览 + 删除）。顶栏 `i` 按钮会**按需探测**（pcall 保护，不在启动时探测，避免触发 panic 重启）当前运行时实际暴露的能力：

| 能力 | 对应接口 |
| --- | --- |
| List dirs | `lvgl.fs.open_dir` |
| Read files | `lvgl.fs.open_file` |
| io.open | `io.open` |
| Delete | `os.remove` |
| Run command | `os.execute` |
| Pipe cmd | `io.popen` |
| Load native | `package.loadlib` |

若某台设备上 `os.execute`/`io.popen` 恰好未被裁剪，后续可在该面板之上扩展 Shell 执行；否则这些项显示 `[--]`。

## 打包与安装

内置一套**无依赖的 Node/Bun 打包工具链**，可直接在终端产出可安装的 `.face`：

```bash
bun scripts/gen-preview.mjs                # 生成 336×480 预览图
bun scripts/build-face.mjs                 # lua/main.lua → bin/DeepScan.face（含自校验）
bun scripts/unpack-face.mjs bin/DeepScan.face  # 校验/解包
lua5.4 scripts/smoke-test.lua              # 冒烟测试（打桩 lvgl，驱动浏览/查看/删除）
```

产物：

| 文件 | 说明 |
| --- | --- |
| `bin/DeepScan.face` | 实机安装包（Vela Lua 表盘容器，Lua 源码明文内嵌，单文件入口） |
| `bin/resource.bin` | 同内容副本 |

### `.face` 容器格式（Face V2，已按真实 9 Pro 样本逐字节验证）

- **头部（0x00–0x10F）**：`5A A5 34 12` 魔数；0x10=2048；0x1C=1；0x20=预览块偏移；0x28 起 10 字节 ASCII 表盘 ID；0x68 起 UTF-8 标题；0xA8=backImageId(0)、0xAC=previewImageOffset；0xB0–0xFF 为 10 个 8 字节描述符 `[count][offset]`（i=5 为应用文件表，i=0 为 element）。
- **文件表（TOC，0x110）**：16 字节条目 `[id=(5<<24)|i][0][偏移][长度]`，共 fileCount 条；其后紧跟 16 字节 **element 数据块** `[TargetId=(5<<24)|入口索引][PosX][PosY][0]*8`。
- **入口定位**：element 的 `TargetId` 指向 Lua 入口文件在 TOC 中的索引（`0x05000000 + index`）。本打包器把唯一入口文件放在索引 0，故 `TargetId = 0x05000000`。
- **文件记录**：`[u16 长度&0xFFFF][u8 长度>>16][u8 名称长度][16B 0]` + 名称 + 数据，4 字节对齐。
- **预览块（文件末尾，0x20/0xAC 指向）**：`[rle][type][宽 u16][高 u16][dataLen][magic 0x5AA521E0][compressType=(w×h×4)<<4|4]` + RLE 压缩的 BGR(A) 图像（230×328，336×480 的等比缩略）。安装器解析该块生成缩略图。

打包脚本对产物做自解析回读校验（入口索引、文件表、预览 magic/尺寸、RLE 解压像素数）。

### 在 Windows 上用 EasyFace 构建（可选）

1. 用 **EasyFace**（`github.com/m0tral/EasyFace`，支持手环 9 Pro）打开 `watchface/fprj/DeepScan.fprj`；
2. 源码入口 `app/_lua/deepscan/deepscan.lua` 对应仓库里的 `lua/main.lua`；
3. 编译后按 EasyFace 的流程刷写安装。

## 系统文件安全说明

- 表盘脚本运行在独立 Lua 进程，文件访问受**系统权限与挂载属性**限制：
  - `/data` 是可写数据分区，删除通常可行；
  - `/resource`、`/misc`、`/mode`、`/etc`、`/dev` 等分区只读，删除会失败并提示 `delete failed`；
- 删除使用 Lua 标准库 `os.remove()`（`pcall` 包裹；若固件裁剪了该接口会提示 `no delete api`）；
- `os.remove` 只能删除**空目录**，非空目录删除会失败；
- 不建议删除正在使用的数据库/日志文件（如 `/data` 下的 `persist.db`、`apps.json`）。

## 运行环境与 API 说明

| 能力 | 接口 | 备注 |
| --- | --- | --- |
| Lua | 5.4 | 设备端运行时 |
| 图形 | `lvgl` | `lvgl.Object` / `lvgl.Label` / `lvgl.BUILTIN_FONT.MONTSERRAT_*` |
| 文件 | `lvgl.fs.open_dir/open_file` | 目录 `read/close`，文件 `read/seek/close`（路径用 NuttX 绝对路径） |
| 删除 | `os.remove` | 标准库（可能被设备裁剪） |
| 振动 | `vibrator`（可选） | 删除成功时轻振反馈 |

> 相关文档：<https://docs.luoxe.cn/docs/vela/lua/>

## 常见问题

- **装完黑屏**：确认入口文件与 element TargetId 匹配（本打包器自动保证）。若用 EasyFace 自行编译，需保证 `.fprj` 的 `Shape="34"` Widget 指向 `app/_lua/deepscan/deepscan.lua`。
- **表盘切换界面预览黑屏/白框漂移**：预览缩略图来自 `.face` 的预览块（230×328 BGR(A) RLE）。本仓库 `scripts/gen-preview.mjs` 生成的 `preview.png` 与 `scripts/build-face.mjs` 内嵌预览保持同一套浅色布局；若仍异常，多为第三方安装工具按旧缓存渲染，重装一次或换用 AstroBox 刷入。
- **点不动**：本表盘为单屏文件管理器（无页面切换）。所有子标签均已加 `EVENT_BUBBLE`、可点元素显式 `CLICKABLE`，点击会落在父卡片/按钮上。
- **删除失败**：多为只读分区、非空目录或无权限，状态栏会显示错误信息。
- **列表太长**：分页浏览（每页 6 行）；`LIST_CAP`（默认 300）可在 `lua/main.lua` 顶部调整。
