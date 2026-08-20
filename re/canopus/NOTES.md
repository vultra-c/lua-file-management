# Canopus 路线核对 — 来自 Searchstars/Canopus-Module-BluetoothAudio 的公开线索

> 来源：<https://github.com/Searchstars/Canopus-Module-BluetoothAudio>
> 分析时间：2026-08-14
> 结论先行：**这个仓库公开了 Canopus 的工程形状、协议线索和部分 target 配置，但没有公开 9 Pro 可运行的 supervisor、完整私有 ABI、签名授权或真机验证载荷。**
> 9 Pro AP 的后续静态分析已经补出一批函数候选；这些是研究线索，不是可安装的 9 Pro target pack。
>
> 后续更新：公开接口与固件证据的阶段性还原稿见 [`SPEC.md`](./SPEC.md)；
> 「整个逆向」的边界与官方快应用替代路线见 [`VERDICT.md`](./VERDICT.md)。

---

## 一、这个仓库给了我们什么（公开工程线索，非完整运行时）

它是一个 Canopus 原生应用范例（蓝牙音频），可以帮助我们理解模块目录、安装表盘、协议字段和 UI 业务结构；但其中依赖的 supervisor、target-private ABI、签名链和生产载荷不能据此视为已获得：

### 1. 设备端安装链（=「安装表盘」概念，与 DeepScan 现有表盘同构）

`watchfaces/bluetooth-audio/main.lua` 是**一次性安装表盘**，流程与我们的 Lua 表盘完全一致：

```
表盘 Lua（lvgl + io.open，全权限）
  ├─ 把 receipt.bin（256B，魔数 "CMI1"=0x31494D43）写到 /data/canopus/inbox/<token>.cmi
  ├─ 把 module.bin（ARM ELF）写到 /data/canopus/inbox/<token>.ko
  ├─ io.open("/dev/canopus","wb") 写入 CPC2 INSTALL 请求（魔数 "2CPC"=0x43504332，含模块 token）
  └─ io.open("/dev/canopus","rb") 读回 CPC2 响应（u32 result，5=COMPLETED）
```

关键点：

- **不是 `insmod`/`lsmod`/`exec`**（本机零售固件没有 modlib，第七轮已定案），而是走
  **`/dev/canopus` 字符设备** —— 由常驻 **Canopus supervisor** 提供。
- supervisor 校验 CMI1(Ed25519) 签名 + target/firmware 身份 + 模块 SHA-256，然后**注册为
  “已安装、默认禁用”的模块**。
- 前置：设备必须先装 `watchfaces/canopus-installer`（Canopus 框架自带），打开后 **LOAD 一次 +
  INSTALL 一次**，`/dev/canopus` 才存在。装好后需在 Canopus Manager 里启用模块并重启。

### 2. 原生应用注册（= 出现在应用列表的核心，`target/native_app.rs`）

模块通过私有 ABI 直接调固件：

```c
app_install(launcher_app_descriptor*, firmware_page_descriptor**, u32 page_count);
app_lookup(u16 app_id);                 // 校验已注册
launcher_add(u16 app_id);               // 把条目写进 Launcher
```

`launcher_app_descriptor` 结构（已逐字段公开）：

```c
package_name             // 如 "com.canopus.headphones\0"
launcher_icon_resource   // 如 "/resource/app/launcher/flashlight.bin\0"（复用系统图标！）
app_id                   // u16，固定 id（示例 0x00CB）
launcher_metadata_callback  // 返回显示名（"Headphones\0"）的函数指针
```

`firmware_page_descriptor` 结构：

```c
page_name    // 页面名
page_id      // u16
app_id       // u16
on_signal / on_create / on_resume / on_pause / on_destroy   // 页面生命周期回调
```

**两阶段发布（重要，避免 re-enter）**：

- stage 1：`app_install()` —— 注册应用 + 页面；
- stage 2：`launcher_add()` —— 应用列表条目（在 miwear 处理完 app-registry 事件之后单独提交）。

### 3. 系统原生 UI（LVX 渲染层，`target/ui_backend.rs`，含 band-9 专属分支）

这直接回答了「系统原生 UI 怎么调」。band-9-pro-3.1.175 的 `#[cfg(feature = "target-xiaomi-band-9-pro-3-1-175")]` 分支明写：

- **band-9 没有 `lvx_content_create`**：页面根对象 `root` 本身就是内容父节点，尺寸由系统页面壳固定；
- 行工厂签名与 band-10 不同：`lvx_list_row_create(parent, primary)` 两个参数，再用
  `lvx_list_row_set_trailing(row, kind, 0)` 挂尾部控件（band-9 常量：switch=1、前向箭头=12）；
- 其它 LVX 调用：`lvx_page_title_create / lvx_label_create / lvx_label_set_text /
  lvx_style_apply(STYLE_MISANS_DEMIBOLD_32) / lvx_set_hidden / lvx_align_to /
  lvx_event_add / lvx_event_get_code / lvx_event_get_user_data / lvx_timer_create`；
- 导航：`activity_navigate(key,0,0,0)`、`activity_finish(page_descriptor)`。

也就是说：公开源码展示了**列表行、标签、页标题、返回、点击事件、定时刷新**的调用意图和 band-9 分支；但实际函数地址、参数 ABI、线程上下文以及 supervisor 仍需固件静态分析或设备只读验证。文件管理器的业务层可以参考蓝牙设备行，但不能直接把源码编译成可安装模块。

### 4. 模块 ABI（`target/module.rs` + `c_shim/canopus_ctor.c`）

- 导出静态描述符 `canopus_module_descriptor: ModuleDescriptorV1`（含 `prepare/activate/
  deactivate/stop/query/publish_native_app/publish_native_app_stage` 六个生命周期回调 +
  `FLAG_HAS_NATIVE_APP | FLAG_NATIVE_APP_STANDALONE | FLAG_REGISTERS_LAUNCHER_ENTRY |
  FLAG_REQUIRES_UI_DISPATCHER` 标志位）；
- C 构造器 `canopus_mod_ctor` 里 `canopus_mod_prepare(0)` + `canopus_register_module_descriptor()`；
- `canopus_register_module_descriptor()` 把 `ModuleRegistrationV1 { magic:"CMR1", descriptor, module_id }`
  写进 `/dev/canopus`（`nuttx_open(path, 2 /*O_WRONLY*/)` → `nuttx_write` → `nuttx_close`）。

### 5. 我们这台设备的 target（关键）

`targets/xiaomi-band-9-pro-3.1.175.env`：

```
RUST_TARGET_FEATURE=target-xiaomi-band-9-pro-3-1-175
RUST_TARGET_TRIPLE=thumbv8m.main-none-eabihf
RUST_TARGET_CPU=cortex-m33
```

与实机固件 **3.1.175** 的 target profile 名称对上。band-9 的 LVX 分支和行工厂差异已经在公开源码中声明，但这只能证明源码保留了构建目标，不能证明 AstroBox 已发布可用的 9 Pro target pack、supervisor 或符号地址表。本轮 AP 静态扫描已独立恢复一批候选地址，但尚未完成 ABI/真机验证。

---

## 二、仍然关闭的部分（硬依赖，不靠逆向）

`crates/bluetooth-audio-device/Cargo.toml` 里这些依赖指向 **相对路径**：

```toml
canopus-abi             = { path = "../../../Canopus/sdk/rust/canopus-abi" }
canopus-runtime         = { path = "../../../Canopus/sdk/rust/canopus-runtime" }
canopus-ui-core         = { path = "../../../Canopus/sdk/rust/canopus-ui-core" }
canopus-target-private  = { path = "../../../Canopus/sdk/rust/canopus-target-private" }
```

它们都来自 `github.com/AstralSightStudios/Canopus`（当前 404，闭源）。其中：

- `canopus-abi / canopus-runtime / canopus-ui-core`：**公开 ABI 类型/状态机/语义模型**（结构在
  本仓库源码里基本能反推出来）；
- `canopus-target-private`：源码引用的**每固件符号地址表和私有调用封装**（`app_install`、
  `launcher_add`、`lvx_*`、`nuttx_open`、`canopus_identity_guard` 等）。公开仓库没有这部分内容；
  本轮从 9 Pro 明文 AP 恢复了部分静态候选，但完整 ABI、supervisor 入口和身份校验仍未闭环。

另有三个构建期产物也只在闭源 Canopus 仓库里（见 `scripts/build-install-watchface.sh`）：

1. `Canopus/targets/<target-id>/target.toml` —— `firmware_sha256`（CMI1 收据要锁它）；
2. `Canopus/target/debug/canopus verify` —— ELF 校验器 CLI；
3. `Canopus/.canopus-local/module-installer-ed25519.pem` —— 本地开发签名私钥
   （`build-module-installer-receipt.py` 用它签 CMI1 收据）。

---

## 三、需要向 AstroBox 要的清单（精确、可整句转发）

1. **`github.com/AstralSightStudios/Canopus` 仓库访问权**（最省事：整仓看，我们自己拉
   `canopus-target-private` 的 `target-xiaomi-band-9-pro-3-1-175` 后端 + `canopus` 校验器 +
   签名脚本）。
2. 若不便开整仓，则单独给：`targets/xiaomi-band-9-pro-3.1.175/`（target pack + `target.toml`）、
   `canopus` 校验器二进制、`canopus-installer` 与 `canopus_hello` 两个安装表盘、以及一个
   **开发签名私钥**（或请他们代签 CMI1 收据）。
3. 说明「supervisor 怎么刷进本机」的官方步骤（AstroBox-NG / `abtools.py init --private`）。

> 注意：`Canopus.toml` 里注明 `identity-guard` 是公开 target pack 就有的，而
> `native-app.register / launcher.entry / ui.dispatch` 属“需设备校验”的 target-private 调用。
> 所以**即使拿到仓库，也要确认 band-9-pro-3.1.175 的 target pack 里这几个能力是完整的**，
> 而不是只有 identity-guard。

---

## 四、拿到 SDK 后的落地计划（文件管理器原生应用）

基本不用再逆向，照抄 BluetoothAudio 结构、换掉业务层即可：

```
Canopus.toml            # module id=org.canopus.filemanager, native_app { app_id, name="Files", entry=... }
crates/filemanager-device/
  src/module.rs         # canopus_module_descriptor + CMR1 注册（照抄）
  src/target/native_app.rs  # app_install + launcher_add，PAGE_COUNT=1（单页文件列表）
  src/target/ui_backend.rs  # LVX：lvx_list_row_create 一行一个文件/目录（band-9 分支）
  src/target/runtime.rs     # 静态状态机（把蓝牙状态换成文件浏览游标/当前目录）
  c_shim/canopus_ctor.c     # C 构造器（照抄）
watchfaces/filemanager/main.lua  # 一次性安装表盘：stage receipt.bin + module.bin → CPC2 INSTALL
targets/xiaomi-band-9-pro-3.1.175.env  # 直接复用
```

文件浏览/删除逻辑复用现有 DeepScan 表盘已验证的能力（`lvgl.fs`/`io.open`/`os.remove` 读写的
真实路径），但渲染改为 **LVX 系统原生列表**，条目经 `launcher_add` 注册后**出现在应用列表**，
图标直接复用系统资源 `/resource/app/launcher/...`。

---

## 五、与现有 DeepScan 工作的关系（一句话）

- DeepScan 表盘（已交付）继续可用：Lua 文件浏览 + 删除，但只在表盘选择器里。
- 第七轮「本机无 modlib、`insmod` 路线关闭」的结论**依然正确**，但与本路线无关——Canopus 走
  `/dev/canopus` 监督器，不依赖零售固件的 modlib。
- 本仓库现在把公开源码线索与 9 Pro AP 静态证据分开记录：API 意图和 band-9 分支可参考，
  但 descriptor 布局、页面回调、LVX 行 ABI、supervisor 加载通道和签名链仍不能视为已验证。

---

## 六、2026-08-20 静态证据修正

9 Pro `3.1.175` OTA 外层 ZIP 中存在可解压的明文 `vela_ap.bin`（7,774,696 B，SHA-256
`4f43b325addd6d9e6e7c7e2a4d00ffe3f23d5fb1560d8fe503544002ac1f516b`）。因此“地址表只能从加密 AP 获取”这一早期结论已收窄：可以继续从 AP 做只读静态分析。

当前已恢复的候选包括 `app_install=0x2c44b5d0`、`app_lookup=0x2c449334`、
`app_launcher_add=0x2c2a7cb8`、`lvx_page_title_create=0x2c2783c8`；同时确认
`app_install` 连续复制 `0x3c` 字节，`app_id` 读取位置为 descriptor `+0x10`。

但 10 Pro supervisor 样本明确负责注册 `/dev/canopus`、校验 CMI1/Ed25519 并调用 target-specific
加载入口，而 9 Pro AP 静态镜像未出现这些 supervisor/modlib 标记。故以上地址只能作为后续
静态研究输入，不能直接调用、写入 `.ko` 或生成可安装 9 Pro Canopus。