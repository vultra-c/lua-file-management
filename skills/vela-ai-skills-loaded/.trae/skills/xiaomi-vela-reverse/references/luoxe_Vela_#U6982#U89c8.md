# Vela_概览

> 来源: 洛汐文档库
> 共 4 篇文档

---

# Xiaomi Vela 非官方开发文档

> 来源: [https://docs.luoxe.cn/docs/vela/](https://docs.luoxe.cn/docs/vela/)

本文档整理 Xiaomi Vela 穿戴设备中的快应用接口、Lua 表盘接口、系统文件、设备节点与实用工具。接口页采用接近官方手册的写法：直接给出模块名、参数、返回值、示例、机型可用性与源代码链接。

逆向文档与免责声明

本文档是根据公开源码、固件静态分析和设备内置资源整理的**非官方逆向文档** ，不代表小米、OpenVela、设备厂商或应用平台的正式承诺。未公开接口可能随系统升级而删除、改名、限制调用或改变语义。使用本文档造成的设备故障、数据丢失、保修影响、帐号风险、隐私泄露或其他损失，应由使用者自行承担。修改系统分区、绕过签名或权限限制前，请先备份数据并确认当地法律、设备所有权和授权范围。

## [开始](<#开始>)

  * [使用前准备](</docs/vela/getting-started/>)
  * [机型可用性](</docs/vela/availability/>)
  * [权限与兼容性](</docs/vela/compatibility/>)


## [快应用接口](<#快应用接口>)

  * [service.health](</docs/vela/features/service-health/>)
  * [service.miaccount](</docs/vela/features/service-miaccount/>)
  * [service.wechat](</docs/vela/features/service-wechat/>)
  * [jumpApp](</docs/vela/features/jumpapp/>)
  * [system.bluetooth 扩展](</docs/vela/features/system-bluetooth/>)
  * [system.cipher](</docs/vela/features/system-cipher/>)
  * [system.digitalkey](</docs/vela/features/system-digitalkey/>)
  * [system.exchange](</docs/vela/features/system-exchange/>)
  * [system.folme](</docs/vela/features/system-folme/>)
  * [system.internal.activity](</docs/vela/features/system-internal-activity/>)
  * [system.internal.messagecenter](</docs/vela/features/system-internal-messagecenter/>)
  * [system.internal.power](</docs/vela/features/system-internal-power/>)
  * [system.media](</docs/vela/features/system-media/>)
  * [system.mqtt](</docs/vela/features/system-mqtt/>)
  * [system.mqttmessage](</docs/vela/features/system-mqttmessage/>)
  * [system.settings](</docs/vela/features/system-settings/>)
  * [system.zlib](</docs/vela/features/system-zlib/>)
  * [locale](</docs/vela/features/locale/>)
  * [Error](</docs/vela/features/error/>)


官网接口的补充成员位于 `extensions`：

  * [system.brightness](</docs/vela/extensions/system-brightness/>)
  * [system.device](</docs/vela/extensions/system-device/>)
  * [system.interconnect](</docs/vela/extensions/system-interconnect/>)
  * [system.prompt](</docs/vela/extensions/system-prompt/>)
  * [system.request](</docs/vela/extensions/system-request/>)
  * [system.sensor](</docs/vela/extensions/system-sensor/>)
  * [system.storage](</docs/vela/extensions/system-storage/>)


## [Lua 表盘与系统应用](<#lua-表盘与系统应用>)

  * [Lua 开发总览](</docs/vela/lua/>)
  * [表盘结构与生命周期](</docs/vela/lua/watchface-development/>)
  * [dataman 数据源](</docs/vela/lua/dataman/>)
  * [topic 消息订阅](</docs/vela/lua/topic/>)
  * [animengine 动画引擎](</docs/vela/lua/animengine/>)
  * [Activity、导航、振动与屏幕](</docs/vela/lua/vendor-modules/>)
  * [LVGL 控件与属性](</docs/vela/lua/lvgl-widgets/>)
  * [LVGL 样式、动画与常量](</docs/vela/lua/lvgl-style-animation/>)
  * [LVGL 显示、输入与文件系统](</docs/vela/lua/lvgl-modules/>)
  * [Lua 5.4 标准库](</docs/vela/lua/standard-library/>)


## [系统与工具](<#系统与工具>)

  * [截屏实现](</docs/vela/system/screenshot/>)
  * [文件系统总览](</docs/vela/system/filesystem/>)
  * [/dev 设备节点](</docs/vela/system/filesystem/dev/>)
  * [/data 目录结构](</docs/vela/system/filesystem/data/>)
  * [/etc 文件总览](</docs/vela/system/etc/>)


## [阅读提示](<#阅读提示>)

  * 快应用接口使用 `app.canIUse('@feature.method')` 检查成员是否存在。
  * Lua 表盘接口使用 `pcall(require, 'module')` 检查模块是否存在。
  * 订阅、定时器、动画和文件句柄应在页面退出时释放。
  * [机型可用性](</docs/vela/availability/>)只给出支持结论；具体接口用法请进入对应接口页。

---

# 使用前准备

> 来源: [https://docs.luoxe.cn/docs/vela/getting-started/](https://docs.luoxe.cn/docs/vela/getting-started/)

本文档中的 API 分为两类：具有完整参数契约的接口，以及仅恢复到部分成员定义的私有接口。前者可以按示例直接试用；后者的示例会标记为“探测模板”。

## [1\. 声明 Feature](<#_1-声明-feature>)

除特别说明外，在 `manifest.json` 中声明 feature：
    
    
    {
      "features": [
        { "name": "system.zlib" }
      ]
    }

一个应用可以一次声明多个接口：
    
    
    {
      "features": [
        { "name": "system.zlib" },
        { "name": "system.sensor" },
        { "name": "system.exchange" }
      ]
    }

如果安装阶段提示 feature 或权限不允许，应删除该声明或改用公开 API；不要依靠捕获 JS 异常绕过 manifest 校验。

## [2\. 导入与能力探测](<#_2-导入与能力探测>)

在 JS 中导入：
    
    
    import zlib from '@system.zlib'
    // 或
    const zlib = require('@system.zlib')

运行前应进行能力探测：
    
    
    import app from '@system.app'
    
    if (app.canIUse('@system.zlib.decompressSync')) {
      // 调用 API
    }

`canIUse()` 只能证明运行时导出了成员；它不代表当前应用签名、权限、设备状态或配套手机端服务一定允许调用。

推荐同时探测 feature 与方法：
    
    
    export function canUse(feature, method) {
      try {
        const name = feature.startsWith('@') ? feature : `@${feature}`
        return app.canIUse(name) && app.canIUse(`${name}.${method}`)
      } catch (e) {
        return false
      }
    }

## [3\. 统一封装回调接口](<#_3-统一封装回调接口>)

多数旧 feature 使用 `success/fail/complete`，并且 `fail` 通常是两个位置参数，而不是一个 Error 对象：
    
    
    export function callFeature(invoke) {
      return new Promise((resolve, reject) => {
        invoke({
          success: resolve,
          fail: (message, code) => reject({ message, code })
        })
      })
    }
    
    // 用法
    const result = await callFeature(callbacks => {
      exchange.get({ key: 'demo', ...callbacks })
    })

不要假定所有 `complete` 都无参数：例如 `system.exchange` 和 `system.internal.power` 的同源 JIDL 把它定义成接收一个字符串。

## [4\. 真机探测记录](<#_4-真机探测记录>)

逆向文档不能替代目标设备验证。建议至少记录：

  * 固件版本、设备型号、应用包名和签名类型；
  * `canIUse('@feature')` 与 `canIUse('@feature.method')` 的结果；
  * 同一参数下同步返回值、成功回调、失败回调和异常；
  * 是否需要手机蓝牙连接、登录状态或健康权限；
  * 应用退到后台、页面销毁后订阅是否仍然存在。


## [5\. 清理原则](<#_5-清理原则>)

传感器、健康数据、微信事件和消息中心都属于订阅型接口。请在页面销毁或应用退出时调用对应取消方法，避免重复回调、句柄泄漏和后台耗电。

---

# 机型可用性

> 来源: [https://docs.luoxe.cn/docs/vela/availability/](https://docs.luoxe.cn/docs/vela/availability/)

符号说明：✅ 可用；❌ 不可用；△ 部分成员可用或需要系统授权。

## [快应用接口](<#快应用接口>)

Feature| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
`service.health`| ✅| ✅  
`service.miaccount`| ❌| △  
`service.wechat`| △| △  
`jumpApp`| △| △  
`system.bluetooth` 扩展| ❌| △  
`system.cipher`| ✅| ✅  
`system.digitalkey`| ❌| △  
`system.exchange`| ✅| ❌  
`system.folme`| △| △  
`system.internal.activity`| △| △  
`system.internal.messagecenter`| △| △  
`system.internal.power`| △| △  
`system.media.previewImage`| ✅| ✅  
`system.mqtt`| ❌| △  
`system.mqttmessage`| ✅| ✅  
`system.settings`| ❌| △  
`system.zlib`| ✅| ✅  
`locale`| ✅| ✅  
`Error`| ✅| ✅  
  
## [官网接口的补充成员](<#官网接口的补充成员>)

API| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
`system.brightness.restoreBrightness`| ✅| ✅  
`system.device` 补充字段| △| △  
`system.interconnect` 补充成员| △| △  
`system.prompt.showDialog`| ✅| ✅  
`system.request` 补充参数| ❌| ✅  
`system.sensor` 补充成员| △| △  
`system.storage.key`| ✅| ✅  
  
## [Lua 表盘接口](<#lua-表盘接口>)

能力| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
Lua 5.4| ✅| ✅  
`lvgl`| ✅| ✅  
`dataman`| ✅| ✅  
`topic`| ✅| ✅  
`activity`| ✅| ✅  
`animengine`| ✅| ✅  
`navigator`| ✅| ✅  
`vibrator`| ✅| ✅  
`screen` 模块| ✅| ✅  
`AnalogTime`| ✅| ✅  
`Pointer`| ✅| ✅  
`ImageLabel`| ✅| ✅  
`ImageBar`| ✅| ✅  
`ImageLineBar`| ✅| ✅  
`CurvedLabel`| ✅| ✅  
`Thumbnail`| ✅| ✅  
  
## [截屏](<#截屏>)

方式| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
`miwear-snapshot`| ✅| ✅  
读取 `/dev/fb0`| △| △  
Lua 公共截屏函数| ❌| ❌  
  
△ 表示接口存在，但可能仅向系统应用、特定签名或具备对应硬件/服务的运行环境开放。

## [官网机型支持表](<#官网机型支持表>)

其他 Xiaomi Vela 机型请以 [Xiaomi Vela JS 应用接口机型支持](<https://iot.mi.com/vela/quickapp/zh/features/>) 为准。

---

# 权限与兼容性

> 来源: [https://docs.luoxe.cn/docs/vela/compatibility/](https://docs.luoxe.cn/docs/vela/compatibility/)

## [manifest 声明不等于授权](<#manifest-声明不等于授权>)

以下 feature 很可能受系统签名、包名或白名单限制：

  * `service.wechat`
  * `system.internal.power`
  * `system.internal.activity`
  * `system.internal.messagecenter`
  * `system.exchange` 的 `vendor` / `application` scope
  * `service.health`


## [建议的启动时能力表](<#建议的启动时能力表>)
    
    
    import app from '@system.app'
    
    const candidates = [
      '@locale',
      '@Error',
      '@jumpApp',
      '@system.cipher',
      '@system.exchange',
      '@system.mqttmessage',
      '@system.zlib',
      '@system.media',
      '@service.health',
      '@service.wechat',
      '@system.internal.power',
      '@system.internal.activity',
      '@system.internal.messagecenter',
      '@system.folme'
    ]
    
    export const supportedPrivateFeatures = Object.fromEntries(
      candidates.map(name => [name, app.canIUse(name)])
    )

## [机型可用性](<#机型可用性>)

不同手环/手表会通过 Kconfig、硬件驱动、系统服务、产品白名单或旧/新 feature 管理器裁剪模块。完整的机型支持表、编译依赖和系统层拒绝条件见[机型可用性与系统限制](</docs/vela/availability/>)。

---

