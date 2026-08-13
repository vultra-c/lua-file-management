# 固件分析笔记 — upd_miwear.watch.n67cn.bin

> 文件：`re/firmware/upd_miwear.watch.n67cn.bin`（50,302,103 字节）
> 来源：仓库根目录 `upd_miwear.watch.n67cn.bin`（用户已提交到 origin/main）的本地分析副本。

## 头部（`` `ZZ~ `` 容器）

| 偏移 | 内容 |
| --- | --- |
| 0x00 | 魔数 `60 5a 5a 7e`（`` `ZZ~ ``） |
| 0x04 | 版本字符串 `3.1.175` |
| 0x4c | `0x5c`（92，头部尺寸相关） |
| 0x50 | `0x8c944` → 构建信息块（`BUILD_DATE=Apr 14 2026 … REV_INFO=11f5e7d:nx_bestbsp_ota`） |
| 0x54 | `0x8c9a4` → **嵌套 `ZZZ~` 容器**（子镜像文件表所在） |
| 0x58 | `0x2f6c1eb`（≈49.7MB，主载荷尺寸） |
| 0x60 | `0x50000`（327,680） |
| 0x68 起 | Thumb 代码开始（`14 48 00 47` = `ldr r0,[pc,#0x50]; bx r0`） |

## 嵌套 `ZZZ~` 容器 + 文件表（✅ 已解析）

嵌套容器位于 `0x8c9a4`，魔数 `5a 5a 5a 7e`（`ZZZ~`）。其后紧跟 **0x80 字节/条的文件表**：

```
条目布局（0x80 字节）：
  0x00      路径（NUL 填充，如 /data/ota/app/vela_ap.bin）
  +0x74     type  u16（1=ap 主镜像，2=boot，5/6/7=外设固件）
  +0x76     常量 0x74（0x74 = 116）
  +0x78     数据偏移 u32
  +0x7C     数据长度 u32
```

### 已提取的 9 个子镜像（`re/firmware/extracted/`，由 `re/scripts/fwextract.mjs` 产出）

| 子镜像 | type | 偏移 | 大小 | 头部前 8 字节 |
| --- | --- | --- | --- | --- |
| `vela_ap.bin`（AP/openvela 主镜像） | 1 | 0x4a0000 | 1,402,841 | `87 6b 63 32 …` |
| `vela_factory.bin` | 2 | 0x5f67dd | 191,544 | `24 16 5f de …` |
| `vela_bl2.bin`（二级引导） | 2 | 0x625419 | 44,157 | `92 c2 09 ed …` |
| `vela_bl.bin` | 6 | 0x63009a | 200,210 | `c9 8e 2d 34 …` |
| `D11A06.bin`（NFC） | 7 | 0x660eb0 | 27,040 | `fc d7 2c fe …` |
| `hyn_wxn_firmware.bin`（触控） | 7 | 0x667854 | 36,422 | `a0 d2 81 77 …` |
| `tp_zinitix_firmware.bin`（触控） | 7 | 0x67069e | 27,050 | `0c f5 a4 7b …` |
| `hyn_firmware.bin`（触控） | 5 | 0x67704c | 229,581 | `86 b5 7f 03 …` |
| `bream.patch`（GPS） | 0 | 0x6af11d | 416 | `e4 e5 24 7e …` |

## 关键事实

- **内核**：NuttX `10.3.0`（字符串 `NuttX.10.3.0.86ac2747e4`，@0x7c12e）。
- **OTA 流程**（MCU 侧明文区字符串还原）：`/data/ota/app/vela_ap.bin → /dev/flash_ap`、
  `/data/ota/boot/vela_bl2.bin → /dev/flash_bl2`；`ram addr` → `copy` → `w offset … crc` → `verify ok!`。
- **文件系统**：MCU 侧 `/system/` 挂载，含：
  - `/system/image/launcher.res`（**桌面/应用列表资源** @0x91a8e）
  - `/system/image/sport_widgets.res`
  - `/system/watchface/<id>/`（表盘 ID：267130002、267130003、367150001 等）
  - `/system/i18n/<lang>/`、`/system/image/ota/`
- **压缩**：固件含 zlib inflate 错误串；OTA 日志用 `gzip -f -1`。

## ⛔ 决定性发现：子镜像全部加密 + RSA 签名

- 9 个子镜像（含 `vela_ap.bin`）数据区**均为高熵密文**：无 ELF 魔数（`7f 45 4c 46` 计数 0）、
  无 gzip/zlib/squashfs 头，无法直接解析。launcher/app 注册与原生 UI 框架都封装在**加密的
  `vela_ap.bin`** 内。
- MCU 侧明文区（0x81000 起）内嵌 **RSA-2048 公钥**，用于**固件签名验证**：
  - 模数：`92DC37B58549DADE9D2E633FFCA36FE955E317A12B291E970675ED09459017F9F833B6E37E34642361B66E4FF7463674D685C1DA5ED6FA8C3B14DB5F5DAB60B9FD765A233FD6ACC1D5ADAA59DB1631ADAF5D`
  - 指数：`10001`（65537）
  - 相关日志串：`key read error` / `key parse error` / `sign verify error` / `sign`
- 加密栈为 **OpenSSL**（对象库字符串：`des-ede3-cbc`、`rsaEncryption`、`sha-1/sha256/sha512WithRSAEncryption`、
  `RSASSA-PSS`）；并带 **minizip**（`extract crypted file using password`）。

### 结论：固件解密是死路

子镜像的解密密钥要么以 RSA 混合加密方式封装（只有厂商私钥能解），要么硬编码在 MCU 侧 Thumb 码内
（需 Ghidra 级反汇编才能确认）。**仅凭仓库内的固件 + RSA 公钥无法在可接受时间内解密 `vela_ap.bin`。**

因此「出现在应用列表 + 系统原生 UI」不应再走「解固件」路线，而应走**运行时逆向**：设备正在运行的
`vela_ap` 已解密并挂载在系统里，直接读设备上的 `/data/apps.json`、`/system/image/launcher.res`、
`/usr/lib` 下的应用框架 `.so` 即可拿到明文符号与注册表（见 `re/README.md` 的 P1/P2 清单）。

> 本仓库已把容器解析/提取（`fwextract.mjs`）、ELF 分析（`analyze.mjs`）、固件扫描（`fwscan.mjs`）、
> 解压（`fwdecomp.mjs`）全部备好；加密墙是唯一且不可绕过的障碍。
