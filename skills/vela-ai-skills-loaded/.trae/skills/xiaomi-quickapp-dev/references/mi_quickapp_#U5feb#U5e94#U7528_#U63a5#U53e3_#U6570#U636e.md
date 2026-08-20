# 快应用_接口_数据

> 来源: 小米快应用官方
> 共 2 篇文档

---

## #文件存储 file

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/data/file.html](https://iot.mi.com/vela/quickapp/zh/features/data/file.html)

# [#](<#文件存储-file>) 文件存储 file

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.file" }
    

## [#](<#导入模块>) 导入模块
    
    
    import file from '@system.file' 
    // 或 
    const file = require('@system.file')
    

## [#](<#接口定义>) 接口定义

### [#](<#file-move-object>) file.move(OBJECT)

将源文件移动到指定位置，接口中使用的 URI 描述请参考[文件组织](</vela/quickapp/zh/guide/framework/project-structure.html#uri>)

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
srcUri | String | 是 | 源文件的 uri，不能是应用资源路径和 tmp 类型的 uri  
dstUri | String | 是 | 目标文件的 uri，不能是应用资源路径和 tmp 类型的 uri  
success | Function | 否 | 成功回调，返回目标文件的 uri  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例>) 示例：
    
    
    file.move({
      srcUri: 'internal://cache/path/to/file',
      dstUri: 'internal://files/path/to/file',
      success: function(uri) {
        console.log(`move success: ${uri}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-copy-object>) file.copy(OBJECT)

将源文件复制一份并存储到指定位置，接口中使用的 URI 描述请参考[文件组织](</vela/quickapp/zh/guide/framework/project-structure.html#uri>)

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
srcUri | String | 是 | 源文件的 uri  
dstUri | String | 是 | 目标文件的 uri，不能是应用资源路径和 tmp 类型的 uri  
success | Function | 否 | 成功回调，返回目标文件的 uri  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-2>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-2>) 示例：
    
    
    file.copy({
      srcUri: 'internal://cache/path/to/file',
      dstUri: 'internal://files/path/to/file',
      success: function(uri) {
        console.log(`copy success: ${uri}`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-list-object>) file.list(OBJECT)

获取指定目录下的文件列表，接口中使用的 URI 描述请参考[文件组织](</vela/quickapp/zh/guide/framework/project-structure.html#uri>)

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 目录 uri  
success | Function | 否 | 成功回调，返回{fileList:[{uri:'file1', lastModifiedTime:1234456, length:123456} ...]}  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
fileList | Array | 文件列表，每个文件的格式为{uri:'file1', lastModifiedTime:1234456, length:123456}  
  
#### [#](<#每个文件的元信息>) 每个文件的元信息：

参数名 | 类型 | 说明  
---|---|---  
uri | String | 文件的 uri，该 uri 可以被其他组件或 Feature 访问  
length | Number | 文件大小，单位 B  
lastModifiedTime | Number | 文件的保存是的时间戳，从 1970/01/01 00:00:00 GMT 到当前时间的毫秒数  
  
#### [#](<#fail-返回错误代码-3>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-3>) 示例：
    
    
    file.list({
      uri: 'internal://files/movies/',
      success: function(data) {
        console.log(data.fileList)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-get-object>) file.get(OBJECT)

获取本地文件的文件信息，接口中使用的 URI 描述请参考[文件组织](</vela/quickapp/zh/guide/framework/project-structure.html#uri>)

#### [#](<#参数-4>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 文件的 uri，不能是应用资源路径和 tmp 类型的 uri  
recursive | Boolean | 否 | 是否递归获取子目录文件列表。默认 false  
success | Function | 否 | 成功回调，返回{uri:'file1', length:123456, lastModifiedTime:1233456}  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-2>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
uri | String | 文件的 uri，该 uri 可以被其他组件或 Feature 访问  
length | Number | 文件大小，单位 B。当 type = dir 时，返回0  
lastModifiedTime | Number | 文件的保存时的时间戳，从 1970/01/01 08:00:00 到当前时间的毫秒数  
type | String | 文件类型，dir：目录；file：文件  
subFiles | Array | 当 type = dir 时，返回目录中的文件列表，recursive 为 true 时，同时返回其子目录中的文件信息  
  
#### [#](<#fail-返回错误代码-4>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-4>) 示例：
    
    
    file.get({
      uri: 'internal://files/path/to/file',
      success: function(data) {
        console.log(data.uri)
        console.log(data.length)
        console.log(data.lastModifiedTime)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-delete-object>) file.delete(OBJECT)

删除本地存储的文件，接口中使用的 URI 描述请参考[文件组织](</vela/quickapp/zh/guide/framework/project-structure.html#uri>)

#### [#](<#参数-5>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 需要删除的文件 uri，不能是应用资源路径和 tmp 类型的 uri  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-5>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-5>) 示例：
    
    
    file.delete({
      uri: 'internal://files/path/to/file',
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-writetext-object>) file.writeText(OBJECT)

写文本到文件

注意

当您使用文件写入接口时，请务必注意及时清理无用的文件，特别是在 IoT 设备内存较小的情况下，可以避免内存过载和应用崩溃的问题。

#### [#](<#参数-6>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 本地文件路径，不支持资源文件路径和 tmp 分区，如果文件不存在会创建文件  
text | String | 是 | 需要写入的字符串  
encoding | String | 否 | 编码格式，默认 UTF-8  
append | Boolean | 否 | 是否追加模式，默认 false  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-6>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-6>) 示例：
    
    
    file.writeText({
      uri: 'internal://files/work/demo.txt',
      text: 'test',
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-writearraybuffer-object>) file.writeArrayBuffer(OBJECT)

写 Buffer 到文件

注意

当您使用文件写入接口时，请务必注意及时清理无用的文件，特别是在 IoT 设备内存较小的情况下，可以避免内存过载和应用崩溃的问题。

#### [#](<#参数-7>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 本地文件路径，不支持资源文件路径和 tmp 分区，如果文件不存在会创建文件  
buffer | Uint8Array | 是 | 需要写入的 Buffer  
position | Number | 否 | 指向文件开始写入数据的位置的偏移量，默认 0  
append | Boolean | 否 | 是否追加模式，默认 false。当为 true 时，position 参数无效  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-7>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-7>) 示例：
    
    
    file.writeArrayBuffer({
      uri: 'internal://files/work/demo',
      buffer: buffer,
      success: function() {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-readtext-object>) file.readText(OBJECT)

从文件中读取文本

#### [#](<#参数-8>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 本地文件路径，支持应用资源路径，例如：'/Common/demo.txt'  
encoding | String | 否 | 编码格式，默认 UTF-8  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-3>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
text | String | 读取的文本  
  
#### [#](<#fail-返回错误代码-8>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
301 | 文件不存在  
  
#### [#](<#示例-8>) 示例：
    
    
    file.readText({
      uri: 'internal://files/work/demo.txt',
      success: function(data) {
        console.log('text: ' + data.text)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-readarraybuffer-object>) file.readArrayBuffer(OBJECT)

从文件中读取 Buffer

#### [#](<#参数-9>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 本地文件路径，支持应用资源路径，例如：'/Common/demo.txt'  
position | Number | 否 | 读取的起始位置，默认值为文件的起始位置  
length | Number | 否 | 读取的长度，不填写则读取到文件结尾  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值-4>) success 返回值：

参数名 | 类型 | 说明  
---|---|---  
buffer | Uint8Array | 读取的文件内容  
  
#### [#](<#fail-返回错误代码-9>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
301 | 文件不存在  
  
#### [#](<#示例-9>) 示例：
    
    
    file.readArrayBuffer({
      uri: 'internal://files/work/demo',
      position: 100,
      length: 100,
      success: function(data) {
        console.log('buffer.length: ' + data.buffer.length)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-access-object>) file.access(OBJECT)

判断文件或目录是否存在

#### [#](<#参数-10>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 目录或文件 uri  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-10>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-10>) 示例：
    
    
    file.access({
      uri: 'internal://files/test',
      success: function(data) {
        console.log(`handling success`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-mkdir-object>) file.mkdir(OBJECT)

创建目录

#### [#](<#参数-11>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 目录的 uri，不能是应用资源路径和 tmp 类型的 uri  
recursive | Boolean | 否 | 是否递归创建该目录的上级目录后再创建该目录。默认 false  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-11>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-11>) 示例：
    
    
    file.mkdir({
      uri: 'internal://files/dir/',
      success: function(data) {
        console.log(`handling success`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#file-rmdir-object>) file.rmdir(OBJECT)

删除目录

#### [#](<#参数-12>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
uri | String | 是 | 目录的 uri，不能是应用资源路径和 tmp 类型的 uri  
recursive | Boolean | 否 | 是否递归删除子文件和子目录。默认 false  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#fail-返回错误代码-12>) fail 返回错误代码：

错误码 | 说明  
---|---  
202 | 参数错误  
300 | I/O 错误  
  
#### [#](<#示例-12>) 示例：
    
    
    file.rmdir({
      uri: 'internal://files/dir/',
      success: function(data) {
        console.log(`handling success`)
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })

---

## #数据存储 storage

> 来源: [https://iot.mi.com/vela/quickapp/zh/features/data/storage.html](https://iot.mi.com/vela/quickapp/zh/features/data/storage.html)

# [#](<#数据存储-storage>) 数据存储 storage

## [#](<#接口声明>) 接口声明
    
    
    { "name": "system.storage" }
    

## [#](<#导入模块>) 导入模块
    
    
    import storage from '@system.storage' 
    // 或 
    const storage = require('@system.storage')
    

## [#](<#方法>) 方法

### [#](<#storage-get-object>) storage.get(OBJECT)

读取存储内容

#### [#](<#参数>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
key | String | 是 | 索引  
default | String | 否 | 如果 key 不存在，返回 default。如果 default 未指定，返回长度为 0 的空字符串  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#success-返回值>) success 返回值：

key 对应的存储内容

#### [#](<#示例>) 示例：
    
    
    storage.get({
      key: 'A1',
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#storage-set-object>) storage.set(OBJECT)

修改存储内容

#### [#](<#参数-2>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
key | String | 是 | 索引  
value | String | 否 | 新值。如果新值是长度为 0 的空字符串，会删除以 key 为索引的数据项  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-2>) 示例：
    
    
    storage.set({
      key: 'A1',
      value: 'V1',
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#storage-clear-object>) storage.clear(OBJECT)

清空存储内容

#### [#](<#参数-3>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-3>) 示例：
    
    
    storage.clear({
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })
    

### [#](<#storage-delete-object>) storage.delete(OBJECT)

删除存储内容

#### [#](<#参数-4>) 参数：

参数名 | 类型 | 必填 | 说明  
---|---|---|---  
key | String | 是 | 索引  
success | Function | 否 | 成功回调  
fail | Function | 否 | 失败回调  
complete | Function | 否 | 执行结束后的回调  
  
#### [#](<#示例-4>) 示例：
    
    
    storage.delete({
      key: 'A1',
      success: function(data) {
        console.log('handling success')
      },
      fail: function(data, code) {
        console.log(`handling fail, code = ${code}`)
      }
    })

---

