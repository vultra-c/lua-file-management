# Canopus ABI / 协议阶段性规格（逆向还原稿）

> 来源：`Searchstars/Canopus-Module-BluetoothAudio` 公开源码（逐文件核对）及 9 Pro `3.1.175` AP 静态分析。
> 状态：这是 **公开接口线索与当前固件证据的阶段性还原稿**；带 `candidate/provisional` 标记的布局和函数均未完成真机 ABI 验证。闭源部分与执行边界见 `VERDICT.md`。
> 日期：原始记录 2026-08-14；静态更新 2026-08-20

Canopus 不是固件里的东西。它是一套 **第三方常驻监督器（supervisor）+ 签名原生模块（ELF）** 体系：
模块用 Rust 写、编译成 `thumbv8m.main-none-eabihf` 的 ARM ELF，由表盘一次性“安装表盘”
投递到设备，监督器校验签名后**注册进系统应用列表**，模块再用私有 ABI 直接调固件的
`app_install / launcher_add / lvx_*` 渲染系统原生 UI。

下面按四层还原：模块 ABI、原生应用注册、LVX 渲染、安装协议。

---

## 1. 模块 ABI（`canopus-abi` / `canopus-runtime`）

模块导出两个符号，加载器靠它们找到模块：

| 符号 | 类型 | 说明 |
| --- | --- | --- |
| `canopus_module_descriptor` | `static ModuleDescriptorV1` | 模块静态描述符 |
| `canopus_register_module_descriptor()` | `fn() -> i32` | 通过 `/dev/canopus` 注册 |

### `ModuleDescriptorV1`（字段顺序 = ABI 布局）

```c
struct ModuleDescriptorV1 {
    u32 struct_size;              // sizeof(ModuleDescriptorV1)
    u32 abi_major;                // ABI_MAJOR
    u32 abi_minor;                // ABI_MINOR
    u32 flags;
    u8  module_id[32];            // 左对齐 NUL 填充，如 b"bluetooth_audio"
    u8  module_version[32];       // b"0.1.0"
    u8  build_id[32];
    u8  target_id[32];            // = canopus_target_private::TARGET_ID（目标固件 id）
    fn prepare(ctx) -> i32;
    fn activate(ctx) -> i32;
    fn deactivate(ctx) -> i32;
    fn stop(ctx) -> i32;
    fn query(writer: *StatusWriterV1) -> i32;
    fn publish_native_app(ctx) -> i32;
    fn publish_native_app_stage(ctx, stage: u32) -> i32;
};
```

每个回调是 `Option<extern "C" fn>`（可空函数指针，在 Rust 里必须写成 `Option<fn>`，
因为 Rust 函数指针不能合法地是 `NULL`）。

### flags（从公开仓库组合出的位）

```
FLAG_HAS_NATIVE_APP
FLAG_NATIVE_APP_STANDALONE
FLAG_REGISTERS_LAUNCHER_ENTRY
FLAG_REQUIRES_UI_DISPATCHER
FLAG_APP_UNREGISTER_REBOOT_REQUIRED
```

（这些是 `canopus-abi` 里的常量名；具体位值在闭源 `canopus-abi` crate 中。）

### 注册过程（`canopus_register_module_descriptor`）

```c
if (canopus_identity_guard() != 0) return -1;          // 目标私密校验

struct ModuleRegistrationV1 reg = {
    .magic      = 0x31524d43,   // "CMR1"
    .descriptor = (u32)(uintptr_t)&canopus_module_descriptor,   // 注意：32 位地址
    .module_id  = { /* 32 字节，NUL 填充 */ },
};

int fd = nuttx_open("/dev/canopus\0", 2 /* O_WRONLY */);
if (fd < 0) return fd;
int w = nuttx_write(fd, &reg, sizeof(reg));
int c = nuttx_close(fd);
// w != sizeof(reg) → 失败
```

要点：
- **`/dev/canopus`** 是监督器提供的字符设备；未安装监督器时 `nuttx_open` 失败。
- `canopus_identity_guard()` 是 `canopus-target-private` 的私有调用，做 target/firmware 身份校验。
- 生命周期语义：`deactivate` 在模块已“常驻”（蓝牙回调已发布等）时返回 `RESULT_REBOOT_REQUIRED`。

### `query` 状态

`query(writer)` 用 `status_put_u32(writer, v)` 依次写 u32（magic、active、resident、last_error、
目标层状态……），最后 `status_writer_publish(writer)`。

---

## 2. 原生应用注册（出现在应用列表，`target/native_app.rs`）

私有 ABI 三个固件调用（地址在闭源 `canopus-target-private`）：

```c
i32         app_install(launcher_app_descriptor*, firmware_page_descriptor**, u32 page_count);
void*       app_lookup(u16 app_id);      // 返回已安装 app 对象（未安装 = NULL）
i32         launcher_add(u16 app_id);    // 把条目写进 Launcher
```

### `launcher_app_descriptor`

```c
/* provisional 9 Pro 3.1.175 layout; not a complete public ABI */
struct launcher_app_descriptor_9p_candidate {
    void* registry_prev;              // +0x00, firmware-owned after install
    void* registry_next;              // +0x04, firmware-owned after install
    void* package_or_name;            // +0x08, required by app_install
    void* icon_or_pointer;            // +0x0c
    u16   app_id;                     // +0x10
    u16   reserved_12;
    void* field_14;                   // pointer/callback role unconfirmed
    void* field_18;                   // pointer/callback role unconfirmed
    void* field_1c;                   // callback-like during teardown
    u32   reserved_20_to_3b[7];
};
```

> **9 Pro 静态修正（2026-08-20）**：`vela_ap.bin` 的 `app_install` 候选
> `0x2c44b5d0` 在入口读取 descriptor `+0x08`，再用 `LDRH descriptor+0x10`
> 查重；随后复制 `0x3c` 字节，并把已安装对象的 `+0x00/+0x04` 改成链表链接。
> 因此此前基于公开示意图的“`app_id` 在 `+0x08`”不能用于这台 9 Pro。
> `+0x14/+0x18/+0x1c` 的具体语义、页面 descriptor 的真实布局和调用 ABI仍未确认。

### `firmware_page_descriptor`

```c
/* public-source sketch only; offsets are not verified for 9 Pro */
struct firmware_page_descriptor_candidate {
    void* field_00;
    u16   field_04;
    u16   field_06;
    void* field_08;
    void* field_0c;
    void* field_10;
    void* field_14;
    void* field_18;
};
```

> 页面 descriptor 目前只保留为公开源码的候选模型。`app_install` 确实接收
> `r1=page-pointer array`、`r2=page_count`，但页面回调字段的真实偏移/参数尚未由
> 9 Pro AP 或只读设备探针闭环确认；不能据此直接发布模块。

### 两阶段发布（避免 re-enter）

```c
// stage 1：注册应用 + 页面
app_install(&app_descriptor, pages /* *mut [page; N] */, N);
void* inst = app_lookup(APP_ID);
// 校验：inst != NULL 且 inst->package_name（偏移 +0x8）== 期望包名

// stage 2：应用列表条目（在 miwear 处理完 app-registry 事件后单独提交）
launcher_add(APP_ID);
```

要点（容易踩的坑，公开仓库已注明）：
- **`app_lookup` 返回对象的 `+0x8` 偏移存包名指针**，用它校验是否装对。
- **`launcher_add` 返回的是“实现定义的簿记结果”，不是 0=成功**——成功的判据是上面
  `app_lookup` 校验通过，而不是 `launcher_add` 返回值。
- 页面生命周期回调全部在 **page owner 线程**跑；LVX 绝不在蓝牙/定时器回调里碰。

---

## 3. LVX 渲染（系统原生 UI，`target/ui_backend.rs`）

全部来自 `canopus-target-private`。每个控件的指针只存在 `ui_backend` 里，页面销毁时清空。

### band-10 vs band-9 差异（关键，band-9 = 3.1.175）

| 调用 | band-10 | **band-9（3.1.175，我们目标）** |
| --- | --- | --- |
| 内容根 | `lvx_content_create(root)` + `lvx_object_set_size` + `lvx_object_align` | **无 `lvx_content_create`；页面根 `root` 就是内容父节点**，尺寸/位置由系统页面壳固定 |
| 行工厂 | `lvx_list_row_create(parent, primary, secondary, trailing)` | **`lvx_list_row_create(parent, primary)` 两参数**，再用 `lvx_list_row_set_trailing(row, kind, 0)` 挂尾部 |
| 尾部 kind 常量 | `TRAILING_FORWARD` / `TRAILING_SWITCH` / `TRAILING_NONE` | **switch=1，前向箭头=12，无=0**（`TRAILING_B9_SWITCH` / `TRAILING_B9_FORWARD`） |

### 完整 LVX 调用清单

```
lvx_page_title_create(root, title, mode, back_cb, back_ctx)  // mode1=画返回键, mode0=不画
lvx_label_create(parent)
lvx_label_set_text(obj, text)
lvx_style_apply(obj, STYLE_MISANS_DEMIBOLD_32, 255, 0)        // 标题字号样式
lvx_list_row_create(parent, primary)                          // band-9
lvx_list_row_set_trailing(row, kind, 0)
lvx_list_row_trailing(row)                                    // 取尾部对象（switch 行用）
lvx_list_row_update(obj, NULL, primary, secondary, 0, selected)
lvx_set_hidden(obj, 0/1)
lvx_align_to(obj, base, ALIGN_TOP_MID|ALIGN_OUT_BOTTOM_MID, x, y)
lvx_object_set_size / lvx_object_align                         // 仅 band-10
lvx_event_add(obj, cb, EVENT_CLICKED|EVENT_ALL, user_data)
lvx_event_get_code(event)
lvx_event_get_user_data(event)
lvx_timer_create(cb, period_ms, user_data)
lvx_timer_delete(timer)
activity_navigate(key, 0, 0, 0)                                // key = (APP_ID<<16)|page_index
activity_finish(page_descriptor_ptr)                           // 返回
```

### 事件模型

- switch 行：注册在**尾部对象**上，`LV_EVENT_ALL`，只在 `EVENT_VALUE_CHANGED` 时响应。
- 普通行：注册在行对象上，`EVENT_CLICKED`。
- user_data 编码 `(page_index << 8) | row_index`；绑定带 generation，避免复用行时错触发。

### 渲染模型

`ui_backend` 维护 `Snapshot`（`canopus-ui-core` 的语义模型：`NodeKind::{Text, StatusRow,
Button, ActionRow, SwitchRow, Section, NavigationPage}` + 每节点 `primary/secondary/checked/enabled/
event_id`）。`apply_snapshot` 做行/标签复用 + 内容哈希增量更新 + 4 Hz 刷新定时器。

---

## 4. 安装协议（一次性“安装表盘”，`watchfaces/*/main.lua`）

### 产物

| 文件 | 约束 | 说明 |
| --- | --- | --- |
| `receipt.bin` | **恰好 256 字节**，`u32 @0 == 0x31494D43`（`"CMI1"`） | Ed25519 签名的安装收据，锁 target/firmware SHA-256 + 模块 SHA-256 |
| `module.bin` | **512B ~ 256KB**，前 4 字节 `\x7FELF` | 编译好的 ARM ELF 模块 |

### 投递路径

```
/data/canopus/inbox/<token>.cmi    ← receipt.bin
/data/canopus/inbox/<token>.ko     ← module.bin
/dev/canopus                       ← CPC2 INSTALL 请求
```

（目录不存在时 `os.execute("mkdir /data/canopus")` + `mkdir /data/canopus/inbox`。）

### CPC2 INSTALL 请求（36 字节头 + payload）

```c
struct cpc2_header {            // 36 字节，小端
    u32 magic;       // 0x43504332  "CPC2"
    u16 header_size; // 36
    u16 ver_major;   // 1
    u16 ver_minor;   // 1
    u16 reserved;    // 0
    u32 total;       // 36 + payload_len
    u32 cmd;         // 2 = CMD_INSTALL
    u32 id;          // 1
    u32 seq;         // 0
    u32 flags;       // 0
    u32 payload_len; // = #(token\0)
    // payload = token .. "\0"
};
```

### CPC2 响应（36 字节）

校验：`magic==CPC2`、`header_size==36`、`ver_major==2`（响应）、`ver_minor==1`、`total==36`、
`cmd==INSTALL`、`id==1`、`seq==0`、`flags@32==0`。

- **结果码在偏移 28**：`RESULT_COMPLETED == 5` 表示成功。
- 失败时用 CPC1 查询取错误码：

```c
// 查询：CPC1(0x43504331) + SUP_CMD_QUERY(0x43510001) + DIAG_QUERY_MAGIC(0x43514431) + 0
// 响应：384 字节，magic == CPS1(0x43505331)，错误码在偏移 32（有符号 i32）
```

### 安装后

模块**默认禁用**，需到 Canopus Manager 里审核启用 + 重启。安装表盘在成功后会被监督器请求
表盘管理器自动切换并删除（删不了时提示手动删）。

---

## 5. 目标（我们这台设备）

`targets/xiaomi-band-9-pro-3.1.175.env`：

```
RUST_TARGET_FEATURE=target-xiaomi-band-9-pro-3-1-175
RUST_TARGET_TRIPLE=thumbv8m.main-none-eabihf
RUST_TARGET_CPU=cortex-m33
```

`Canopus.toml` 能力声明里，`identity-guard` 是公开 target pack 就有的，而
`native-app.register / launcher.entry / ui.dispatch` 属“需设备校验”的 target-private 调用。

---

## 6. 依赖地图（哪些公开、哪些闭源）

`crates/bluetooth-audio-device/Cargo.toml` 指向 `../../../Canopus/sdk/rust/...`：

| crate | 作用 | 状态 |
| --- | --- | --- |
| `canopus-abi` | `ModuleDescriptorV1`、flags、ABI 版本、`ContextV1`/`StatusWriterV1` | 闭源（结构可从公开仓库反推，本文件已还原） |
| `canopus-runtime` | `status_put_u32` / `status_writer_publish` 等 | 闭源 |
| `canopus-ui-core` | `Snapshot` / `NodeKind` / `TextStyle` 语义模型 | 闭源 |
| **`canopus-target-private`** | **每个固件的符号地址表**（`app_install`、`launcher_add`、`app_lookup`、`lvx_*`、`nuttx_*`、`canopus_identity_guard` 的真实地址）+ `TARGET_ID` | **闭源，唯一真正按固件逆向出来的部分** |

构建期还依赖三个闭源产物：`targets/<id>/target.toml`（含 `firmware_sha256`）、
`canopus verify`（ELF 校验器 CLI）、`.canopus-local/module-installer-ed25519.pem`（本地开发签名私钥）。
