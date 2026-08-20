# Vela_快应用接口_Extensions

> 来源: 洛汐文档库
> 共 7 篇文档

---

# system.brightness 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-brightness/](https://docs.luoxe.cn/docs/vela/extensions/system-brightness/)

## [`brightness.systembrightnessrecovery()`](<#brightness-systembrightnessrecovery>)

旧版 brightness feature 的内部恢复入口，用于把快应用修改过的亮度/屏幕状态恢复到系统值。
    
    
    import app from '@system.app'
    import brightness from '@system.brightness'
    
    if (app.canIUse('@system.brightness.systembrightnessrecovery')) {
      brightness.systembrightnessrecovery()
    }

方法无参数，固件未显示返回值或回调。它的职责是恢复由快应用亮度模块修改过的系统亮度/亮屏状态，适合在页面退出后的清理阶段调用。
    
    
    onDestroy() {
      try {
        if (app.canIUse('@system.brightness.systembrightnessrecovery')) {
          brightness.systembrightnessrecovery()
        }
      } catch (e) {}
    }

不要把它理解成“恢复出厂亮度”：它恢复的是 brightness feature 保存的系统状态，具体目标值由系统实现决定。若应用从未修改亮度，通常无需调用。

固件包含独立实现 `__brightness_systembrightnessrecovery`，但当前公开 JIDL 已不再声明该方法，因此只能视为版本私有兼容接口。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：brightness.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/brightness.jidl>)（当前 JIDL 不再声明恢复入口）
  * [C++ 实现：brightness_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/brightness_impl.cpp>)

---

# system.device 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-device/](https://docs.luoxe.cn/docs/vela/extensions/system-device/)

import device from '@system.device'

官网文档已经列出 `getInfo()`、`getDeviceId()`、`getSerial()`、`getTotalStorage()`、`getAvailableStorage()`，但目标固件还有以下差异。

## [`device.getId(options)`](<#device-getid-options>)

内部 ID 获取接口，参数使用通用回调对象：
    
    
    device.getId({
      success: data => console.log(data),
      fail: (msg, code) => console.error(code, msg)
    })

`success` 的精确返回形态未从固件静态恢复，首次真机测试应打印完整值，不要直接假定是字符串：
    
    
    device.getId({
      success: result => console.log(JSON.stringify(result)),
      fail: (message, code) => console.error(code, message),
      complete: () => console.log('getId finished')
    })

固件中存在独立的 `system_device_wrap_getId`，不是 `getDeviceId` 的字符串残留。

## [`device.getDeviceId(options?)` 的同步返回](<#device-getdeviceid-options-的同步返回>)

同源 JIDL 将其定义为返回 String，且回调对象可为 `null`。部分版本因此可直接：
    
    
    const id = device.getDeviceId()

兼容写法应同时接受同步返回和回调：
    
    
    function readDeviceId() {
      return new Promise((resolve, reject) => {
        let settled = false
        const done = value => {
          if (!settled && value != null) {
            settled = true
            resolve(value)
          }
        }
    
        try {
          const returned = device.getDeviceId({
            success: done,
            fail: (message, code) => reject({ message, code })
          })
          done(returned)
        } catch (e) {
          reject(e)
        }
      })
    }

官网只描述了回调形式。此同步形式涉及稳定设备标识并受 `hapjs.permission.DEVICE_INFO` 约束。

系统层明确拦截

当前 openvela Feature Framework 源码在 `FeatureInstance::isBlackListed()` 中专门匹配 `system.device` \+ `getDeviceId`。命中后，`requestPermissions()` 直接返回 `false`。因此“在 manifest 中声明权限”并不足以让普通应用调用成功；只有设备厂商移除该黑名单，或系统通过预授权/白名单绕过动态申请时，接口才可能可用。

## [`device.getInfo()` 的额外字段](<#device-getinfo-的额外字段>)

字段| 类型| 说明  
---|---|---  
`IMEI`| String| 蜂窝设备标识；无蜂窝硬件时可能为空  
`miProductId`| String| 小米产品 ID  
`deviceModel`| String| 小米设备型号  
`miDeviceAlias`| String| 设备别名  
      
    
    device.getInfo({
      success: info => {
        console.log('product:', info.miProductId)
        console.log('model:', info.deviceModel)
        console.log('alias:', info.miDeviceAlias)
      }
    })

没有蜂窝硬件时 `IMEI` 可能为空或根本不存在。代码应使用字段存在性判断，不要把这些扩展字段作为必填。

## [隐私与稳定性](<#隐私与稳定性>)

  * `getId()`、`getDeviceId()`、`IMEI` 都可能属于稳定标识，受 `hapjs.permission.DEVICE_INFO` 和系统隐私策略约束；其中上游运行时明确拦截 `getDeviceId` 的动态权限请求；
  * 不要把设备标识写入日志、URL 查询参数或全局 exchange；
  * `miDeviceAlias` 可能由用户修改，不适合作唯一键；
  * `deviceModel` 与产品 ID 适合做兼容性分支，但仍需同时检查 feature 能力。


## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：device.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/device.jidl>)
  * [C++ 实现：device_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/device_impl.cpp>)
  * [权限黑名单：feature_instance.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/src/feature_instance.cpp>)

---

# system.interconnect 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-interconnect/](https://docs.luoxe.cn/docs/vela/extensions/system-interconnect/)

官网公开了连接实例、状态、诊断、发送和四类事件，但未列出 JIDL 中保留的旧状态接口。

## [`connect.getApkStatus()`](<#connect-getapkstatus>)

无参数，同步返回手机端应用状态字符串：

返回值| 含义  
---|---  
`CONNECTED`| 手机端应用已连接  
`DISCONNECTED`| 通道存在但当前未连接  
`UNINSTALLED`| 手机端应用未安装  
      
    
    import interconnect from '@system.interconnect'
    
    const connect = interconnect.instance()
    
    if (typeof connect.getApkStatus === 'function') {
      console.log(connect.getApkStatus())
    }

该方法在 JIDL 中明确标记为废弃。新代码应使用 `getReadyState()` 和 `diagnosis()`，因为后者能区分连接超时、应用未安装和其他错误。

## [Promise 返回形式](<#promise-返回形式>)

同源 JIDL 把以下方法定义为 Promise：
    
    
    const state = await connect.getReadyState()
    const diagnosis = await connect.diagnosis({ timeout: 10000 })
    await connect.send({ data: payload, timeout: 1000 })

官网主要展示 callback 写法。不同框架版本可能同时支持两种风格，应以返回对象是否具有 `.then` 为准。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：interconnect.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/interconnect.jidl>)
  * [C++ 实现：interconnect_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/interconnect_impl.cpp>)

---

# system.prompt 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-prompt/](https://docs.luoxe.cn/docs/vela/extensions/system-prompt/)

官网只列出 `showToast()`；固件还注册并实现 `showDialog()`。

## [`prompt.showDialog(options)`](<#prompt-showdialog-options>)

参数| 类型| 必填| 默认值  
---|---|---|---  
`title`| String| 否| `""`  
`message`| String| 是| —  
`autocancel`| Boolean| 否| `true`  
`success`| Function| 否| 接收 `{ index: integer }`  
`cancel`| Function| 否| 无参数  
`complete`| Function| 否| 无参数  
  
同步返回 `void`。`success` 返回被点击按钮的索引；`cancel` 表示弹窗被取消（例如允许点按外部区域时），不是某个按钮索引。
    
    
    prompt.showDialog({
      title: '提示',
      message: '确认继续？',
      autocancel: true,
      success: res => console.log('button index', res.index),
      cancel: () => console.log('cancelled')
    })

## [Promise 封装](<#promise-封装>)
    
    
    function showDialog(options) {
      return new Promise((resolve, reject) => {
        prompt.showDialog({
          ...options,
          success: ({ index }) => resolve({ type: 'button', index }),
          cancel: () => resolve({ type: 'cancel' }),
          complete: () => {}
        })
      })
    }
    
    const result = await showDialog({
      title: '提示',
      message: '确认继续？',
      autocancel: false
    })

JIDL 没有定义 `fail` 回调，因此参数错误或 UI 管理器不可用时，不一定能像其他 feature 一样收到 `(message, code)`。调用前应确保应用仍在前台、页面未销毁，并避免同时弹出多个对话框。

JIDL 中还存在 `{ text, color }` 的 `button` 结构痕迹，但当前 `DialogInfo` 没有稳定公开的按钮数组字段，不应依赖。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：prompt.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/prompt.jidl>)
  * [C++ 实现：prompt_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/prompt_impl.cpp>)

---

# system.request 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-request/](https://docs.luoxe.cn/docs/vela/extensions/system-request/)

官网列出 `download()` 和 `onDownloadComplete()`，但遗漏了 `download()` 的两个字段。

字段| 类型| 默认值| 说明  
---|---|---|---  
`share`| Boolean| `true`| 下载文件是否按共享语义处理  
`onDownLoadNotify`| Function| —| 进度通知，注意固件 ABI 中 `Load` 的大小写  
  
进度回调参数：
    
    
    {
      result: number,
      percent: number
    }

`result` 是底层下载进度状态/结果码，`percent` 是进度百分比；JIDL 没有给出 `result` 枚举，也没有规定百分比一定单调递增。UI 应把 percent 限制到 0–100，并允许重复通知。
    
    
    request.download({
      url: 'https://example.com/file.bin',
      share: false,
      onDownLoadNotify: ({ result, percent }) => {
        console.log(result, percent)
      },
      success: ({ token }) => console.log(token)
    })

## [推荐进度处理](<#推荐进度处理>)
    
    
    let lastPercent = 0
    
    request.download({
      url,
      share: false,
      onDownLoadNotify(info) {
        if (!info || typeof info.percent !== 'number') return
        lastPercent = Math.max(lastPercent, Math.min(100, info.percent))
        updateProgress(lastPercent)
      },
      success({ token }) {
        console.log('download token:', token)
      },
      fail(message, code) {
        console.error('download failed:', code, message)
      }
    })

`share: true` 是固件默认值，可能改变下载文件的可见范围或后续共享语义；处理敏感文件时显式设为 `false`。字段名必须严格写作 `onDownLoadNotify`，其中 `DownLoad` 的 `L` 大写是 ABI 的一部分。

进度通知不等同于下载完成，最终状态仍以 `success/fail` 及官网的 `onDownloadComplete()` 契约为准。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
❌| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：request.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/request.jidl>)
  * [C++ 实现：request_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/request_impl.cpp>)

---

# system.sensor 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-sensor/](https://docs.luoxe.cn/docs/vela/extensions/system-sensor/)

官网当前只文档化气压计、加速度计和罗盘。目标固件还实现以下传感器接口。

## [专用订阅接口](<#专用订阅接口>)

订阅方法| 取消方法| 回调数据  
---|---|---  
`subscribeProximity(options)`| `unsubscribeProximity()`| `{ distance: number }`  
`subscribeLight(options)`| `unsubscribeLight()`| `{ intensity: number }`  
`subscribeStepCounter(options)`| `unsubscribeStepCounter()`| `{ steps: number }`  
`subscribeHumidity(options)`| `unsubscribeHumidity()`| `{ humidity: number }`  
`subscribeAmbientTemperature(options)`| `unsubscribeAmbientTemperature()`| `{ temperature: number }`  
  
回调数据单位没有在 JIDL 中声明。`distance`、`intensity`、`humidity`、`temperature` 和 `steps` 都只能确认是 Number；不要未经真机校准就写死 cm、lux、%、°C 等单位标签。

通用 `options`：

字段| 类型| 说明  
---|---|---  
`reserved`| Boolean| 默认 `false`  
`interval`| String| 仅部分传感器使用；加速度计默认 `normal`  
`callback`| Function| 数据回调  
`fail`| Function| `(message, code)`；光照 JIDL 中没有 fail 字段  
  
每种专用订阅都应与对应取消方法成对使用：
    
    
    sensor.subscribeProximity({
      reserved: false,
      callback: ({ distance }) => console.log(distance),
      fail: (message, code) => console.error(code, message)
    })
    
    // 页面销毁时
    sensor.unsubscribeProximity()

光照订阅的 JIDL 没有 `fail` 字段，因此不要依赖失败回调：
    
    
    sensor.subscribeLight({
      reserved: false,
      callback: ({ intensity }) => console.log(intensity)
    })

## [通用 `sensor.subscribe(options)`](<#通用-sensor-subscribe-options>)

参数| 类型| 必填| 说明  
---|---|---|---  
`type`| Integer| 是| `sensor.DATA_TYPES` 中的类型值  
`reserved`| Boolean| 否| 默认 `false`  
`interval`| String| 否| 默认 `low`；实现识别 `low`、`mid`、`high`  
`callback`| Function| 是| 传感器数据回调  
`fail`| Function| 否| 失败回调  
  
返回订阅 ID/状态整数。对应取消方法为：
    
    
    sensor.unsubscribe(type)

虽然 `subscribe()` 返回整数，但 `unsubscribe()` 接收的是传感器 `type`，不是返回值。固件日志把非法 callback ID、传感器不支持、interval 非法、内存不足和底层 topic 订阅失败区分为不同失败路径。

通用订阅示例：
    
    
    const type = sensor.DATA_TYPES.HUMIDITY
    
    if (sensor.checkAvailable(type)) {
      const status = sensor.subscribe({
        type,
        reserved: false,
        interval: 'low',
        callback: data => console.log('sensor data', data),
        fail: (message, code) => console.error(code, message)
      })
      console.log('subscribe status:', status)
    }

实现识别 `low`、`mid`、`high`。专用加速度计接口的默认 interval 是 `normal`，不要把两套默认值混为一谈。采样越快通常越耗电。

## [`sensor.getRecentData(options)`](<#sensor-getrecentdata-options>)

获取某传感器最近一次数据。

参数| 类型| 必填  
---|---|---  
`type`| Integer| 是  
`success`| Function| 否；接收 `{ data, dataType }`  
`fail`| Function| 否  
`complete`| Function| 否  
      
    
    sensor.getRecentData({
      type: sensor.DATA_TYPES.PROXIMITY,
      success: ({ data, dataType }) => {
        console.log(dataType, data)
      },
      fail: (message, code) => console.error(code, message),
      complete: () => console.log('read complete')
    })

`data` 是宽泛对象，结构通常与对应订阅回调一致。最近值可能是缓存，不等同于此刻重新采样。

## [`sensor.checkAvailable(type)`](<#sensor-checkavailable-type>)

同步返回 Boolean，表示指定传感器类型是否存在。

传入未知编号时应视为 `false`；固件存在 `sensor type is not exist`/`sensor not exist` 错误路径。

## [`sensor.DATA_TYPES`](<#sensor-data-types>)

固件成员表至少包含以下名称：

  * `ACCELEROMETER`
  * `COMPASS`
  * `PROXIMITY`
  * `STEP_COUNTER`
  * `BAROMETER`
  * `HUMIDITY`
  * `AMBIENT_TEMPERATURE`
  * `WRIST_LIFT`


二进制未保留足够信息来安全恢复所有数值，运行时应读取常量对象而不是硬编码。
    
    
    if (sensor.checkAvailable(sensor.DATA_TYPES.HUMIDITY)) {
      sensor.subscribeHumidity({
        callback: res => console.log(res.humidity),
        fail: (msg, code) => console.error(code, msg)
      })
    }

## [生命周期和并发](<#生命周期和并发>)

  * 在 `onDestroy` 中取消所有已建立订阅；
  * 避免同时使用同一种传感器的专用订阅和通用订阅，除非真机确认底层支持多订阅者；
  * `reserved` 的业务语义没有公开，保持默认 `false`；
  * 计步器在无对应硬件/系统服务的产品上会明确失败；
  * 腕抬 `WRIST_LIFT` 只在常量痕迹中确认，没有专用订阅签名，应通过通用 API 探测。


## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
△| △  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：sensor.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/sensor.jidl>)
  * [C++ 实现：sensor_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/sensor_impl.cpp>)

---

# system.storage 补充 API

> 来源: [https://docs.luoxe.cn/docs/vela/extensions/system-storage/](https://docs.luoxe.cn/docs/vela/extensions/system-storage/)

## [`storage.key(options)`](<#storage-key-options>)

按索引获取 key。

参数| 类型| 必填  
---|---|---  
`index`| Integer| 是，必须不小于 0  
`success`| Function| 否，接收 key 字符串  
`fail`| Function| 否  
`complete`| Function| 否  
      
    
    storage.key({
      index: 0,
      success: key => console.log(key)
    })

`key()` 用于按数据库内部顺序枚举 key。顺序不应视为插入顺序或稳定排序；删除/新增记录后索引可能变化。

## [枚举示例](<#枚举示例>)

目标固件未确认公开 `length` 属性，因此只能在已知上限内逐项读取，并在失败时结束：
    
    
    function getKeyAt(index) {
      return new Promise((resolve, reject) => {
        storage.key({
          index,
          success: resolve,
          fail: (message, code) => reject({ message, code })
        })
      })
    }
    
    async function listKeys(max = 100) {
      const keys = []
      for (let index = 0; index < max; index++) {
        try {
          keys.push(await getKeyAt(index))
        } catch (e) {
          break
        }
      }
      return keys
    }

固件明确拒绝 `index < 0`；越过末尾时底层 `uv_db_key` 会失败。不要无上限扫描。

上游新 JIDL 还定义了 `get_sync()` 和只读 `length`，但目标固件没有对应实现符号，本文不把它们计入已确认 API。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [JIDL：storage.jidl](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/jidl/storage.jidl>)
  * [C++ 实现：storage_impl.cpp](<https://github.com/open-vela/frameworks_runtimes_feature/blob/dev/modules/storage_impl.cpp>)

---

