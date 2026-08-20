# Vela_快应用接口_Features

> 来源: 洛汐文档库
> 共 19 篇文档

---

# Error

> 来源: [https://docs.luoxe.cn/docs/vela/features/error/](https://docs.luoxe.cn/docs/vela/features/error/)

把 libuv/NuttX 风格的整数错误码转换为文本。该模块名首字母大写，不是 JavaScript 内置 `Error` 构造函数的方法。

## [`Error.strerror(errnum)`](<#error-strerror-errnum>)

参数| 类型| 必填| 说明  
---|---|---|---  
`errnum`| Integer| 是| libuv/系统错误码  
  
同步返回错误描述字符串。C++ 实现直接调用 `uv_strerror(errnum)`，再复制成 Feature Framework 字符串。
    
    
    const errorFeature = require('@Error')
    
    const message = errorFeature.strerror(-2)
    console.log(message)

不要把业务错误码、HTTP 状态码或 feature 回调 code 都传给它；只有底层采用 libuv 错误码时结果才有意义。未知编号可能返回通用 unknown error 文本。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：error.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/error.jidl>)
  * [C++ 实现：error_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/error_impl.cpp>)

---

# jumpApp

> 来源: [https://docs.luoxe.cn/docs/vela/features/jumpapp/](https://docs.luoxe.cn/docs/vela/features/jumpapp/)

厂商应用跳转桥，提供原生应用跳转与快应用跳转。

## [`jumpApp.jumpApp(uri, param)`](<#jumpapp-jumpapp-uri-param>)
    
    
    jumpApp(uri: string, param: string): void

参数| 类型| 必需| 说明  
---|---|---|---  
`uri`| String| 是| 原生目标 URI，必须以 `native://` 开头  
`param`| String| 是| 交给目标应用的附加参数；需要结构化数据时由调用方先序列化  
  
原生实现先检查两个参数都是字符串，再检查 URI scheme，随后记录 `uri` 与 `param` 并交给系统应用跳转器。缺参、传对象或非 `native://` URI 都会直接失败。
    
    
    import jumpApp from '@jumpApp'
    
    const uri = 'native://target/path'
    const param = JSON.stringify({ source: 'com.example.demo' })
    
    try {
      jumpApp.jumpApp(uri, param)
    } catch (e) {
      console.error('jump failed', e)
    }

`target/path` 的允许值由产品注册表决定。不要把示例占位 URI 当成真实系统应用地址。

## [`jumpApp.launchQuickApp(uri, param?)`](<#jumpapp-launchquickapp-uri-param>)

用于启动另一个快应用。接口会取得当前包名，其底层仍使用 URI 与附加参数模型：
    
    
    launchQuickApp(uri: string, param?: string | object): void

参数| 类型| 必需| 说明  
---|---|---|---  
`uri`| String| 是| 目标快应用 URI；应包含系统能解析的包名/页面信息  
`param`| String/Object| 否| 传给目标页面的启动参数；旧 wrapper 可能在进入 native 前序列化  
  
固件明确检查：

  * URI 必须以实现要求的 scheme 开头；
  * 当前应用包名不能为空；
  * 系统必须启用 `CONFIG_QUICKAPP_VAPP_XMS`，否则直接报不支持。


## [探测与兼容封装](<#探测与兼容封装>)
    
    
    import app from '@system.app'
    
    console.log('jumpApp', app.canIUse('@jumpApp.jumpApp'))
    console.log('launchQuickApp', app.canIUse('@jumpApp.launchQuickApp'))

不同固件的 `launchQuickApp` wrapper 可能要求第二个参数已经是 JSON 字符串。可统一显式序列化：
    
    
    export function launchQuickAppCompat(uri, params = {}) {
      if (typeof uri !== 'string' || !uri) throw new TypeError('uri required')
      const payload = typeof params === 'string' ? params : JSON.stringify(params)
      return jumpApp.launchQuickApp(uri, payload)
    }

不要枚举系统包名或构造未知 scheme；错误跳转可能触发系统组件权限检查或把应用带离当前任务栈。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * 当前 openvela Feature Framework 仓库没有公开对应 JIDL或 C++ 实现。
  * 可参考公开的 [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)。

---

# locale

> 来源: [https://docs.luoxe.cn/docs/vela/features/locale/](https://docs.luoxe.cn/docs/vela/features/locale/)

底层区域设置 feature。它与公开的 `system.configuration.getLocale()` 功能接近，但在 Feature Framework 中是独立模块。

## [`locale.get()`](<#locale-get>)

无参数，同步返回当前系统语言和国家/地区：
    
    
    {
      language: string,
      countryOrRegion: string
    }

探测调用：
    
    
    import app from '@system.app'
    
    if (app.canIUse('@locale.get')) {
      const locale = require('@locale')
      const value = locale.get()
      console.log(value.language, value.countryOrRegion)
    }

部分运行时可能使用不带 `@` 的旧式 require 名称。若 `@locale` 不可导入，应优先改用公开接口：
    
    
    import configuration from '@system.configuration'
    
    const value = configuration.getLocale()

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：feature_locale.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/feature_locale.jidl>)
  * [C++ 实现：locale_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/locale_impl.cpp>)

---

# service.health

> 来源: [https://docs.luoxe.cn/docs/vela/features/service-health/](https://docs.luoxe.cn/docs/vela/features/service-health/)

健康数据服务。小米/openvela 2026 大赛文档已公开采样族的完整参数：`getRecentSamples`、`subscribeSample`、`unsubscribeSample`，大赛分支范围是心率、血氧和压力。较早的 dev 实现与出货固件可能只注册心率；固件中还存在两个未进入公开指南的便捷成员。
    
    
    import health from '@service.health'

## [Manifest](<#manifest>)

Feature 与健康权限必须同时声明。后台持续订阅还要加入 `config.background.features`：
    
    
    {
      "deviceTypeList": ["watch"],
      "features": [
        { "name": "service.health" }
      ],
      "permissions": [
        { "name": "hapjs.permission.HEALTH" }
      ],
      "config": {
        "background": {
          "features": ["service.health"]
        }
      }
    }

只声明 Feature 不声明权限会被健康数据权限管控拒绝；只声明权限则无法加载模块。

## [数据类型](<#数据类型>)

常量| 值| `value` 类型/单位  
---|---|---  
`health.DATA_TYPES.HEART_RATE`| `0`| Integer，bpm  
`health.DATA_TYPES.SPO2`| `6`| Integer，百分比  
`health.DATA_TYPES.STRESS`| `9`| Integer，压力值  
  
上表是 `dev-ai-contest-2026` 第一方指南的契约。公开 dev 分支的 `health.jidl` 目前只定义 `HEART_RATE = 0`，其 C++ 实现也只映射 `algo_heartrate`。因此必须读取设备实际导出的 `health.DATA_TYPES`，不能在旧系统上仅凭数值 6/9 假定血氧和压力已接入。

Sample 结构统一为：
    
    
    interface Sample {
      timeStamp: number // 毫秒级 epoch 时间戳
      value: number
    }

大赛模拟器中三类数据都是 1 Hz；指南给出的真机压力数据约 60 秒一次。不要用模拟器频率推定其他出货固件的功耗或采样周期。

## [`health.getRecentSamples(options)`](<#health-getrecentsamples-options>)
    
    
    interface GetRecentSamplesOptions {
      dataTypes: number[]
      success?: (items: RecentSample[]) => void
      fail?: (data: object, code: number) => void
      complete?: () => void
    }
    
    interface RecentSample {
      dataType: number
      data: Sample
    }
    
    getRecentSamples(options: GetRecentSamplesOptions): Promise<RecentSample[]>

同一个方法同时支持 Promise 和 options 回调。`dataTypes` 必须是非空数组。
    
    
    health.getRecentSamples({
      dataTypes: [
        health.DATA_TYPES.HEART_RATE,
        health.DATA_TYPES.SPO2,
        health.DATA_TYPES.STRESS
      ]
    }).then(items => {
      for (const item of items) {
        console.log(item.dataType, item.data.timeStamp, item.data.value)
      }
    }).catch(error => console.error(error))

只返回能够查询到的类型。没有缓存或请求类型均不可用时返回空数组并走 success；不支持的类型会被跳过，不会令整个请求报 203。

## [`health.subscribeSample(options)`](<#health-subscribesample-options>)
    
    
    subscribeSample(options: {
      dataType: number
      callback: (sample: Sample) => void
      fail?: (data: object, code: number) => void
    }): void
    
    
    health.subscribeSample({
      dataType: health.DATA_TYPES.HEART_RATE,
      callback(sample) {
        console.log(`heart rate=${sample.value}, time=${sample.timeStamp}`)
      },
      fail(data, code) {
        if (code === 203) console.log('当前固件不支持此数据类型')
      }
    })

该方法不返回订阅 ID；每种类型以 `dataType` 标识。未支持的类型会走 fail，错误码为 203。

## [`health.unsubscribeSample(options)`](<#health-unsubscribesample-options>)
    
    
    unsubscribeSample(options: { dataType: number }): void
    
    
    onDestroy() {
      health.unsubscribeSample({
        dataType: health.DATA_TYPES.HEART_RATE
      })
    }

声明 `config.background.features` 后，应用进入后台仍会收到订阅回调。无需在 `onShow`/`onHide` 重复订阅；不再使用时必须取消，避免后台功耗与重复回调。

## [错误码](<#错误码>)

code| 含义  
---|---  
`200`| 通用/系统错误  
`202`| 参数错误，例如 `dataTypes` 缺失或为空  
`203`| 当前数据类型不支持  
  
## [固件扩展成员](<#固件扩展成员>)

方法| 说明  
---|---  
`health.getHr()`| 读取当前/最近心率的旧便捷入口  
`health.getTodayCalorie()`| 读取今日活动卡路里相关数据  
  
这两个成员没有进入公开指南，旧 JIDL 也没有定义可用的返回对象或回调契约。普通应用应使用采样族；卡路里接口在公开版本中尚未开放。

## [机型可用性](<#机型可用性>)

数据类型| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
心率| ✅| ✅  
血氧| △| △  
压力| △| △  
  
## [获取源代码](<#获取源代码>)

  * [第一方使用手册：service_health_guide.md](<https://github.com/open-vela/docs/blob/dev-ai-contest-2026/zh-cn/contest_2026/quickapp/service_health_guide.md>)
  * [官方完整示例：health-demo](<https://github.com/open-vela/packages_apps/tree/dev-ai-contest-2026/wearable/health-demo>)
  * [JIDL：health.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/health.jidl>)
  * [C++ 实现：health_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/health_impl.cpp>)

---

# service.miaccount

> 来源: [https://docs.luoxe.cn/docs/vela/features/service-miaccount/](https://docs.luoxe.cn/docs/vela/features/service-miaccount/)

小米帐号系统服务桥，用于扫码登录、取得 Service Token，并对小米帐号请求参数进行加解密。
    
    
    import miaccount from '@service.miaccount'

这些方法采用快应用常见的 options + `success/fail/complete` 回调模型。回调数据会包含帐号标识、Token 或加密材料，不应写入日志。

## [方法总览](<#方法总览>)

方法| 关键参数| 用途  
---|---|---  
`getUserId`| 无或回调对象| 读取当前系统帐号用户 ID  
`loginByScan`| `serviceId`| 发起手表扫码登录  
`getServiceToken`| `serviceId`、`accountType`| 读取已缓存的服务 Token  
`refreshServiceToken`| `serviceId`、`accountType`| 强制刷新服务 Token  
`setEnv`| `0` 或 `1`| 切换帐号服务环境  
`getEnv`| 无| 读取环境  
`encryptRequestParams`| 加密参数对象| 生成帐号协议要求的加密请求参数  
`decryptResponseData`| `security`、`data`| 解密服务响应  
  
## [扫码登录](<#扫码登录>)
    
    
    interface LoginByScanOptions {
      serviceId: string
      cServiceId?: string
      cBackUri?: string
      loginCallback?: string
      success?: (result: object) => void
      fail?: (result: object, code?: number) => void
      complete?: () => void
    }

`serviceId` 是原生实现强制检查的字段。预装汽车应用还传入当前业务的 `cServiceId`、回跳 URI 和登录回调地址。成功结果可包含登录 URL、二维码或过期时间；具体字段取决于帐号服务版本。
    
    
    miaccount.loginByScan({
      serviceId: 'your-service-id',
      cServiceId: 'your-client-service-id',
      cBackUri: 'https://example.invalid/callback',
      loginCallback: 'https://example.invalid/login-result',
      success(result) {
        // 用页面二维码组件展示 result 中的登录地址。
      },
      fail(data, code) { console.error(code) }
    })

## [用户与 Service Token](<#用户与-service-token>)
    
    
    getUserId(options?: Callbacks): void
    
    getServiceToken(options: {
      serviceId: string
      accountType?: string | number
      success?: (result: ServiceTokenResult) => void
      fail?: FailureCallback
      complete?: () => void
    }): void
    
    refreshServiceToken(options: GetServiceTokenOptions): void

固件关联字段包括 `serviceToken`、`security`、`stsCookies` 和 `expireTime`。调用方必须按 `expireTime` 刷新，不要永久缓存 Token；`security` 是后续请求加解密材料，不是可展示字段。

## [环境](<#环境>)
    
    
    setEnv(env: 0 | 1): void
    getEnv(options?: Callbacks): void

原生实现只接受 `0` 或 `1`。它们分别代表哪个部署环境由产品配置决定，不能在没有真实配置表时写成“正式/预发”。修改环境会令已有登录态、Token 和服务器地址不匹配，只应由系统应用在初始化阶段设置。

## [请求加解密](<#请求加解密>)
    
    
    encryptRequestParams(options: object): void
    
    decryptResponseData(options: {
      security: string
      data: string
      success?: (plainText: string) => void
      fail?: FailureCallback
      complete?: () => void
    }): void

`encryptRequestParams` 的输入是待加密参数及当前帐号安全材料组成的对象；预装应用把返回结果进行 URI 编码后用于网络请求。`decryptResponseData` 强制要求 `security` 与 `data`。不要自行实现或替换其加密算法，系统帐号服务会管理密钥格式与轮换。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| △  
  
## [获取源代码](<#获取源代码>)

  * openvela Feature Framework 当前没有公开该厂商服务的 JIDL 或 C++ 实现。
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# service.wechat

> 来源: [https://docs.luoxe.cn/docs/vela/features/service-wechat/](https://docs.luoxe.cn/docs/vela/features/service-wechat/)

微信原生任务桥。接口本身可导入不代表普通应用能连接微信服务；固件还包含 `WECHAT_APP` 专用判断。
    
    
    import wechat from '@service.wechat'

该接口是异步任务总线，不是微信登录、支付或网络请求 API。推荐流程是：先注册任务和事件回调，再分配唯一 `task_id`，最后调用原生函数；页面退出时取消两个回调。

## [`wechat.js_invoke_function(info)`](<#wechat-js-invoke-function-info>)

字段| 类型| 说明  
---|---|---  
`task_id`| Number| 任务 ID  
`func_name`| String| 原生函数名  
`request_body`| String| 请求体；通常是业务协议要求的 JSON 字符串  
  
方法同步返回 `void`。真正结果通过任务回调返回，并用同一个 `task_id` 关联。

## [任务回调](<#任务回调>)
    
    
    wechat.js_regist_task_callback(data => {
      // data: { task_id: number, error_code: number, resp_body: string }
    })
    
    wechat.js_unregist_task_callback()

## [事件回调](<#事件回调>)
    
    
    wechat.js_regist_event_callback(data => {
      // data: { event: string, event_body: string }
    })
    
    wechat.js_unregist_event_callback()

## [完整调用骨架](<#完整调用骨架>)

下面的 `func_name` 只是占位符；固件未暴露微信侧允许调用的函数名清单，不应把它当成可直接运行的业务示例。
    
    
    let nextTaskId = 1
    const pending = new Map()
    
    wechat.js_regist_task_callback(result => {
      const task = pending.get(result.task_id)
      if (!task) return
      pending.delete(result.task_id)
    
      if (result.error_code === 0) {
        task.resolve(result.resp_body)
      } else {
        task.reject(result)
      }
    })
    
    wechat.js_regist_event_callback(({ event, event_body }) => {
      console.log('wechat event', event, event_body)
    })
    
    function invokeWechat(funcName, body) {
      const taskId = nextTaskId++
      return new Promise((resolve, reject) => {
        pending.set(taskId, { resolve, reject })
        wechat.js_invoke_function({
          task_id: taskId,
          func_name: funcName,
          request_body: JSON.stringify(body)
        })
      })
    }
    
    function disposeWechatBridge() {
      wechat.js_unregist_task_callback()
      wechat.js_unregist_event_callback()
      pending.clear()
    }

`task_id` 和 `error_code` 在 JIDL 中是 `double`，JS 层应使用可安全精确表示的整数，不要超过 `Number.MAX_SAFE_INTEGER`。`resp_body`/`event_body` 只是字符串，是否为 JSON 必须由具体业务协议决定，解析时应捕获异常。

## [限制与失败判断](<#限制与失败判断>)

  * 固件应用加载器存在 `WECHAT_APP` 专用判断，说明包名、签名或进程身份可能参与授权；
  * 注册成功不代表微信侧服务在线，手机未连接或未登录时可能永远没有任务结果；
  * JIDL 没有超时机制，调用方必须自己设置超时并清理 `pending`；
  * 同一应用应只维护一套全局回调，重复注册可能覆盖旧回调。


完整方法：

方法  
---  
`js_invoke_function(info)`  
`js_regist_task_callback(callback)`  
`js_regist_event_callback(callback)`  
`js_unregist_task_callback()`  
`js_unregist_event_callback()`  
  
## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：wechat.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/wechat.jidl>)
  * [C++ 实现：wechat_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/wechat_impl.cpp>)

---

# system.bluetooth 与 BLE 广播

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-bluetooth/](https://docs.luoxe.cn/docs/vela/features/system-bluetooth/)

官网已经公开 `system.bluetooth.ble` 的 Scanner 与 GATT Client；本页补充 `system.bluetooth.getAddressAsync()`、`createAdvertiser()` 和 advertiser 实例，用于读取本机蓝牙地址及发送 BLE 广播。

## [导入](<#导入>)
    
    
    import bluetooth from '@system.bluetooth'
    import ble from '@system.bluetooth.ble'

## [`bluetooth.getAddressAsync(callback)`](<#bluetooth-getaddressasync-callback>)
    
    
    getAddressAsync(callback: (address: string) => void): void

原生入口严格要求一个参数且必须是函数。回调值是本机蓝牙地址；失败时实现可能不给回调，因此业务侧应设置超时。
    
    
    bluetooth.getAddressAsync(address => {
      console.log('BT address', address)
    })

蓝牙 MAC 属于设备标识。预装汽车应用同时声明 `hapjs.permission.DEVICE_INFO`，普通应用即使能导入 Feature，也可能被权限或系统签名策略拒绝。

## [`ble.createAdvertiser()`](<#ble-createadvertiser>)
    
    
    createAdvertiser(): Advertiser

返回一个广播器实例。实例确认有 `startAdvertising()` 和 `stopAdvertising()`。

## [`advertiser.startAdvertising(options)`](<#advertiser-startadvertising-options>)
    
    
    interface AdvertiseSetting {
      interval: number
      txPower?: number
      connectable?: boolean
    }
    
    interface ServiceData {
      serviceUuid: string
      serviceValue: ArrayBuffer
    }
    
    interface AdvData {
      serviceUuids?: string[]
      serviceData: ServiceData[]
    }
    
    interface StartAdvertisingOptions {
      setting: AdvertiseSetting
      advData: AdvData
      success?: (data?: object) => void
      fail?: (data: object, code?: number) => void
      complete?: () => void
    }
    
    startAdvertising(options: StartAdvertisingOptions): void

字段| 必需| 说明  
---|---|---  
`setting.interval`| 是| 广播间隔，数值单位由蓝牙后端定义；不要直接套用毫秒  
`setting.txPower`| 否| 发射功率枚举或档位，由产品蓝牙栈解释  
`setting.connectable`| 否| 当前接口只支持不可连接广播；传 `true` 会被忽略  
`advData.serviceUuids`| 否| 广播的 Service UUID 列表  
`advData.serviceData`| 是| 至少一个 Service Data 项；空数组会报错  
`serviceUuid`| 是| UUID 字符串，预装应用使用 128 位 UUID  
`serviceValue`| 是| Service Data 二进制内容，使用 `ArrayBuffer`  
      
    
    const advertiser = ble.createAdvertiser()
    const bytes = new Uint8Array([0x01, 0x02, 0x03])
    
    advertiser.startAdvertising({
      setting: {
        interval: 160,
        txPower: 0,
        connectable: false
      },
      advData: {
        serviceUuids: ['0000FE95-0000-1000-8000-00805F9B34FB'],
        serviceData: [{
          serviceUuid: '0000FE95-0000-1000-8000-00805F9B34FB',
          serviceValue: bytes.buffer
        }]
      },
      success() { console.log('advertising') },
      fail(data, code) { console.error(code, data) }
    })

## [`advertiser.stopAdvertising()`](<#advertiser-stopadvertising>)
    
    
    stopAdvertising(): void

页面隐藏、应用退出或登录二维码失效时必须停止广播。不要依赖垃圾回收释放蓝牙资源。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| △  
  
## [获取源代码](<#获取源代码>)

  * openvela Feature Framework 当前没有公开这三个厂商模块的 JIDL 或 C++ 实现。
  * [Xiaomi Vela 官网：蓝牙 bluetooth](<https://iot.mi.com/vela/quickapp/zh/features/system/bluetooth.html>)
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# system.cipher

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-cipher/](https://docs.luoxe.cn/docs/vela/features/system-cipher/)

旧式高层密码接口。官网公开的 `system.crypto` 仍应作为新代码的首选；`system.cipher` 更像兼容层。
    
    
    import cipher from '@system.cipher'

## [公共回调](<#公共回调>)

名称| 签名| 说明  
---|---|---  
`success`| `(result) => void`| 字符串结果通常为 `{ text: string }`；验签结果为布尔值或含布尔值对象  
`fail`| `(message: string, code: number) => void`| 失败回调  
`complete`| `() => void`| 成功或失败后执行  
  
支持的 `hashType`：`MD5`、`SHA1`、`SHA256`、`SHA512`，默认 `SHA256`。

所有方法同步返回 `void`，结果只能从回调取得。固件错误字符串表明参数缺失、非法 `action`、RSA 解密失败以及 IV 越界会进入失败路径。

## [`cipher.rsa(options)`](<#cipher-rsa-options>)

RSA 加密或解密。

参数| 类型| 必填| 说明  
---|---|---|---  
`action`| String| 是| `encrypt` 或 `decrypt`  
`text`| String| 是| 输入文本；编码细节依实现  
`key`| String| 是| RSA 公钥或私钥文本  
`hashType`| String| 否| 默认 `SHA256`  
`success` / `fail` / `complete`| Function| 否| 通用回调  
      
    
    cipher.rsa({
      action: 'encrypt',
      text: 'hello',
      key: publicKeyPem,
      hashType: 'SHA256',
      success: res => console.log(res.text),
      fail: (msg, code) => console.error(code, msg)
    })

解密时把 `action` 改为 `decrypt` 并传入对应私钥。JIDL 只声明输入输出为字符串，没有规定 PEM/DER、Base64、字符集、RSA padding 或密文编码；这些都必须用 目标机型实机和你的密钥格式验证。不要假定它与 WebCrypto 的默认格式互通。

## [`cipher.sign(options)`](<#cipher-sign-options>)

RSA 签名。参数沿用 RSA 参数结构，但实际必需的是 `text`、`key`、`hashType`；`action` 对签名没有意义。
    
    
    cipher.sign({
      text: 'payload',
      key: privateKeyPem,
      hashType: 'SHA256',
      success: ({ text: signature }) => console.log(signature),
      fail: (message, code) => console.error(code, message)
    })

固件包含 `RSA-SHA1`、`RSA-SHA256`、`RSA-SHA512` 字符串。签名结果的字符串编码未由 JIDL 规定，常见情况是 Base64，但文档不把它写成保证。

## [`cipher.verify(options)`](<#cipher-verify-options>)

RSA 验签。

参数| 类型| 必填  
---|---|---  
`text`| String| 是  
`key`| String| 是  
`signature`| String| 是  
`hashType`| String| 否，默认 `SHA256`  
`success` / `fail` / `complete`| Function| 否  
      
    
    cipher.verify({
      text: 'payload',
      signature,
      key: publicKeyPem,
      hashType: 'SHA256',
      success: result => {
        // JIDL 只标为“object，语义为 boolean”
        console.log('verify result', result)
      }
    })

由于 JIDL 的成功参数是宽泛 object，真机上应先检查它是布尔值，还是 `{ result: boolean }` 一类包装对象。

## [`cipher.digest(options)`](<#cipher-digest-options>)

计算摘要。
    
    
    cipher.digest({
      hashType: 'SHA256',
      text: 'hello',
      success: res => console.log(res.text)
    })

摘要作用于 `text` 的内部字符串编码。要对任意二进制文件做摘要，应使用公开 `system.crypto` 等能明确接受 buffer 的接口。

## [`cipher.md5(options)`](<#cipher-md5-options>)

MD5 快捷接口。参数为 `text` 和三类通用回调。
    
    
    cipher.md5({
      text: 'hello',
      success: ({ text }) => console.log(text)
    })

MD5 不适合密码存储、签名或完整性安全校验，只应兼容旧协议。

## [`cipher.aes(options)`](<#cipher-aes-options>)

AES 加密或解密。

参数| 类型| 必填| 默认值/说明  
---|---|---|---  
`action`| String| 是| `encrypt` / `decrypt`  
`text`| String| 是| 输入文本  
`key`| String| 是| AES 密钥  
`iv`| String| 是| 初始化向量  
`ivOffset`| Integer| 否| `0`  
`ivLen`| Integer| 否| `16`；`ivOffset` 不能超过 IV 长度  
`success` / `fail` / `complete`| Function| 否| 通用回调  
      
    
    cipher.aes({
      action: 'encrypt',
      text: 'hello',
      key: aesKey,
      iv: aesIv,
      ivOffset: 0,
      ivLen: 16,
      success: ({ text }) => console.log(text),
      fail: (message, code) => console.error(code, message)
    })

`ivOffset` 与 `ivLen` 指示从 IV 字符串中使用的区段。固件明确检查 offset 不得超过 IV 长度，但没有在 JIDL 中说明 AES mode、padding、密钥/IV 编码和输出编码；跨平台协议必须先用固定测试向量验证。

## [选择建议](<#选择建议>)

  * 新应用：优先官网公开的 `system.crypto`；
  * 兼容旧协议：可用 `system.cipher`，但把算法、padding、编码和测试向量写入业务协议；
  * 不要在日志中打印私钥、AES key、IV 或明文；
  * `SHA1`、`MD5` 仅用于被迫兼容的旧系统。


## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：cipher.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/cipher.jidl>)
  * [C++ 实现：cipher_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/cipher_impl.cpp>)

---

# system.digitalkey

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-digitalkey/](https://docs.luoxe.cn/docs/vela/features/system-digitalkey/)

数字车钥匙系统桥，后端是 DKF/ICCOA 服务、蓝牙栈和安全单元。可用于创建和激活车钥匙、处理 APDU、订阅车辆状态并发送远程无钥匙进入（RKE）动作。
    
    
    import digitalkey from '@system.digitalkey'

警告

这是安全关键接口。错误调用可能导致钥匙停用、删除、车辆连接中断或安全单元状态不一致。不要在没有车厂协议、帐号授权及恢复流程时调用写操作。

## [回调约定](<#回调约定>)

除事件属性外，方法采用 options 对象和 `success/fail/complete` 回调：
    
    
    interface Callbacks<T = object> {
      success?: (data: T) => void
      fail?: (data: object, code?: number) => void
      complete?: () => void
    }

固件还注册了 `onscanresult`、`onconnect`、`ondisconnect`、`onkeyactive` 和 `onvehicleconnectionstatechange` 事件属性。预装应用主要使用订阅方法与 `onkeyactive`。

## [服务与扫描](<#服务与扫描>)

### [`getDkfInfo(options?)`](<#getdkfinfo-options>)

读取 DKF 服务和安全单元基础信息。预装应用从成功结果使用 `dkAttestation`，并把它交给云端钥匙激活流程。
    
    
    digitalkey.getDkfInfo({
      success(info) { console.log('DKF ready', Boolean(info)) },
      fail(data, code) { console.error(code) }
    })

### [`startScan(options)` / `stopScan()`](<#startscan-options-stopscan>)
    
    
    startScan(options: Callbacks & {
      keyId: string
      timeout?: number
    }): void
    
    stopScan(): void

`keyId` 必需；原生实现还校验 `timeout` 必须是数值。扫描结果通过成功回调或 `onscanresult` 到达。

## [蓝牙连接](<#蓝牙连接>)
    
    
    connect(options: Callbacks & { address: string }): void
    disconnect(options: Callbacks & { address: string }): void
    getVehicleConnectionState(options: Callbacks & { keyId: string }): void

`address` 是扫描得到的车辆蓝牙地址。连接状态还会通过 `onconnect`、`ondisconnect` 或车辆状态订阅回调更新。

## [钥匙生命周期](<#钥匙生命周期>)
    
    
    createKey(options: Callbacks & {
      vid?: string
      vehicleId?: string
      vehicleOEMId?: string
    }): void
    
    enableKey(options: Callbacks & { keyId: string }): void
    disableKey(options: Callbacks & { keyId: string }): void
    deleteKey(options: Callbacks & { keyId: string }): void
    getKeyActivedData(options: Callbacks & { keyId: string }): void
    getKeyInfo(options: Callbacks & { keyId?: string }): void

字段/方法| 说明  
---|---  
`vid` / `vehicleId` / `vehicleOEMId`| 创建钥匙的车辆标识；原生实现要求这组标识完整到足以定位车辆，预装应用同时传入 `vehicleId` 和 `vehicleOEMId`  
`enableKey`| 重新启用已存在的本地钥匙  
`disableKey`| 暂停钥匙，不删除安全材料  
`deleteKey`| 删除本地钥匙；通常还需同步云端状态  
`getKeyActivedData`| 读取激活流程所需数据  
`getKeyInfo`| 读取本地钥匙/安全单元信息；预装应用使用结果中的 `seCplc`/`cplc`  
      
    
    digitalkey.createKey({
      vehicleId: 'vehicle-id-from-cloud',
      vehicleOEMId: 'oem-id-from-cloud',
      success(data) { console.log('created') },
      fail(data, code) { console.error('createKey', code) }
    })

## [安全单元 APDU](<#安全单元-apdu>)

### [`requestApplet(options)`](<#requestapplet-options>)
    
    
    requestApplet(options: Callbacks & {
      data: string | ArrayBuffer
    }): void

`data` 必需。预装应用按云端下发的 APDU 序列逐项调用，并检查 `responseData` 与 `responseSw`。输入格式、分包和允许的 APDU 都由 DKF/车厂协议决定，不应使用任意命令探测安全单元。

### [`setVehicleBleMac(options)`](<#setvehicleblemac-options>)
    
    
    setVehicleBleMac(options: Callbacks & {
      keyId: string
      mac: string
    }): void

`keyId` 和 `mac` 都必需，用于把云端/扫描取得的车辆蓝牙地址绑定到钥匙。

## [RKE 动作](<#rke-动作>)
    
    
    requestRKEAction(options: Callbacks & {
      keyId: string
      functionId: number
      actionId: number
      isConsecutive?: boolean
    }): void

`keyId`、`functionId`、`actionId` 必需。固件还检查 `isConsecutive` 的类型。动作编号属于车辆协议，不能把不同品牌或车型的编号互换。
    
    
    digitalkey.requestRKEAction({
      keyId,
      functionId,
      actionId,
      isConsecutive: false,
      success(data) { console.log('RKE accepted') },
      fail(data, code) { console.error('RKE failed', code) }
    })

成功回调只说明请求被 DKF 接收；车辆是否执行还应从后续状态消息确认。

## [状态订阅](<#状态订阅>)
    
    
    subscribeKeyStatus(options: Callbacks & {
      keyId: string
      callback?: (status: object) => void
    }): void
    
    unsubscribeKeyStatus(options: { keyId: string } | string): void
    
    subscribeVehicleStatus(options: Callbacks & {
      keyId: string
      callback?: (status: object) => void
    }): void
    
    unsubscribeVehicleStatus(options: { keyId: string } | string): void

两个订阅均强制要求 `keyId`。预装应用从车辆状态中处理 `entityId`、`entityStatus`、`entityStatusUnit`、`timeStamp` 等字段；字段语义仍由车厂协议定义。
    
    
    digitalkey.subscribeVehicleStatus({
      keyId,
      callback(status) {
        // 先按车辆协议检查时间戳与实体编号，再更新 UI。
      }
    })
    
    // 页面销毁时
    digitalkey.unsubscribeVehicleStatus({ keyId })
    digitalkey.unsubscribeKeyStatus({ keyId })
    digitalkey.stopScan()

## [完整成员清单](<#完整成员清单>)

类别| 成员  
---|---  
服务信息| `getDkfInfo`  
扫描/连接| `startScan`、`stopScan`、`connect`、`disconnect`、`getVehicleConnectionState`  
钥匙| `createKey`、`enableKey`、`disableKey`、`deleteKey`、`getKeyActivedData`、`getKeyInfo`  
安全单元/车辆| `requestApplet`、`setVehicleBleMac`、`requestRKEAction`  
订阅| `subscribeKeyStatus`、`unsubscribeKeyStatus`、`subscribeVehicleStatus`、`unsubscribeVehicleStatus`  
事件| `onscanresult`、`onconnect`、`ondisconnect`、`onkeyactive`、`onvehicleconnectionstatechange`  
  
## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| △  
  
## [获取源代码](<#获取源代码>)

  * openvela Feature Framework 当前没有公开该厂商数字钥匙模块的 JIDL 或 C++ 实现。
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# system.exchange

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-exchange/](https://docs.luoxe.cn/docs/vela/features/system-exchange/)

跨作用域字符串键值交换。与 `system.storage` 的应用私有数据库不同，底层使用系统 property/exchange 服务。
    
    
    import exchange from '@system.exchange'

## [作用域](<#作用域>)

`scope`| 含义| 限制  
---|---|---  
`global`| 全局交换域| 默认；不能同时提供 `package`、`sign`  
`vendor`| 厂商域| 不能同时提供 `package`、`sign`  
`application`| 指定应用域| 固件实现要求同时提供目标 `package` 与 `sign`  
  
`package`、`sign` 是目标固件实现中存在的扩展字段；上游 JIDL 没有公开它们。

底层会给 key 加作用域前缀，因此同名 key 在不同 scope 下不是同一条记录。固件会拒绝不支持的 scope、超长 key/value，以及 scope 与 `package/sign` 的非法组合。

## [`exchange.set(options)`](<#exchange-set-options>)

参数| 类型| 必填  
---|---|---  
`key`| String| 是  
`value`| String| 是  
`scope`| String| 否，默认 `global`  
`package`| String| `application` scope 时是  
`sign`| String| `application` scope 时是  
`success`| Function| 否；接收字符串  
`fail`| Function| 否；`(message, code)`  
`complete`| Function| 否  
  
同步返回 `void`。`success` 的字符串参数由底层 property 回调产生，业务代码通常不需要解析它。

## [`exchange.get(options)`](<#exchange-get-options>)

参数同上但不需要 `value`。成功回调接收 `{ value: string }`。

## [`exchange.remove(options)`](<#exchange-remove-options>)

删除指定 `key`。参数为 `key`、作用域字段和通用回调。

## [`exchange.clear(options)`](<#exchange-clear-options>)

清空指定作用域。参数为作用域字段和通用回调。
    
    
    exchange.set({
      key: 'demo-key',
      value: 'demo-value',
      scope: 'global',
      success: () => exchange.get({
        key: 'demo-key',
        scope: 'global',
        success: res => console.log(res.value)
      })
    })

## [Promise 封装与完整 CRUD](<#promise-封装与完整-crud>)
    
    
    function getExchange(key, scope = 'global') {
      return new Promise((resolve, reject) => {
        exchange.get({
          key,
          scope,
          success: ({ value }) => resolve(value),
          fail: (message, code) => reject({ message, code })
        })
      })
    }
    
    function removeExchange(key, scope = 'global') {
      return new Promise((resolve, reject) => {
        exchange.remove({
          key,
          scope,
          success: resolve,
          fail: (message, code) => reject({ message, code })
        })
      })
    }
    
    function clearExchange(scope = 'global') {
      return new Promise((resolve, reject) => {
        exchange.clear({
          scope,
          success: resolve,
          fail: (message, code) => reject({ message, code })
        })
      })
    }

`clear()` 会影响整个指定作用域，不要用它代替逐 key 清理。特别是 `global` 或 `vendor` 可能由多个组件共享。

## [application scope 探测模板](<#application-scope-探测模板>)
    
    
    exchange.get({
      key: 'shared-key',
      scope: 'application',
      package: '目标应用包名',
      sign: '目标应用签名标识',
      success: ({ value }) => console.log(value),
      fail: (message, code) => console.error(code, message)
    })

固件证明这两个字段必须同时提供，但没有证明 `sign` 需要证书摘要、别名还是厂商内部 token。除非你掌握目标系统协议，否则不要猜测其格式。

固件会检查 key 和 value 长度，但二进制没有暴露稳定的 JS 层最大值；不要把它用于大块数据。

它只存字符串：对象需要 `JSON.stringify()`，读取后用 `JSON.parse()`，并处理旧版本/损坏数据。敏感 token 不应明文放入全局交换域。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ❌  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：exchange.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/exchange.jidl>)
  * [C++ 实现：exchange_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/exchange_impl.cpp>)

---

# system.folme

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-folme/](https://docs.luoxe.cn/docs/vela/features/system-folme/)

小米 UI Folme 动画桥，提供以下成员：

成员| 说明  
---|---  
`setTo`| 立即把目标设置到属性状态  
`fromTo`| 从一组属性动画到另一组属性  
`startGroup`| 启动一组对象/属性动画  
`isFinished`| 查询动画是否结束  
`cancel`| 取消动画  
`getState`| 获取动画状态  
`attr`| 单属性描述字段  
`attrs`| 多属性描述字段  
`onUpdate`| 更新回调  
`onComplete`| 完成回调  
  
这是面向旧 UI 引擎对象的原生动画桥，不是普通 DOM/CSS API。状态对象以 `attr`、`fromState`、`toState` 和配置项组合表达。

固件实现还确认：

  * `fromTo` 最终进入内部 `fromToInner`；
  * 配置支持 `ease` 和 `delay`，默认缓动痕迹为 `{ "ease": ["immediate", 0] }`；
  * 目标元素被删除时会报 `Folme element is removed or deleting.`；
  * 可动画属性至少包括 `scale-x/y`、`translate-x/y`、边框宽度/圆角、padding 和 margin 各方向属性。


## [已确认的属性名](<#已确认的属性名>)
    
    
    scale-x              scale-y
    translate-x          translate-y
    border-width         border-top-width
    border-right-width   border-bottom-width
    border-left-width    border-radius
    padding-top          padding-right
    padding-bottom       padding-left
    margin-top           margin-right
    margin-bottom        margin-left

属性名必须使用连字符形式，不能根据 CSS 习惯擅自改成 camelCase。

## [参数对象](<#参数对象>)
    
    
    interface FolmeState {
      attr: string
      value?: number | string
      [property: string]: unknown
    }
    
    interface FolmeConfig {
      delay?: number
      ease?: string | unknown[]
      onUpdate?: (value: unknown) => void
      onComplete?: () => void
    }
    
    interface FromToOptions extends FolmeConfig {
      attr: string
      fromState: FolmeState | object
      toState: FolmeState | object
    }

`fromState`、`toState` 是原生实现强制读取的字段，动画对象还必须带框架分配的 unique identifier；普通 JS 对象无法伪造有效 DOM 元素句柄。预装汽车应用确认使用 `attr: 'scale'`、`fromState`、`toState`、`ease: 'cubic-bezier'`、`delay`、`onUpdate` 和 `onComplete`。

## [方法职责与入参](<#方法职责与入参>)

方法| 可确认的职责| 未确认项  
---|---|---  
`setTo(target, toState)`| 立即把目标设置到 `toState`| 状态字段随属性类型变化  
`fromTo(target, options)`| 按 `fromState` 到 `toState` 启动动画| 返回值不应作为完成依据  
`startGroup(group)`| 批量启动一组对象/属性动画| 每项仍需有效元素 identifier  
`isFinished(target)`| 查询目标动画是否结束| 返回布尔值  
`cancel(target, attrs?)`| 取消目标全部或指定属性动画| `attrs` 是属性名数组  
`getState(target, attrs)`| 读取指定属性当前状态| `attrs` 必须是字符串属性名  
  
## [`fromTo` 示例](<#fromto-示例>)

固件明确解析 `ease` 与 `delay`，并包含默认片段：
    
    
    import folme from '@system.folme'
    
    // target 必须来自当前页面旧 UI 引擎，不能传 CSS selector。
    folme.fromTo(target, {
      attr: 'scale',
      fromState: { scale: 1 },
      toState: { scale: 0.92 },
      ease: 'cubic-bezier',
      delay: 0,
      onUpdate(value) {},
      onComplete() {}
    })

旧版本也保留 `{ ease: ['immediate', 0] }` 形式的内部默认配置；因此 `ease` 既可能是预设名，也可能是引擎参数数组。不同 UI 运行时不应混用。

## [推荐替代方案](<#推荐替代方案>)

普通应用优先使用框架公开的 CSS transition、animation 或组件动画。只有在你能从同版本预装快应用恢复真实调用点时，才应尝试 Folme，并同时记录目标对象来源、位置参数顺序、`attr/attrs` 形态、回调入参以及页面销毁行为。

由于私有旧 Feature 没有可获取的 JIDL，不同属性的状态字段和值域仍需从同版本预装应用确认。调用前使用 `canIUse()`，并优先采用框架公开的 CSS/动画能力。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * 当前公开仓库没有 `system.folme` 的 JIDL或 C++ 实现。
  * [Feature Framework 构建文件中的 Folme 条目](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/Makefile>)

---

# system.internal.activity

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-internal-activity/](https://docs.luoxe.cn/docs/vela/features/system-internal-activity/)

控制原生 Activity/Service 的内部桥。同源 JIDL 定义如下。

方法| 返回值| 参数  
---|---|---  
`startActivity(target, params)`| Integer 状态码| `target: string`, `params: object`  
`stopActivity(target)`| Integer 状态码| `target: string`  
`startService(target, params)`| Integer 状态码| `target: string`, `params: object`  
`stopService(target)`| Integer 状态码| `target: string`  
`bindService(target, params, connection)`| Integer bindId；错误为 `-1`| 见下方  
`unbindService(bindId)`| Void| `bindId: integer`  
`moveToBackground(nonRoot)`| Boolean| `nonRoot: boolean`  
  
所有方法都是同步调用，返回值是提交到原生 Activity/Service 管理器的状态，不表示目标业务已经执行完成。`target` 的命名规则和 `params` 的字段由目标原生组件定义，不属于此 ABI。

`connection`：
    
    
    {
      connectCallBack: () => {},
      disconnectCallBack: () => {}
    }

## [调用骨架](<#调用骨架>)

以下 target 仅是占位符。必须从系统组件协议、预装应用或厂商文档获得真实目标名。
    
    
    import activity from '@system.internal.activity'
    
    const status = activity.startActivity('vendor.component.Target', {
      source: 'quickapp'
    })
    
    console.log('startActivity status:', status)

启动/停止 Service：
    
    
    const startStatus = activity.startService('vendor.service.Target', {
      mode: 'demo'
    })
    
    const stopStatus = activity.stopService('vendor.service.Target')

绑定 Service：
    
    
    let bindId = -1
    
    bindId = activity.bindService(
      'vendor.service.Target',
      { mode: 'demo' },
      {
        connectCallBack() {
          console.log('service connected')
        },
        disconnectCallBack() {
          console.log('service disconnected')
        }
      }
    )
    
    if (bindId > 0) {
      activity.unbindService(bindId)
      bindId = -1
    }

JIDL 只明确保证 `bindService()` 成功时 `bindId > 0`、错误时 `-1`。其他方法的具体状态码枚举没有公开，不能假设 `0` 或任意非零值的意义。

`moveToBackground(nonRoot)` 返回是否成功。`nonRoot` 的准确调度语义未由 JIDL 解释；普通应用不应依赖它改变系统任务栈。

部分 JIDL 版本还把连接与断开回调记作两个独立 callback 定义，因此拼写和回调触发时机应以真机为准。

警告

该接口能启动系统原生组件。错误 target/params 可能导致系统服务异常、安全校验失败或设备不稳定。只应在可恢复的测试设备上验证，不要枚举或暴力尝试系统组件。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：activity.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/activity.jidl>)
  * [C++ 实现：activity_feature_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/activity_feature_impl.cpp>)

---

# system.internal.messagecenter

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-internal-messagecenter/](https://docs.luoxe.cn/docs/vela/features/system-internal-messagecenter/)

MiConnect/Message Center 的跨设备消息桥，提供 `subscribe`、`unsubscribe`、`publish` 和 `unpublish`。所有方法使用 options 对象和快应用标准回调。

## [确认成员](<#确认成员>)

成员/字段| 类型| 说明  
---|---|---  
`subscribe`| Function| 订阅 topic；回调收到基础数据和扩展数据  
`unsubscribe`| Function| 取消指定 topic 订阅  
`publish`| Function| 发布消息  
`unpublish`| Function| 取消发布/停止某 topic 的持续发布  
`trustlevel`| Integer| MiConnect 信任级别  
`dispatchtype`| Integer| 分发类型  
`devicefilter`| `String[]`| 设备过滤列表  
`dstdevicelist`| `String[]`| 目标设备列表  
`sendtypes`| `Integer[]`| 发送通道/类型列表  
`basedata`| String/TypedArray| 基础数据  
`extenddata`| String/TypedArray| 扩展数据  
  
固件日志还确认订阅回调至少关联 `topic_name`、`basedata` 和 `extenddata`，并分别记录两段数据长度。底层为 MiConnect 消息中心，发布选项会被转换成 device filter、目标设备列表和 send type 列表。

## [建议的探测方式](<#建议的探测方式>)
    
    
    import app from '@system.app'
    
    const feature = '@system.internal.messagecenter'
    const methods = ['subscribe', 'unsubscribe', 'publish', 'unpublish']
    
    for (const method of methods) {
      console.log(method, app.canIUse(`${feature}.${method}`))
    }

## [参数定义](<#参数定义>)
    
    
    interface MessageCallbacks {
      success?: (data?: object) => void
      fail?: (data: object, code?: number) => void
      complete?: () => void
    }
    
    interface MessageData {
      topic: string
      basedata?: string | ArrayBuffer | Uint8Array
      extenddata?: string | ArrayBuffer | Uint8Array
      trustlevel?: number
      dispatchtype?: number
      devicefilter?: string[]
      dstdevicelist?: string[]
      sendtypes?: number[]
    }
    
    subscribe(options: MessageCallbacks & {
      topic: string
      listener: (message: ReceivedMessage) => void
    }): void
    
    unsubscribe(options: MessageCallbacks & { topic: string }): void
    publish(options: MessageCallbacks & MessageData): void
    unpublish(options: MessageCallbacks & { topic: string }): void

米家应用的订阅回调使用单个结果对象，并读取 `basedata`、`extenddata` 与 `datatype`；不同后端也可能把 topic 放在结果中。接收二进制时先判断 `ArrayBuffer`/TypedArray，再进行 UTF-8 或协议解码。

## [发布对象](<#发布对象>)
    
    
    const options = {
      topic: 'vendor.topic',       // topic 字段由实现日志确认，成员字符串可能被全局去重
      trustlevel: 0,
      dispatchtype: 0,
      devicefilter: [],
      dstdevicelist: [],
      sendtypes: [],
      basedata: new Uint8Array(),
      extenddata: new Uint8Array()
    }

字段含义：

字段| 用法建议  
---|---  
`topic`| 非空业务主题；四个操作都围绕它工作  
`trustlevel`| MiConnect 信任级别；枚举值未从固件恢复，不要随意提高  
`dispatchtype`| 分发策略；枚举值未知  
`devicefilter`| 允许/筛选设备标识列表；固件逐个复制字符串  
`dstdevicelist`| 明确目标设备列表；固件逐个复制字符串  
`sendtypes`| 传输通道/类型整数列表；枚举未知  
`basedata`| 主负载，建议使用 `Uint8Array`  
`extenddata`| 附加元数据，建议使用 `Uint8Array`  
  
## [调用示例](<#调用示例>)

topic、信任级别、分发类型和 send type 必须由真实 MiConnect 协议提供。下面使用占位 topic，不能直接用于业务：
    
    
    import messagecenter from '@system.internal.messagecenter'
    
    const topic = 'vendor.protocol.topic'
    
    messagecenter.subscribe({
      topic,
      listener(message) {
        console.log(message.topic, message.datatype)
      },
      fail(data, code) { console.error('subscribe', code) }
    })
    
    messagecenter.publish({
      topic,
      basedata: new Uint8Array([1, 2, 3]),
      extenddata: new Uint8Array(0),
      success() { console.log('published') },
      fail(data, code) { console.error('publish', code) }
    })
    
    // 页面销毁时
    messagecenter.unsubscribe({ topic })
    messagecenter.unpublish({ topic })

固件日志中的常见失败点包括：参数错误、topic 复制失败、发布数据创建失败、option 创建失败、未先订阅就取消订阅，以及底层 publish/unpublish 失败。

## [生命周期](<#生命周期>)

从 wrapper 与日志可以确认合理顺序为：

  1. `subscribe(...)` 建立 topic 订阅；
  2. 订阅回调接收 topic、基础数据和扩展数据；
  3. 不再接收时 `unsubscribe(...)`；
  4. 发布侧用 `publish(...)`，持续发布场景再用 `unpublish(...)` 停止。


`trustlevel`、`dispatchtype`、`sendtypes` 的枚举整数及设备标识格式仍属于 MiConnect 私有协议。预装米家应用在常用发布场景只传 `topic`、`basedata`、`extenddata` 与回调；不需要定向分发时不要凭空补齐这些高级字段。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * 当前公开仓库没有 `system.internal.messagecenter` 的 JIDL或 C++ 实现。
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# system.internal.power

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-internal-power/](https://docs.luoxe.cn/docs/vela/features/system-internal-power/)

高危系统内部接口。

## [`power.shutDown(status?)`](<#power-shutdown-status>)

请求关机。同步返回 `void`；若系统接受请求，JS 环境可能在回调执行前就被终止。

## [`power.reboot(status?)`](<#power-reboot-status>)

请求重启。同步返回 `void`。

`status` 可省略，或包含：

字段| 签名  
---|---  
`success`| `(data: string) => void`  
`fail`| `(data: string, code: number) => void`  
`complete`| `(data: string) => void`  
      
    
    import power from '@system.internal.power'
    
    power.reboot({
      fail: (msg, code) => console.error(code, msg)
    })

参数可以整体省略：
    
    
    power.reboot()

但调试阶段建议保留失败回调。由于成功后设备会关机/重启，不能依赖 `success` 或 `complete` 做关键数据保存；应先完成持久化，再发起电源操作。
    
    
    async function rebootAfterSave() {
      await saveApplicationState()
      power.reboot({
        success: message => console.log('accepted', message),
        fail: (message, code) => console.error('rejected', code, message),
        complete: message => console.log('request complete', message)
      })
    }

普通第三方应用即使能 `require()`，也可能在 manifest 校验、权限检查或签名白名单阶段失败。不要把它用于公开发行应用。

警告

不要循环调用、在启动阶段自动调用，或把该能力暴露给未经确认的远程消息。测试前确保设备可通过充电/按键恢复，并保存未同步数据。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：power.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/power.jidl>)
  * [C++ 实现：power_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/power_impl.cpp>)

---

# system.media

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-media/](https://docs.luoxe.cn/docs/vela/features/system-media/)

官网目录中的 `system.audio` 是音频播放；这里的 `system.media` 是独立图片预览 feature。

## [`media.previewImage(options)`](<#media-previewimage-options>)

参数| 类型| 必填| 说明  
---|---|---|---  
`current`| Object/Any| 否| 当前展示项；默认 `null`，精确形态未固定  
`uris`| `String[]`| 是| 图片 URI 列表  
`success`| Function| 否| 成功回调  
`fail`| Function| 否| `(message, code)`  
`complete`| Function| 否| 完成回调  
      
    
    import media from '@system.media'
    
    media.previewImage({
      current: null,
      uris: [
        'internal://files/a.jpg',
        'internal://files/b.jpg'
      ],
      fail: (msg, code) => console.error(code, msg)
    })

`current` 在 JIDL 中故意定义为宽泛的 `object`。旧实现可能接受索引、URI 或媒体项对象，但 当前固件样本的 JIDL 没有给出契约；最稳妥的调用是省略它或传 `null`，让预览从默认图片开始。若要指定当前图，应分别真机测试 `0`、URI 字符串和对象形态，不能把任一种写成跨固件保证。

`success` 表示预览界面已成功调起，不代表用户看完图片；`complete` 在成功或失败路径后执行。JIDL 中三个回调均无成功数据。

## [使用建议](<#使用建议>)

  * URI 应是快应用有权读取的本地/内部 URI；普通文件系统绝对路径可能被沙箱拒绝；
  * 在调用前过滤空字符串并确认 `uris.length > 0`；
  * 大图是否缩放、缓存和支持的格式由系统媒体实现决定；
  * 不要把 `system.media` 与音频播放的 `system.audio` 混用。


    
    
    function previewImages(uris) {
      const valid = uris.filter(uri => typeof uri === 'string' && uri.length > 0)
      if (!valid.length) throw new Error('no image uri')
    
      media.previewImage({
        uris: valid,
        success: () => console.log('preview opened'),
        fail: (message, code) => console.error(code, message),
        complete: () => console.log('preview request completed')
      })
    }

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：media.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/media.jidl>)
  * [C++ 实现：media_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/media_impl.cpp>)

---

# system.mqtt

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-mqtt/](https://docs.luoxe.cn/docs/vela/features/system-mqtt/)

原生 MQTT 客户端 Feature。它与只负责 protobuf 编解码的 `system.mqttmessage` 不同：`system.mqtt` 建立网络连接、订阅主题并发布消息。
    
    
    import mqtt from '@system.mqtt'

## [`mqtt.createConnection(options)`](<#mqtt-createconnection-options>)
    
    
    interface MqttConnectOptions {
      brokerUrl: string
      clientId?: string
      username?: string
      password?: string
      clean?: boolean
      keepalive?: number
      reconnectPeriod?: number
      connectTimeout?: number
      userProperties?: object
    }
    
    createConnection(options: MqttConnectOptions): MqttClient

字段| 必需| 说明  
---|---|---  
`brokerUrl`| 是| Broker URL；格式不合法或缺失会直接报错  
`clientId`| 否| 客户端 ID；未传时固件可生成以 `mqtt_` 开头的 ID  
`username`、`password`| 否| Broker 凭据  
`clean`| 否| 是否使用 clean session  
`keepalive`| 否| MQTT keepalive 周期  
`reconnectPeriod`| 否| 自动重连间隔  
`connectTimeout`| 否| 建连超时  
`userProperties`| 否| MQTT 用户属性；预装汽车应用用于携带业务元数据  
      
    
    const client = mqtt.createConnection({
      brokerUrl: 'ssl://broker.example.invalid:8883',
      clientId: 'watch-client-id',
      username: 'user',
      password: 'short-lived-token',
      clean: true,
      keepalive: 60,
      reconnectPeriod: 3000,
      connectTimeout: 10000,
      userProperties: { channel: 'watch' }
    })

协议 scheme、TLS 证书和端口是否可用由厂商 MQTT 后端决定。示例域名不可直接使用。

## [客户端事件](<#客户端事件>)
    
    
    client.onconnect = () => {}
    client.ondisconnect = reason => {}
    client.onreconnect = () => {}
    client.onerror = error => {}
    client.onmessage = (topic, payload) => {}

固件确认 `onconnect`、`ondisconnect`、`onreconnect`、`onmessage`；预装应用还设置 `onerror`。`payload` 可能是 `String` 或 `ArrayBuffer`，应按协议判断后再解码。

## [订阅与发布](<#订阅与发布>)
    
    
    client.addTopic(options: {
      topic: string
      success?: Function
      fail?: Function
      complete?: Function
    }): void
    
    client.removeTopic(options: { topic: string } | string): void
    
    client.publish(options: {
      topic: string
      payload: string | ArrayBuffer
      retain?: boolean
      success?: Function
      fail?: Function
      complete?: Function
    }): void

`addTopic` 对应订阅，原生实现强制要求 `topic`。`publish` 强制要求 `topic`，并只接受 String 或 ArrayBuffer 的 `payload`。固件还保留 `addTopicListener`、`removeTopicListener` 内部入口；业务应用使用 `onmessage` 接收消息即可。
    
    
    client.onconnect = () => {
      client.addTopic({
        topic: 'ToWatch/device-id/#',
        fail(data, code) { console.error('subscribe', code) }
      })
    }
    
    client.onmessage = (topic, payload) => {
      console.log('message topic', topic)
    }
    
    client.publish({
      topic: 'FromWatch/device-id/result',
      payload: new Uint8Array([1, 2, 3]).buffer,
      retain: false
    })

## [断开连接](<#断开连接>)

预装应用在 `onHide`/`onDestroy` 调用客户端的 `disconnect()`。应先移除不再使用的主题，再断开连接；不要让后台重连器在页面销毁后继续运行。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| △  
  
## [获取源代码](<#获取源代码>)

  * openvela Feature Framework 当前没有公开该厂商 MQTT Feature 的 JIDL 或 C++ 实现。
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# system.mqttmessage

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-mqttmessage/](https://docs.luoxe.cn/docs/vela/features/system-mqttmessage/)

用于小米内部 MQTT 消息结构的 protobuf 校验、编码与解码，不负责建立 MQTT 连接。
    
    
    import mqttmessage from '@system.mqttmessage'

## [消息结构](<#消息结构>)

字段| 类型| protobuf 编号  
---|---|---  
`ts`| Integer/Number| 1  
`id`| String| 2  
`carId`| String| 3  
`packageName`| String| 4  
`action`| String| 5  
`data`| Uint8Array/ArrayBuffer| 6  
  
`ts` 在 protobuf 中是整数语义，但 JS 运行时只有 Number。若协议要求毫秒时间戳，当前日期仍处于安全整数范围；不要传 BigInt，固件类型校验不接受它。

## [方法](<#方法>)

方法| 返回值| 说明  
---|---|---  
`verify(object)`| Boolean| 检查对象及字段类型，不检查业务含义  
`encode(object)`| Uint8Array| 校验并编码 protobuf；对象为空或校验失败时失败  
`decode(buffer)`| Object| 解码 typed buffer；空参数、普通数组或损坏数据会失败  
      
    
    const msg = {
      ts: Date.now(),
      id: '1',
      carId: '',
      packageName: 'com.example.demo',
      action: 'ping',
      data: new Uint8Array([1, 2, 3])
    }
    
    if (mqttmessage.verify(msg)) {
      const wire = mqttmessage.encode(msg)
      const decoded = mqttmessage.decode(wire)
      console.log(decoded.action, decoded.data)
    }

## [安全封装](<#安全封装>)
    
    
    export function encodeMqttMessage(message) {
      if (!message || !mqttmessage.verify(message)) {
        throw new TypeError('invalid mqtt message')
      }
      const result = mqttmessage.encode(message)
      if (!result) throw new Error('mqtt message encode failed')
      return result
    }
    
    export function decodeMqttMessage(buffer) {
      if (!(buffer instanceof Uint8Array) && !(buffer instanceof ArrayBuffer)) {
        throw new TypeError('typed buffer required')
      }
      const result = mqttmessage.decode(buffer)
      if (!result) throw new Error('mqtt message decode failed')
      return result
    }

## [字段解释与边界](<#字段解释与边界>)

  * `id`：业务消息 ID，模块不会替你生成或去重；
  * `carId`：协议保留的车辆标识，不属于设备蓝牙 ID；
  * `packageName`：消息来源/目标业务包名，不会自动从当前应用填充；
  * `action`：业务动作名，允许值由上层协议决定；
  * `data`：原始二进制负载，不会自动 JSON 编解码。


该模块不建立连接、不选择 broker、不发布消息，也不验证 `packageName` 是否等于当前应用。`verify()` 通过只能说明类型可编码。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：mqttmessage.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/mqttmessage.jidl>)
  * [C++ 实现：mqttmessage_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/mqttmessage_impl.cpp>)
  * [Protobuf 定义：mqtt_message.proto](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/mqtt_message.proto>)

---

# system.settings

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-settings/](https://docs.luoxe.cn/docs/vela/features/system-settings/)

厂商系统属性键值桥。它不是快应用自己的 `system.storage`：`system.settings` 读写系统业务属性，并能订阅跨进程更新。
    
    
    import settings from '@system.settings'

## [方法](<#方法>)
    
    
    getProp(options: {
      key: string
      success?: (value: string | number | object) => void
      fail?: Function
      complete?: Function
    }): void
    
    setProp(options: {
      key: string
      value: string | number
      success?: Function
      fail?: Function
      complete?: Function
    }): void
    
    subscribeProp(options: {
      key: string
      callback: (value: unknown) => void
      success?: Function
      fail?: Function
      complete?: Function
    }): void
    
    unsubscribeProp(key: string): void

方法| 行为  
---|---  
`getProp`| 异步读取指定 key  
`setProp`| 写入字符串或数值；其他 value 类型会被拒绝  
`subscribeProp`| 订阅 key 的更新，`callback` 必须是函数  
`unsubscribeProp`| 取消对应 key 的订阅  
      
    
    settings.getProp({
      key: 'car',
      success(value) { console.log(value) },
      fail(data, code) { console.error(code, data) }
    })
    
    settings.subscribeProp({
      key: 'car',
      callback(value) { console.log('car settings changed', value) }
    })
    
    // 页面销毁时
    settings.unsubscribeProp('car')

预装汽车应用也使用 `car.vid` 等带前缀的 key。key 不是公共注册表；不要枚举、覆盖或删除其他系统组件的属性。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| △  
  
## [获取源代码](<#获取源代码>)

  * openvela Feature Framework 当前没有公开该厂商模块的 JIDL 或 C++ 实现。
  * [Feature Framework 仓库](<https://github.com/open-vela/frameworks_runtimes_feature>)

---

# system.zlib

> 来源: [https://docs.luoxe.cn/docs/vela/features/system-zlib/](https://docs.luoxe.cn/docs/vela/features/system-zlib/)

只提供一个同步解压方法；没有压缩、流式解压或异步接口。

## [`zlib.decompressSync(data)`](<#zlib-decompresssync-data>)

同步解压 typed buffer，返回 `Uint8Array`；输入不是 typed buffer 或解压失败时返回 `null`。

实现会依次尝试：

  1. zlib 包装流（`MAX_WBITS`）；
  2. raw DEFLATE（`-MAX_WBITS`）；
  3. gzip（`MAX_WBITS + 16`）。


    
    
    import zlib from '@system.zlib'
    
    const output = zlib.decompressSync(compressedUint8Array)
    if (output === null) {
      console.error('decompress failed')
    } else {
      console.log('decompressed bytes:', output.byteLength)
    }

输入推荐使用 `Uint8Array`。如果拿到的是 `ArrayBuffer`，可显式创建视图：
    
    
    function decompressArrayBuffer(buffer) {
      return zlib.decompressSync(new Uint8Array(buffer))
    }

解压 UTF-8 文本时仍需单独解码；此接口不会返回字符串：
    
    
    const bytes = zlib.decompressSync(payload)
    if (bytes) {
      const text = new TextDecoder('utf-8').decode(bytes)
      console.log(text)
    }

这是同步接口，大数据会阻塞快应用 JS/uvloop。实现以 16 KiB 为增长块，没有对最终解压尺寸施加显式上限，调用方应自行限制不可信输入。尤其要防止小输入解压成超大数据的 zip bomb 类负载。

建议同时限制压缩数据大小和业务允许的预期输出大小；由于 API 只有在完成后才返回，无法在中途终止解压。对不可信网络数据，优先在手机端或后端解压。

## [返回值判定](<#返回值判定>)

返回值| 含义  
---|---  
`Uint8Array`| 解压成功；零长度是否有效取决于输入流  
`null`| 参数不是 typed buffer，或三种模式均解压失败  
  
## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：system_zlib.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/system_zlib.jidl>)
  * [C++ 实现：system_zlib_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/system_zlib_impl.cpp>)

---

