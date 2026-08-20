# re/ — 原生 UI 逆向工作区（历史资料）

> **Legacy notice:** 本目录保留上一轮 Canopus/固件静态逆向证据，不参与当前 Lua 后端表盘和 Vela Files 轻应用的构建，也不应据此执行未经验证的设备地址。

目标：把「文件管理器」从 **lvgl 表盘** 升级为 **真正的系统原生应用 UI**（出现在应用列表、用系统原生控件渲染）。

**当前状态**：
- ✅ 固件容器已解析；`fwextract.mjs` 提取的是 9 个 `ZZZ~` 高熵表项，外层 ZIP 另含一份可解压的明文 AP。
- ✅ `re/scripts/apscan.mjs` 已从 9 Pro 3.1.175 AP 中定位 `app_install`、`app_lookup`、
  `app_launcher_add`、`lvx_page_title_create` 的静态候选地址——见 `re/canopus/FIRMWARE_SYMBOLS.md`。
- ✅ 表盘侧注入探针仍保留并已按实机结果记录；但本机 Lua shell 的 `insmod/lsmod/exec` 失败，
  不能把朋友设备上的 modlib 闭环直接视为本机执行通道。
- ⚠️ RSA-2048 仍约束固件升级包合法性；静态拿到函数地址不等于拥有 Canopus supervisor、
  签名授权或可调用的模块 ABI。任何地址都必须先做只读真机探针。
- ✅ 表盘已内置**一键采集**：顶栏 `i` → **`DUMP`**，把下方 P1/P2/P3 的大部分样本自动写到
  `/data/deepscan_re/`（见 `lua/main.lua` 的 `runREDump`）。装好表盘后按一下 `DUMP`，再用文件管理器
  进入 `/data/deepscan_re/` 把内容逐条发回来即可，无需手动敲 `ls`/`cat`。

下面是三层逆向接口与所需样本的清单。

---

## 要逆向的三层

| 层 | 逆向对象 | 目的 |
| --- | --- | --- |
| **L1 执行通道** | 表盘 Lua → `insmod`/`exec` 的真实调用方式 | 让我们的表盘能稳定执行原生代码 |
| **L2 原生 UI 框架** | 固件里的 UI/应用框架库（导出符号、调用约定） | 写 C 原生模块调用系统原生控件 |
| **L3 应用列表注册** | `/data/apps.json` 等注册表的 schema | 让文件管理器以图标出现在应用列表 |

---

## 需要你提供的东西（按优先级）

### P0 — 你朋友的执行通道成果（最高优先级）

1. 那篇完整文档 **`docs/ELF注入闭环验证成功_20260813.md`** 以及相关笔记。我目前只拿到摘要，
   缺最关键的一环：**Lua 到底怎么触发 `insmod` / `exec`**。
2. **`min_module/test_module.ko`**（1180 字节）和它的 **C 源码**（如果有）。
3. 探针表盘 **`probe_v104_10P.bin`** 或它的 **Lua 源码**——重点看它如何从 Lua 侧调用 `insmod`/`exec`
   （是 `os.execute`？写某个文件/套接字？某个隐藏 API？还是通过 modlib 的导出符号？）。

> 把这三样放到 `re/exec/` 目录下即可。

### P1 — 应用列表注册表（系统数据）

4. **`/data/apps.json`**（或等价物）的完整内容。用我们已做好的文件管理器打开它，
   把「文本预览」内容贴给我；或者用 AstroBox 的 ADBFS / adb 把文件拉出来放到 `re/system/`。
5. **`/data` 目录树清单**：`ls -laR /data`（或至少 `ls -la /data`）——看 `persist.db`、`apps.json`、
   `app/` 等结构。
6. 根目录与系统分区清单：`ls -la /`、`ls -la /usr`、`ls -la /system`、`ls -la /etc`、
   `mount` 的输出。

### P2 — 固件二进制（原生 UI 框架库）

7. **当前固件的升级包**（`.bin` / `.zip`），或直接从设备拉出的共享库目录
   **`/usr/lib`（或 `/system/lib`、`/lib`）下的 `.so` 文件**。
   - 重点找名字带 `ui` / `appfw` / `vela` / `widget` / `launcher` / `framework` 的库。
   - 打包压缩后放进 `re/firmware/`（或 `re/libs/`）。
8. 如果方便，`ls -la /usr/lib`、`ls -la /system/lib` 的清单先发我，我来圈定要拉哪些库。

### P3 — 运行环境信息（搭交叉编译 + 分析用）

9. 以下命令的输出（有权限就读）：`/proc/kallsyms`、`/proc/modules`、`uname -a`、`cat /proc/version`。
10. 能对应上这台设备固件的 **NuttX / openvela 版本** 或 **Vela SDK 版本**——
    用于搭建能编 `.ko` 的交叉工具链（arm-none-eabi / aarch64，取决于 SoC）。

---

## 收到样本后我会做什么

1. **L1**：把朋友的 insmod/exec 调用方式固化成表盘里可复用的注入通道（替换现在 `lua/main.lua` 里
   `INJECT` 表里的占位命令）。
2. **L2**：用 `readelf` / `nm` / `objdump`（本仓库 `re/scripts/analyze.mjs` 已封装）+ Ghidra/IDA
   分析 UI 库的导出符号与调用约定，找到「创建窗口/列表/按钮/文本框」的入口，写一个 C 原生模块去调用。
3. **L3**：逆向 `apps.json` 的 schema，注入一个条目，让文件管理器以图标出现在应用列表，
   点击后启动我们注入的原生模块。

---

## 目录约定

```
re/
  exec/        # P0：朋友 .ko / 探针 / 文档
  system/      # P1：apps.json / 目录清单 / mount / proc 输出
  firmware/    # P2：固件包（已放入 upd_miwear.watch.n67cn.bin）+ NOTES.md 分析笔记
  libs/        # P2：单独拉出的共享库（可并入 firmware）
  report/      # analyze.mjs 生成的分析报告（自动）
  scripts/analyze.mjs   # ELF 分析器：架构/依赖/导出符号/UI 相关字符串
  scripts/fwscan.mjs    # 固件扫描：`ZZ~ 头 + 压缩/分区签名 + 关键字符串定位
  scripts/fwdecomp.mjs  # 固件解压：gzip/zlib 流解压 + squashfs 超级块解析
  scripts/zip-inspect.mjs # 外层 ZIP local entry / AP 提取
  scripts/apscan.mjs      # AP Thumb-2 静态地址候选扫描
  scripts/canopus-gap.mjs # 9 Pro AP 与 10 Pro supervisor 的执行通道差分
```

```bash
bun re/scripts/fwextract.mjs          # 解析 `ZZ~/`ZZZ~ 容器，提取 9 个子镜像 → re/firmware/extracted/
bun re/scripts/analyze.mjs            # 扫描 exec/system/firmware/libs 下的 ELF 并出报告
bun re/scripts/fwscan.mjs             # 扫描固件头部/压缩签名/关键字符串
bun re/scripts/fwdecomp.mjs           # 解压固件内 gzip/zlib 流 + squashfs 超块
bun re/scripts/zip-inspect.mjs        # 列出外层 ZIP local entry，并可提取明文 AP
bun re/scripts/apscan.mjs             # 输出 9 Pro app/LVX 静态候选地址
bun re/scripts/canopus-gap.mjs         # 比较 9 Pro AP 与 supervisor 标记/缺失项
```

分析器不修改任何输入文件，只读样本、写 `re/report/`。
