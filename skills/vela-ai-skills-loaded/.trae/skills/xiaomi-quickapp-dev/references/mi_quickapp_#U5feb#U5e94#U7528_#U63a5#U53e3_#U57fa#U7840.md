# 快应用_接口_基础

> 来源: 小米快应用官方
> 共 5 篇文档

---

## #应用上下文 app

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/basic/app.html](https://iot.mi.com/vela/quickapp/zh/features/basic/app.html)

# [#](<#应用上下文-app>) 应用上下文 app

## [#](<#接口声明>) 接口声明

无需声明

## [#](<#导入模块>) 导入模块
    
    
    import app from '@system.app' 
    // 或 
    const app = require('@system.app')
    

## [#](<#接口定义>) 接口定义

### [#](<#app-getinfo>) app.getInfo()

获取当前应用信息

#### [#](<#参数>) 参数：

无

#### [#](<#返回值>) 返回值：

参数名 | 类型 | 说明  
---|---|---  
packageName | String | 应用包名  
icon | String | 应用图标路径  
name | String | 应用名称  
versionName | String | 应用版本名称  
versionCode | Integer | 应用版本号  
logLevel | String | log 级别  
source | Object | 应用来源  
  
#### [#](<#source>) source

参数名 | 类型 | 说明  
---|---|---  
packageName | String | 来源 app 的包名，一级来源  
type | String | 来源类型，二级来源，值为 shortcut、push、url、barcode、nfc、bluetooth、other  
  
#### [#](<#示例>) 示例：
    
    
    console.log(JSON.stringify(app.getInfo()))
    
    
    
    // console 值打印
    {
      // 应用包名
      "packageName": "com.example.demo",
      // 应用名称
      "name": "demo",
      // 应用版本名称
      "versionName": "1.0.0",
      // 应用版本号
      "versionCode": 1,
      // 应用图片
      "icon": "/common/logo.png",
      // log 级别
      "logLevel": "debug",
      // 应用来源
      "source": {
        // 来源app的包名
        "packageName": "",
        // 来源类型
        "type": "shortcut"
      }
    }
    

### [#](<#app-terminate>) app.terminate()

退出当前应用

#### [#](<#参数-2>) 参数：

无

#### [#](<#返回值-2>) 返回值：

无

#### [#](<#示例-2>) 示例：
    
    
    app.terminate()
    

### [#](<#app-loadlibrary-name>) app.loadLibrary(name)

加载动态库，需要与厂商合作。

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
name | String | 是 | lib 库名称  
  
#### [#](<#返回值-3>) 返回值：

动态库加载结果

#### [#](<#示例-3>) 示例：
    
    
    import app from '@system.app'
    const testApp = app.loadLibrary('test_app')
    
    testApp.on('js_task_callback', () => {
      // callback action
    })
    

### [#](<#app-caniuse>) app.canIUse()[3+](</vela/quickapp/zh/guide/version/APILevel3>)

#### [#](<#参数-4>) 参数：

类型 | 描述  
---|---  
String | 要查询的能力，格式见下方  
  
#### [#](<#返回值-4>) 返回值：

类型 | 描述  
---|---  
Boolean | 查询的能力是否支持  
  
### [#](<#入参格式>) 入参格式

#### [#](<#查询接口>) 查询接口
    
    
    // 查询feature下的方法是否支持
    '@${featureName}.${method}'
    // 查询某个feature是否支持
    '@${featureName}'
    

**示例**
    
    
    import app from '@system.app';
    
    if (app.canIUse('@system.router.push')) {
      // 可以使用方法@system.router.push
    }
    if (app.canIUse('@system.router')) {
      // 可以使用@system.router接口
    }
    

#### [#](<#查询组件>) 查询组件

type取值可以是`'attr'`、`'style'`、`'method'`，分别对应组件的属性、样式、方法。
    
    
    // 查询组件下的属性、样式、方法是否支持
    `${componentName}.${type}.${name}`
    // 查询组件是否支持
    `${componentName}`
    

**示例**
    
    
    import app from '@system.app';
    
    if (app.canIUse('scroll')) {
      // 可以使用scroll组件
    }
    if (app.canIUse('scroll.attr.scroll-x')) {
      // 可以使用scroll组件的scroll-x属性
    }

---

## #应用配置 configuration

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/basic/configuration.html](https://iot.mi.com/vela/quickapp/zh/features/basic/configuration.html)

# [#](<#应用配置-configuration>) 应用配置 configuration

## [#](<#接口声明>) 接口声明

无需声明

## [#](<#导入模块>) 导入模块
    
    
    import configuration from '@system.configuration' 
    // 或 
    const configuration = require('@system.configuration')
    

## [#](<#接口定义>) 接口定义

### [#](<#configuration-getlocale>) configuration.getLocale()

获取应用当前的语言环境。默认使用系统的语言环境，会因为设置或系统语言环境改变而发生变化

#### [#](<#参数>) 参数：

无

#### [#](<#返回值>) 返回值：

参数名 | 类型 | 说明  
---|---|---  
language | String | 语言  
countryOrRegion | String | 国家或地区  
  
#### [#](<#示例>) 示例：
    
    
    const locale = configuration.getLocale()
    console.log(locale.language)

---

## #设备信息 device

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/basic/device.html](https://iot.mi.com/vela/quickapp/zh/features/basic/device.html)

# [#](<#设备信息-device>) 设备信息 device

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.device" }
    

## [#](<#导入模块>) 导入模块
    
    
    import device from '@system.device' 
    // 或 
    const device = require('@system.device')
    

## [#](<#接口定义>) 接口定义

### [#](<#device-getinfo-object>) device.getInfo(OBJECT)

获取设备信息

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
brand | string | 设备品牌  
manufacturer | string | 设备生产商  
model | string | 设备型号  
product | string | 设备代号  
osType | string | 操作系统名称  
osVersionName | string | 操作系统版本名称  
osVersionCode | number | 操作系统版本号  
platformVersionName | string | 运行平台版本名称  
platformVersionCode | number | 运行平台版本号  
language | string | 系统语言  
region | string | 系统地区  
APILevel[2+](</vela/quickapp/zh/guide/version/APILevel2>) | number | 框架api版本  
screenWidth | number | 屏幕宽  
screenHeight | number | 屏幕高  
screenDensity[3+](</vela/quickapp/zh/guide/version/APILevel3>) | number | 屏幕密度，即：设备像素比（device pixel ratio），是设备物理像素和逻辑像素（DP）的比值，其计算公式为：DPR = 设备 PPI / 160，PPI（pixels per inch）表示每英寸的像素数  
screenShape | string | 屏幕形状，可取值：rect 表示方形屏，circle 表示圆形屏，pill-shaped[3+](</vela/quickapp/zh/guide/version/APILevel3>) 表示胶囊形屏  
deviceType[2+](</vela/quickapp/zh/guide/version/APILevel2>) | string | 设备类型，可取值：watch、band、smartspeaker  
  
#### [#](<#示例>) 示例：
    
    
    device.getInfo({
      success: function(ret) {
        console.log(`handling success， brand = ${ret.brand}`)
      }
    })
    

### [#](<#device-getdeviceid-object>) device.getDeviceId(OBJECT)

获取设备唯一标识

#### [#](<#权限要求>) 权限要求

获取设备信息

开发者需要在 manifest.json 里面配置权限：
    
    
    {
      "permissions": [
        { "name": "hapjs.permission.DEVICE_INFO" }
      ]
    }
    

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-2>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
deviceId | String | 设备唯一标识  
  
#### [#](<#示例-2>) 示例：
    
    
    device.getDeviceId({
      success: function (data) {
        console.log(`handling success: ${data.deviceId}`)
      },
      fail: function (data, code) {
        console.log(`handling fail, code = ${code}`)
      },
    })
    

### [#](<#device-getserial-object>) device.getSerial(OBJECT)

获取设备序列号

#### [#](<#权限要求-2>) 权限要求

获取设备信息

开发者需要在 manifest.json 里面配置权限：
    
    
    {
      "permissions": [
        { "name": "hapjs.permission.DEVICE_INFO" }
      ]
    }
    

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-3>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
serial | String | 设备序列号  
      
    
    device.getSerial({
        success: (data) => {
            console.log(`handling success: ${data.serial}`)
        },
        fail: (data, code) => {
            console.log(`handling fail, code = ${code}`)
        }
    })
    

### [#](<#device-gettotalstorage-object>) device.getTotalStorage(OBJECT)

获取存储空间的总大小

#### [#](<#参数-4>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-4>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
totalStorage | Number | 存储空间的总大小，单位是 Byte  
      
    
    device.getTotalStorage({
        success: (data) => {
            console.log(`handling success: ${data.totalStorage}`)
        },
        fail: (data, code) => {
            console.log(`handling fail, code = ${code}`)
        }
    })
    

### [#](<#device-getavailablestorage-object>) device.getAvailableStorage(OBJECT)

获取存储空间的可用大小

#### [#](<#参数-5>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-5>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
availableStorage | Number | 存储空间的可用大小，单位是 Byte  
      
    
    device.getAvailableStorage({
        success: (data) => {
            console.log(`handling success: ${data.availableStorage}`)
        },
        fail: (data, code) => {
            console.log(`handling fail, code = ${code}`)
        }
    })

---

## #页面路由 router

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/basic/router.html](https://iot.mi.com/vela/quickapp/zh/features/basic/router.html)

# [#](<#页面路由-router>) 页面路由 router

## [#](<#接口声明>) 接口声明

无需声明

## [#](<#导入模块>) 导入模块
    
    
    import router from '@system.router' 
    // 或 
    const router = require('@system.router')
    

## [#](<#接口定义>) 接口定义

### [#](<#router-push-object>) router.push(OBJECT)

跳转到应用内的某个页面

#### [#](<#参数>) 参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 要跳转到的 uri，可以是下面的格式：  
1、包含 schema 的完整 uri；  
2、以‘/’开头的应用内页面的路径；例：/about  
3、以非‘/’开头的应用内页面的名称；例：About  
4、特殊的，如果 uri 的值是"/"，则跳转到 path 为"/"的页，没有则跳转到首页  
  
支持包含 schema 的完整 uri。对于带有 schema 的 uri，处理流程如下：  
如果 schema 是 hap （参见 [hap 链接](</vela/quickapp/zh/guide/framework/other/hap-schema.html>)），会跳转到 hap 链接所支持的类型  
params | Object | 否 | 跳转时需要传递的数据，参数可以在目标页面中通过`this.param1`的方式使用，param1 为 json 中的参数名，param1 对应的值会统一转换为 String 类型。使用`this.param1`变量时，需要在目标页面中在 `public`（应用外传参）或 `protected` (应用内传参)下定义 key 名相同的属性  
  
#### [#](<#params参数>) params参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
___PARAM_LAUNCH_FLAG___ | String | 否 | JS 应用启动参数，目前仅支持"clearTask"，在启动目标页面时会清除除此页面外的其他页面。详见[页面启动模式](</vela/quickapp/zh/guide/framework/other/launch-mode.html>)  
  
#### [#](<#示例>) 示例：

  * 应用内切换页面

    * path 切换
          
          router.push({
            uri: '/about',
            params: {
              testId: '1'
            }
          })
          

    * name 切换
          
          // open page by name
          router.push({
            uri: 'About',
            params: {
              testId: '1'
            }
          })
          

    * 切换页面并清除其他页面
          
          router.push({
            uri: '/about',
            params: {
              ___PARAM_LAUNCH_FLAG___: 'clearTask'
            }
          })
          


### [#](<#router-replace-object>) router.replace(OBJECT)

用应用内的某个页面替换当前页面，并销毁被替换的页面

#### [#](<#参数-2>) 参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 要跳转到的 uri，可以是下面的格式：

  1. 以"/"开头的应用内页面的路径；例：/about
  2. 以非"/"开头的应用内页面的名称；例：About
  3. 特殊的，如果 uri 的值是"/"，则跳转到 path 为"/"的页，没有则跳转到首页

  
params | Object | 否 | 跳转时需要传递的数据，参数可以在目标页面中通过`this.param1`的方式使用，param1 为 json 中的参数名，param1 对应的值会统一转换为 String 类型。使用`this.param1`变量时，需要在目标页面中在 `public`（应用外传参）或 `protected` (应用内传参)下定义 key 名相同的属性  
  
#### [#](<#示例-2>) 示例：
    
    
    router.replace({
      uri: '/test',
      params: {
        testId: '1'
      }
    })
    

### [#](<#router-back-object>) router.back(OBJECT)

返回指定页面

#### [#](<#参数-3>) 参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
path | String | 否 | 返回目标页面的路径，可以是以下几种取值：

  1. 不传该参数，返回上一页面
  2. 以"/"开头的应用内已打开页面的路径；例：/about
  3. 特殊的，如果 path 的值是"/"，则跳转到页面名称为"/"的页，没有则跳转到首页

注意点：
  1. path 需要是以"/"开头的当前应用已经打开的页面路径，否则均视为无效参数，返回上一页面
  2. 若根据 path 未匹配到已经打开的页面，返回上一页面
  3. 若根据 path 参数匹配到多个页面，返回至最后打开的页面

  
  
#### [#](<#示例-3>) 示例：
    
    
    // A页面, open page by name
    router.push({
      uri: 'B'
    })
    // B页面, open page by name
    router.push({
      uri: 'C'
    })
    // C页面, open page by name
    router.push({
      uri: 'D'
    })
    // D页面, open page by name
    router.push({
      uri: 'E'
    })
    // E页面不传入页面路径，返回至D页面
    router.back()
    // D页面不传入页面名称，返回至C页面
    router.back()
    // C页面传入页面路径，返回至A页面
    router.back({
      path: '/A'
    })
    

### [#](<#router-clear>) router.clear()

清空所有历史页面记录，仅保留当前页面

#### [#](<#参数-4>) 参数：

无

#### [#](<#示例-4>) 示例：
    
    
    router.clear()
    

### [#](<#router-getlength>) router.getLength()

获取当前页面栈的页面数量

#### [#](<#返回值>) 返回值:

类型 | 说明  
---|---  
Number | 页面数量  
  
#### [#](<#示例-5>) 示例：
    
    
    var length = router.getLength()
    console.log(`page's length = ${length}`)
    

### [#](<#router-getstate>) router.getState()

获取当前页面状态

#### [#](<#返回参数>) 返回参数：

参数名 | 类型 | 说明  
---|---|---  
index | Number | 当前页面在页面栈中的位置  
name | String | 当前页面的名称  
path | String | 当前页面的路径  
  
#### [#](<#示例-6>) 示例：
    
    
    var page = router.getState()
    console.log(`page index = ${page.index}`)
    console.log(`page name = ${page.name}`)
    console.log(`page path = ${page.path}`)
    

### [#](<#router-getpages>) router.getPages()

获取当前页面栈列表

#### [#](<#返回值-2>) 返回值：

类型 | 说明  
---|---  
Array | 页面栈列表。数组每一项都为 Object 类型  
  
数组每一项构成：

字段 | 类型 | 说明  
---|---|---  
name | String | 页面的名称  
path | String | 页面的路径  
  
#### [#](<#示例-7>) 示例：
    
    
    var stacks = router.getPages()
    console.log('栈底页面名称为：', stacks[0].name) // 如 list、detail 等
    console.log('栈底页面路径为：', stacks[0].path) // 如 /list、/detail、/home/preview

---

## #通用语法

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/grammar.html](https://iot.mi.com/vela/quickapp/zh/features/grammar.html)

# [#](<#通用语法>) 通用语法

框架提供各种接口来获取应用的基本信息或者调用系统能力，每个接口包含若干 api 来执行具体的任务。接口使用前需要进行接口声明、模块导入，然后才能调用该接口下定义的若干 api。

## [#](<#接口声明>) 接口声明

在 manifest.json 文件的 features 字段下进行声明，例如：
    
    
    [{ "name": "system.network" }]
    

## [#](<#导入模块>) 导入模块

使用接口前，需要在代码里导入接口模块，例如：
    
    
    import network from '@system.network'
    // 或
    const network = require('@system.network')
    

## [#](<#接口-api-调用>) 接口 api 调用

接口提供的 api 的调用方式大概有以下几种：

  * 同步 api
  * 异步 api
  * 订阅类 api


### [#](<#同步-api-调用>) 同步 api 调用

如果 api 没有返回值，一般会定义成同步 api，直接调用即可，例如：
    
    
    audio.play()
    

### [#](<#异步-api-调用>) 异步 api 调用

如果 api 有返回值，一般会定义成异步 api 的形式，这类 api 除了普通参数，还有“success \ fail \ complete“这三个通用参数——分别是 api 执行“成功 \ 失败 \ 完成“后的回调方法，调用时可以传入这三个参数来获取 api 执行成功的返回值或进行执行失败 \ 完成后的处理，这三个通用参数的说明如下：

名称 | 方法参数 | 参数类型 | 参数值 | 说明  
---|---|---|---|---  
success | data | any | api 执行的返回值，详见接口使用文档 | api 执行成功后触发  
fail | data | any | api 执行错误信息内容，一般是字符串，也可能是其他类型，详见接口使用文档 | api 执行失败后触发  
| code | number | api 执行错误码，详见[通用错误码](<#%E9%80%9A%E7%94%A8%E9%94%99%E8%AF%AF%E7%A0%81>) |   
complete | - | - | - | api 执行完成后触发  
  
代码示例：
    
    
    storage.get({
      key: 'A1',
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#订阅-取消订阅-api>) 订阅 / 取消订阅 api

订阅类 api 不会立即返回结果，这类 api 需要开发者传入回调函数作为参数，该回调函数会在 api 完成时或者事件变化时被触发，可以执行多次。该通用回调函数参数说明如下：

名称 | 方法参数 | 参数类型 | 参数值 | 说明  
---|---|---|---|---  
success | data | any | api 执行的返回值，详见接口使用文档 | api 调用成功或事件变更时触发，可能会触发多次  
fail | data | any | 错误信息内容，一般是字符串，也可能是其他类型，详见接口使用文档 | api 执行失败时触发。一旦触发该回调函数，success不会再次被调用，接口调用结束  
| code | number | api 执行错误码，详见[通用错误码](<#%E9%80%9A%E7%94%A8%E9%94%99%E8%AF%AF%E7%A0%81>) |   
  
代码示例：
    
    
    geolocation.subscribe({
      success: function(data) {
        console.log(
          `handling success: longitude = ${data.longitude}, latitude = ${
            data.latitude
          }`
        )
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

## [#](<#通用错误码>) 通用错误码

所有接口的 api 在执行出现错误时，会返回统一定义的通用错误码或者 api 自己定义的特殊错误码。这里对通用错误码进行说明如下：

code | 定义  
---|---  
200 | 系统通用错误，所有系统未知异常发生时抛出。比如框架申请内存空间失败等  
201 | 用户拒绝  
202 | 参数错误，调用时未按照 api 定义进行正确的传参  
203 | 该功能不支持  
204 | 请求超时  
205 | 重复提交  
207 | 用户拒绝并选择不再询问  
300 | I/O 错误

---

