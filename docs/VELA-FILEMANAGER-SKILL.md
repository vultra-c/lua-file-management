# Vela Files 项目开发规范

> 本文件是当前仓库的项目级 skill，已按 `skills/vela-ai-skills-loaded/` 中的 Vela Lua、QuickApp 和 openvela 参考资料复核。

## 产品结构

- `lua/backend.lua`：Lua 文件系统后端，负责目录列表、文本预览、删除和 QuickApp 请求/响应协议。
- `lua/main.lua`：336×480 Lua 表盘 UI，调用后端，不执行原生模块注入；顶部 `Q` 处理待处理的轻应用请求。
- `quickapp/file-manager/src/`：标准 Vela JS 轻应用，APP 模式管理自己的 `internal://files/`，SYSTEM 模式写入桥接请求并展示 Lua 返回的数据。
- `tools/build-companion.mjs`：生成 ZIP-compatible debug `.rpk`，不替代官方编译器；QuickApp 正式包由 `aiot-toolkit@2.0.5` 生成。

## 已加载的 skill

- `xiaomi-vela-reverse`：Lua/LVGL 生命周期、文件/目录 userdata、Vela `/data` 和挂载参考；
- `xiaomi-quickapp-dev`：QuickApp 项目结构、manifest、`@system.file`、调试和发布流程；
- `openvela-os-dev`：openvela 架构、设备和调试参考。

## 权限边界与桥接模型

1. Lua 表盘和 Vela JS 轻应用是不同运行时，不能互相 `require`。
2. 官方 QuickApp 文件 URI 是应用私有虚拟路径：`internal://files/`、`internal://cache/`、`internal://mass/`、`internal://tmp/`。QuickApp 不能直接把它们改写成任意系统 `/data`。
3. 技能资料记录的物理映射是 `/data/quickapp/file/{package}/`；本项目把 `internal://files/.velafiles-bridge/` 作为轻应用私有请求/响应目录，Lua 端按 `com.deepscan.velafiles` 读取该映射路径。该映射和 Lua 权限是 9 Pro 真机待验证项，不是通用 QuickApp IPC 保证。
4. `launchQuickApp` 只能用于 QuickApp→QuickApp，不能据此推断 QuickApp 能自动启动 Lua 表盘；`system.event` 也不作为 Band 9 Pro 的跨运行时桥接。因此流程是“轻应用排队 → 用户打开表盘处理 → 轻应用读取结果”。轻应用把挂起请求持久化在 `request.txt`，冷启动时会自动恢复并读取 `response.txt`，不依赖进程存活。
5. 请求必须包含 `version=1`、`ready=1`、请求 ID、操作和路径；Lua 端只接受 `/data` 或其子路径，拒绝 `.`、`..`、空字节和其他根目录。
6. 响应写入成功后，Lua 端把请求改为消费标记，避免重启后重放旧的删除请求；下一次 QuickApp 请求覆盖该文件。
7. Lua 后端优先使用 `lvgl.fs.open_dir`、`lvgl.fs.open_file`，每次操作都显式关闭句柄并用 `pcall` 保护；删除受当前进程权限和挂载属性限制。
8. 删除必须经过用户确认；Lua 端拒绝删除 `/` 和 `/data` 根目录，目录操作不递归。
9. Lua 页面要提供 `pageOnPause`/`pageOnResume`，不得在页面退出后继续使用无效 LVGL userdata；后台定时器、动画、topic 和文件句柄必须清理。

## 安装前提

- 先安装 Lua 表盘并用无关紧要的测试文件验证浏览、预览和删除；
- 再用官方 `aiot-toolkit@2.0.5` 或 AIoT-IDE 打开 `quickapp/file-manager/` 项目根目录，执行 `bun run build`/`bun run release`；release 前准备 `sign/certificate.pem` 和 `sign/private.pem`，私钥不得进入仓库；
- 先验证 QuickApp APP 模式，再验证 SYSTEM 模式的请求排队、表盘 `Q` 处理和响应回传；
- QuickApp 的 `/data/quickapp` 映射、Lua 表盘的全局文件权限和最终签名策略都必须在真实 9 Pro 上实测。

## 验证要求

每次修改后至少运行：

```bash
bun --check tools/build-companion.mjs
bun --check tools/verify-companion.mjs
bun scripts/build-face.mjs
bun scripts/unpack-face.mjs bin/VelaFiles.face
lua5.4 scripts/smoke-test.lua
lua5.4 scripts/bridge-smoke.lua
bun tools/build-companion.mjs
bun tools/verify-companion.mjs
cd quickapp/file-manager && bun run build
cd quickapp/file-manager && bun run release  # requires sign/
```
