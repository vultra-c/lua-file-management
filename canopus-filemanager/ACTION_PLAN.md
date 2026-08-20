# 行动清单：从「源码在仓库」到「手环上出现文件管理器」

## 现状

- `canopus-filemanager/` 按参考仓库（Canopus-Module-BluetoothAudio）的公开工程结构移植，
  业务层是文件浏览 + 删除，目标固件 **3.1.175**（Band 9 Pro）。公开源码有该 target profile；
  9 Pro AP 静态逆向已恢复一批地址候选，但没有公开可安装的 supervisor、完整 ABI 验证和签名授权。
- 你本次提供的 Manager `v65537` 与 BluetoothAudio 资源都只发布 `xmb10p`（小米手环 10 Pro `3.101.030/036`）；不能直接用于 9 Pro，也不能改名绕过签名/target 校验。
- 本地已验证：图标生成 ✅、Lua 安装表盘冒烟测试 6/6 ✅、C 构造器编译 ✅。
- Rust 模块代码已写好（`crates/filemanager-device/`），但**本环境没有 cargo/nightly，
  也没有闭源 Canopus SDK**，无法在这里产出最终 `.bin`；而且 9 Pro AP 新证据已修正
  `app_install` descriptor 的布局（app_id=`+0x10`、复制大小=`0x3c`），页面 descriptor
  和 LVX 行 ABI 仍需 target-private SDK/只读探针确认。

## 你只需要做 3 件事

> 逆向工作仍在继续：9 Pro AP 的 `app_install`/LVX/文件 API 地址可以静态恢复，但
> 10 Pro supervisor 样本显示 Canopus 的首次启动仍依赖目标特定的加载入口。没有 9 Pro
> supervisor 或新的运行时证据前，不要安装任何 10 Pro `.ko`。

### 1. 先拿到 9 Pro 专用 Canopus 运行时或官方代签

公开的 `Searchstars/Canopus-Module-BluetoothAudio` 只能证明源码仓库声明了
`xiaomi-band-9-pro-3.1.175` profile；它的生产安装表盘实际只打包 10 Pro
`3.101.030/036`，且 `FIRMWARE_PARITY.md` 的真机验证也只覆盖 10 Pro。仓库自己的
`re/scripts/apscan.mjs` 已可从 9 Pro AP 恢复静态 API 候选，但这还不是可安装载荷。

请向 AstroBox/模块作者确认并提供以下任一套正式支持：

- 9 Pro `3.1.175` 的 Canopus supervisor/Manager 及其安装表盘；
- 9 Pro 对应的 `canopus-target-private`、target `target.toml`、`canopus verify` 和 SDK；
- 对本项目 `file_manager` 模块进行官方签名的开发收据/安装包（不需要把私钥放进仓库）。

如果对方确实提供完整 SDK，再把它放到本仓库同级目录 `Canopus/`（脚本默认 `../Canopus`），
并安装 nightly 工具链：
```bash
rustup toolchain install nightly --component rust-src llvm-tools
rustup target add thumbv8m.main-none-eabihf --toolchain nightly
```

不要把 10 Pro 的 Manager 或 BluetoothAudio 二进制改名后安装到 9 Pro。

### 2. 构建

```bash
cd canopus-filemanager
sh scripts/build-install-watchface.sh
```
产物在 `watchfaces/filemanager/`：`main.lua` + `filemanager-xiaomi-band-9-pro-3.1.175.bin`
+ `.cmi.bin` + `appicon_filemanager.bin`。脚本会跑全部校验，任何一步失败会停下报错。

### 3. 安装到设备

1. 手环先装与 **9 Pro 3.1.175** 匹配的 Canopus Manager/supervisor；当前公开的 `v65537` 仅支持 10 Pro，不能用于本机。安装后重启。
2. 把 `watchfaces/filemanager/` 打包成表盘安装包，用 Zepp/小米运动健康 App 装到
   手环 → 表盘自动执行 CPC2 INSTALL（固件检测 → stage 图标/收据/模块 → 安装请求）。
3. 打开 **Canopus Manager → 模块列表 → 启用 file_manager**（默认禁用，安全策略）。
4. 回应用列表，应该能看到 **Files** 图标 → 打开即原生 UI 文件管理器。

## 如果某一步卡住

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `insmod`/`/dev/canopus` 不存在 | 没装 Canopus Manager | 先装 supervisor |
| `build-module-installer-receipt.py` 找不到 | SDK 没放对位置 | 确认 `../Canopus` 结构 |
| 收据签名失败 | 没有私钥 | 向 astrobox 要 `module-installer-ed25519.pem` |
| 模块能装但列表没图标 | `native-app.register`/`launcher.entry` 能力在 band-9 后端不完整，或 descriptor 偏移不匹配 | 用 SDK 的 target pack 核对，或让 astrobox 补地址 |
| 文件删除被拒 | 固件文件 API 权限 | 在 `fs.rs` 换用系统文件 API（需设备实测） |

## 备选路径（如果永远拿不到 SDK）

- 用你朋友已验证的 **ELF 注入链路**（`insmod` + `lsmod` + `exec`）跑一个自研模块，
  但那就没有原生 UI / 应用列表注册，只能算“有文件管理能力的表盘”，不符合本次目标。
- 或者继续向 astrobox 团队要 SDK —— 他们能做出 Canopus Manager 和蓝牙模块，
  说明 SDK 是存在的，只是没公开。

## 当前逆向阶段（不需要你立刻提供新文件）

我会继续只读分析 9 Pro AP，优先恢复：

1. NuttX `open/read/write/close/unlink` 的可调用地址和参数约定；
2. `app_install` 的完整页面数组/生命周期布局；
3. LVX 行、事件和导航函数的调用关系；
4. 与 10 Pro supervisor 绝对入口对应的 9 Pro target record 候选。

如果你愿意做设备侧配合，下一次只需安装现有安全表盘并点击 `i → DUMP`，把
`/data/deepscan_dump.txt` 发回即可；不要点击 `INJECT`，不要安装 10 Pro supervisor，
也不要执行本报告中的候选地址。