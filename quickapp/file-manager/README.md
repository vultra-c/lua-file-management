# Vela Files companion QuickApp

这是与 `lua/main.lua` 配套的 Xiaomi Vela JS 轻应用源码，目标设备类型为 `watch`。

## 两种工作模式

### APP：轻应用私有文件

- 使用官方 `@system.file` API 访问当前轻应用自己的 `internal://files/` 沙箱；
- 使用 `file.list` 列表、`file.get` 判断目录、`file.readText` 预览文本；
- 使用 `file.delete` 删除文件、`file.rmdir({ recursive: false })` 删除空目录；
- 调用前使用 `@system.app.canIUse` 探测接口，不支持时显示明确提示。

### SYSTEM：Lua 表盘代理访问 `/data`

轻应用不能直接把 `internal://files/` 当成系统 `/data`。本项目采用一个明确的文件交接协议：

1. 轻应用把 `LIST`、`READ` 或已确认的 `DELETE` 请求写入自己的：
   `internal://files/.velafiles-bridge/request.txt`；
2. 按技能包记录的 Vela 文件系统映射，Lua 表盘尝试从：
   `/data/quickapp/file/com.deepscan.velafiles/.velafiles-bridge/request.txt`
   读取请求；
3. Lua 表盘使用自己的 `lvgl.fs`/Lua 文件权限访问系统 `/data`，把结果写入同一映射目录的 `response.txt`；
4. 轻应用轮询自己的 `internal://files/.velafiles-bridge/response.txt`，解析列表、预览或删除结果。

挂起请求是持久化的：切到表盘期间轻应用进程可能被杀，但 `request.txt` 仍在；重新打开轻应用时会自动从 `request.txt` 恢复挂起状态、读取 `response.txt` 并直接显示结果，不需要再次排队。

桥接请求带有版本号、请求 ID、`ready=1` 和操作类型；Lua 端只接受 `/data` 及其子路径，拒绝 `.`、`..`、空字节和其他根目录。处理完成后会写入消费标记，避免 Lua 状态重启时重复执行旧请求。

## 重要限制

- `launchQuickApp` 只证明 QuickApp→QuickApp 跳转，不能证明 QuickApp 能启动 Lua 表盘；因此当前流程需要用户在轻应用和表盘之间切换一次，不能假装自动跳转已经存在；
- `system.event` 在技能资料的 Band 9 Pro 支持矩阵中不作为可用的跨运行时通道；本项目不使用未知事件、原生 URI 或 Canopus；
- `/data/quickapp/file/{package}` 的物理映射、Lua 表盘是否能读取/写入该目录，以及表盘是否能访问目标 `/data` 子目录，都必须在真实 9 Pro 上验证；
- 如果映射或权限不成立，轻应用会保留明确的失败提示，Lua 表盘本身仍可独立浏览和删除其能访问的文件；
- 删除前轻应用会确认，Lua 端仍会拒绝删除 `/` 和 `/data` 根目录；目录删除不递归。

## 设备使用流程

1. 安装并打开 `bin/VelaFiles.face`，先用无关紧要的测试文件验证 Lua 表盘的浏览、预览和删除；
2. 直接安装已由云端官方 toolkit 生成的 `quickapp/file-manager/dist/com.deepscan.velafiles.release.0.4.0.rpk`；如需重建，用 AIoT-IDE 或仓库内 `bun run release`；
3. 安装签名后的轻应用，先在 `APP` 模式验证自己的 `internal://files/`；
4. 点击 `SYSTEM`，选择要访问的 `/data` 路径或操作；
5. 看到排队提示后切换到 Lua 表盘（表盘启动/恢复时自动处理请求，也可以点击顶部 `Q`）；
6. 切回轻应用：即使进程在切走时被杀，重新打开也会自动恢复请求并显示结果。

不要先操作系统数据库、OTA 文件、健康数据、日志或正在使用的文件。传输和安装出现错误时，先确认表盘/轻应用版本匹配，并按设备端安装步骤逐步重试。

## 源码结构

```text
quickapp/file-manager/
├── README.md
├── package.json
└── src/
    ├── manifest.json
    ├── app.ux
    └── pages/files/files.ux
```

正式开发时请用 AIoT-IDE 打开包含 `src/` 的项目根目录，而不是只打开 `src/`。

## 本地结构包、云端构建与正式签名

仓库内的 `bun tools/build-companion.mjs` 会生成根目录 ZIP-compatible debug `.rpk`，并由 `tools/verify-companion.mjs` 校验 manifest、桥接协议标记、PNG 图标和 ZIP 结构。它用于源码/结构回归，不是官方签名器。

本项目已在云端验证官方 `aiot-toolkit@2.0.5`：

```bash
cd quickapp/file-manager
bun run build
bun run release
```

正式 release 需要项目根 `sign/certificate.pem` 与 `sign/private.pem`。本轮为了验证云端链路临时生成了自签名证书，release 包已保留，但临时私钥已删除且不会提交。长期发布请使用你自己保存的同一套证书，以便后续更新包保持签名一致；也可以在 AIoT-IDE 的发布流程中生成签名文件。
