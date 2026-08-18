# 文件管理器原生应用（Canopus 模块）— 构建与安装

本目录是从 `Searchstars/Canopus-Module-BluetoothAudio` 1:1 复刻的 Canopus 模块工程，
业务层换成**文件浏览 + 删除**。目标：小米手环 9 Pro，固件 **3.1.175**
（`xiaomi-band-9-pro-3.1.175`，参考仓库已内置该 target）。

## 目录结构

```
canopus-filemanager/
├── Canopus.toml                        # 模块声明（生命周期、能力、native_app）
├── Cargo.toml                          # workspace（panic=abort, opt-level=z, fat LTO）
├── .cargo/config.toml                  # thumbv8m.main-none-eabi rustflags
├── targets/xiaomi-band-9-pro-3.1.175.env   # target 选择（与参考仓库逐字节一致）
├── crates/filemanager-device/
│   ├── Cargo.toml                      # staticlib + target feature
│   ├── c_shim/canopus_ctor.c           # 构造函数 glue（无 codec，单遍链接）
│   └── src/
│       ├── lib.rs                      # 导出入口
│       ├── module.rs                   # 模块生命周期 + 命令分派
│       └── target/
│           ├── mod.rs                  # target 协调器
│           ├── fs.rs                   # 文件系统抽象（list/stat/delete）
│           ├── runtime.rs              # 状态机
│           ├── ui.rs                   # UI 语义模型
│           ├── native_app.rs           # 应用注册
│           └── ui_backend.rs           # LVX 渲染后端（band-9 分支）
├── sdk-stubs/                          # 本地 cargo check 用的 SDK 桩（非真实 SDK）
├── scripts/
│   ├── build-device.sh                 # 构建 + 链接 + 校验模块
│   ├── link-device.sh                  # 单遍 ld.lld -r 链接
│   ├── verify-device.sh                # 加载映像大小 + 未定义符号校验
│   ├── build-install-payload.sh        # 构建 + CMI1 签名收据
│   ├── build-install-watchface.sh      # 组装安装表盘 + 全量校验
│   ├── gen-appicon.mjs                 # 117×117 ARGB8888 图标生成（54768 B）
│   └── smoke-watchface.lua             # Lua 冒烟测试（lua5.4，已通过 6/6）
└── watchfaces/filemanager/
    ├── main.lua                        # 一次性安装表盘（CPC2 INSTALL）
    └── appicon_filemanager.bin         # 生成的 launcher 图标
```

## 前置条件（你需要在有 Canopus SDK 的机器上做）

1. **拿到闭源 Canopus SDK**（`vela-science` 的 `canopus` 包，或 AstroBox 团队的 SDK）：
   - 把 SDK 放到本仓库**同级**目录 `Canopus/`（即 `../Canopus`，脚本默认路径）。
   - SDK 需包含：`sdk/c/`（C 头）、`sdk/rust/canopus-abi`、`sdk/rust/canopus-runtime`、
     `sdk/rust/canopus-target-private`（含 `target-xiaomi-band-9-pro-3-1-175` feature）、
     `targets/<target>/target.toml`（含 `firmware_sha256`）、`scripts/build-module-installer-receipt.py`、
     `target/debug/canopus` CLI。
   - 本仓库的 `sdk-stubs/` 只是本地 `cargo check` 占位，**不能**用于真机。
2. **nightly Rust + thumbv8m.main-none-eabihf target**：
   ```bash
   rustup toolchain install nightly --component rust-src llvm-tools
   rustup target add thumbv8m.main-none-eabihf --toolchain nightly
   ```
3. **模块安装私钥**：`$CANOPUS/.canopus-local/module-installer-ed25519.pem`
   （AstroBox 私钥；没有它无法生成合法 CMI1 签名收据）。
4. **设备端**：手环必须先装 **Canopus Manager**（supervisor，AstroBox 团队发布），
   否则 `/dev/canopus` 不存在，表盘会提示 “Canopus Manager is not installed”。

## 构建与安装

```bash
# 1) 构建 + 签名载荷（模块 + 收据）
sh scripts/build-install-payload.sh

# 2) 组装安装表盘（含 Lua 冒烟测试 + 产物校验）
sh scripts/build-install-watchface.sh

# 3) 把 watchfaces/filemanager/ 打包成表盘安装包（.bin），
#    通过 Zepp/小米运动健康 App 安装到手环；表盘会自动执行 CPC2 INSTALL。
```

## 已验证 / 未验证

- ✅ `scripts/gen-appicon.mjs`：生成 54768 B 图标，头 `19 10 00 00 | 117 | 117 | 468 | 0`。
- ✅ `scripts/smoke-watchface.lua`：lua5.4 下 6/6 通过（happy path 安装 + 不支持的固件）。
- ✅ `c_shim/canopus_ctor.c`：arm-none-eabi-gcc 编译通过。
- ⚠️ Rust 侧：本环境无 cargo/rustup/nightly，`crates/filemanager-device` 未在真 SDK 上
  编译验证；`sdk-stubs/` 里是本地占位桩。拿到 SDK 后按上文构建。
- ⚠️ 真机行为（能否出现在应用列表、原生 UI 渲染、删除文件权限）取决于闭源
  `canopus-target-private` 的 band-9 后端地址，需设备实测。

## 关键机制（参考仓库佐证）

- 模块是 **ET_REL ELF**，由固件 modlib 经 `insmod` 加载；`canopus_module_descriptor`
  是入口符号，构造函数注册描述符。
- 安装走 **CPC2 INSTALL**（`/dev/canopus` 写 36 字节头 + payload，读回校验），
  收据是 **CMI1**（256 B：magic/version/header/lifecycle/module_version/artifact_size/
  module_id/target_id/firmware_sha256/module_sha256/签名）。
- 表盘是**一次性安装器**：检测固件版本 → 校验并 stage 图标/收据/模块到
  `/data/canopus/` → CPC2 请求安装 → 提示去 Canopus Manager 启用模块。