# 快应用_接口_网络

> 来源: 小米快应用官方
> 共 4 篇文档

---

## #数据请求 fetch

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/network/fetch.html](https://iot.mi.com/vela/quickapp/zh/features/network/fetch.html)

# [#](<#数据请求-fetch>) 数据请求 fetch

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.fetch" }
    

## [#](<#导入模块>) 导入模块
    
    
    import fetch from '@system.fetch' 
    // 或 
    const fetch = require('@system.fetch')
    

## [#](<#接口定义>) 接口定义

### [#](<#fetch-fetch-object>) fetch.fetch(OBJECT)

获取网络数据

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
url | String | 是 | 资源 url  
data | String/Object/ArrayBuffer | 否 | 请求的参数，可以是字符串，或者是 js 对象、arraybuffer 对象。参考 `data与Content-Type关系` 部分  
header | Object | 否 | 请求的 header，会将其所有属性设置到请求的 header 部分。User-Agent 设置示例：{"Accept-Encoding": "gzip, deflate","Accept-Language": "zh-CN,en-US;q=0.8,en;q=0.6"}  
method | String | 否 | 默认为 GET，可以是：OPTIONS，GET，HEAD，POST，PUT，DELETE，TRACE，CONNECT  
responseType | String | 否 | 支持返回类型是 text，json，file，arraybuffer，默认会根据服务器返回 header 中的 Content-Type 确定返回类型，详见 `success返回值`  
success | Function | 否 | 成功返回的回调函数  
fail | Function | 否 | 失败的回调函数，可能会因为权限失败  
complete | Function | 否 | 结束的回调函数（调用成功、失败都会执行）  
  
#### [#](<#data-与-content-type-关系>) data 与 Content-Type 关系

data | Content-Type | 说明  
---|---|---  
String | 不设置 | Content-Type 默认为 text/plain，data 值作为请求的 body  
String | 任意 Type | data 值作为请求的 body  
Object | 不设置 | Content-Type 默认为 application/x-www-form-urlencoded，data 按照 url 规则进行 encode 拼接作为请求的 body  
Object | application/x-www-form-urlencoded | data 按照 url 规则进行 encode 拼接作为请求的 body  
Object | application/x-www-form-urlencoded 之外的任意 type | -  
ArrayBuffer | 不设置 | Content-Type 默认为 application/octet-stream，data 值作为请求的 body  
ArrayBuffer | 任意 Type | data 值作为请求的 body  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
code | Integer | 服务器状态 code  
data | String/Object /ArrayBuffer | 参考 `responseType与success中data关系` 部分  
headers | Object | 服务器 response 的所有 header  
  
#### [#](<#responsetype-与-success-中-data-关系>) responseType 与 success 中 data 关系：

responseType | data | 说明  
---|---|---  
无 | String | 服务器返回的 header 中 type 是 text/*或 application/json、application/javascript、application/xml，值是文本内容，否则是存储的临时文件的 uri，临时文件如果是图片或者视频内容，可以将图片设置到 image  
text | String | 返回普通文本  
json | Object | 返回 js 对象  
file | String | 返回存储的临时文件的 uri  
arraybuffer | ArrayBuffer | 返回 ArrayBuffer 对象  
  
#### [#](<#示例>) 示例：
    
    
    fetch.fetch({
      url: 'http://www.example.com',
      responseType: 'text',
      success: function(response) {
        console.log(`the status code of the response: ${response.code}`)
        console.log(`the data of the response: ${response.data}`)
        console.log(
          `the headers of the response: ${JSON.stringify(response.headers)}`
        )
      },
      fail: function(data, code) {
        console.log(`handling fail, errMsg = ${data}`)
        console.log(`handling fail, errCode = ${code}`)
      }
    })
    
    // 我们也可以使用promise的方式处理回调
    fetch
      .fetch({
        url: 'http://www.example.com',
        responseType: 'text'
      })
      .then(res => {
        const result = res.data
    
        console.log(`the status code of the response: ${result.code}`)
        console.log(`the data of the response: ${result.data}`)
        console.log(
          `the headers of the response: ${JSON.stringify(result.headers)}`
        )
      })
      .catch(error => {
        console.log(`handling fail, errMsg = ${error.data}`)
        console.log(`handling fail, errCode = ${error.code}`)
      })
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #设备通信 interconnect

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/network/interconnect.html](https://iot.mi.com/vela/quickapp/zh/features/network/interconnect.html)

# [#](<#设备通信-interconnect>) 设备通信 interconnect

用于和搭配使用的手机 app 进行通信，收发手机 app 数据。 通信连接会自动建立，应用内不用关心连接的创建和销毁，但是可以注册回调函数来接收连接状态改变的信息，以便于进行相应处理，例如对用户进行提示。

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.interconnect" }
    

## [#](<#导入模块>) 导入模块
    
    
    import interconnect from '@system.interconnect'
    // 或
    const interconnect = require('@system.interconnect')
    

## [#](<#接口定义>) 接口定义

### [#](<#interconnect-instance>) interconnect.instance()

获取连接对象，在 app 中以单例形式存在，后续的数据收发都是基于这个连接对象

#### [#](<#参数>) 参数：

无

#### [#](<#返回值>) 返回值：

interconnect 的链接实例 connect 对象

#### [#](<#示例>) 示例：
    
    
    const connect = interconnect.instance()
    

### [#](<#connect-getreadystate-object>) connect.getReadyState(OBJECT)

获取 App 连接状态

#### [#](<#object参数>) OBJECT参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
  
#### [#](<#success-返回值>) success 返回值：

属性值 | 类型 | 说明  
---|---|---  
status | Number | 1：连接成功，2：连接断开  
  
#### [#](<#fail-返回值>) fail 返回值：

参数值 | 类型 | 说明  
---|---|---  
data | String | 错误信息  
code | Number | 错误码  
  
#### [#](<#错误码说明>) 错误码说明：

[支持通用错误码](</vela/quickapp/zh/features/grammar.html#通用错误码>)

错误码 | 说明  
---|---  
1006 | 连接断开  
  
#### [#](<#示例-2>) 示例：
    
    
    connect.getReadyState({
      success: (data) => {
        if (data.status === 1) {
          console.log('连接成功')
        } else if (data.status === 2) {
          console.log('连接失败')
        }
      },
      fail: (data, code) => {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#connect-diagnosis-object>) connect.diagnosis(OBJECT)

诊断手表应用和对端应用的连接情况，如果连接成功则返回ok，连接失败则返回失败原因。如果调用时正在连接则等待连接结束后再返回最终状态。

#### [#](<#obejct参数>) Obejct参数：

属性 | 类型 | 必填 | 说明  
---|---|---|---  
timeout | Number | 否 | 等待诊断的超时时间，单位毫秒   
默认值：10000ms  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
  
#### [#](<#success-返回值-2>) success 返回值：

属性值 | 类型 | 说明  
---|---|---  
status | Number | 0: OK 链接成功  
204：CONNECT_TIMEOUT 连接超时  
1001：APP_UNINSTALLED 对端应用未安装  
1000：OTHERS 其他链接错误  
  
#### [#](<#fail-返回值-2>) fail 返回值：

参数值 | 类型 | 说明  
---|---|---  
data | String | 错误信息  
code | Number | 错误码  
  
#### [#](<#错误码说明-2>) 错误码说明：

[支持通用错误码](</vela/quickapp/zh/features/grammar.html#通用错误码>)

#### [#](<#示例-3>) 示例：
    
    
    connect.diagnosis({
      success: function (data) {
        console.log(`handling success, version = ${data.status}`)
      },
      fail: function (data, code) {
        console.log(`handling fail, code = ${code}`)
      },
    })
    

### [#](<#connect-send-object>) connect.send(OBJECT)

发送数据到手机 App 端

#### [#](<#object参数-2>) Object参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | Object | 是 | 发送的数据  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
  
#### [#](<#success-返回值-3>) success 返回值：

无

#### [#](<#fail-返回值-3>) fail 返回值：

参数值 | 类型 | 说明  
---|---|---  
data | String | 错误信息  
code | Number | 错误码  
  
#### [#](<#错误码说明-3>) 错误码说明：

[支持通用错误码](</vela/quickapp/zh/features/grammar.html#通用错误码>)

错误码 | 说明  
---|---  
204 | 链接超时  
1006 | 连接断开  
  
#### [#](<#示例-4>) 示例：
    
    
    connect.send({
      data: {
        str: 'test',
        num: 123
      },
      success: ()=>{
        console.log(`handling success`)
      },
      fail: (data, code)=> {
        console.log(`handling fail, errMsg = ${data.data}, errCode = ${data.code}`)
      }
    })
    

## [#](<#事件>) 事件

### [#](<#connect-onmessage>) connect.onmessage

接收手机 App 端数据

#### [#](<#回调参数>) 回调参数：

参数名 | 类型 | 说明  
---|---|---  
data | String | 接收的数据  
  
#### [#](<#示例-5>) 示例：
    
    
    connect.onmessage = (data) => {
      console.log(`received message: ${data.data}`)
    }
    

### [#](<#connect-onopen>) connect.onopen

连接打开时的回调函数

#### [#](<#回调参数-2>) 回调参数：

参数名 | 类型 | 说明  
---|---|---  
isReconnected | Boolean | 是否是重新连接  
  
#### [#](<#示例-6>) 示例：
    
    
    connect.onopen = function (data) {
      console.log('connection opened isReconnected: ', data.isReconnected)
    }
    

### [#](<#connect-onclose>) connect.onclose

连接关闭时的回调函数

#### [#](<#回调参数-3>) 回调参数：

参数名 | 类型 | 说明  
---|---|---  
code | Number | 链接关闭状态码  
data | String | 连接关闭返回的数据  
  
#### [#](<#示例-7>) 示例：
    
    
    connect.onclose = (data) => {
      console.log(`connection closed, reason = ${data.data}, code = ${data.code}`)
    }
    

### [#](<#connect-onerror>) connect.onerror

连接出错时的回调函数

#### [#](<#回调参数-4>) 回调参数：

参数名 | 类型 | 说明  
---|---|---  
code | Number | 错误码，见错误码说明  
data | String | 错误信息  
  
#### [#](<#错误码说明-4>) 错误码说明：

[支持通用错误码](</vela/quickapp/zh/features/grammar.html#通用错误码>)

错误码 | 说明  
---|---  
1000 | 未知错误  
1001 | 手机 APP 未安装  
1006 | 连接断开  
  
#### [#](<#示例-8>) 示例：
    
    
    connect.onerror = (data)=> {
      console.log(`connection error, errMsg = ${data.data}, errCode = ${data.code}`)
    }
    

## [#](<#开发注意事项>) 开发注意事项

interconnect 通信前提要保证快应用和三方应用安卓端两者的包名及签名保持一致。

  * 保证快应用 manifest.json 里 package 字段与 需要接入的三方app 安卓端包名一致。
  * 快应用签名需要使用三方应用安卓端签名，可以从.jks中提取证书及私钥，方法如下：


  1. 先将 jks 转换成 p12，执行以下命令，输入相应密码后，在同级目录下生成对应的 p12 格式文件。


    
    
    keytool -importkeystore -srckeystore keystore.jks -destkeystore keystore.p12 -srcstoretype jks -deststoretype pkcs12
    

  2. 再将 p12 转 pem，执行以下命令，输入上一步设置的 p12 文件密码后，在同级目录下生成对应的 pem 格式文件。


    
    
    openssl pkcs12 -nodes -in keystore.p12 -out keystore.pem
    

  3. 从 pem 格式文件中复制出私钥和证书：  
把-----BEGIN PRIVATE KEY-----到-----END PRIVATE KEY-----的内容复制到private.pem中。  
把-----BEGIN CERTIFICATE-----到-----END CERTIFICATE-----的内容复制到certificate.pem中。


  * 如果本地没有安装Openssl或想要更简便的操作流程，我们提供了[在线签名生成工具 (opens new window)](<https://cdn.hybrid.xiaomi.com/aiot-ide/signature-generate-tool/v2/index.html>)。该工具是一个基于WebAssembly编写的Web应用，它可以在浏览器环境中直接生成 pem 格式的私钥和证书，无需将签名文件和密码上传到远程服务器，充分保证了用户的隐私安全。使用在线签名生成工具的步骤如下：

    1. 上传 p12 文件并输入对应的密码；

    2. 点击“生成签名”按钮，等待签名生成成功弹窗出现；

    3. 点击“下载签名”按钮，下载 pem 格式的私钥和证书；

  * 快应用需要将上述生成的私钥 private.pem 和证书 certificate.pem 放在快应用根目录 /sign/debug 和 /sign/release 下出包测试。

  * 在真机测试的时候建议先输入包名uninstall老包再安装新包，可以观察桌面图标卸载的话会删除应用图标保证彻底替换。


参考附录

  1. 小米穿戴第三方APP能力开放接口文档：[点击下载 (opens new window)](<https://vela-docs.cnbj1.mi-fds.com/vela-docs/files/%E5%B0%8F%E7%B1%B3%E7%A9%BF%E6%88%B4%E7%AC%AC%E4%B8%89%E6%96%B9APP%E8%83%BD%E5%8A%9B%E5%BC%80%E6%94%BE%E6%8E%A5%E5%8F%A3%E6%96%87%E6%A1%A3_1.4.pdf> "下载")
  2. interconnect开发测试demo：[点击下载 (opens new window)](<https://cdn.cnbj3-fusion.fds.api.mi-img.com/quickapp-vela/interconnect_dev_test_demo.zip> "下载")

---

## #下载 request

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/network/request.html](https://iot.mi.com/vela/quickapp/zh/features/network/request.html)

# [#](<#下载-request>) 下载 request

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.request" }
    

## [#](<#导入模块>) 导入模块
    
    
    import request from '@system.request' 
    // 或 
    const request = require('@system.request')
    

## [#](<#接口定义>) 接口定义

### [#](<#request-download-object>) request.download(OBJECT)

下载文件

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
url | String | 是 | 资源 url  
header | String | 否 | 请求的 header，会将其所有属性设置到请求的 header 部分  
filename | String | 否 | 下载文件名。默认从网络请求或 url 中获取  
success | Function | 否 | 成功返回的回调函数  
fail | Function | 否 | 失败的回调函数  
complete | Function | 否 | 结束的回调函数（调用成功、失败都会执行）  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
token | String | 下载的 token，根据此 token 获取下载状态  
  
#### [#](<#示例>) 示例：
    
    
    request.download({
      url: 'http://www.example.com',
      success: function(data) {
        console.log(`handling success${data.token}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#request-ondownloadcomplete-object>) request.onDownloadComplete(OBJECT)

监听下载任务

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
token | String | 是 | download 接口返回的 token  
success | Function | 否 | 成功返回的回调函数  
fail | Function | 否 | 失败的回调函数  
complete | Function | 否 | 结束的回调函数（调用成功、失败都会执行）  
  
#### [#](<#success-返回值-2>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
uri | String | 下载文件的 Uri（默认情况下该文件处于应用缓存目录。如果文件类型为图片或者视频且要求用户可以在相册等应用内查看，则需要将该文件转存至公共目录，参考media接口中的方法实现即可）  
  
#### [#](<#fail-返回错误代码>) fail 返回错误代码：

错误码 | 说明  
---|---  
1000 | 下载失败  
1001 | 下载任务不存在  
  
#### [#](<#示例-2>) 示例：
    
    
    request.onDownloadComplete({
      token: '123',
      success: function(data) {
        console.log(`handling success${data.uri}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #上传 uploadtask3+

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/network/uploadtask.html](https://iot.mi.com/vela/quickapp/zh/features/network/uploadtask.html)

# [#](<#上传-uploadtask>) 上传 uploadtask[3+](</vela/quickapp/zh/guide/version/APILevel3>)

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.uploadtask" }
    

## [#](<#导入模块>) 导入模块
    
    
    import uploadtask from '@system.uploadtask' 
    // 或 
    const uploadtask = require('@system.uploadtask')
    

## [#](<#接口定义>) 接口定义

### [#](<#方法>) 方法

### [#](<#uploadtask-uploadtask-uploadfile-object>) UploadTask uploadtask.uploadFile(OBJECT)

创建一个上传请求，每次成功调用 uploadtask.uploadFile 将返回本次请求的 UploadTask 实例

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
url | String | 是 | 开发者服务器接口地址  
filePath | String | 是 | 要上传文件资源的路径 (本地路径)  
name | String | 是 | 文件对应的 key，开发者在服务端可以通过这个 key 获取文件的二进制内容  
header | Object | 否 | 请求的 header，会将其所有属性设置到请求的 header 部分  
formData | Object | 否 | HTTP 请求中其他额外的 form data  
timeout | Number | 否 | 超时时间，单位为毫秒  
success | Function | 否 | 成功返回的回调函数  
fail | Function | 否 | 失败的回调函数  
complete | Function | 否 | 结束的回调函数（调用成功、失败都会执行）  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
statusCode | Integer | 服务器状态 code  
data | String | 开发者服务器返回的数据  
headers | Object | 服务器 response 的所有 header  
  
# [#](<#uploadtask>) UploadTask

## [#](<#方法-2>) 方法

### [#](<#uploadtask-abort>) UploadTask.abort()

中断上传任务

### [#](<#uploadtask-onprogressupdate-callback>) UploadTask.onProgressUpdate(callback)

监听上传进度变化事件

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
callback | Function | 是 | 上传进度变化事件的回调函数  
  
#### [#](<#callback-返回值>) callback 返回值：

参数名 | 类型 | 说明  
---|---|---  
progress | Number | 上传进度百分比  
totalBytesSent | Number | 已经上传的数据长度，单位 Bytes  
totalBytesExpectedToSend | Number | 预期需要上传的数据总长度，单位 Bytes  
  
### [#](<#uploadtask-offprogressupdate-function-callback>) UploadTask.offProgressUpdate(function callback)

取消监听上传进度变化事件。callback 是可选的，如果不传则取消所有通过 onProgressUpdate 监听的上传进度变化事件

#### [#](<#示例>) 示例：
    
    
    const retUploadTask = uploadtask.uploadFile({
      url: 'http://www.example.com',
      filePath: "internal://mass/download/test.png",
      name: "testImg",
      success: function(res){
        console.log("Upload success.resp = " + JSON.stringify(res))
      },
      fail: function(data, code) {
        console.log(`handling fail, errMsg = ${data}`)
        console.log(`handling fail, errCode = ${code}`)
      }
    })
    // 中断请求任务
    retUploadTask.abort()
    
    // 监听上传进度事件
    retUploadTask.onProgressUpdate(res => {
      console.log(
        `listening upload progress update event, progressUpdate data = ${JSON.stringify(res)}`
      )
    })
    
    // 取消监听上传进度事件
    retUploadTask.offProgressUpdate()
    

取消特定的上传进度事件
    
    
    function cb(res) {
      console.log(
        `listening for upload progress update event 1, progressUpdate data = ${JSON.stringify(
          res
        )}`
      )
    }
    
    // 此次监听会被取消
    retUploadTask.onProgressUpdate(cb)
    
    // event2 监听依然有效，不会被取消
    retUploadTask.onProgressUpdate((res) => {
      console.log(
        `listening for upload progress update event 2, progressUpdate data = ${JSON.stringify(
          res
        )}`
      )
    })
    
    retUploadTask.offProgressUpdate(cb)
    

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 不支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

