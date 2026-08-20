# Vela Files Pair — 小米手环 9 Pro 文件管理器

这是一个不依赖 Canopus 或原生模块注入的实验性方案：

- **Lua 表盘**：`lua/main.lua` + `lua/backend.lua`，在表盘进程获得的 Lua/LVGL 文件权限范围内浏览、预览和删除设备文件；
- **Vela Files 轻应用**：`quickapp/file-manager/src/`，提供私有沙箱模式，并把 SYSTEM 模式请求交给 Lua 表盘代理；
- **统一校验打包**：`.face` 使用仓库内的 Lua 表盘容器打包器；根目录 `.rpk` 是离线结构回归包，正式 QuickApp 包已用官方 `aiot-toolkit@2.0.5 release` 云端构建并签名。

## 重要权限边界

官方 QuickApp 文件 API 的 URI 是应用私有虚拟路径：

```text
internal://files/  → 当前 QuickApp 的私有持久文件区
internal://cache/  → 当前 QuickApp 的缓存区
internal://mass/   → 当前 QuickApp 的大文件区
internal://tmp/    → 系统映射的临时区（按 API 规则使用）
```

轻应用不能直接把这些 URI 改写成系统 `/data`。当前实现采用一个**用户确认式文件桥**，不是伪造 IPC：

1. 轻应用 SYSTEM 模式把 `LIST`、`READ` 或已确认的 `DELETE` 写到自己的 `internal://files/.velafiles-bridge/request.txt`；
2. Lua 表盘读取技能资料记录的物理映射 `/data/quickapp/file/com.deepscan.velafiles/.velafiles-bridge/request.txt`；
3. Lua 表盘使用自己的文件 API 访问系统 `/data`，把结果写入同一目录的 `response.txt`；
4. 轻应用读取自己的 `internal://files/.velafiles-bridge/response.txt` 并继续显示。

`launchQuickApp` 只覆盖 QuickApp→QuickApp，不能证明能自动启动 Lua 表盘；Band 9 Pro 也不能把 `system.event` 当成已验证的跨运行时通道。因此用户需要在轻应用排队后切换到表盘（表盘启动/恢复时自动处理请求，也可点顶部 `Q` 手动处理），再切回轻应用查看结果。

轻应用的挂起请求会持久化在 `request.txt`：切到表盘期间即使轻应用进程被杀，重新打开轻应用也会自动恢复挂起请求并读取 `response.txt` 显示结果，不需要再次排队。

桥接请求有版本、ID、`ready=1`、操作和路径字段。Lua 只接受 `/data` 及其子路径，拒绝 `.`、`..`、空字节和其他根目录；删除需要轻应用先确认，Lua 端仍拒绝 `/` 和 `/data` 根目录。

## 目录

```text
lua/
  backend.lua                         # Lua 文件操作与桥接后端
  main.lua                            # 336×480 表盘 UI，Q 处理桥接请求
quickapp/file-manager/
  package.json                         # 官方 AIoT 项目脚本
  src/manifest.json                   # 官方 Vela 清单
  src/app.ux                          # 轻应用生命周期
  src/pages/files/files.ux            # APP/SYSTEM 双模式 UI
scripts/
  build-face.mjs                      # 生成 .face
  unpack-face.mjs                     # 校验/解包 .face
  bridge-smoke.lua                    # 桥接协议离线测试
tools/
  build-companion.mjs                 # 生成开发 .rpk
  verify-companion.mjs                # 校验 .rpk、manifest、PNG 和桥接标记
docs/VELA-FILEMANAGER-SKILL.md        # 项目级开发规范
skills/vela-ai-skills-loaded/         # 已加载的 vela-ai-skills 文档
```

上一轮 Canopus/原生注入研究资料仍在 `canopus-filemanager/`、`payload/`、`re/` 中，仅作为历史记录，不参与新构建。

## 构建与验证

离线回归需要 Bun 或 Node 18+、Lua 5.4；官方 QuickApp 云端构建使用 `aiot-toolkit@2.0.5`。不需要 Rust、cargo、Canopus SDK 或原生模块私钥。

```bash
bun run build:all
bun run verify:all
```

也可以分别执行：

```bash
bun scripts/build-face.mjs
bun scripts/unpack-face.mjs bin/VelaFiles.face
lua5.4 scripts/smoke-test.lua
lua5.4 scripts/bridge-smoke.lua
bun tools/build-companion.mjs
bun tools/verify-companion.mjs
```

产物：

```text
bin/VelaFiles.face
bin/resource.bin
dist/com.deepscan.velafiles.debug.0.4.0.rpk
dist/velafiles-companion.manifest.json
quickapp/file-manager/dist/com.deepscan.velafiles.release.0.4.0.rpk
```

根目录 `.rpk` 仅用于本地结构验证；官方 release 包位于 `quickapp/file-manager/dist/com.deepscan.velafiles.release.0.4.0.rpk`，已由云端 `aiot-toolkit@2.0.5 release` 生成。后续发布应在 `quickapp/file-manager/sign/` 提供自己的 `certificate.pem` 与 `private.pem` 后运行：

```bash
cd quickapp/file-manager
bun run build
bun run release
```

本轮云端验证使用的是临时自签名证书，私钥已从工作区删除且没有进入仓库；它证明官方打包链路可运行，不替代你长期维护的发行证书。

## 安装和测试顺序

1. 安装 `bin/VelaFiles.face` 到小米手环 9 Pro；
2. 打开表盘，先从无关紧要的测试文件开始，确认能进入目录、查看文本、删除文件；
3. 不要先删除系统数据库、OTA 文件、健康数据、日志或正在使用的文件；
4. 安装 `quickapp/file-manager/dist/com.deepscan.velafiles.release.0.4.0.rpk`；如需重新发布，打开 `quickapp/file-manager/`，使用官方 `bun run release` 或 AIoT-IDE 构建并签名；
5. 安装签名后的 RPK，在 `APP` 模式验证轻应用自己的 `internal://files/`；
6. 点击 `SYSTEM`，选择 `/data` 或子目录操作；
7. 看到排队提示后切换到 Lua 表盘（表盘会自动处理，也可以点顶部 `Q`）；
8. 切回轻应用——即使切走时轻应用进程被杀，重新打开也会自动恢复请求并显示结果。

如果桥接目录映射或表盘权限不成立，轻应用会显示失败原因；这不影响表盘单独管理它实际能访问的目录。安装、传输或签名报错时，先确认表盘和 RPK 版本匹配，再按安装工具/视频步骤逐步重试。

## 参考依据

本仓库已重新下载并加载 `vela-ai-skills.zip`，包含：

- `xiaomi-vela-reverse`：Lua/LVGL 文件接口、生命周期和 Vela 文件系统参考；
- `xiaomi-quickapp-dev`：官方 manifest、`@system.file`、工具链与调试参考；
- `openvela-os-dev`：openvela 架构和调试参考。

其中官方文件 API 明确规定 `file.list` 返回 `{ fileList: [{ uri, length, lastModifiedTime }] }`，目录类型需要用 `file.get` 查询；本项目已经按此实现。技能资料记录的 `/data/quickapp/file/{package}` 映射只作为 Lua 文件桥的目标假设，必须真机确认。仓库自带打包器不替代签名工具。

## 安全边界和限制

- Lua 表盘的 `lvgl.fs`、`io`、`os.remove` 受固件权限、挂载和机型限制；每次操作都用 `pcall`，句柄按操作关闭；
- Lua 表盘不使用 `os.execute`、`insmod`、`exec`、Canopus supervisor、原生模块或私钥；
- QuickApp 只使用官方 `@system.file` 沙箱 API 和其内部桥接文件，不直接请求系统 `/data`；
- 桥接是用户确认式的文件交接，不能替代未经证实的自动启动/IPC；
- 删除操作需要确认，Lua 端拒绝根目录，目录不递归；
- 桌面测试覆盖 Lua UI、桥接协议、路径安全、`.face` 容器和 `.rpk` 结构，但不能替代 9 Pro 真机权限/映射测试；
- 当前环境不能证明 9 Pro 固件一定授予 Lua 表盘访问全部 `/data`，也不能把仓库 debug RPK 声称为已签名生产包。
