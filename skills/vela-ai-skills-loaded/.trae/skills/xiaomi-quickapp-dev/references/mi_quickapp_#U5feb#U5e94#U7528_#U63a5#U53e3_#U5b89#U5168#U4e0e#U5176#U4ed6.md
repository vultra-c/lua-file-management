# 快应用_接口_安全与其他

> 来源: 小米快应用官方
> 共 3 篇文档

---

## #密码算法 crypto

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/security/crypto.html](https://iot.mi.com/vela/quickapp/zh/features/security/crypto.html)

# [#](<#密码算法-crypto>) 密码算法 crypto

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.crypto" }
    

## [#](<#导入模块>) 导入模块
    
    
    import crypto from '@system.crypto' 
    // 或 
    const crypto = require('@system.crypto')
    

## [#](<#接口定义>) 接口定义

### [#](<#crypto-hashdigest-object>) crypto.hashDigest(OBJECT)

创建数据的哈希摘要

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String/Uint8Array | 否 | 待计算内容，和uri二者必须有一个  
uri | String | 否 | 待计算文件地址，和data二者必须有一个  
algo | String | 否 | 算法 默认： SHA256   
可选：MD5， SHA1，SHA256，SHA512  
  
#### [#](<#返回值>) 返回值：

类型 | 说明  
---|---  
String | 经过计算生成的摘要内容  
  
#### [#](<#示例>) 示例：
    
    
    const digest = crypto.hashDigest({
      data: 'hello',
      algo: 'MD5'
    })
    

### [#](<#crypto-hmacdigest-object>) crypto.hmacDigest(OBJECT)

创建加密 HMAC 摘要

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String | 是 | 待计算数据  
algo | String | 否 | 算法 默认： SHA256   
可选：MD5， SHA1，SHA256，SHA512  
key | String | 是 | 密钥  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 完成回调  
  
#### [#](<#success-返回值-object>) success 返回值 Object：

参数值 | 类型 | 说明  
---|---|---  
data | String | 摘要  
  
#### [#](<#示例-2>) 示例：
    
    
    crypto.hmacDigest({
      data: 'hello',
      algo: 'SHA256',
      key: 'a secret',
      success: function(res) {
        console.log(`### crypto.hmacDigest success:`, res.data)
      },
      fail: function(data, code) {
        console.log(`### crypto.hmacDigest fail ### ${code}: ${data}`)
      }
    })
    

### [#](<#crypto-sign-object>) crypto.sign(OBJECT)

用于生成签名

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String/Uint8Array | 否 | 被签名文本，和uri二者必须有一个  
uri | String | 否 | 被签名文件地址，和data二者必须有一个  
algo | String | 否 | 签名算法，默认：'RSA-SHA256'   
可选：RSA-MD5， RSA-SHA1，RSA-SHA256，RSA-SHA512  
privateKey | String | 是 | 私钥  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 完成回调  
  
#### [#](<#success-返回值-object-2>) success 返回值 Object：

参数值 | 类型 | 说明  
---|---|---  
data | String/Uint8Array | 如果输入为字符串，则返回经过base64编码的字符串；否则返回Uint8Array；如果只传uri，默认返回string  
  
#### [#](<#示例-3>) 示例：
    
    
    crypto.sign({
      data: 'hello',
      algo: 'RSA-SHA256',
      privateKey: 'a secret',
      success: function(res) {
        console.log(`### crypto.sign success:`, res.data)
      },
      fail: function(data, code) {
        console.log(`### crypto.sign fail ### ${code}: ${data}`)
      }
    })
    

### [#](<#crypto-verify-object>) crypto.verify(OBJECT)

用于验证签名

#### [#](<#参数-4>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String/Uint8Array | 否 | 被签名文本，和uri二者必须有一个  
uri | String | 否 | 被签名文件地址，和data二者必须有一个  
algo | String | 否 | 签名算法，默认：'RSA-SHA256'   
可选：RSA-MD5， RSA-SHA1，RSA-SHA256，RSA-SHA512  
signature | String/Uint8Array | 是 | 签名  
publicKey | String | 是 | 公钥  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 完成回调  
  
#### [#](<#success-返回值-boolean>) success 返回值 Boolean：

类型 | 说明  
---|---  
Boolean | 校验结果，通过为true，不通过为false  
  
#### [#](<#示例-4>) 示例：
    
    
    crypto.verify({
      data: 'hello',
      algo: 'RSA-SHA256',
      publicKey: 'public key',
      signature: 'signature',
      success: function(data) {
        console.log(`### crypto.verify success:`, data)
      },
      fail: function(data, code) {
        console.log(`### crypto.verify fail ### ${code}: ${data}`)
      }
    })
    

### [#](<#crypto-encrypt-object>) crypto.encrypt(OBJECT)

加密

#### [#](<#参数-5>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String/Uint8Array | 是 | 待加密数据  
algo | String | 否 | 加密算法 默认： RSA   
可选：RSA， AES  
key | String | 是 | 加密使用到的密钥，经过 base64 编码后生成的字符串  
options | Object | 否 | 加密参数  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 完成回调  
  
#### [#](<#rsa-参数options>) RSA 参数options：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
transformation | String | 否 | RSA 算法的加密模式和填充项，默认为"RSA/None/PKCS1Padding"  
  
#### [#](<#aes-参数options>) AES 参数options：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
transformation | String | 否 | AES 算法的加密模式和填充项，默认为"AES/CBC/PKCS7Padding"  
iv | String | 否 | AES 加解密的初始向量，经过 base64 编码后的字符串，默认值为 key 值  
ivOffset | Number | 否 | AES 加解密的初始向量偏移，整数，默认值为 0  
ivLen | Number | 否 | AES 加解密的初始向量字节长度，整数，默认值为 16  
  
#### [#](<#success-返回值-object-3>) success 返回值 Object：

参数值 | 类型 | 说明  
---|---|---  
data | String/Uint8Array | 如果输入为字符串，则返回经过base64编码的字符串；否则返回Uint8Array  
  
#### [#](<#示例-5>) 示例：
    
    
    crypto.encrypt({
      //待加密的文本内容
      data: 'hello',
      //base64编码后的加密公钥
      key: crypto.btoa('KEYKEYKEYKEYKEYK'),
      algo: 'AES',
      success: function(res) {
        console.log(`### crypto.encrypt success:`, res.data)
      },
      fail: function(data, code) {
        console.log(`### crypto.encrypt fail ### ${code}: ${data}`)
      }
    })
    

### [#](<#crypto-decrypt-object>) crypto.decrypt(OBJECT)

解密

#### [#](<#参数-6>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
data | String/Uint8Array | 是 | 待解密数据  
algo | String | 否 | 解密算法 默认： RSA   
可选：RSA， AES  
key | String | 是 | 加密或解密使用到的密钥，经过 base64 编码后生成的字符串  
options | Object | 否 | 解密参数  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 完成回调  
  
#### [#](<#rsa-参数options-2>) RSA 参数options：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
transformation | String | 否 | RSA 算法的加密模式和填充项，默认为"RSA/None/PKCS1Padding"  
  
#### [#](<#aes-参数options-2>) AES 参数options：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
transformation | String | 否 | AES 算法的加密模式和填充项，默认为"AES/CBC/PKCS7Padding"  
iv | String | 否 | AES 加解密的初始向量，经过 base64 编码后的字符串，默认值为 key 值  
ivOffset | Number | 否 | AES 加解密的初始向量偏移，整数，默认值为 0  
ivLen | Number | 否 | AES 加解密的初始向量字节长度，整数，默认值为 16  
  
#### [#](<#success-返回值-object-4>) success 返回值 Object：

参数值 | 类型 | 说明  
---|---|---  
data | String/Uint8Array | 如果输入为字符串，则返回经过base64编码的字符串；否则返回Uint8Array  
  
#### [#](<#示例-6>) 示例：
    
    
    crypto.decrypt({
      //待解密的内容
      data: 'WB96uM08PfYIHu5G1p6YwA==',
      //base64编码后的加密公钥
      key: crypto.btoa('KEYKEYKEYKEYKEYK'),
      algo: 'AES',
      success: function(res) {
        console.log(`### crypto.decrypt success:`, res.data)
      },
      fail: function(data, code) {
        console.log(`### crypto.decrypt fail ### ${code}: ${data}`)
      }
    })
    

### [#](<#crypto-btoa-string>) crypto.btoa(STRING)

从String对象中创建一个 base-64 编码的 ASCII 字符串，其中字符串中的每个字符都被视为一个二进制数据字节

#### [#](<#参数-7>) 参数：

类型 | 必填 | 说明  
---|---|---  
String | 是 | 待编码文本  
  
#### [#](<#返回值-string>) 返回值 String：

类型 | 说明  
---|---  
String | 经过编码之后的结果  
  
#### [#](<#示例-7>) 示例：
    
    
    const encodeData = crypto.btoa('hello')
    

### [#](<#crypto-atob-string>) crypto.atob(STRING)

对经过 base-64 编码的字符串进行解码

#### [#](<#参数-8>) 参数：

类型 | 必填 | 说明  
---|---|---  
String | 是 | 待解码文本  
  
#### [#](<#返回值-string-2>) 返回值 String：

类型 | 说明  
---|---  
String | 经过解码之后的结果  
  
#### [#](<#示例-8>) 示例：
    
    
    const encodeString = crypto.btoa('hello')
    const res = crypto.atob(encodeString)
    

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

## #音频 audio

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/other/audio.html](https://iot.mi.com/vela/quickapp/zh/features/other/audio.html)

# [#](<#音频-audio>) 音频 audio

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.audio" }
    

## [#](<#导入模块>) 导入模块
    
    
    import audio from '@system.audio' 
    // 或 
    const audio = require('@system.audio')
    

## [#](<#方法>) 方法

### [#](<#audio-play>) audio.play()

开始播放音频

#### [#](<#参数>) 参数

无

#### [#](<#示例>) 示例：
    
    
    audio.play()
    

### [#](<#audio-pause>) audio.pause()

暂停播放音频

#### [#](<#参数-2>) 参数

无

#### [#](<#示例-2>) 示例：
    
    
    audio.pause()
    

### [#](<#audio-stop>) audio.stop()

停止音频播放，可以通过 play 重新播放音频

#### [#](<#参数-3>) 参数

无

#### [#](<#示例-3>) 示例：
    
    
    audio.stop()
    

### [#](<#audio-getplaystate-object>) audio.getPlayState(OBJECT)

获取当前播放状态数据

#### [#](<#参数-4>) 参数

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数值 | 类型 | 说明  
---|---|---  
state | String | 播放状态,分别为'play'，'pause'，'stop'  
src | String | 当前播放的音频媒体 uri，停止时返回空字符串  
currentTime | Number | 当前音频的当前进度，单位秒，停止时返回-1  
percent | Number | 当前播放进度百分比，范围0-100  
autoplay | Boolen | 当前音频是否在自动播放  
loop | Boolen | 当前音频是否在循环播放  
volume | Number | 当前音频的音量，默认当前系统媒体音量，音量变化范围[0.0,1.0]  
muted | Boolen | 当前音频是否在静音播放  
duration | Number | 音频的播放时长，单位秒，未知返回 NaN  
  
#### [#](<#示例-4>) 示例：
    
    
    audio.getPlayState({
      success: function(data) {
        console.log(`handling success: state: ${data.state},src:${data.src},currentTime:${data.currentTime},autoplay:${data.autoplay},loop:${data.loop},volume: ${data.volume},muted:${data.muted},notificationVisible:${data.notificationVisible}`)
      },
      fail: function(data, code) {
        console.log('handling fail, code=' + code)
      }
    })
    

## [#](<#属性>) 属性

名称 | 参数类型 | 是否可读 | 是否可写 | 必填 | 描述  
---|---|---|---|---|---  
src | String | 是 | 是 | 是 | 播放的音频媒体 uri  
currentTime | Number | 是 | 是 | 否 | 音频的当前进度，单位秒，对值设置可以调整播放进度  
duration | Number | 是 | 否 | 否 | 音频的播放时长，单位秒，未知返回 NaN  
autoplay | Boolean | 是 | 是 | 否 | 音频是否自动播放，默认 false  
loop | Boolean | 是 | 是 | 否 | 音频是否循环播放，默认 false  
volume | Number | 是 | 是 | 否 | 音频的音量，默认当前系统媒体音量，音量变化范围[0.0,1.0]  
muted | Boolean | 是 | 是 | 否 | 音频是否静音，默认 false  
streamType | String | 是 | 否 | 否 | 使用音频的类型，可能的值有 music、voicecall，值为 music 时使用扬声器播放，voicecall 时使用听筒播放（手表、手环设备不支持此配置），默认为 music  
meta | Object<{title: string, artist: string, album: string}> | 否 | 是 | 否 | 音频元数据信息，包括歌名、歌手、专辑名  
  
#### [#](<#示例-5>) 示例：
    
    
    // let currentTime = audio.currentTime
    audio.currentTime = 5
    

## [#](<#事件>) 事件

名称 | 描述  
---|---  
play | 在调用 play 方法后或者 autoplay 为 true 时的回调事件。被动触发场景举例：1. 蓝牙耳机控制播放音频  
pause | 在调用 pause 方法后的回调事件。被动触发场景举例：1. 音频焦点被抢占，例如：播放音频时收到来电；2. 蓝牙耳机控制暂停音频  
stop | 在调用 stop 方法后的回调事件。被动触发场景举例：1. 正在打电话时播放音频  
loadeddata | 第一次获取到音频数据的回调事件  
ended | 播放结束时的回调事件  
durationchange | 播放时长变化时的回调事件  
error | 播放发生错误时的回调事件  
  
#### [#](<#示例-6>) 示例：
    
    
    audio.onplay = function() {
      console.log(`audio starts to play`)
    }
    audio.onplay = null

---

## #弹窗 prompt

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/other/prompt.html](https://iot.mi.com/vela/quickapp/zh/features/other/prompt.html)

# [#](<#弹窗-prompt>) 弹窗 prompt

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.prompt" }
    

## [#](<#导入模块>) 导入模块
    
    
    import prompt from '@system.prompt' 
    // 或 
    const prompt = require('@system.prompt')
    

## [#](<#接口定义>) 接口定义

### [#](<#prompt-showtoast-object>) prompt.showToast(OBJECT)

显示 Toast 提示信息

#### [#](<#参数>) 参数

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
message | String | 是 | 显示的文本信息  
duration | Number | 否 | 显示持续时间，单位ms，默认值1500，建议区间：1500-10000  
  
#### [#](<#示例>) 示例：
    
    
    prompt.showToast({
      message: 'Message Info',
      duration: 2000
    })

---

