# 行动清单：从「源码在仓库」到「手环上出现文件管理器」

## 现状

- `canopus-filemanager/` 已 1:1 复刻参考仓库（Canopus-Module-BluetoothAudio）的工程结构，
  业务层是文件浏览 + 删除，目标固件 **3.1.175**（Band 9 Pro）。
- 本地已验证：图标生成 ✅、Lua 安装表盘冒烟测试 6/6 ✅、C 构造器编译 ✅。
- Rust 模块代码已写好（`crates/filemanager-device/`），但**本环境没有 cargo/nightly，
  也没有闭源 Canopus SDK**，无法在这里产出最终 `.bin`。

## 你只需要做 3 件事

### 1. 拿到 Canopus SDK（唯一硬门槛）

参考仓库 `Searchstars/Canopus-Module-BluetoothAudio` 能构建出 `.bin`，
说明构建它只需要两样东西，都在它自己的仓库里或它引用的地方：

- **闭源 SDK**（`vela-science` 的 `canopus` npm 包 / `Canopus` 仓库，AstroBox 团队用的
  就是它）：包含 `sdk/rust/canopus-abi`、`canopus-runtime`、`canopus-target-private`
  （band-9 后端地址在里面）、`targets/*/target.toml`、`build-module-installer-receipt.py`、
  `canopus` CLI。
- **模块安装私钥** `module-installer-ed25519.pem`（AstroBox 签名用；没有它收据无法签名）。

> 找谁要：你朋友/astrobox 团队既然发布了可安装的 Canopus 模块，他们手里就有 SDK 和私钥。
> 把本仓库 `canopus-filemanager/` 给他们看，他们一眼就知道缺什么。

拿到后放到 **本仓库同级目录** `Canopus/`（脚本默认 `../Canopus`），
再装 nightly 工具链：
```bash
rustup toolchain install nightly --component rust-src llvm-tools
rustup target add thumbv8m.main-none-eabihf --toolchain nightly
```

### 2. 构建

```bash
cd canopus-filemanager
sh scripts/build-install-watchface.sh
```
产物在 `watchfaces/filemanager/`：`main.lua` + `filemanager-xiaomi-band-9-pro-3.1.175.bin`
+ `.cmi.bin` + `appicon_filemanager.bin`。脚本会跑全部校验，任何一步失败会停下报错。

### 3. 安装到设备

1. 手环先装 **Canopus Manager**（supervisor，astrobox 发布），装完重启。
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
| 模块能装但列表没图标 | `native-app.register`/`launcher.entry` 能力在 band-9 后端不完整 | 用 SDK 的 target pack 核对，或让 astrobox 补地址 |
| 文件删除被拒 | 固件文件 API 权限 | 在 `fs.rs` 换用系统文件 API（需设备实测） |

## 备选路径（如果永远拿不到 SDK）

- 用你朋友已验证的 **ELF 注入链路**（`insmod` + `lsmod` + `exec`）跑一个自研模块，
  但那就没有原生 UI / 应用列表注册，只能算“有文件管理能力的表盘”，不符合本次目标。
- 或者继续向 astrobox 团队要 SDK —— 他们能做出 Canopus Manager 和蓝牙模块，
  说明 SDK 是存在的，只是没公开。