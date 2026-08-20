# 9 Pro 3.1.175 AP 静态逆向结果

> 分析日期：2026-08-20  
> 固件：`re/firmware/upd_miwear.watch.n67cn.bin`  3.1.175  
> 自动化入口：[`re/scripts/apscan.mjs`](../scripts/apscan.mjs)

## 这次真正拿到的输入

此前 `fwextract.mjs` 解析的是 OTA 内层 `ZZZ~` 文件表；其中的
`/data/ota/app/vela_ap.bin` 是 1,402,841 字节的高熵载荷，不能直接当作 AP
可执行镜像。继续检查固件中的 ZIP local entry 后，发现了另一份同名 AP：

| 项目 | 值 |
| --- | --- |
| ZIP local entry 偏移 | `0x94af8` |
| 压缩方式 | deflate raw（ZIP method 8） |
| 压缩大小 | `4,816,380` B |
| 解压大小 | `7,774,696` B |
| 解压后 SHA-256 | `4f43b325addd6d9e6e7c7e2a4d00ffe3f23d5fb1560d8fe503544002ac1f516b` |
| 运行时基址推断 | `0x2c080000` |

基址不是猜测：AP 内含 `FLASH_BASE=0x2C000000`、`OTA_CODE_OFFSET=0x80000`，
并且代码中的绝对指针能精确指向同一镜像内的字符串，例如
`0x2c68eafc = 0x2c080000 + 0x60eafc`。

解压后的镜像包含可反汇编 Thumb-2 代码和明文字符串：

- `NuttShell (NSH) NuttX-10.3.0`
- `lvgl/src/core/lv_obj.c`
- `lvx_widgets/lvx_list.c`
- `lvx_page_title_create`
- `app_install`
- `app_launcher_add`

## Canopus 所需的第一批静态地址

地址是 AP 运行时地址；模块若以函数指针调用，使用右侧的 Thumb entry（地址 + 1）。

| 逻辑 API | 运行时候选 | Thumb entry | 证据 | 置信度 |
| --- | ---: | ---: | --- | --- |
| `app_install` | `0x2c44b5d0` | `0x2c44b5d1` | 函数序言后校验 descriptor，读取 `app_id`（descriptor `+0x10`），分配并链接页面数组；同函数的文字池指向 `app_install` 诊断字符串 | 高 |
| `app_lookup` | `0x2c449334` | `0x2c449335` | 遍历应用链表，比较对象 `+0x10` 的 u16 app id，返回匹配对象或 NULL；`app_install` 会直接调用它检查重复 | 高 |
| `launcher_add` / `app_launcher_add` | `0x2c2a7cb8` | `0x2c2a7cb9` | 函数拥有 `app_launcher_add` 文字池；两个调用点在调用前传入 app-id 形状的 u16 | 高 |
| `lvx_page_title_create` | `0x2c2783c8` | `0x2c2783c9` | 函数拥有 `lvx_page_title_create` 文字池；有两个 Thumb BL 调用点 | 高 |

这些地址只说明“固件里可以定位到对应代码”，不等于已经形成可运行的模块 ABI。
实际调用还需要确认参数布局、线程上下文、返回值和页面对象生命周期。

## `app_install` descriptor 的新增证据

`re/scripts/apscan.mjs` 现在会复核并打印这组静态证据：

| 偏移 | 观察结果 | 置信度 |
| ---: | --- | --- |
| `+0x00` / `+0x04` | `app_install` 复制 descriptor 后，把已安装对象这两个字改成注册表链表链接 | 中 |
| `+0x08` | 入口要求非空，并复制到已安装对象；与 `app_lookup` 返回对象的包名指针位置一致 | 高 |
| `+0x0c` | 条件复制的指针字段，具体语义未定 | 高 |
| `+0x10` | `LDRH` 取出并传给 `app_lookup`，是 app id | 高 |
| `+0x14` / `+0x18` | 条件复制的指针/回调候选，具体语义未定 | 高 |
| `+0x1c` | 已安装对象销毁路径通过 `BLX` 调用的 callback-like 字段 | 中 |
| 总大小 | 连续复制 `0x3c`（60）字节 | 高 |

调用形状也比此前更清楚：`r0=descriptor`、`r1=page-pointer array`、
`r2=page_count`；函数把 `r2` 保存为循环边界，并逐项读取 `r1` 数组。这个结论
**推翻了旧的“`app_id` 位于 descriptor `+0x08`”示意布局**。公开 Canopus
`sdk-stubs` 和文件管理器代码已改成 9 Pro 的 provisional raw layout，但它们仍不能
替代真实 `target-private` SDK；页面 descriptor 的字段偏移和回调 ABI尚未闭环。

## LVX 列表层的新增证据

`lvx_list_set_parent` 字符串位于 AP `file+0x6ce32b`；包含该字符串 literal pool
并通过相邻控制流检查/链接 parent 的候选函数为 `0x2c438148`
（Thumb `0x2c438149`），静态置信度 **中**。这只覆盖 list-parent/error 路径，
不能把它误称为 `lvx_list_row_create`、`lvx_list_row_update` 或事件注册 API。

同一片 `lvx_list.c` 代码还出现了两个相关候选：

| 逻辑角色（暂定） | 运行时候选 | Thumb entry | 证据 | 置信度 |
| --- | ---: | ---: | --- | --- |
| list child create/attach | `0x2c438268` | `0x2c438269` | 有函数序言，分配/复制 child descriptor，并直接调用 `0x2c438148`；公开 row 名称尚未恢复 | 中 |
| list child lookup | `0x2c4382b8` | `0x2c4382b9` | 有函数序言，遍历对象 `+0x78` 附近的 child 数组并返回匹配项；具体控件类型未确认 | 中低 |

### 页面生命周期包装层候选

AP 中保留了 page-manager 包装层的函数名文字。文字的绝对指针被放入唯一的
literal pool，且相邻位置是完整 Thumb 函数序言和回调字段分发，因此可以给出中等
置信度的静态候选：

| 逻辑角色（暂定） | 运行时候选 | Thumb entry | 文字引用 | 置信度 |
| --- | ---: | ---: | --- | --- |
| page resume wrapper | `0x2c44bb10` | `0x2c44bb11` | `on_resume_wrapped`，AP `file+0x6d24d8`，literal `file+0x3cbb90` | 中 |
| page destroy wrapper | `0x2c44bba4` | `0x2c44bba5` | `on_destroy_wrapped`，AP `file+0x6d2383`，literal `file+0x3cbc4c` | 中 |
| page create wrapper | `0x2c44fc58` | `0x2c44fc59` | `on_create_wrapped`，AP `file+0x6d2547`，literal `file+0x3cfc48` | 中 |
| screen-session destroy | `0x2c44e8f0` | `0x2c44e8f1` | `screen_session_destroy`，AP `file+0x6d24ea`，literal `file+0x3ce934` | 中 |
| LVX eventbus unsubscribe | `0x2c4391ec` | `0x2c4391ed` | `lvx_eventbus_unsubscribe`，AP `file+0x6cdcc6`，literal `file+0x3b921c` | 中高 |

这些包装函数能说明 page owner 的生命周期确实由固件集中调度，并且会通过页面对象
内的函数指针字段调用回调；它们**不能**直接推出 `firmware_page_descriptor` 的字段偏移、
回调参数顺序或线程切换规则。`lvx_list_row_create/update`、`lvx_event_add` 和
`activity_navigate/finish` 的导出 ABI仍未闭环。

## 目前已经回答的问题

1. **AstroBox 是否可能通过逆向固件做 target pack？** 是。现在已经能从官方 9 Pro
   AP 镜像恢复应用注册和一部分 LVX 入口的候选地址；这与公开 Canopus 工程中
   `target-private` 的职责吻合。
2. **9 Pro 是否完全没有原生 UI 入口？** 不是。AP 内有完整 LVGL/LVX 和 launcher，
   不是“没有能力”，而是需要正确 ABI 与执行上下文。
3. **是否能只凭这些地址直接安装文件管理器？** 不能。当前设备实测 Lua shell 的
   `insmod/lsmod/exec` 失败；Canopus 还需要一个能提供 `/dev/canopus` 的 supervisor、
   模块校验/签名流程，以及页面回调的真实调用约定。

## 下一轮静态逆向

继续分析可以补齐：

- `lvx_list` 行创建/更新、label、event、navigation 的函数边界和参数；
- page descriptor 的精确字段偏移、回调参数和页面线程上下文；
- supervisor 所需的 NuttX 文件/设备调用入口；
- 与公开 10 Pro supervisor 的 target 地址表做差分，检查哪些是固件通用函数、哪些是
  target-specific。

这些工作只读固件并生成候选报告，不会修改固件或生成刷写包。真机验证时应先做只读
探针，不能把未经验证的地址直接写入模块或调用可能改变系统状态的函数。

## Supervisor 与执行通道差分（2026-08-20）

新增脚本：[`re/scripts/canopus-gap.mjs`](../scripts/canopus-gap.mjs)。它从 OTA 外层
ZIP local entry 重新提取 AP，并与工作区抽出的 10 Pro supervisor 做只读标记比较；不会
写入、链接、安装或执行任何模块。

### 9 Pro AP 与 10 Pro supervisor 的静态差异

| 标记/证据 | 9 Pro AP（`vela_ap.bin`） | 10 Pro supervisor 样本 |
| --- | ---: | ---: |
| `/dev/canopus` 字符串 | 0 | 1 |
| `canopus` / `supervisor` 标识 | 0 / 0 | supervisor 符号与字符串存在 |
| `insmod` / `lsmod` / `modlib` | 0 / 0 / 0 | supervisor 本身为 ET_REL 模块，安装表盘链路使用 `insmod` |
| `app_install` / `app_launcher_add` | 5 / 1 | 由模块通过 target-private 调用 |
| `lvx_page_title_create` | 1 | 由 target UI 后端间接调用 |
| NuttX `vfs/fs_open.c`、`fs_read.c`、`fs_close.c` 标记 | 各 1 | supervisor 通过绝对地址使用 I/O |

“0 次字符串”不是运行时绝对否定，但和此前 9 Pro Lua 实测 `insmod`/`lsmod` 无输出、
退出码 65280 的结果相互吻合：当前零售 AP 中没有发现 Canopus supervisor 或通用
modlib 的静态痕迹。AP 的 `app_install` 与 LVX 代码属于固件自身，并不会自动提供
`/dev/canopus`。

### supervisor 样本恢复出的 target-specific 硬门槛

对 `payload/canopus-manager/sup-3.101.036.ko` 的 ET_REL 符号/Thumb 反汇编确认：

- `sup_register_device`（模块偏移 `0x0fd4`）创建 `/dev/canopus` 的 fops，并通过目标固件
  绝对入口注册/注销字符设备；
- `sup_load_module`（`0x1036`）先按 module id 构造路径、调用 `sup_verify_package_at`
  校验，再通过目标固件绝对入口装载模块，并检查目标/固件/模块元数据；
- `sup_verify_package_at`（`0x1658`）使用固件绝对的 `open/read/close` 入口读取包和
  256 字节收据；
- `canopus_install_receipt_validate`（`0x22f8`）检查 `CMI1` magic、version 1、
  size 256、保留字段、生命周期范围、module id、target id、32 字节固件哈希，最后
  调用 Ed25519 校验；
- `identity_guard`（`0x6fb2`）和 `canopus_manager_target_init`（`0x7042`）把目标身份
  与 supervisor 的 target record 绑定。样本内明确出现
  `xiaomi-band-10-pro-3.101.036`，所以它不是 9 Pro target pack。

### 对 9 Pro 逆向路线的修正

目前可以继续从 9 Pro AP 恢复 `app_install`、LVX、NuttX 文件 API 和 target-specific
绝对地址；但**仅有这些地址不能生成 Canopus**。还缺：

1. 能在 9 Pro 上把 supervisor 放进执行区的真实安装/加载通道；
2. 9 Pro supervisor 的 `/dev/canopus` 实现和模块加载绝对入口；
3. 9 Pro target record、identity guard 规则、签名公钥/官方代签流程。

因此“supervisor 可以独立绕过零售固件 modlib”现在只能算未证实假设；已有 10 Pro 样本
反而证明其常规安装链路依赖 `insmod`。在拿到 9 Pro supervisor 或新的设备运行时证据
之前，不应把 10 Pro `.ko` 改名后安装，也不应直接执行本文件前文的静态候选地址。
