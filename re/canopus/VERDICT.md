# Canopus「整个逆向出来」的最终判定

> 原始记录日期：2026-08-14；静态逆向更新：2026-08-20
> 当前判定：**公开源码、协议线索和 9 Pro AP 的部分静态入口已经恢复，但完整 Canopus 运行时仍未闭环。**
> 早期“接口面 100% 完成、地址只能从加密 AP 获取”的表述已被本轮证据收窄：现在可以继续静态分析明文 AP，
> 但 supervisor、真实私有 ABI、签名授权和首次加载通道仍是独立硬门槛。

---

## 一、“逆向 Canopus”到底在逆什么

拆开看仍然是四块，但完成度不同：

| 块 | 内容 | 当前状态 |
| --- | --- | --- |
| A. 模块 ABI | `ModuleDescriptorV1`、CMR1 注册、生命周期、flags | 公开源码线索已整理；真实 SDK/加载器 ABI 未验证 |
| B. 应用列表注册 | `app_install / app_lookup / launcher_add`、descriptor、两阶段发布 | 9 Pro AP 已有静态候选；descriptor 完整布局和调用 ABI 未闭环 |
| C. 原生 UI | LVX 调用和 band-9 分支 | 公开源码 + AP 静态候选；行控件、事件、导航 ABI 未闭环 |
| D. 安装协议 | CMI1 收据、CPC2 INSTALL、CPC1 错误查询 | 10 Pro 样本行为已分析；9 Pro supervisor/签名通道缺失 |

因此 `SPEC.md` 是**公开接口和当前证据的阶段性还原稿**，不是可直接生成 9 Pro 载荷的完整 SDK。

---

## 二、卡住的三样东西（都不是“逆向”，是访问权）

1. **`canopus-target-private`：每个固件的符号地址表**
   `app_install / launcher_add / app_lookup / lvx_* / nuttx_open / canopus_identity_guard`
   这些函数在 `vela_ap.bin` 里的真实地址。**这是唯一真正“按固件逆向”出来的部分**，
   而早期提取路径看到的 9 个 `ZZZ~` 子镜像是高熵载荷；但 2026-08-20 已从同一 OTA 外层 ZIP
   找到可解压的明文 `vela_ap.bin`，因此符号地址可以通过只读静态分析逐步恢复。
   - 当前已得到 `app_install`、`app_lookup`、`app_launcher_add`、`lvx_page_title_create` 等候选地址；
   - 这些候选仍缺参数、线程上下文和 supervisor 配套，不能直接当作 target-private SDK 使用。

2. **Ed25519 签名私钥 + `canopus` ELF 校验器**
   CMI1 收据要签名、模块要过校验器，这两样只在闭源 Canopus 仓库里。没有它们，
   就算写出了模块，监督器也不收。

3. **监督器本体 + 它的安装表盘**
   `/dev/canopus` 由常驻监督器提供；先得用 `canopus-installer` 表盘 LOAD+INSTALL 一次，
   `/dev/canopus` 才存在。监督器二进制、安装表盘、刷入步骤都在闭源仓库。

**一句话：Canopus 不在固件里，它是 AstroBox 的私有运行时。9 Pro AP 的静态地址和部分调用关系还可以继续逆向；但私钥、9 Pro supervisor、首次加载通道以及完整运行时 ABI 不是仅凭当前仓库就能证明或获得的东西。**

---

## 三、顺带辟谣：`vela-science/*` 与 Canopus 无关

用户之前给的三个链接（`github.com/vela-science/vela`、`npm @vela-science/canopus`）已核实：
- `vela-science` 是一个**开放科学 / 科学版本控制**组织（topics: event-sourcing、open-science、
  provenance、reproducibility、verification），`vela` 是他们的“科学状态版本控制”产品，
  **不是小米 Vela OS**。
- `@vela-science/canopus`（v0.4.x~0.8.0）是一个 Node.js **研究工具 CLI**（"research harness over
  released Vela interfaces"），license Apache-2.0/MIT，**与手环表盘注入的 Canopus SDK 同名无关**
  （Canopus 与 Vela 都是恒星/星座名，撞名而已）。
- 真正的 SDK 是 `AstralSightStudios/Canopus`（当前 404 / 私有）。已枚举该组织全部公开仓库，
  只有 2021 年的 C# 废弃项目和若干测试仓，**没有 SDK、没有 target pack、没有私钥**。

---

## 四、真正的发现：官方 Vela 快应用（快应用 / QuickApp）路径

`Searchstars/AstralIME`（GPL-3.0）—— 你朋友团队自己 2024 年就开源了一个：
**它是用官方 Vela 快应用框架写的第三方输入法**，结构：

```
src/app.ux                 # 应用生命周期
src/manifest.json          # package / name / deviceTypeList:["watch"] / router
src/pages/*/*.ux           # 页面（.ux = 模板+样式+脚本）
dist/com.astralsightstudios.vela.astralime.debug.1.0.0.rpk   # 产物
```

`manifest.json` 关键字段：`minPlatformVersion: 1000`、`designWidth: 480`、`router.entry`、
`features: ["system.router", "system.record"]`。官方文档：
**https://iot.mi.com/vela/quickapp**。

这意味着：**“出现在应用列表 + 系统原生 UI + 真实应用”这件事，官方快应用框架原生支持，
开源、有现成例子（AstralIME）、不需要 Canopus、不需要签名私钥、不需要刷监督器。**
这正是最初目标（文件管理作为轻应用出现在应用列表、用系统原生 UI）的正规做法。

⚠️ 唯一要核实的一点：快应用跑在 JS 运行时里，**文件系统访问能力**取决于框架是否暴露
`@system.file` 之类 API（AstralIME 只用了 `system.router`/`system.record`）。这需要在官方文档里
确认，或直接写个最小快应用在设备上试 `@system.file` / `@system.storage`。

---

## 五、给 AstroBox 的清单（若仍坚持 Canopus 路线）

1. `github.com/AstralSightStudios/Canopus` 仓库访问权（最好整仓）；
2. 不便开仓则单独给：`targets/xiaomi-band-9-pro-3.1.175/` target pack + `target.toml`、
   `canopus` 校验器、`canopus-installer` / `canopus_hello` 安装表盘、一个**开发签名私钥**（或代签）；
3. 监督器刷入本机（3.1.175）的官方步骤。

拿到后我可以直接照 `SPEC.md` 把 `bluetooth_audio` 换成文件管理器（`lvx_list_row_create`
一行一个文件/目录、删除复用 `os.remove`），产出“应用列表出现 + 原生 UI + 浏览删除”的文件管理器。

---

## 六、建议的下一步（二选一）

- **A（推荐，官方且立即可做）**：改走 Vela 快应用。我先验证 `@system.file` 能力，
  然后照 AstralIME 结构写文件管理器快应用。
- **B（保留 Canopus）**：先拿到 §五 的 SDK/授权，我再落地 `SPEC.md` 里的文件管理器原生模块。

---

## 七、AstroBox 资源来源与获取渠道核实（2026-08-15）

用户追问“AstroBox 的资源从哪来、能不能自己拿”。核实结果：

### 来源

| 部分 | 真实来源 |
| --- | --- |
| 接口/ABI/UI/安装协议 | AstroBox 团队自己写的，就公开在 `Searchstars/Canopus-Module-BluetoothAudio`（已还原进 SPEC.md） |
| target pack 符号地址 | **逆向固件**得来——BES2700iMP 那条公开路线（atc1441 的 `MiBand10-BES2700iMP-BEST1503-Hacking` 已证明可行：dump 固件 → Ghidra 反汇编 → 定位 `app_install`/`launcher_add`/`lvx_*`） |
| 签名私钥 + 监督器 | AstroBox 自己生成/自己写的**私有运行时**，不在任何公开渠道 |

### 获取渠道核查（全部落空）

- **crates.io**：搜 `canopus` 只有“Codeowners 校验器”和 `vela-science` 的占位 crate，**无** `canopus-abi / canopus-runtime / canopus-ui-core / canopus-target-private`。
- **npm**：搜 `canopus` 全是撞名/无关包（`@zauto/canopus`、`@vela-science/canopus` 等），**无** SDK。
- **全网代码搜索**：`"canopus-target-private"` / `"canopus-abi"` 零命中，**无公开镜像/泄漏**。
- **astrobox.online**：官方站只有 App 下载与社区资源，**无** SDK/target pack 分发页。
- **GitHub org**：`AstralSightStudios` 下只有 `AstroBox-Public`（Tauri 工具箱）与 `AstroBox-NG-Plugin-*`，`Canopus` 仓库 404/私有。

### 结论

三样缺的东西里，只有“符号地址表”理论上能靠自己逆向固件补（周级 Ghidra 工程，且卡 OTA 解密或需 SWD 硬件 dump）；**私钥 + 监督器是别人闭源运行时，任何公开渠道都拿不到，也不是“逆向”能产出的对象**。因此方案 B 的硬依赖就是 AstroBox 的访问权，无法绕过。

（另有一条公开正路可作为备选：atc1441 的 BES2700iMP 开源固件 SDK——但那是“刷自制固件”级别，风险与工程量更高，不属本次目标。）

## 八、2026-08-20 静态逆向修正

此前“地址表锁在加密 `vela_ap.bin` 中、仅凭固件无法静态得到”的结论需要收窄：
`fwextract.mjs` 取到的 `ZZZ~` 表项仍是高熵载荷，但同一个 OTA 外层 ZIP local entry
还含有一份可解压的明文 AP。通过 `re/scripts/apscan.mjs`，已经得到 9 Pro 3.1.175
的第一批静态候选：

- `app_install = 0x2c44b5d0`；
- `app_lookup = 0x2c449334`；
- `app_launcher_add = 0x2c2a7cb8`；
- `lvx_page_title_create = 0x2c2783c8`。

这意味着“自己逆向出 target-private 地址”从理论障碍变成了可继续推进的静态分析工程。
但原判定中的另外两项仍成立：

1. 当前仓库没有 9 Pro 可安装的 Canopus supervisor/`/dev/canopus` 提供者；
2. 当前仓库没有 AstroBox 模块签名授权和完整模块 ABI/线程上下文验证。

因此这些地址不能直接塞进 `canopus-filemanager` 生成 `.ko`，更不能直接在手环上调用。
下一步应先补齐 LVX 其余函数和 descriptor 布局，再以只读探针验证；拿到 supervisor
或官方代签后，才进入文件管理器模块的真机测试。
