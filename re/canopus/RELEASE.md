# Canopus — 官方发布物逆向分析（Searchstars 两仓库）

> 日期：2026-08-18
> 来源：
> - `Searchstars/Canopus-Manager-AstroBox-Release`（发布包）
> - `Searchstars/Canopus-Module-BluetoothAudio`（模块 + 构建链源码）
> 产物已下载到 `payload/canopus-manager/`，supervisor 模块已从 .bin 中抽出并分析。

---

## 一、这两个仓库各是什么

### 1. `Canopus-Manager-AstroBox-Release` — 发布包（管理器表盘成品）

仓库只有 4 个文件，是一个完整的「Canopus 模块管理器」表盘包：

| 文件 | 内容 |
| --- | --- |
| `canopus-installer-prod-10p-036+030.bin` | 编译好的管理器表盘（217,791 B） |
| `manifest_v2.json` | 清单：`restype: "canopus"`、`id: canopus_manager`、下载键 `xmb10p` |
| `icon.png` / `cover.png` | 表盘图标/封面 |

**manifest 里三句关键声明**（决定成败，逐字重要）：
- 「目前仅支持 **3.101.036** 固件」→ 只支持 **小米手环 10 Pro**，下载键 `xmb10p` 也印证。
- 「每次设备重启后必须切换到该表盘重新进注入（点击 Run 按钮）」→ supervisor 是**每次开机由表盘重新注入**的，不持久化在 flash。
- 「从 AstroBox 安装的 Canopus 管理器只允许加载从 AstroBox 官方源获取的模块」→ **签名门**。

### 2. `Canopus-Module-BluetoothAudio` — 模块源码 + 构建链

- `watchfaces/bluetooth-audio-prod/main.lua` — 生产安装表盘 Lua：读 `ro.build.version` → 选对应 signed 载荷 → 写入 `/data/canopus/inbox/` → 向 `/dev/canopus` 发 CPC2 INSTALL。
- `scripts/build-install-payload.sh` — 完整构建链：Rust 交叉编译 → clang 链接 → **`canopus verify`（闭源校验器）** → 用 `module-installer-ed25519.pem`（AstroBox 私钥）签 CMI1 收据。
- `targets/xiaomi-band-9-pro-3.1.175.env` — **他们确实有我们这台 9 Pro 3.1.175 的构建目标**（`thumbv8m.main-none-eabihf` / `cortex-m33`，注释直言 Band-9 与 Band-10 共用 Cortex-M33 FPv5）。但 `MODULE_MAX_SIZE=0`（未启用），且真实符号地址表仍在闭源 `canopus-target-private`。

---

## 二、从 .bin 里抽出的 supervisor —— 整个 Canopus 系统就是两个 .ko

把 `canopus-installer-prod-10p-036+030.bin` 反解，里面有：

```
_lua/canopus-installer-prod/main.lua
_lua/canopus-installer-prod/canopus_supervisor-xiaomi-band-10-pro-3.101.030.bin  (ET_REL ARM, 72,863 B)
_lua/canopus-installer-prod/canopus_supervisor-xiaomi-band-10-pro-3.101.036.bin  (ET_REL ARM, 127,556 B)
_lua/canopus-installer-prod/manager_icon.bin
```

两个 ELF 已在 `payload/canopus-manager/sup-3.101.030.ko` / `sup-3.101.036.ko` 抽出。`readelf` 结果（3.101.030）：

- **ELF32 / ET_REL / ARM / EABI5 / soft-float**，80 个段，`.text` 35,876 B，`.bss` 36,540 B。
- **零 UNIQUE/UND 导入符号** —— 固件符号地址全部在编译期以绝对地址烧进 `.rodata`（这就是 target pack 的本质：一张地址表）。
- 内部符号把整个系统的组成写得清清楚楚：

| 符号 | 作用 |
| --- | --- |
| `canopus_sup_ctor` / `canopus_sup_dtor` | 模块 init/fini（经 `.init_array`/`.fini_array`） |
| `sup_register_device` / `sup_unregister_device` | 创建/注销 `/dev/canopus` |
| `sup_dispatch` / `canopus_supervisor_handle_command` / `canopus_supervisor_handle_v2_request` | CPC1/CPC2 命令分发 |
| `sup_load_module` / `sup_stage_package` / `sup_verify_package_at` / `sup_verify_file` | 模块加载 + 校验 |
| `sup_registry_persist` / `sup_registry_restore` / `canopus_supervisor_save_registry` | `/data/canopus/registry.bin` 持久化/恢复 |
| `sup_activate_module` / `canopus_supervisor_activate_restored_modules` | 开机恢复已启用模块 |
| `canopus_monocypher_compat.c` | **Monocypher = Ed25519 验签**（签名门的实现） |
| `canopus_manager_target_lvgl_v9.c` / `canopus_ui.c` / `canopus_manager_native.c` | **管理器 UI 直接编译进 supervisor**（LVGL v9） |
| `canopus_lifecycle.c` / `canopus_module.c` / `canopus_resource.c` | 生命周期/模块框架/图标资源 |
| `canopus_module_descriptor_check` / `canopus_supervisor_register_descriptor` | 模块描述符校验/注册 |

安装 Lua 的关键动作（strings 还原）：

```lua
-- 每次开机：
set_status("Loading supervisor...")
local inserted = run(string.format("insmod %s %s", shell_quote(MODULE_PATH), MODULE_NAME))
-- 然后 supervisor_present() 探测 /dev/canopus
-- 再依次发 CPC1 INSTALL 0/1/2（安装 → 发布 Launcher 条目）
```

**结论：整个 Canopus（supervisor + 管理器 UI + 模块框架 + Ed25519 验签）就是这两个 .ko，靠 `insmod` 注入。表盘 Lua 只是引导器。**

---

## 三、对你（9 Pro 3.1.175）的硬结论

1. **supervisor 本身就是 `insmod` 加载的** —— 而你的 3.1.175 上 `insmod` 返回 `exit 65280`（DeepScan 多轮探针已实锤）。**没有 insmod = 没有 supervisor = 没有 /dev/canopus = Canopus 在你机器上根本起不来**。这不是缺 SDK 的问题，是固件没有可用 modlib。
2. **官方发布物只支持 10 Pro 3.101.030/036**，supervisor 里烧的是那两版固件的符号地址。就算强灌到 9 Pro，地址全错，行为未定义。
3. **签名门是 Monocypher Ed25519**：supervisor 内置 AstroBox 公钥，只收 AstroBox 私钥签的 CMI1 收据。自己编的文件管理器模块，没有 AstroBox 私钥签名，**在任何设备上都过不了 `sup_verify_package_at`**。
4. 三样闭源资产里，现在**证实 supervisor 本体确实是"逆向固件 + 自研编译"的 .ko**，但它不改变 3.1.175 的处境。

---

## 四、你需要做什么（三条路，按现实排序）

### 路 A：换 10 Pro 3.101.030/036（唯一官方支持，能立刻跑起来）
1. 从本仓库 `payload/canopus-manager/` 下载 4 个文件（.bin + manifest + 两个 png）。
2. 用 AstroBox 应用（`astrobox.online` 的 App，装好对 10 Pro）把这包作为表盘装进 10 Pro。
3. 切到该表盘 → 点 Run → 表盘自动 `insmod` supervisor → 管理器出现。
4. 之后只能装 AstroBox 官方源里**已签名**的模块。

### 路 B：让 AstroBox 帮你签一个「文件管理器」模块（在你 9 Pro 上唯一现实的路）
- 你的设备没法自己跑 Canopus，但 **AstroBox 已经为 9 Pro 3.1.175 建了 target**（`targets/xiaomi-band-9-pro-3.1.175.env`，Cortex-M33）。
- 找 Searchstars/AstroBox 团队：我们按 `SPEC.md` 把文件管理器模块写好（LVX 原生 UI + 目录游标 + `os.remove` 删除），请他们用 `module-installer-ed25519.pem` 代签一份 9 Pro 3.1.175 的 CMI1 收据，并确认 9 Pro 的 supervisor 何时发布。
- 这是唯一能「应用列表出现 + 原生 UI + 9 Pro」的正路。

### 路 C：放弃 Canopus，走 atc1441 自制固件（对 3.1.175 唯一能自给自足的路）
- 3.1.175 无 modlib，Canopus 系全断。atc1441 的 `MiBand10-BES2700iMP-BEST1503-Hacking` 是开源固件 SDK，自带可执行区/原生 UI 能力。
- 代价：刷自制固件 = 变砖风险 + 工程量上一个数量级，且不再是"表盘注入轻应用"。

---

## 五、文件清单

```
payload/canopus-manager/
  canopus-installer-prod-10p-036+030.bin   # 官方管理器表盘成品（217,791 B）
  manifest_v2.json                         # 清单（restype: canopus, xmb10p）
  icon.png / cover.png
  sup-3.101.030.ko                         # 抽出：supervisor 模块（ET_REL ARM, 72,863 B）
  sup-3.101.036.ko                         # 抽出：supervisor 模块（ET_REL ARM, 127,556 B）
```
