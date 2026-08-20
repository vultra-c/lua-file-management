# Vela_系统与工具

> 来源: 洛汐文档库
> 共 32 篇文档

---

# ROMFS /etc 总览

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/](https://docs.luoxe.cn/docs/vela/system/etc/)

p67tc 包含 AP、二级引导、工厂、OTA 和恢复环境五套独立 ROMFS；o63 本次 OTA 包中可直接提取 AP 与 OTA 两套。启动到哪个阶段，就使用该镜像内的 `/etc`。

## [五套环境](<#五套环境>)

环境| 主要职责| 原始文件数  
---|---|---  
AP| 正常系统、穿戴服务和快应用运行环境| p67tc 6；o63 6 个业务配置/脚本，另含 D-Bus 配置  
BL2| 启动决策、OTA 验证、工厂/恢复/AP 跳转| 6  
Factory| 产线检测、组装校准和工厂测试服务| 4  
OTA| 验证更新包并写入 BL2、Resource、AP 分区| 6  
Recovery| 恢复界面和恢复资源挂载| 3  
  
同名文件不能直接互换。例如 AP 的 `rcS` 启动日常业务服务，BL2 的 `rcS` 决定下一阶段启动哪个镜像，OTA 的 `rcS` 则执行签名验证和刷写流程。

## [o63 的主要差异](<#o63-的主要差异>)

  * AP 增加 `dbus-1/system.conf` 与 `dbus-1/system.d/`，供系统 D-Bus 守护进程定义总线策略；
  * AP 不含 p67tc 的 `miwear_product.json`、`md5test.txt`；产品能力更多来自拆分的 vendor/system/app 分区；
  * `rc.sysinit` 分别挂载 `/dev/vendor`、`/dev/system`、`/dev/app`、`/dev/misc`、`/dev/i18n`、`/dev/font`、`/dev/watchface`、`/dev/quickapp`、`/dev/factory`；
  * o63 将 `/dev/data` 以 FATFS/exFAT 挂载到 `/data`，将 `/dev/userlog` 挂到 `/log`，不沿用 p67tc 的 `/dev/nand_data` YAFFS 路径；
  * `rcS` 增加 `dkf_iccoa` 与 `account`，分别支撑数字车钥匙和 `service.miaccount`。


各子页保留 p67tc 原始文件逐项解释；遇到上述 o63 差异时以本节和接口页的机型可用性为准。

## [启动关系](<#启动关系>)
    
    
    flowchart TD
        BL2["BL2 /etc"] --> CHECK{"复位原因与系统状态"}
        CHECK -->|正常| AP["AP /etc"]
        CHECK -->|未完成工厂流程| FACTORY["Factory /etc"]
        CHECK -->|恢复模式| RECOVERY["Recovery /etc"]
        CHECK -->|OTA 包| OTA["OTA /etc"]
        OTA -->|更新完成后重启| BL2

## [文件目录](<#文件目录>)

### [AP](<#ap>)

  * [build.prop](</docs/vela/system/etc/ap/build-prop/>)
  * [font_config.json](</docs/vela/system/etc/ap/font-config-json/>)
  * [dbus-1/system.conf](</docs/vela/system/etc/ap/dbus-system-conf/>)
  * [dbus-1/system.d](</docs/vela/system/etc/ap/dbus-system-d/>)
  * [miwear_product.json](</docs/vela/system/etc/ap/miwear-product-json/>)
  * [md5test.txt](</docs/vela/system/etc/ap/md-5-test-txt/>)
  * [init.d/rc.sysinit](</docs/vela/system/etc/ap/rc-sysinit/>)
  * [init.d/rcS](</docs/vela/system/etc/ap/rcs/>)


### [BL2](<#bl2>)

  * [build.prop](</docs/vela/system/etc/bl-2/build-prop/>)
  * [key.avb](</docs/vela/system/etc/bl-2/key-avb/>)
  * [recovery_reset.sh](</docs/vela/system/etc/bl-2/recovery-reset/>)
  * [md5test.txt](</docs/vela/system/etc/bl-2/md-5-test-txt/>)
  * [init.d/rc.sysinit](</docs/vela/system/etc/bl-2/rc-sysinit/>)
  * [init.d/rcS](</docs/vela/system/etc/bl-2/rcs/>)


### [Factory](<#factory>)

  * [build.prop](</docs/vela/system/etc/factory/build-prop/>)
  * [md5test.txt](</docs/vela/system/etc/factory/md-5-test-txt/>)
  * [init.d/rc.sysinit](</docs/vela/system/etc/factory/rc-sysinit/>)
  * [init.d/rcS](</docs/vela/system/etc/factory/rcs/>)


### [OTA](<#ota>)

  * [build.prop](</docs/vela/system/etc/ota/build-prop/>)
  * [key.avb](</docs/vela/system/etc/ota/key-avb/>)
  * [recovery_reset.sh](</docs/vela/system/etc/ota/recovery-reset/>)
  * [md5test.txt](</docs/vela/system/etc/ota/md-5-test-txt/>)
  * [init.d/rc.sysinit](</docs/vela/system/etc/ota/rc-sysinit/>)
  * [init.d/rcS](</docs/vela/system/etc/ota/rcs/>)


### [Recovery](<#recovery>)

  * [md5test.txt](</docs/vela/system/etc/recovery/md-5-test-txt/>)
  * [init.d/rc.sysinit](</docs/vela/system/etc/recovery/rc-sysinit/>)
  * [init.d/rcS](</docs/vela/system/etc/recovery/rcs/>)


## [rc.sysinit 与 rcS 的区别](<#rc-sysinit-与-rcs-的区别>)

本固件中可以按以下方式理解：

  * `rc.sysinit`：先建立运行环境，重点是挂载文件系统、属性/数据库守护进程和基础日志；
  * `rcS`：在挂载完成后启动该镜像真正负责的业务，或决定下一阶段启动目标。


脚本没有 shebang，由固件 init/NSH 以系统 shell 语法解释。`set +e` 表示命令失败后继续；`set -e` 表示后续命令失败时终止当前脚本。后台符号 `&` 让 daemon 启动后脚本继续执行。

## [关于 `_romfs_manifest.tsv`](<#关于-romfs-manifest-tsv>)

各提取目录里的 `_romfs_manifest.tsv` 由本项目的 ROMFS 解包脚本生成，记录 inode 偏移、节点类型、文件长度和解包路径。它不在原始 ROMFS 中，不会被设备读取，也不是系统配置。重打包时不要把它放回 `/etc`。

节点类型中常见值：

类型| 含义  
---|---  
`1`| 目录  
`2`| 普通文件  
`3`| 符号链接  
  
## [修改边界](<#修改边界>)

这些 `/etc` 位于 ROMFS，运行时通常只读。临时行为优先通过 `/data`、属性或手动启动服务验证；永久修改需要重建对应 ROMFS、保持镜像尺寸和对齐，并处理 AP/BL2/OTA 的校验或签名链。

---

# AP build.prop

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/build-prop/](https://docs.luoxe.cn/docs/vela/system/etc/ap/build-prop/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 221 字节  
SHA-256| `3eef024dac2f19bc73db5374c01e3b30c6e4c43070834b12b3203f9afe1810f0`  
使用阶段| 正常 AP 系统  
  
这是正常系统的只读构建属性。系统属性服务可把这些键暴露给 `getprop`、设备信息接口、UI 布局和兼容性判断。

## [属性解释](<#属性解释>)

属性| 样本值| 含义  
---|---|---  
`ro.build.version`| `3.101.036`| 面向系统组件比较的固件版本  
`ro.build.customer_version`| `CONBINE_LTALM078_T3.101.036_06242053`| 厂商构建/交付版本，尾段看起来包含构建批次或时间标识  
`ro.product.device.screenshape`| `rect`| 屏幕形状为矩形，影响布局和资源选择  
`ro.product.device.devicetype`| `band`| 产品类型为手环  
`ro.sf.lcd_density`| `336`| 逻辑屏幕密度，影响 dp/px 换算和资源匹配  
`ro.build.id`| `CONBINE_LTALM078_T3.101.036`| 构建标识，不含 customer version 的批次后缀  
  
`ro.*` 通常是启动后只读属性。直接执行 `setprop ro.build.version ...` 很可能失败或只产生短暂覆盖；永久改变需要修改 ROMFS 并重刷 AP。

## [与其他镜像的差异](<#与其他镜像的差异>)

AP 与 Factory 的该文件完全相同。BL2/OTA 版本没有 `ro.sf.lcd_density`，且 `customer_version` 被缩短；这是因为引导和升级环境不需要完整 UI/产品属性。

## [o63 机型值](<#o63-机型值>)

属性| Xiaomi Watch S4 41mm o63  
---|---  
`ro.build.version`| `3.100.028`  
`ro.ota.version`| `1`  
`ro.product.device.devicetype`| `watch`  
`ro.product.device.screenshape`| `circle`  
`ro.sf.lcd_density`| `352`  
`ro.build.id`| `3.100.028`  
  
o63 文件为 160 字节，SHA-256 为 `6c7f90c4c480b54a2d593227e5f017459e8da514024f686f164eb4fbc4a1886d`。它不含 p67tc 的 `ro.build.customer_version`。应用应读取属性而不是根据文档硬编码屏幕形状、设备类型或 density。

## [修改影响](<#修改影响>)

  * 改版本号可能影响升级比较、日志标识和兼容性分支，但不会改变实际代码；
  * 改 `devicetype` 或 `screenshape` 可能让 UI 选错布局；
  * 改 density 会改变快应用和系统 UI 的缩放，可能造成触控坐标与显示不一致；
  * 伪造 build id 不能绕过镜像签名或 API 白名单。

---

# AP D-Bus system.conf

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/dbus-system-conf/](https://docs.luoxe.cn/docs/vela/system/etc/ap/dbus-system-conf/)

o63 新增的系统 D-Bus 总线配置，p67tc AP `/etc` 未包含该文件。它决定系统总线的监听地址、服务激活、默认消息策略和附加配置目录。

## [关键配置](<#关键配置>)

项目| o63 配置| 作用  
---|---|---  
总线类型| `system`| 创建系统级总线而非用户 session bus  
Unix socket| `/var/run/dbus/system_bus_socket`| 本核进程连接入口  
RPMsg listener| `rpmsg:name=dbus_socket`| 让远端核通过 RPMsg 连接 D-Bus  
服务目录| `standard_system_servicedirs`| 搜索标准 `.service` 激活描述  
service helper| `/usr/lib/dbus-1.0/dbus-daemon-launch-helper`| 按需启动系统服务的 helper 路径  
日志| `syslog`| 把 daemon 日志送到系统日志后端  
配置目录| 相对 `system.d` 与 `/etc/dbus-1/system.d`| 加载各服务的策略片段  
本地覆盖| `/etc/dbus-1/system-local.conf`| 文件存在时最后加载  
  
## [默认策略](<#默认策略>)

o63 配置允许所有用户连接、拥有 bus name、发送 method call、signal、reply，并接收所有主要消息类型。它只对 `org.freedesktop.DBus` 的少数管理接口做显式拒绝，例如更新激活环境、调试统计和 systemd activator；root 仍可使用 Monitoring 与 Stats。

这比常见桌面 Linux 的 system bus 默认策略宽松。真正的访问控制可能继续在服务端方法、调用方凭据、RPMsg 对端或系统应用签名层执行，但不能假定它们一定存在。

## [修改影响](<#修改影响>)

  * 新增 `listen` XML 元素会扩大可连接面，可能把系统服务暴露给非预期进程或远端核；
  * 放宽 `allow`/移除 `deny` 可能允许应用调用关机、帐号、密钥等高权限服务；
  * 收紧规则可能导致 `account`、`dkf_iccoa`、MiConnect 或其他系统进程启动后无法通信；
  * ROMFS 只读，永久修改需要重建 AP 镜像；仅在 `/data` 放同名文件不会自动覆盖本配置。


系统包含 `system-local.conf` 的可选入口，但 o63 没有提供该文件，也没有证明启动时会从可写分区绑定覆盖 `/etc`。如果要实验，优先复制配置到独立环境并以显式 `dbus-daemon --config-file` 启动测试总线，不要直接替换正在工作的系统总线。

## [机型可用性](<#机型可用性>)

机型/样本| 结果  
---|---  
Xiaomi Watch S4 41mm（o63）| 文件存在，包含 Unix 与 RPMsg 两个 listener  
Xiaomi Smart Band 10 Pro（p67tc）| AP `/etc` 未发现该文件  
  
## [获取源代码](<#获取源代码>)

  * [D-Bus bus configuration manual](<https://dbus.freedesktop.org/doc/dbus-daemon.1.html>)

---

# AP D-Bus system.d

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/dbus-system-d/](https://docs.luoxe.cn/docs/vela/system/etc/ap/dbus-system-d/)

`system.d` 是 D-Bus 系统服务策略片段目录。`system.conf` 同时加载相对 `system.d` 和绝对 `/etc/dbus-1/system.d`；正常情况下服务可在这里用独立 `.conf` 文件声明可拥有的 bus name、可调用的接口和允许用户。

o63 ROMFS 中该位置只有一个零字节 `.gitkeep` 占位文件，提取路径表现为 `dbus-1/system.d/system.d/.gitkeep`，没有实际 `.conf` 策略。`.gitkeep` 不是 D-Bus 规范文件，daemon 不会把它当成策略。

## [如何添加策略](<#如何添加策略>)

典型策略文件需要以 `.conf` 结尾并包含 `busconfig` 根节点。添加前必须先确定服务的 bus name、接口、调用用户及最小权限；不要复制“allow all”模板。错误策略可能让服务无法拥有名称，或让普通进程访问帐号、数字钥匙和设备控制接口。

该目录位于 AP ROMFS。要让系统 daemon 自动读取新增文件，需要重建镜像或在 daemon 启动前把可写目录挂载到对应路径；仅创建 `/data/dbus-1/system.d` 不会生效，除非同时修改启动参数或挂载关系。

## [机型可用性](<#机型可用性>)

机型/样本| 结果  
---|---  
Xiaomi Watch S4 41mm（o63）| 目录存在，只有空占位文件  
Xiaomi Smart Band 10 Pro（p67tc）| AP `/etc` 未发现该目录  
  
## [获取源代码](<#获取源代码>)

  * [D-Bus bus configuration manual](<https://dbus.freedesktop.org/doc/dbus-daemon.1.html>)

---

# AP font_config.json

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/font-config-json/](https://docs.luoxe.cn/docs/vela/system/etc/ap/font-config-json/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 18887 字节  
SHA-256| `4179aae0a85c134e66f7b099669f15204f01813a7a754d03d88a83ca1166354e`  
顶层字段| `emoji-list`、`font-family`  
  
该文件是 AP 字体回退和图片 Emoji 路由表。它不会把字体嵌入系统，而是告诉字体管理器：主字体缺少字形时按什么顺序回退，以及特定 Unicode 应从哪个资源目录加载图片。

## [emoji-list](<#emoji-list>)

共 7 条规则：

字体名| 资源目录| 格式| 匹配字号| Unicode 范围数  
---|---|---|---|---  
`Emoji_Local`| `/resource/system/whatsapp/`| `.bin`| 24–40| 186  
`Emoji_WeChat`| `/resource/system/wechat/emoji24/`| `.png`| 24–29| 2  
`Emoji_WeChat`| `/resource/system/wechat/emoji30/`| `.png`| 30–31| 2  
`Emoji_WeChat`| `/resource/system/wechat/emoji32/`| `.png`| 32–33| 2  
`Emoji_WeChat`| `/resource/system/wechat/emoji34/`| `.png`| 34–37| 2  
`Emoji_WeChat`| `/resource/system/wechat/emoji38/`| `.png`| 38–41| 2  
`Emoji_WeChat`| `/resource/system/wechat/emoji42/`| `.png`| 42–60| 2  
  
`unicode-range` 使用十进制码点的闭区间 `begin/end`。渲染器先按码点判断规则，再根据 `match-size` 选择最接近当前字号的资源目录。

示例结构：
    
    
    {
      "font-name": "Emoji_WeChat",
      "path": "/resource/system/wechat/emoji32/",
      "ext": ".png",
      "match-size": { "min": 32, "max": 33 },
      "unicode-range": [
        { "begin": 57345, "end": 57379 }
      ]
    }

## [font-family](<#font-family>)

共定义 8 条 MiSans 回退链：

主字体| 回退顺序  
---|---  
`MiSans-Demibold`| Demibold-All → Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Demibold-All`| Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Semibold`| Demibold-All → Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Semibold-All`| Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Medium`| Medium-All → Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Medium-All`| Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Regular`| Regular-All → Emoji_Local → Emoji_WeChat  
`MiSans-Regular-All`| Emoji_Local → Emoji_WeChat  
  
带 `-All` 的字体承担更完整字符集回退；Emoji 位于链尾，避免普通字符被图片资源抢占。

## [修改与扩展](<#修改与扩展>)

可以通过新增 Unicode 区间或回退字体支持额外字符，但必须同时把对应字体/图片放入 `/resource`，并确保字体管理器认识该名称。区间重叠时的优先级取决于数组顺序，错误配置可能导致普通符号被替换成微信或 WhatsApp 图片。

这是 AP ROMFS 文件；只改 `/resource` 而不改路由表，或只改路由表而不提供资源，都不会得到完整效果。

## [o63 机型差异](<#o63-机型差异>)

o63 文件为 3677 字节，SHA-256 为 `1af826acde44952bd9f98b560f3fa77d76aebee2314265bc8c070978860e412a`。顶层字段相同，但字体链缩为 6 条，并使用 `MiSans-Demibold-subset`、`MiSans-Regular-subset` 等圆表资源名称；`Emoji_Local` 规则只保留 2 段 Unicode 范围，匹配字号为 30–40。

字体配置不能跨机型覆盖。p67tc 的完整字符集资源名和 o63 的 subset 资源名不同，复制 JSON 而不同时复制匹配字体文件会造成找不到字体、缺字或内存占用异常。

---

# AP md5test.txt

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/md-5-test-txt/](https://docs.luoxe.cn/docs/vela/system/etc/ap/md-5-test-txt/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2016 字节  
SHA-256| `9fc6eec8c55755632e926389b0753147c20fbbc63fde44d32e11091b89445ad5`  
内容| 32 行固定 ASCII 测试串  
  
每行都是：
    
    
    0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ

单行 62 个可见字符加一个换行，共 63 字节；32 行正好是 2016 字节。

## [含义](<#含义>)

它不是 MD5 校验清单：文件中没有路径和摘要。更合理的用途是文件系统/ROMFS/哈希实现的固定输入样本，可用于产测或启动阶段验证读取和摘要结果是否稳定。

AP、BL2、Factory、OTA、Recovery 五份 `md5test.txt` 完全相同，说明它来自公共 ROMFS 模板，而不是某个阶段的业务配置。二进制中出现文件名只证明它被打入镜像，不能证明启动脚本会自动执行测试。

## [修改影响](<#修改影响>)

正常业务不应依赖该文件。若有隐藏的产测命令比较预期 MD5，修改内容会让自检失败；删除它也可能让产测工具报告缺少测试样本。它不能用于开启 Feature、绕过签名或修改系统版本。

---

# AP miwear_product.json

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/miwear-product-json/](https://docs.luoxe.cn/docs/vela/system/etc/ap/miwear-product-json/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 1168 字节  
SHA-256| `5a73032ae4ba974a64d3a935ba724da80a6e422b88e187b7982028a52a5b1ea1`  
加载程序| AP `rcS` 中的 `miwear_product_load`  
  
该文件把硬件 `board_id` 映射为销售型号、MiWear 设备名和产品 ID，使同一 AP 镜像可以服务多个区域/硬件变体。

## [产品映射](<#产品映射>)

board_id| device_model| miwear_model| miwear_pid| 区域线索  
---|---|---|---|---  
20| `M2551B1`| `miwear.watch.p67cn`| `29598`| 中国大陆  
21| `M2552B1`| `miwear.watch.p67gl`| `29601`| 全球版  
22| `M2558B1`| `miwear.watch.p67gln`| `33343`| 全球变体  
23| `M2553B1`| `miwear.watch.p67tc`| `29599`| 台港等繁中变体  
24| `M2559B1`| `miwear.watch.p67glt`| `29600`| 全球变体  
  
五条记录的 `device_name` 都是 `Xiaomi Smart Band 10 Pro`。

## [字段意义](<#字段意义>)

字段| 用途  
---|---  
`board_id`| 从板级/efuse/工厂信息读取的硬件变体编号  
`device_name`| 展示名称  
`device_model`| 对外型号，如配对、升级和售后识别  
`miwear_model`| MiWear 软件产品命名空间  
`miwear_pid`| 小米穿戴服务使用的数字产品 ID  
  
## [启动时行为](<#启动时行为>)

正常 AP 启动且 `/data/nobusiness` 不存在时，`miwear_product_load` 在 Bluetooth、MiWear、健康等服务之前运行。它很可能把匹配记录写入系统属性或共享产品配置，供后续 daemon 使用。

## [修改风险](<#修改风险>)

改映射可以实验性伪装区域型号，但不会改变射频、NFC、传感器或认证硬件。错误的 PID/model 可能导致：

  * 手机端无法识别或绑定；
  * OTA 查询到错误产品包；
  * 云服务、表盘商店和地区功能错配；
  * 应用根据 `system.device` 返回值走错兼容分支。


不要把其他机型记录直接追加到这里后期待硬件兼容；该文件只做身份映射，不提供驱动。

---

# AP rcS

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/rcs/](https://docs.luoxe.cn/docs/vela/system/etc/ap/rcs/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 289 字节  
SHA-256| `2aa992437f4f52fbda7e0884701e6044ecb269d942696ced0d0654c9c3743f0a`  
阶段| AP 业务服务启动  
  
## [错误处理](<#错误处理>)

脚本先执行 `set +e`，随后立刻执行 `set -e`，因此最终生效的是遇错退出。某个前台命令失败可能阻止后续服务启动；带 `&` 的后台进程启动失败通常不会像同步命令那样提供可靠状态。

## [`/data/nobusiness` 总开关](<#data-nobusiness-总开关>)

脚本只有在 `/data/nobusiness` 不是目录时才启动主要业务：
    
    
    if [ ! -d /data/nobusiness ];then
      # 主要业务服务
    fi

这个目录相当于维修/无业务模式开关。它存在时会一起停掉产品映射、蓝牙业务、健康、MiConnect、振动等服务，但脚本末尾的 `at_cmd` 仍会启动。

## [服务解释](<#服务解释>)

命令| 作用| 影响的上层能力  
---|---|---  
`miwear_product_load`| 根据 `miwear_product.json` 加载型号/PID| 设备身份、配对、地区能力  
`bluetoothd`| 蓝牙核心 daemon| BLE/连接  
`miwear_bluetooth`| MiWear 蓝牙业务层| 手机配对与数据同步  
`miwear_algo_service`| 穿戴算法服务| 运动/健康算法  
`miwear_activity_service`| Activity/Service 桥| `system.internal.activity`  
`miwear_capture_service`| 捕获/采集服务| 截图、采集或诊断类能力  
`nfc_stack_bridge`| NFC 协议栈桥| 门卡/支付/NFC 应用  
`miconnect`| 小米互联通信，输出重定向到 `/dev/log`| 消息中心、互联  
`miwear`| 穿戴主业务进程| UI 和系统业务协调  
`charger_manage`| 充电状态管理| 电池/充电 UI 与策略  
`vibratord`| 振动服务| `system.vibrator`  
`healthd`| 健康数据服务| `service.health`、系统健康应用  
`at_cmd`| AT/诊断命令服务| 调试、工厂或售后通信  
  
## [修改方案](<#修改方案>)

若 `/data/nobusiness` 误存在，优先改名后重启，不必修改 ROMFS：
    
    
    mv /data/nobusiness /data/nobusiness.disabled
    sync
    reboot

若只想恢复一个服务，可在 shell 中确认没有同名进程后手动启动，例如 `healthd &`。永久改脚本需要重建 AP 内嵌 ROMFS，并同步处理镜像校验。

## [o63 服务差异](<#o63-服务差异>)

o63 的 `rcS` 使用 `set +e`，不会因单个服务失败立即终止。启动顺序是：

  1. `sensor_middle_service`；
  2. `nfc_stack_bridge`；
  3. `miconnect`；
  4. `dkf_iccoa`；
  5. 若不存在 `/data/nobusiness`，启动 `miwear` 与 `miwear_algo_service`；
  6. 根据 `/data/nolowpower`、`/data/logmaskr` 调整电源/日志；
  7. 启动 `account`。


`dkf_iccoa` 与 `account` 位于 `nobusiness` 条件之外，因此创建该目录不会关闭数字钥匙和帐号 daemon；这与 p67tc “大量业务一起停掉”的行为不同。o63 也没有在脚本中单独启动 `healthd`、`miwear_capture_service` 或 `vibratord`，相应能力可能已合入主进程/算法服务或由其他启动机制提供，不能照抄 p67tc 的手动启动命令。

---

# AP rc.sysinit

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ap/rc-sysinit/](https://docs.luoxe.cn/docs/vela/system/etc/ap/rc-sysinit/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 403 字节  
SHA-256| `c68d54f0826f7b6bd12ca57f74d1f76ba6f92e0e14f2490bf9f1059a2e28e90f`  
阶段| AP 最早期系统初始化  
  
该脚本先建立正常系统需要的挂载点，再启动基础守护进程。

## [命令逐项解释](<#命令逐项解释>)

命令| 含义  
---|---  
`set +e`| 个别命令失败后继续执行，避免一个挂载失败阻止整个 AP 启动  
`mount -t procfs /proc`| 提供进程和内核状态接口  
`mount -t tmpfs /tmp`| 建立易失临时目录  
`pmconfig stay normal`| 把电源管理状态设置/保持在正常模式  
`mount -t romfs /dev/resource /resource`| 挂载只读资源分区  
`mount -t yaffs -o autoformat /dev/nand_data /data`| 挂载用户/应用数据；无法识别时可能自动格式化  
`mount -t littlefs -o autoformat /dev/nv /misc`| 把 NV 分区作为 `/misc`，保存属性/状态类数据  
`mount -t littlefs -o autoformat /dev/mode /mode`| 挂载模式分区，保存启动/工作模式  
`offline_log start -w &`| 启动离线日志写入  
`kvdbd &`| 启动键值数据库服务，供属性或系统组件使用  
`system_trace`| 初始化系统追踪设施  
`miwear_rtc_checker`| 检查/修正穿戴设备 RTC 状态  
  
## [关键风险](<#关键风险>)

`autoformat` 很重要：当文件系统损坏或类型不匹配时，挂载器可能直接格式化分区。修改分区节点、文件系统类型或挂载顺序前必须先备份 `/data`、`/misc` 和 `/mode`。

`/resource` 是只读 ROMFS，正常运行时不能直接覆盖其中资源；`/data`、`/misc`、`/mode` 才是持久可写区域。

## [与 rcS 的关系](<#与-rcs-的关系>)

只有这些挂载和基础服务完成后，AP `rcS` 才能读取 `/data/nobusiness`、加载产品映射并启动 MiWear、健康、连接和振动服务。

## [o63 差异](<#o63-差异>)

o63 不使用上表的单一 `/dev/resource` 与 YAFFS `/dev/nand_data`。它把 vendor、system、app、misc、i18n、font、watchface、quickapp、factory 九个 ROMFS 分别挂载，使用 `fsckexfat` 检查 `/dev/data` 后挂到 `/data`，并把 `/dev/userlog` 挂到 `/log`。

它还启动 audio/cp/sensor 三个 RPMsg 远端核，挂载 `rpmsgfs`，运行 `sensor_load`、`kvdbd` 与 RTC checker。任何精简启动方案都必须保留与硬件协处理器的初始化顺序，否则主 UI 可能启动但音频、传感器或安全服务不可用。

---

# BL2 build.prop

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/build-prop/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/build-prop/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 203 字节  
SHA-256| `7ed497f987f8ab85a310a3df4bc7159a410d534130071fd63bdfc740a38c73d0`  
使用阶段| 二级引导环境  
  
BL2 的构建属性用于引导日志、版本识别和少量设备类型判断。它比 AP 版本精简。

## [属性](<#属性>)

属性| 值| 说明  
---|---|---  
`ro.build.version`| `3.101.036`| 与 AP 对齐的系统版本  
`ro.build.customer_version`| `CONBINE_LTALM078_T`| 精简的产品构建族标识  
`ro.product.device.screenshape`| `rect`| 矩形屏幕  
`ro.product.device.devicetype`| `band`| 手环产品  
`ro.build.id`| `CONBINE_LTALM078_T3.101.036`| 完整构建 ID  
  
BL2 没有 `ro.sf.lcd_density`，因为引导阶段不承担正常 AP UI 的密度布局。它和 OTA 的 `build.prop` 完全相同。

## [修改影响](<#修改影响>)

改这里不会改变 AP 启动后的 `getprop` 结果，因为 AP 会使用自己的 `/etc/build.prop`。它可能影响 BL2/OTA 版本日志或引导侧的兼容检查。若想伪造整机版本，需要同时理解 AP、BL2、OTA 和升级服务各自读取哪套属性，单改一份容易造成版本不一致。

---

# BL2 key.avb

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/key-avb/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/key-avb/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 520 字节  
SHA-256| `da7ef021ca05ef66f940a98aa795c9aba83bb1e399073a7a2762c332c9ca38fe`  
用途| 验证 `/ota/vela_ota.bin`  
  
这是 AVB 格式的 RSA 公钥数据，不是私钥，也不是证书。BL2 `rcS` 在从 OTA ZIP 启动更新环境前执行：
    
    
    avb_verify /ota/vela_ota.bin /etc/key.avb

验证失败会清理 OTA 状态、删除 `/data/ota.zip` 并重启。

## [二进制结构](<#二进制结构>)

520 字节符合 AVB RSA-2048 公钥结构：

区域| 长度| 含义  
---|---|---  
`key_num_bits`| 4| 大端值 `2048`  
`n0inv`| 4| Montgomery 运算参数，样本值 `0x63f48b51`  
`modulus`| 256| RSA 模数  
`rr`| 256| `R² mod n` 预计算值  
  
AVB blob 通常不单独保存私钥或完整 X.509 元数据；签名端持有对应私钥，设备只保存验证所需的公钥参数。

## [与 OTA key.avb 的关系](<#与-ota-key-avb-的关系>)

BL2 和 OTA 环境里的 `key.avb` 字节完全相同。BL2 用它验证 OTA 启动镜像，OTA 环境用同一公钥验证整个 `ota.zip`，形成同一信任根下的两阶段检查。

## [修改影响](<#修改影响>)

替换公钥只有在所有验证阶段都同步使用新密钥、相关镜像和 ZIP 都用对应私钥重新签名时才有意义。只改 BL2 key 会让官方 OTA 镜像无法通过；只改 OTA key 则可能根本无法先通过 BL2 对 `vela_ota.bin` 的验证。

即使能重打 BL2 ROMFS，BL2 自身还可能受更早启动级验证。没有硬件恢复手段时不要修改。

---

# BL2 md5test.txt

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/md-5-test-txt/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/md-5-test-txt/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2016 字节  
SHA-256| `9fc6eec8c55755632e926389b0753147c20fbbc63fde44d32e11091b89445ad5`  
  
内容是 32 行相同的 62 字符 ASCII 序列，不包含任何摘要或文件路径。它更像 BL2 ROMFS/哈希/存储测试使用的固定输入样本，而不是启动镜像校验数据库。

BL2 真正的 OTA 完整性检查使用 `key.avb`、`avb_verify` 和 OTA ZIP 验证流程，与这个文本文件没有直接关系。

五套 `/etc` 的 `md5test.txt` 完全相同，说明它由公共构建模板复制。删除或修改可能影响隐藏的产测命令，但不会关闭 AVB，也不能绕过 OTA 签名。

---

# BL2 rcS

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/rcs/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/rcs/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2370 字节  
SHA-256| `b65efc082cec87cad53ffcf3c30e6cbf627853a0be604719d4857e2db5f53831`  
阶段| 启动目标选择与 OTA 引导  
  
这是五套脚本中最关键的一份。它根据复位原因、OTA 状态、恢复标志和工厂完成状态决定启动 OTA、Recovery、Factory 还是正常 AP。

## [调试设置](<#调试设置>)

  * `set +e`：命令失败后继续；
  * `set -x`：把执行的命令展开输出到日志，便于分析引导失败。


## [复位原因处理](<#复位原因处理>)

reset cause| 动作  
---|---  
`cpu_soft_reset(restore)`| 执行 `recovery_reset.sh` 格式化 `/data`  
`cpu_soft_reset(factory)`| 同样格式化 `/data`  
`cpu_soft_reset(bootloader)`| 调用厂商 `rb` 工具后重启  
  
`rb -f /dev --skip_prefix vela_ --skip_suffix .bin` 的实现不在当前开源材料中。从参数只能确认它针对 `/dev` 并过滤特定名称，不能安全地把它解释成普通删除或刷写命令。

## [OTA 包探测](<#ota-包探测>)

如果 `/data/ota.zip` 存在，BL2 会：

  1. 以 zipfs 挂载到 `/ota`；
  2. 读取 `persist.ota.inprocess`；
  3. 非更新中状态会清零 `persist.bl2.ota.trytimes`；
  4. 更新中则增加重试计数；超过 5 次时清理 OTA 文件和状态并重启。


这套计数避免设备反复启动失败的 OTA 环境形成永久循环。

## [启动 OTA 环境](<#启动-ota-环境>)

当 reset cause 为 recovery，或 `persist.ota.inprocess=1` 时：
    
    
    avb_verify /ota/vela_ota.bin /etc/key.avb
    cp -f /ota/vela_ota.bin /data/vela_ota.bin
    boot /data/vela_ota.bin

只有 AVB 验证成功才把 OTA 镜像复制到 `/data` 并启动。失败会复位预检查状态、标记 `persist.ota_fail=1`、删除 OTA ZIP 并重启。

## [Recovery 与 Factory 分支](<#recovery-与-factory-分支>)

条件| 动作  
---|---  
`boot_reset_flag=1`| 挂载 `/resource`，启动 `/resource/prebuild/vela_recovery.bin`  
`ro.factory.finished != 1`| 挂载 `/resource`，启动 `/resource/prebuild/vela_factory.bin`  
  
`miwear_recovery_boot` 在读取 `boot_reset_flag` 前运行，可能负责更新恢复状态或对接恢复服务。

## [正常 AP 分支](<#正常-ap-分支>)

没有命中前述分支时，脚本强制卸载 `/data`，打印 `System Mode (AP)`，随后执行无参数 `boot`。BL2 由此把控制权交给默认 AP 分区。

## [可修改的启动策略](<#可修改的启动策略>)

  * 修改 `boot_reset_flag` 可以请求 Recovery，但具体属性存储和清除时机由 `miwear_recovery_boot` 决定；
  * 修改 `ro.factory.finished` 可能强制进入 Factory；
  * 放置 `/data/ota.zip` 只会触发探测，仍必须通过 ZIP/AVB 验证；
  * 删除 OTA 状态前应同时理解 `persist.ota.inprocess`、`persist.ota.precheck.finished` 和 retry 次数，避免半更新状态。


永久修改该脚本需要重建 BL2 ROMFS；BL2 是启动链关键部分，风险高于修改 AP。

---

# BL2 rc.sysinit

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/rc-sysinit/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/rc-sysinit/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 325 字节  
SHA-256| `5e538725470f03bbc30fe40c355f40ea54e3fada2dc6f5a8b5df542280def784`  
阶段| BL2 基础挂载与工厂信息同步  
  
## [挂载项](<#挂载项>)

挂载点| 设备| 文件系统/选项| 用途  
---|---|---|---  
`/tmp`| 内存| tmpfs| 引导临时文件  
`/data`| `/dev/nand_data`| YAFFS `autoformat`| 应用和系统数据  
`/wasted_nv`| `/dev/nand_nv`| YAFFS `autoformat`| 旧/废弃或兼容 NV 数据区域  
`/mode`| `/dev/mode`| LittleFS| 启动模式状态  
`/misc`| `/dev/nv`| LittleFS `autoformat`| 持久属性和引导状态  
  
BL2 没有挂载 `/resource` 或 procfs；这些只在需要时由后续 `rcS` 或目标镜像处理。

## [启动命令](<#启动命令>)

命令| 作用  
---|---  
`kvdbd &`| 为 `getprop/setprop` 等持久状态提供键值数据库服务  
`fac_assemble`| 读取/组装工厂数据、板级身份或校准信息  
`factory_sync`| 把工厂信息同步到当前系统可用位置  
  
`fac_assemble` 和 `factory_sync` 是厂商命令，公开源码不足以还原所有字段。它们在 BL2 启动决策之前运行，说明板级身份和工厂状态可能直接影响是否进入 Factory 以及后续产品配置。

## [修改风险](<#修改风险>)

更改 `/misc`、`/mode` 的挂载设备会破坏 OTA 重试计数、factory finished 等属性。`/wasted_nv` 名称虽然像废弃区，也不应在未确认数据格式前清空。

---

# BL2 recovery_reset.sh

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/bl-2/recovery-reset/](https://docs.luoxe.cn/docs/vela/system/etc/bl-2/recovery-reset/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 256 字节  
SHA-256| `1bf971b1e548d02682f48591fd71590af6d6276c675809003f58fc1f16217bc2`  
调用条件| reset cause 为 `restore` 或 `factory`  
  
这是恢复出厂数据清理脚本。BL2 `rcS` 检测到 `cpu_soft_reset(restore)` 或 `cpu_soft_reset(factory)` 时调用它。

## [实际操作](<#实际操作>)
    
    
    set +e
    umount -f /data
    mount -t yaffs -o forceformat /dev/nand_data /data

步骤含义：

  1. 关闭遇错退出；
  2. 强制卸载 `/data`；
  3. 使用 YAFFS `forceformat` 重新格式化 NAND 数据分区并挂载回来。


因此它清理的核心是 `/dev/nand_data`，会删除已安装快应用、应用数据、系统数据库和位于 `/data` 的 OTA 临时文件。

## [被注释的 SST 清理](<#被注释的-sst-清理>)

脚本还保留了一段注释代码，原计划挂载 `/dev/sst` 并删除 `/sst/00000080`：
    
    
    # mount -t littlefs /dev/sst /sst
    # rm -r /sst/00000080

SST 通常用于安全存储或受保护对象。该段被注释说明当前恢复出厂默认保留这块数据，可能是为了保留设备身份、密钥或工厂校准。不要在不了解对象含义时取消注释。

## [风险与回滚](<#风险与回滚>)

`forceformat` 是不可逆数据操作。运行前应备份 `/data`；仅把脚本改成普通 `autoformat` 不等于安全清理，也可能导致恢复出厂不彻底。OTA 环境内有完全相同的副本，但其 `rcS` 没有直接调用。

---

# Factory build.prop

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/factory/build-prop/](https://docs.luoxe.cn/docs/vela/system/etc/factory/build-prop/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 221 字节  
SHA-256| `3eef024dac2f19bc73db5374c01e3b30c6e4c43070834b12b3203f9afe1810f0`  
使用阶段| 工厂/产测镜像  
  
该文件与 AP `/etc/build.prop` 字节完全相同，包含系统版本、完整 customer version、矩形屏幕、手环类型、336 density 和 build id。

## [为什么 Factory 需要完整属性](<#为什么-factory-需要完整属性>)

Factory 环境会运行 `lc_factory` 等带 UI 和硬件测试的程序，因此仍需要：

  * `ro.sf.lcd_density=336` 选择正确的界面缩放；
  * 屏幕形状和产品类型决定测试 UI/项目；
  * 完整 customer version 用于产线日志、版本追溯和放行记录。


## [与 AP 相同不代表环境相同](<#与-ap-相同不代表环境相同>)

Factory 使用自己的可执行镜像、`rc.sysinit` 和 `rcS`。相同属性只保证产品身份一致，不会让 Factory 自动启动 AP 的 MiWear、NFC 或快应用服务。

修改 Factory 版本属性可能让产测记录与实际 AP 版本不一致，进而导致工厂放行或售后诊断误判。

---

# Factory md5test.txt

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/factory/md-5-test-txt/](https://docs.luoxe.cn/docs/vela/system/etc/factory/md-5-test-txt/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2016 字节  
SHA-256| `9fc6eec8c55755632e926389b0753147c20fbbc63fde44d32e11091b89445ad5`  
  
文件由 32 行固定 ASCII 测试串组成，与其他四套 `/etc` 完全相同。Factory 是最可能主动使用这类测试向量的环境：产测可以读取固定输入，验证文件系统、内存传输或 MD5 实现是否得到预期值。

但当前 `rc.sysinit` 和 `rcS` 都没有显式引用它，因此是否由 `lc_factory` 的隐藏测试项调用无法仅靠脚本确认。

它不是分区摘要清单，也不包含设备唯一数据。修改它不会修改工厂完成标志，但可能让相应自测项目失败。

---

# Factory rcS

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/factory/rcs/](https://docs.luoxe.cn/docs/vela/system/etc/factory/rcs/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 87 字节  
SHA-256| `7a206c310523505fb46d8c7613f7c9b42dfdca4e3f6ec198b669b58d1454e726`  
阶段| 工厂业务进程启动  
  
Factory `rcS` 很短，只启动产测所需服务：

命令| 作用  
---|---  
`bluetoothd &`| 蓝牙核心服务  
`BTCONN START &`| 厂商蓝牙连接/射频测试入口  
`charger_manage &`| 充电和供电测试支持  
`healthd &`| 健康传感器数据后端  
`vibratord &`| 马达测试后端  
`lc_factory &`| 主工厂测试应用  
  
它没有启动正常 AP 的 `miwear`、MiConnect、NFC bridge 或快应用环境，避免业务进程占用硬件并干扰测试。

## [实验价值](<#实验价值>)

Factory 镜像可用于确认 `healthd`、`vibratord` 或 Bluetooth 驱动是否在硬件层可工作。如果 Factory 能测试成功而 AP API 失败，问题更可能位于 AP 服务、权限或 Feature 层，而不是硬件本身。

不要在正常 AP 里直接同时启动 `BTCONN START` 和完整 MiWear 蓝牙栈；它们可能争用控制器。

---

# Factory rc.sysinit

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/factory/rc-sysinit/](https://docs.luoxe.cn/docs/vela/system/etc/factory/rc-sysinit/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 414 字节  
SHA-256| `919179bf0a80db6d1de30ad35f11eceb1d116bde63b716d0b24e8ceb51b7efa4`  
阶段| Factory 基础环境  
  
Factory 的挂载布局接近 AP，但更强调诊断命令和产测日志。

## [挂载](<#挂载>)

命令| 作用  
---|---  
`mount -t procfs /proc`| 提供进程/内核状态供测试读取  
`mount -t tmpfs /tmp`| 测试临时目录  
`pmconfig stay normal`| 避免产测时进入低功耗  
`mount -t romfs /dev/resource /resource`| 提供工厂图片、字体、固件等资源  
`mount -t yaffs -o autoformat /dev/nand_data /data`| 挂载持久数据区  
`mount -t littlefs -o autoformat /dev/mode /mode`| 挂载模式分区  
`mount -t littlefs -o autoformat /dev/nv /misc`| 挂载 NV/属性区  
  
## [基础服务](<#基础服务>)

服务| 用途  
---|---  
`offline_log start -w &`| 保存产测和故障日志  
`kvdbd &`| 提供属性/键值存储  
`at_cmd &`| 提前开放 AT/诊断指令通道  
`miwear_rtc_checker`| 检查 RTC  
`system_trace`| 初始化系统追踪  
  
与 AP 相比，Factory 把 `at_cmd` 放在 `rc.sysinit`，使正式工厂应用启动前就能通过外部工具控制设备。

## [修改风险](<#修改风险>)

删除 `pmconfig stay normal` 可能让长时间测试被休眠打断；关闭日志和 AT 通道会显著降低产线可诊断性。`autoformat` 仍可能在文件系统异常时格式化数据分区。

---

# OTA build.prop

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/build-prop/](https://docs.luoxe.cn/docs/vela/system/etc/ota/build-prop/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 203 字节  
SHA-256| `7ed497f987f8ab85a310a3df4bc7159a410d534130071fd63bdfc740a38c73d0`  
使用阶段| OTA 更新环境  
  
该文件与 BL2 的 `build.prop` 完全相同：版本为 `3.101.036`，产品类型为 `band`，屏幕为 `rect`，build id 为 `CONBINE_LTALM078_T3.101.036`。

OTA 环境不渲染正常系统 UI，因此没有 `ro.sf.lcd_density`，customer version 也使用缩短值 `CONBINE_LTALM078_T`。

## [用途](<#用途>)

这些属性主要用于更新日志、镜像环境识别和可能的升级脚本条件。真正决定包能否安装的仍是签名验证、版本/预检查状态和 `ota.sh` 执行结果，不是单个文本版本号。

只修改 OTA `build.prop` 不会改变刷入后的 AP 版本；更新完成后系统读取的是新 AP 自己的属性。

---

# OTA key.avb

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/key-avb/](https://docs.luoxe.cn/docs/vela/system/etc/ota/key-avb/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 520 字节  
SHA-256| `da7ef021ca05ef66f940a98aa795c9aba83bb1e399073a7a2762c332c9ca38fe`  
用途| `zip_verify ota.zip /etc/key.avb`  
  
这是 RSA-2048 AVB 公钥 blob，与 BL2 `/etc/key.avb` 完全相同。OTA `rcS` 在挂载 ZIP 和运行包内 `ota.sh` 前，用它验证 `/data/ota.zip`。

## [验证层次](<#验证层次>)

  1. BL2 使用同一公钥验证 ZIP 内的 `vela_ota.bin`；
  2. 启动 OTA 环境后，OTA 再验证整个 `ota.zip`；
  3. 验证通过才挂载 `/ota` 并执行刷写脚本。


这避免攻击者只替换 OTA ZIP 中的 AP/Resource/BL2 文件，同时保留一个合法 OTA 启动镜像。

## [格式](<#格式>)

二进制由大端 `2048` 位数值、`n0inv=0x63f48b51`、256 字节模数和 256 字节 Montgomery `rr` 组成。它不包含签名私钥。

替换它需要同时处理 BL2 信任根和所有待验证产物；单独替换会切断官方升级链。

---

# OTA md5test.txt

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/md-5-test-txt/](https://docs.luoxe.cn/docs/vela/system/etc/ota/md-5-test-txt/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2016 字节  
SHA-256| `9fc6eec8c55755632e926389b0753147c20fbbc63fde44d32e11091b89445ad5`  
  
这是公共的 32 行固定输入测试文件，不是 OTA 包中文件的 MD5 清单。OTA 的真实性检查由 `zip_verify` 和 `key.avb` 完成，分区写入则由 `dd ... verify` 做写后校验。

当前 OTA 脚本没有引用 `md5test.txt`。它可能供底层 ROMFS、摘要算法或工厂诊断命令自测。删除它不能绕过 ZIP 签名，也不会改变更新进度属性。

---

# OTA rcS

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/rcs/](https://docs.luoxe.cn/docs/vela/system/etc/ota/rcs/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 1652 字节  
SHA-256| `f34f1f21a71cef93d02f1d0d92344ad5973bdb26749477c56ea5a3828699d07d`  
阶段| OTA 包验证与刷写调度  
  
## [挂载与恢复资源](<#挂载与恢复资源>)

脚本首先挂载：

  * `/dev/resource` → `/resource`，ROMFS；
  * `/dev/nand_data` → `/data`，YAFFS `autoformat`。


它检查 `/data` 挂载返回码，但只打印错误，不立即退出。随后启动 `system_trace`，并在 `/data/recovery` 不存在时从 `/resource/recovery` 复制恢复界面资源。

## [OTA 包存在性](<#ota-包存在性>)

如果 `/data/ota.zip` 不存在，脚本调用 `miwear_recovery_ota 0`、重启并回到旧系统。这避免空 OTA 环境停留。

## [进度属性](<#进度属性>)

脚本初始化：

属性| 初始值| 用途  
---|---|---  
`ota.progress.size`| `0`| 当前写入对象大小  
`ota.progress.status`| `0`| 更新状态  
`ota.version.current`| `0`| 当前更新版本/阶段  
`ota.progress.current`| `0`| 当前百分比/阶段点  
`ota.progress.next`| `15`| 下一进度节点  
  
`miwear_recovery_ota &` 在后台根据这些属性更新恢复 UI。

## [签名验证](<#签名验证>)
    
    
    zip_verify /data/ota.zip /etc/key.avb

失败时：

  * 删除 `/data/ota.zip`；
  * 设置 `ota.progress.current=-2`；
  * 清除 `persist.ota.precheck.finished`；
  * 重启。


验证成功才把进度推进到 15，并以 zipfs 把包挂载到 `/ota`。挂载失败设置进度 `-3`、删除 ZIP 并重启。

## [执行包内 ota.sh](<#执行包内-ota-sh>)

挂载成功后：

  1. 创建 `/data/ota_tmp`；
  2. 设置 `persist.ota.inprocess=1`；
  3. 执行 `sh /ota/ota.sh > /dev/log`；
  4. 读取 `ota.progress.current`，等于 100 才打印成功；
  5. 无论成功与否都清除 `persist.ota.inprocess`；
  6. 删除临时目录、OTA ZIP 和 `/data/mass/silent_ota`；
  7. 退出，由外层恢复/引导流程处理重启。


本包的 `ota.sh` 按 BL2 → Resource → AP 顺序使用 `dd ... verify` 写入分区。中途断电可能形成跨分区版本不一致，因此不应在低电量或供电不稳定时测试。

## [修改与自定义包](<#修改与自定义包>)

仅修改 ZIP 内 `ota.sh` 会使签名验证失败。要制作自定义 OTA，需要同时解决 ZIP 签名、`vela_ota.bin` 的 AVB 验证、分区大小和更早启动链。直接把 `zip_verify` 从脚本删除也没有解决 BL2 已执行的第一层验证。

---

# OTA rc.sysinit

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/rc-sysinit/](https://docs.luoxe.cn/docs/vela/system/etc/ota/rc-sysinit/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 58 字节  
SHA-256| `84caafba06dcf66f426405c9e84a5d5e2c70b803a3c6295aa213c9c4ab931431`  
阶段| OTA 最小初始化  
  
这是五套环境中最短的 `rc.sysinit`：
    
    
    set +e
    mount -t procfs "/proc"
    mount -t tmpfs /tmp

它只建立 procfs 和临时内存文件系统。`/resource` 与 `/data` 留给 OTA `rcS` 挂载，使该脚本能检查挂载返回码并按更新逻辑处理错误。

OTA 环境不启动 `kvdbd`、MiWear、健康或 UI 业务 daemon，尽量减少更新时的资源占用和分区竞争。属性命令由该镜像的基础运行环境提供，具体持久化机制可能已经静态集成。

修改这个脚本通常没有必要；把业务服务加入 OTA 环境会增加更新失败和设备节点冲突风险。

---

# OTA recovery_reset.sh

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/ota/recovery-reset/](https://docs.luoxe.cn/docs/vela/system/etc/ota/recovery-reset/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 256 字节  
SHA-256| `1bf971b1e548d02682f48591fd71590af6d6276c675809003f58fc1f16217bc2`  
  
该脚本与 BL2 副本完全相同：强制卸载 `/data`，然后以 YAFFS `forceformat` 重新格式化 `/dev/nand_data`。

OTA `rcS` 本身没有调用它。它可能来自 BL2/OTA 共用 ROMFS 模板，或作为更新失败、人工恢复和厂商命令的备用工具存在。

脚本中清理安全存储 `/sst/00000080` 的部分被注释，因此默认不会删除该对象。不要因为文件位于 OTA 环境就认为执行它可以修复更新；它会清空用户数据，但不会自动回滚已经写入的 BL2、Resource 或 AP 分区。

---

# Recovery md5test.txt

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/recovery/md-5-test-txt/](https://docs.luoxe.cn/docs/vela/system/etc/recovery/md-5-test-txt/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 2016 字节  
SHA-256| `9fc6eec8c55755632e926389b0753147c20fbbc63fde44d32e11091b89445ad5`  
  
这是五套环境共享的固定 ASCII 测试向量：32 行数字、大小写字母序列。Recovery 的启动脚本没有引用它，因此它不是恢复项目列表、分区摘要或恢复口令。

它可能用于 ROMFS/MD5/存储诊断，或只是公共镜像模板遗留。即使删除也不会让 Recovery 绕过签名，但可能影响隐藏的诊断命令。

---

# Recovery rcS

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/recovery/rcs/](https://docs.luoxe.cn/docs/vela/system/etc/recovery/rcs/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 34 字节  
SHA-256| `3d2adaba82e9f47a9235d0ef918836228c6e2ccefa357dda05e107a3af714cb9`  
阶段| Recovery 主程序启动  
  
完整脚本只有：
    
    
    set +e
    miwear_recovery_recovery &

`miwear_recovery_recovery` 是恢复模式主程序，负责恢复 UI、用户操作和与 BL2/OTA 状态的交互。字体、i18n、表盘资源和 `/data` 已由 `rc.sysinit` 准备。

主程序放到后台后脚本结束，说明镜像 init 会继续维持系统，而不是把该进程作为前台 PID 1。若进程崩溃，脚本没有自动重启逻辑；是否有 watchdog 由系统其他部分决定。

替换这一命令可以启动自定义恢复程序，但必须保证它能处理属性、重启原因和分区操作，否则可能失去正常 OTA/恢复入口。

---

# Recovery rc.sysinit

> 来源: [https://docs.luoxe.cn/docs/vela/system/etc/recovery/rc-sysinit/](https://docs.luoxe.cn/docs/vela/system/etc/recovery/rc-sysinit/)

## [文件信息](<#文件信息>)

项目| 值  
---|---  
大小| 501 字节  
SHA-256| `047dc195c5d63beadb908ca4150ea1af879350079d85fc47bc69a2639c7a0615`  
阶段| 恢复 UI 资源准备  
  
## [基础挂载](<#基础挂载>)

挂载| 作用  
---|---  
procfs → `/proc`| 进程和内核状态  
tmpfs → `/tmp`| 临时数据  
`pmconfig stay normal`| 恢复期间保持正常功耗模式  
`/dev/resource` → `/resource`| 访问恢复资源和预置镜像  
`/dev/nand_data` → `/data`| 访问 OTA 包、备份和恢复状态  
  
`/data` 使用 YAFFS `autoformat`，文件系统损坏时仍有自动格式化风险。

## [loop 资源挂载](<#loop-资源挂载>)

脚本把三个资源文件映射为只读 loop 设备：

loop| 后端文件| 挂载点| 用途  
---|---|---|---  
`/dev/loop0`| `/resource/watchface.bin`| `/watchface`| 表盘/恢复预览资源  
`/dev/loop1`| `/resource/font.bin`| `/font`| 恢复界面字体  
`/dev/loop2`| `/resource/i18n.bin`| `/i18n`| 恢复界面多语言文本  
  
步骤是先 `losetup -r` 建立只读映射，再以 ROMFS 挂载。资源分离能让 Recovery 只加载所需内容，而不把大型资源编入 recovery 可执行镜像。

## [样本兼容性提示](<#样本兼容性提示>)

当前解出的主 Resource ROMFS 没有以普通文件形式列出这三个顶层 `.bin`，但二进制和 Recovery 脚本中仍保留名称。这可能表示资源布局来自共用脚本、文件由其他打包层提供，或该产品使用了不同资源组织。由于脚本是 `set +e`，单个 loop 挂载失败不会自动终止后续 Recovery 启动。

## [修改风险](<#修改风险>)

替换字体、i18n 或表盘 ROMFS 必须保持内部格式正确。错误的 loop 路径通常导致恢复界面缺字或资源缺失；修改 `/data` 挂载参数则可能直接破坏用户数据。

---

# Vela 文件系统总览

> 来源: [https://docs.luoxe.cn/docs/vela/system/filesystem/](https://docs.luoxe.cn/docs/vela/system/filesystem/)

当前分析样本运行的是 NuttX/Vela 风格的单一根文件系统。启动脚本把只读资源分区、可写数据分区和少量配置分区挂到固定目录；驱动则把设备接口注册到 `/dev`。因此，固件镜像里能检索到某个路径，只能说明有代码会尝试访问它，实际节点仍取决于机型、启动阶段、内核配置和硬件初始化结果。

## [启动时的主要挂载关系](<#启动时的主要挂载关系>)

设备节点| 挂载点| 文件系统| 用途  
---|---|---|---  
`/dev/resource`| `/resource`| ROMFS| 应用资源、字体、语言包、表盘、恢复程序等只读资源  
`/dev/nand_data`| `/data`| YAFFS| 用户数据、应用数据库、日志、OTA 包和运行时状态  
`/dev/nv`| `/misc`| LittleFS| 小型持久化系统配置  
`/dev/mode`| `/mode`| LittleFS| 启动/工作模式状态  
`/dev/nand_nv`| `/wasted_nv`| YAFFS| BL2 阶段使用的另一块 NAND 持久区  
  
AP、Factory 与 Recovery 会用 `autoformat` 挂载 `/data`；文件系统损坏或首次启动时可能自动格式化。BL2/OTA 的 `recovery_reset.sh` 则明确用 `forceformat` 重建 `/data`，会删除其中全部数据。

## [文档](<#文档>)

  * [/dev 设备节点](</docs/vela/system/filesystem/dev/>)：分区、终端、日志、输入、传感器、通信和硬件驱动节点。
  * [/data 目录结构](</docs/vela/system/filesystem/data/>)：快应用沙箱、原生应用数据库、健康数据、日志、OTA 与恢复文件。
  * [ROMFS /etc 总览](</docs/vela/system/etc/>)：各启动环境的挂载与服务启动脚本。


## [路径判读规则](<#路径判读规则>)

  1. 启动脚本中的 `mount`、`dd`、`losetup` 路径可直接确定用途。
  2. 二进制字符串中的路径表示对应模块包含访问逻辑，不保证该功能在本机当前系统配置下启用。
  3. `/dev` 是动态设备文件系统，不是固件包中预先存放的一组普通文件。
  4. `/data` 是可写分区，实际目录会随使用功能、配对状态和升级历史逐步创建。

---

# /data 目录结构与用途

> 来源: [https://docs.luoxe.cn/docs/vela/system/filesystem/data/](https://docs.luoxe.cn/docs/vela/system/filesystem/data/)

`/data` 是两类样本的主要可写数据分区，但底层文件系统不同：

机型/样本| 数据设备| 文件系统与挂载  
---|---|---  
Xiaomi Smart Band 10 Pro（p67tc）| `/dev/nand_data`| YAFFS；正常启动可 `autoformat`，恢复脚本可 `forceformat`  
Xiaomi Watch S4 41mm（o63）| `/dev/data`| 先 `fsckexfat -y -v`，再以 FATFS 挂到 `/data`  
  
o63 还把 `/dev/userlog` 单独挂到 `/log`，因此其在线日志不一定写入 `/data/log`。目录用途大体相同，但分区级备份、修复和权限语义不能跨机型照搬。

恢复脚本会清空整个分区

p67tc 的 BL2/OTA `/etc/recovery_reset.sh` 先强制卸载 `/data`，再执行 `mount -t yaffs -o forceformat /dev/nand_data /data`。这不是删除几个设置文件，而是重建整个数据文件系统。不要在 o63 上执行这条 YAFFS 命令；其数据设备和文件系统均不同。

本页目录来自启动脚本和固件二进制中的固定路径。带 `%s`、`%u`、`%lu` 的名称是运行时格式模板；未使用过的功能不会预先创建对应目录。

## [顶层结构](<#顶层结构>)

路径| 用途  
---|---  
`/data/app/`| 系统原生应用的私有数据库、配置、图标缓存和状态。  
`/data/quickapp/`| 快应用运行时的文件沙箱与缓存。不要与 `/data/app/quickapp/` 混淆。  
`/data/fitness/`| 运动健康算法输入、缓存、数据库和 UI 聚合结果。  
`/data/gps/`| GNSS 辅助定位数据、芯片日志和星历文件。  
`/data/misc/`| 蓝牙、GNSS、车联等系统组件的共享私有数据。  
`/data/offlinelog/`、`/data/log/`| 离线诊断、功耗、录音、GPS 和蓝牙崩溃日志。  
`/data/mass/`| 大容量/用户可见或跨模块共享数据；静默 OTA 也在其下暂存。  
`/data/system/`| 框架级数据库。  
`/data/factory/`| 工厂自动化、老化与闪存/触控测试结果。  
`/data/recovery/`| 从只读资源复制出来的恢复程序与配置。  
`/data/recording/`| 录音生成的 PCM/WAV 文件。  
`/data/uorb/`| uORB 传感器总线时序/诊断数据。  
`/data/user/`| 用户功能数据，目前固件明确出现微信支付数据库。  
`/data/cache/`、`/data/tmp/`| 系统缓存和临时文件。  
`/data/etc/`| 可写配置覆盖，目前出现 ALSA 配置。  
`/data/files/`| 跨模块文件区，固件出现音频子目录。  
`/data/training/`、`/data/train_plan/`| 训练记录与训练计划。  
  
顶层还存在若干独立数据库、状态文件、升级包和硬件固件暂存文件，见后文。

## [快应用数据](<#快应用数据>)

### [`/data/quickapp/`：运行时沙箱](<#data-quickapp-运行时沙箱>)

固件中的路径模板为 `/data/quickapp/%s/%s/%s`。结合运行时路径实现，可还原为：

路径| 用途  
---|---  
`/data/quickapp/cache/{package}/`| 某快应用的可清理缓存。  
`/data/quickapp/file/{package}/`| 某快应用的内部持久文件。  
`/data/quickapp/mass/{package}/`| 某快应用的大文件/共享存储区。  
`/data/quickapp/tmp/`| 快应用运行时共用的临时目录；该类型不再追加包名。  
  
文档 API 中的 `internal://cache/`、`internal://files/` 等虚拟路径由运行时映射到这些真实目录。应用不应硬编码 `/data/quickapp`，因为权限检查、配额和包名隔离在虚拟路径层完成。

### [`/data/app/quickapp/`：安装管理信息](<#data-app-quickapp-安装管理信息>)

文件| 用途  
---|---  
`config.json`| 快应用系统组件/安装器的配置。  
`rpk_info.json`| 已安装 RPK 的元信息或索引。  
  
这里属于系统原生 `quickapp` 管理组件，不是单个快应用的沙箱。手工改 `rpk_info.json` 可能造成包文件、签名信息和安装数据库不一致。

## [原生应用数据 `/data/app`](<#原生应用数据-data-app>)

子目录/文件| 用途  
---|---  
`alarm/alarm.db`| 闹钟记录。  
`calendar/calendar.db`| 日历数据。  
`compass/compass.db`| 指南针校准/应用状态。  
`ctrl/ctrl.db`| 控制类应用状态；具体表结构需再解析数据库。  
`fusion/fusion.db`、`fusion/image/`| 融合中心数据库和图片缓存。  
`health/health.db`| 健康应用数据库。  
`home/home.db`| 主界面/首页状态。  
`launcher/launcher.db`| 应用列表、顺序或启动器状态。  
`nfc/nfccard_common.db`| NFC 卡片公共数据库。  
`nfc/nfccard_switch.db`| NFC 卡片开关/启用状态。  
`nfc/nfccard.json`| NFC 卡片配置/描述信息。  
`nfc/nfc_force_rf.conf`| 强制 RF 行为配置。  
`nfc/rfConfig_flag.txt`| RF 配置应用标志。  
`notifications/noti_reply_sms.db`| 通知快捷回复/短信回复数据。  
`notifications/icon/`、`small/`| 通知图标缓存。  
`perpetual_calendar/perpetual_calendar.db`| 万年历数据库。  
`recorder/data.txt`、`temp_data.txt`| 录音列表/临时元数据。  
`recorder/flag.bin`、`flagtmp.bin`| 录音状态标志及临时副本。  
`sale/record.wav`| 销售/演示测试使用的录音样本。  
`sport/`| 运动应用私有数据。  
`system/install_info_v1.db`| 安装信息数据库。  
`system/system.db`| 系统应用数据库。  
`system/uninstall_app.db`| 卸载应用记录。  
`timer/timer.db`| 计时器数据。  
`todolist/todolist.db`| 待办事项。  
`tomatotimer/tomatotimer.db`| 番茄钟状态。  
`training/training.db`| 训练应用数据库。  
`watchface/watchface.db`| 表盘安装、选择与索引信息。  
`weather/database.db`| 天气缓存数据库。  
`worldclock/worldclock.db`| 世界时钟城市列表。  
`text.bin`| `/data/app` 下的独立二进制数据文件；仅凭路径无法确定结构。  
  
这些 `.db` 多数是 SQLite，但不能只看扩展名就假定。备份后可用 `file` 和 `sqlite3 '.tables'` 只读确认；系统服务运行时直接替换数据库可能丢失 WAL/锁状态。

## [运动健康 `/data/fitness`](<#运动健康-data-fitness>)

这是 `/data` 中层级最深、写入最频繁的一组目录，也包含敏感健康数据。

路径| 用途  
---|---  
`cache/database/`| `allday.db`、`common.db`、`daily.db`、`trainsys.db`、`vita_remind.db`、`vitality.db` 等算法/业务数据库。  
`cache/algorithm/`| 算法运行缓存，例如室内跑校准。  
`cache/abnormal/`| 异常健康事件缓存。  
`cache/osahs/`| 睡眠呼吸暂停相关的心率和 OSAHS 分析缓存。  
`cache/sleep/`| 按时间命名的血氧、心率、睡眠缓存及评估结果。  
`cache/swimhr/`| 游泳心率缓存。  
`capture/`| 传感器/算法采集数据。  
`daily/`| 日级汇总数据。  
`research/`、`research/p32/`| 研究功能和 p32 格式/版本的数据。  
`sleep/hrv/`| 睡眠 HRV 数据。  
`sport/highlvl/`| 高阶运动算法配置。  
`sport/p{profile}/`| 分用户/档案的运动恢复数据。  
`view/arh/`| 静息/全天心率分布视图数据。  
`view/baroatt/`| 气压与海拔记录和 12 小时静息数据。  
`view/bo/`| 血氧异常和当天详情。  
`view/hr/`| 心率原始、详情、分布、30 天静息与高低/房颤异常结果。  
`view/research/`| 血压研究所需的加速度、气压、PPG 质量等原始数据。  
`view/sleep/`| 睡眠阶段及 v1/v2 UI 聚合结果。  
`view/sport_history/`| 运动轨迹、索引和恢复记录。  
`view/stress/`| 压力当天详情、分布和 30 天结果。  
`view/vigor/`| 活力相关展示数据。  
  
文件名中的 `%lu` 多为时间戳，`%u` 多为 profile/实例编号，`.algo` 是算法产出格式而非可执行文件。不要通过删除单个 `.algo` 文件来“校准”健康功能；数据库、缓存索引和 UI 汇总可能互相依赖。

## [定位、蓝牙、日志与媒体](<#定位、蓝牙、日志与媒体>)

路径| 用途  
---|---  
`/data/gps/airoha/EPO_BDS_3.DAT`| Airoha GNSS 的北斗辅助星历。  
`/data/gps/airoha/EPO_GAL_3.DAT`| Galileo 辅助星历。  
`/data/gps/airoha/EPO_GR_3_X.DAT`| GPS/GLONASS 组合辅助星历。  
`/data/gps/c2t/epo.pgl`| 另一 GNSS 实现使用的 EPO 数据。  
`/data/gps/log/`| GNSS 日志。  
`/data/misc/gps/mnl.prop`、`mnl_GLP.prop`| GNSS/MNL 配置属性。  
`/data/misc/bt/bt_storage.db`| 蓝牙配对、设备或协议栈持久状态。  
`/data/misc/bt/snoop/`| Bluetooth snoop 抓包日志。  
`/data/misc/car/`| 车联功能数据。  
`/data/offlinelog/btc_dump.log`| 蓝牙控制器转储日志。  
`/data/offlinelog/gps/`| 离线 GNSS 日志。  
`/data/offlinelog/power/tdp0.log`、`tdp1.log`| 功耗/电源诊断日志。  
`/data/offlinelog/record/`| 诊断录音输入/输出 PCM。  
`/data/offlinelog/log{time}.gz`| 按时间压缩的离线日志。  
`/data/log/btc_dump.log`| 当前日志区中的蓝牙控制器转储。  
`/data/recording/{id}.pcm`、`{id}.wav`| 录音原始数据和封装后的音频。  
`/data/media_manage_data.bin`| 媒体管理器索引/状态。  
`/data/media_song_data.bin`| 歌曲列表或媒体条目数据。  
`/data/files/audio/`| 音频文件区。  
  
BT snoop 和离线日志可能包含设备地址、通知内容、定位数据或音频，应按敏感数据处理。

## [OTA、Recovery 与硬件固件](<#ota、recovery-与硬件固件>)

路径| 用途与生命周期  
---|---  
`/data/ota.zip`| 完整 OTA 包。BL2/OTA 会验签、以 ZIPFS 挂载到 `/ota`，完成或失败后按分支删除。  
`/data/ota_tmp/`| OTA 临时目录，流程结束时删除。  
`/data/vela_ota.bin`| BL2 从 OTA 包复制的 OTA 执行镜像，随后用 `boot` 启动。  
`/data/mass/silent_ota/`| 静默 OTA 的大文件暂存目录，升级结束后清理。  
`/data/recovery/recovery/recovery.conf`| Recovery 配置。OTA 环境首次发现 `/data/recovery` 不存在时，会从 `/resource/recovery` 复制整套文件。  
`/data/hyn_firmware_p67.bin`| Hynitron 触控固件暂存/升级文件。  
`/data/tp_gtw631_zinitix_firmware.bin`| GTW631/Zinitix 触控固件。  
`/data/tp_vxn_gtw623_firmware.bin`| GTW623/VXN 触控固件。  
`/data/tp_zinitix_firmware.bin`| 通用 Zinitix 触控固件路径。  
  
这些触控固件路径说明 AP 包含在线升级/替换逻辑，不代表把任意同名文件放入 `/data` 就会安全刷写。触发条件、镜像头、型号校验和回滚能力必须从对应驱动继续确认。

## [系统状态、用户数据与特殊开关](<#系统状态、用户数据与特殊开关>)

路径| 用途  
---|---  
`/data/persist.db`| 系统持久属性/键值状态数据库。实际表结构应从文件确认。  
`/data/system/framework.db`| 框架级共享数据库。  
`/data/power_event`| 电源事件记录或状态。  
`/data/usage_stats`| 使用统计数据。  
`/data/snapshot/{name}.bin`| p67 系统截图的 framebuffer 原始文件。  
`/data/mifind/mifind_record.db`| 查找设备/米家查找功能记录。  
`/data/user/wxpay/wxpay.db`| 微信支付用户数据库。  
`/data/training/records_data.bin`| 训练记录的二进制存储。  
`/data/store_demo`| 门店演示模式状态或目录。  
`/data/nobusiness/`| 正常 AP `rcS` 的停服开关：目录存在时跳过业务服务启动。  
`/data/del_res`| 资源删除/清理标记或列表；具体格式需读取实机文件后确定。  
`/data/etc/alsa.conf`| 可写 ALSA 音频配置，可覆盖/补充固件内置音频参数。  
  
`/data/nobusiness` 的判断是 `if [ ! -d /data/nobusiness ]; then ...`。因此它必须是目录才会触发；同名普通文件不会满足 `-d`。创建它后重启会让大量业务服务不启动，适合救援排障，但 UI、蓝牙、健康、快应用等功能也可能一起消失。删除该目录并重启可恢复正常启动路径。

## [工厂测试与临时文件](<#工厂测试与临时文件>)

路径| 用途  
---|---  
`/data/factory/cit_auto_test_result.txt`| CIT 自动测试结果。  
`/data/factory/rmt_auto_test_result.txt`| RMT 自动测试结果。  
`/data/factory/fac_runin_info.txt`| 老化测试信息。  
`/data/factory/fac_runin_error.txt`| 老化测试错误。  
`/data/factory/fac_runin_tp.txt`| 老化过程的触控测试信息。  
`/data/factory/flash_test.txt`| Flash 测试结果。  
`/data/test10m.dat`| 约 10 MiB 的存储/吞吐测试文件。  
`/data/tmp/29598_log.tar.gz`| 某诊断编号对应的日志包。  
`/data/tmpcompress.tar.gz`| 临时压缩输出。  
  
工厂测试结果常用于售后判定。若要清理空间，先备份这些文本；不要在不清楚测试状态机的情况下伪造“通过”结果。

## [备份与安全修改](<#备份与安全修改>)

先确认真实挂载，再做文件级备份：
    
    
    mount | grep ' /data '
    df -h /data
    du -k /data/* 2>/dev/null

如果目标 shell 支持 `tar`，可在业务服务停止后备份关注的目录：
    
    
    tar -czf /data/mass/vela-data-backup.tar.gz \
      /data/app /data/quickapp /data/system /data/misc

注意不要把备份包写回正在完整备份的目录形成递归，也不要在数据库活跃写入时只复制单个 `.db`。最稳妥的方式是在 Recovery 或停服状态下做文件级备份。p67tc 的分区级备份必须理解 YAFFS OOB/ECC 布局；o63 的 FATFS/exFAT 镜像也应保留分区尺寸、引导区和文件系统校验信息。两者都不能把普通文件复制误当作跨机型可恢复镜像。

---

# /dev 设备节点

> 来源: [https://docs.luoxe.cn/docs/vela/system/filesystem/dev/](https://docs.luoxe.cn/docs/vela/system/filesystem/dev/)

本页汇总 p67tc 与 o63 启动脚本及二进制中出现的 `/dev` 路径。它不是某次开机后的 `ls /dev` 快照：节点由驱动在运行时注册，机型和启动环境可见的集合并不完全相同。

不要直接试写未知设备

对分区节点执行 `dd`、重定向或随机 `ioctl` 可能立即破坏系统；对 watchdog、充电、NFC、触控固件节点误操作也可能造成重启、失去触控或硬件异常。先只读检查节点类型和挂载关系。

## [分区、块设备与挂载源](<#分区、块设备与挂载源>)

o63 使用更细的资源分区布局：`/dev/vendor`、`/dev/system`、`/dev/app`、`/dev/misc`、`/dev/i18n`、`/dev/font`、`/dev/watchface`、`/dev/quickapp`、`/dev/factory` 分别挂载；`/dev/data` 是 FATFS/exFAT 数据分区，`/dev/userlog` 是独立日志分区。p67tc 的启动路径则以 `/dev/resource` 和 `/dev/nand_data` 为主。写盘或恢复前必须先按当前机型的 `mount` 输出确认。

节点| 用途  
---|---  
`/dev/ap`| AP 系统分区。OTA 脚本把 `vela_ap.bin` 以 32 KiB 块写入此节点，并启用写后校验。  
`/dev/bl2`| 第二阶段启动/升级分区。OTA 脚本把 `vela_bl2.bin` 写入此节点。  
`/dev/resource`| 只读资源分区，正常系统和 Recovery 都将其以 ROMFS 挂载到 `/resource`。  
`/dev/nand_data`| 主数据 NAND 分区，以 YAFFS 挂载到 `/data`。`autoformat` 允许首次启动/损坏时重建。  
`/dev/nand_nv`| BL2 中以 YAFFS 挂到 `/wasted_nv` 的 NAND 持久区；正常 AP 脚本未挂载它。  
`/dev/nv`| 小型非易失分区，以 LittleFS 挂到 `/misc`。  
`/dev/mode`| 模式分区，以 LittleFS 挂到 `/mode`，供启动模式或升级流程保存状态。  
`/dev/data`| 二进制中存在的另一数据设备名；当前五套启动脚本实际挂载的是 `/dev/nand_data`，不要把两者视为同一节点后直接写入。  
`/dev/bes_flash`| BES 平台底层 Flash 驱动接口，面向原始闪存控制/测试逻辑。  
`/dev/bes_nand`| BES 平台底层 NAND 驱动接口，层级低于 `/dev/nand_data` 这类文件系统分区。  
`/dev/ram`、`/dev/ram0`| RAM 块设备/首个 RAM disk，常用于临时文件系统、测试或镜像挂载。  
`/dev/loop`| loop 驱动控制或基础名。Recovery 实际构造 `/dev/loop0`～`/dev/loop2`。  
`/dev/loop0`| Recovery 将 `/resource/watchface.bin` 绑定到此节点，再以 ROMFS 挂到 `/watchface`。  
`/dev/loop1`| Recovery 将 `/resource/font.bin` 绑定后挂到 `/font`。  
`/dev/loop2`| Recovery 将 `/resource/i18n.bin` 绑定后挂到 `/i18n`。  
`/dev/tmpb`、`/dev/tmpc`| 固件包含的临时块/测试设备名，启动脚本未使用；用途和数据格式不能仅凭路径确定。  
  
`/dev/ap` 与 `/dev/bl2` 来自升级包的 `ota.sh`；其余挂载节点可在各环境的 `rc.sysinit`、`rcS` 或二进制访问路径中确认。

## [控制台、日志与标准伪设备](<#控制台、日志与标准伪设备>)

节点| 用途  
---|---  
`/dev/console`| 系统控制台，早期启动输出和交互 shell 的默认终端。  
`/dev/tty`| 当前进程的控制终端。  
`/dev/ttyS0`、`/dev/ttyS1`、`/dev/ttyS2`| 硬件串口，具体哪一路接调试口、外设或协处理器取决于板级配置。  
`/dev/pty`、`/dev/ptmx`、`/dev/pts/`、`/dev/ttyp`| 伪终端主从设备，用于 shell、调试会话或进程间终端仿真。  
`/dev/kmsg`| 内核消息接口，用于读取或写入内核日志。  
`/dev/log`| 系统日志设备；AP 启动脚本把服务输出重定向到日志体系。  
`/dev/logrpmsg`| 经 RPMsg 传输日志的接口，常用于主核与远端核/协处理器之间转发日志。  
`/dev/null`| 丢弃写入数据，读取立即返回 EOF。  
`/dev/zero`| 读取时产生全零字节。  
`/dev/random`、`/dev/urandom`| 随机数设备。密码学代码应使用系统提供的安全随机接口，不要自行降级。  
`/dev/oneshot`| one-shot 定时器驱动接口，供一次性高精度定时/调度使用；具体 `ioctl` 需匹配该固件驱动。  
  
## [显示、按键与输入设备](<#显示、按键与输入设备>)

节点| 用途  
---|---  
`/dev/fb`、`/dev/fb0`| framebuffer 显示设备；`fb0` 通常表示首块显示缓冲。  
`/dev/input0`| 首个通用输入设备，事件格式由 NuttX 输入驱动决定。  
`/dev/buttons`| 板级实体按键接口。  
`/dev/ubutton`| user-space button/虚拟按键设备。  
`/dev/ukeyboard`| user-space/虚拟键盘设备。  
`/dev/mouse0`| 首个鼠标/指针类输入设备，触控适配层也可能复用此类接口。  
  
节点存在不代表第三方应用可以读取。输入设备一般由系统 UI 独占或受权限限制，直接消费事件还可能与系统手势冲突。

## [传感器与 uORB](<#传感器与-uorb>)

节点| 用途  
---|---  
`/dev/i2c`| 通用 I²C 总线接口，供传感器和外设驱动访问。总线号/地址由板级配置决定。  
`/dev/usensor`| NuttX 统一传感器接口或其兼容层。  
`/dev/uorb/`| uORB 发布/订阅设备目录。  
`/dev/uorb/sensor_`| 代码拼接传感器 topic 名称时使用的前缀。  
`/dev/uorb/sensor_accel0`| 首个加速度计 topic/设备。  
`/dev/uorb/sensor_gyro0`| 首个陀螺仪 topic/设备。  
`/dev/uorb/sensor_gps_factory0`| 工厂测试使用的 GNSS 传感器 topic。  
  
`/dev/uorb/*` 是消息总线接口，不等同于寄存器直通。固件还会把 uORB 时序统计写到 `/data/uorb/` 或 `/data//uorb_timings%u.txt`，用于诊断传感器数据链路。

## [通信、蓝牙与 GNSS](<#通信、蓝牙与-gnss>)

节点| 用途  
---|---  
`/dev/ttyBT`、`/dev/ttyBT0`| 蓝牙控制器/协议栈使用的串行通道。  
`/dev/ttyGNSS`| GNSS 模块串行通道。  
`/dev/tun`| TUN 三层虚拟网络设备，供用户态网络隧道或协议适配使用。  
  
这些设备通常由蓝牙、定位和网络系统服务持有。即使文件权限允许，第二个进程直接打开同一串口也可能破坏协议状态。

## [电源、振动、NFC 与其他硬件](<#电源、振动、nfc-与其他硬件>)

节点| 用途  
---|---  
`/dev/charge/batt_charger`| 电池充电器控制与状态接口。  
`/dev/charge/batt_gauge`| 硬件电量计接口。  
`/dev/charge/soft_gauge`| 软件电量估算器接口。  
`/dev/lra0`| 首个 LRA 线性马达/触觉反馈设备。  
`/dev/nfc_sn100`| NXP SN100 系列 NFC 控制器设备。  
`/dev/thn31/`| THN31 NFC/安全外设驱动目录；内部子节点名由驱动运行时创建。  
`/dev/rtc`、`/dev/rtc0`| 实时时钟接口与首个 RTC 实例。  
`/dev/sst`| 安全存储（secure storage）接口，可能承载密钥或受保护状态。  
`/dev/watchdog0`| 首个硬件 watchdog。打开后若未按协议喂狗，系统可能被复位。  
  
`/dev/charge/` 和 `/dev/thn31/` 也以目录前缀形式出现在固件中，说明调用方会拼接子节点；上表只列出了固件中可直接恢复的名称。

## [动态节点名模板](<#动态节点名模板>)

固件还保留了以下格式化字符串。它们不是字面存在的节点，而是驱动按实例号或 topic 名生成路径时使用的模板。

模板| 生成结果  
---|---  
`/dev/%s`、`/dev/%.24s`| 把驱动名拼到 `/dev/` 下；后者把名称限制为最多 24 个字符。无法仅凭模板确定最终设备。  
`/dev/fb%d`、`/dev/fb%d.%d`| framebuffer 实例以及其平面/overlay 子实例，例如 `fb0`。  
`/dev/i2c%d`| 带总线编号的 I²C 设备，例如 `i2c0`、`i2c1`。  
`/dev/ram%d`| 编号 RAM disk，例如 `ram0`。  
`/dev/rtc%d`| 编号 RTC，例如 `rtc0`。  
`/dev/pts/%d`、`/dev/pts/%u`| 伪终端从设备编号。  
`/dev/pty%d`、`/dev/pty%u`| 编号伪终端设备。  
`/dev/ttyp%d`、`/dev/ttyp%u`| 另一套编号伪终端名称。  
`/dev/ttyBT%d`| 编号蓝牙串行设备，例如 `ttyBT0`。  
`/dev/ttyGNSS%d`| 编号 GNSS 串行设备。  
`/dev/tmpb%06lx`、`/dev/tmpc%06lx`| 带 6 位十六进制后缀的临时块/字符设备名；后缀通常用于避免命名冲突，协议仍需从创建它的调用点确认。  
`/dev/uorb/%s`、`/dev/uorb/%s%d`| 按 topic 名和实例号生成 uORB 节点。  
`/dev/uorb/sensor_%s%s%d`| 按传感器类型、附加名称和实例号生成传感器 topic。  
  
因此，实机出现 `i2c0`、`rtc1` 或新的 `sensor_*` 并不算文档遗漏；它们属于相同模板的运行时实例。

## [实机只读确认](<#实机只读确认>)

在有 shell 的设备上，可以先执行：
    
    
    ls -l /dev
    mount
    df -h
    cat /proc/partitions 2>/dev/null
    dmesg | grep -E 'nand|romfs|yaffs|littlefs|uorb|sensor|nfc|charge'

检查某个节点是否正在被挂载或占用：
    
    
    mount | grep '/dev/resource\|/dev/nand_data\|/dev/nv\|/dev/mode'
    fuser /dev/ttyGNSS 2>/dev/null

不同 shell 工具集可能没有 `grep`、`fuser` 或 `df -h`。这不影响节点本身，只需改用系统现有的只读命令。不要用 `cat /dev/nand_data` 来“查看内容”：它读取的是原始 YAFFS 分区，不是目录中的文件。

---

# 截屏

> 来源: [https://docs.luoxe.cn/docs/vela/system/screenshot/](https://docs.luoxe.cn/docs/vela/system/screenshot/)

系统提供两种可用的截屏方式：p67 的系统截图命令，以及直接读取 framebuffer。Lua 表盘接口没有公开全屏截图函数。

## [p67：系统截图命令](<#p67-系统截图命令>)

p67 的截图处理最终执行：
    
    
    dd if=/dev/fb0 of=/data/snapshot/<名称>.bin bs=483840 count=1

因此截图保存在：
    
    
    /data/snapshot/<名称>.bin

文件是 framebuffer 原始像素，不是 PNG、JPEG 或 BMP。每次读取固定 `483840` 字节。系统成功响应会返回所用名称；失败返回 `SCREEN_SHOT=ERROR`。

设备同时注册了 `miwear-snapshot` 名称。它属于系统截图服务入口，不向快应用或 Lua 表盘开放。p67 的本地落盘位置就是上面的 `/data/snapshot/`；无需再扫描 `/tmp` 或 `/log`。

### [导出文件](<#导出文件>)

取得系统 shell 后：
    
    
    ls -l /data/snapshot

把生成的 `.bin` 复制到电脑，再按设备 framebuffer 的宽、高、stride 和像素格式转换。不要仅凭文件长度猜测可视分辨率，因为缓冲区可能包含行对齐或不可见区域。

## [o63：`miwear-snapshot`](<#o63-miwear-snapshot>)

o63 提供 `miwear-snapshot` 服务入口，但不使用 p67 的 `/data/snapshot/{名称}.bin` 固定路径。该入口由系统截图/调试通道接收结果，本地文件系统中没有固定输出文件。
    
    
    miwear-snapshot

调用后应从连接设备使用的 MiWear 调试端读取结果。它不是带 `-o` 参数的通用截图工具，也不会默认生成 `/data/snapshot/*.bin`。

## [直接读取 `/dev/fb0`](<#直接读取-dev-fb0>)

系统程序可查询 framebuffer 信息后保存当前 plane。输出路径可自行指定：
    
    
    #include <nuttx/video/fb.h>
    #include <sys/ioctl.h>
    #include <sys/mman.h>
    #include <fcntl.h>
    #include <stdint.h>
    #include <stdio.h>
    #include <string.h>
    #include <unistd.h>
    
    int main(int argc, char **argv)
    {
      const char *outpath = argc > 1 ? argv[1] : "/data/screenshot.raw";
      struct fb_videoinfo_s vinfo = {0};
      struct fb_planeinfo_s pinfo = {0};
      int fb = open("/dev/fb0", O_RDONLY);
      if (fb < 0) { perror("open /dev/fb0"); return 1; }
    
      if (ioctl(fb, FBIOGET_VIDEOINFO,
                (unsigned long)(uintptr_t)&vinfo) < 0 ||
          ioctl(fb, FBIOGET_PLANEINFO,
                (unsigned long)(uintptr_t)&pinfo) < 0) {
        perror("framebuffer info");
        close(fb);
        return 1;
      }
    
      printf("fmt=%u xres=%u yres=%u bpp=%u stride=%u fblen=%lu\n",
             vinfo.fmt, vinfo.xres, vinfo.yres, pinfo.bpp,
             pinfo.stride, (unsigned long)pinfo.fblen);
    
      void *pixels = mmap(NULL, pinfo.fblen, PROT_READ, MAP_SHARED, fb, 0);
      if (pixels == MAP_FAILED) { perror("mmap"); close(fb); return 1; }
    
      int out = open(outpath, O_WRONLY | O_CREAT | O_TRUNC, 0600);
      if (out < 0) { perror("open output"); munmap(pixels, pinfo.fblen); close(fb); return 1; }
    
      const uint8_t *p = pixels;
      size_t left = pinfo.fblen;
      while (left != 0) {
        ssize_t n = write(out, p, left);
        if (n <= 0) { perror("write"); break; }
        p += n;
        left -= (size_t)n;
      }
    
      close(out);
      munmap(pixels, pinfo.fblen);
      close(fb);
      return left == 0 ? 0 : 1;
    }

读取前必须用 `FBIOGET_VIDEOINFO` 和 `FBIOGET_PLANEINFO` 获取：

  * `xres`、`yres`：可视宽高；
  * `bpp`、`fmt`：位深与像素格式；
  * `stride`：每行实际字节数；
  * `fblen`：映射及保存长度。


若确定为无行填充的小端 RGB565，可转换为：
    
    
    ffmpeg -f rawvideo -pixel_format rgb565le \
      -video_size <宽>x<高> -i screenshot.raw -frames:v 1 screenshot.png

当 `stride` 大于每行有效像素字节数时，需要先逐行去除 padding。读取过程中 UI 仍可能刷新，必要时等待画面静止后再抓取。

## [Lua 表盘](<#lua-表盘>)

Lua 绑定中没有确认到可调用的 `take_snapshot`、`screenshot` 或同等全屏方法。固件内部出现的 LVGL snapshot 符号属于原生图形实现，不能据此写成 Lua 方法。

Lua 表盘若需要预览图，应由开发工具渲染，或由系统侧通过上述截图入口取得，不要调用：
    
    
    -- 不存在的公开接口
    -- root:take_snapshot()

## [机型可用性](<#机型可用性>)

能力| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
`miwear-snapshot`| ✅| ✅  
固定写入 `/data/snapshot/`| ✅| ❌  
系统读取 `/dev/fb0`| ✅| ✅  
Lua 全屏截图函数| ❌| ❌  
  
## [获取源代码](<#获取源代码>)

  * [NuttX framebuffer 字符设备说明](<https://github.com/apache/nuttx/blob/master/Documentation/components/nxgraphics/framebuffer_char_driver.rst>)
  * [LVGL snapshot 原生实现](<https://github.com/lvgl/lvgl/tree/master/src/others/snapshot>)

---

