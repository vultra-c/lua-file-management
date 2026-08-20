# 快应用_其他

> 来源: 小米快应用官方
> 共 3 篇文档

---

## #常见问题

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/other/faq.html](https://iot.mi.com/vela/quickapp/zh/guide/other/faq.html)

# [#](<#常见问题>) 常见问题

## [#](<#如何适配不同尺寸的屏幕>) 如何适配不同尺寸的屏幕？

框架默认的屏幕分辨率是480*480，Vela三方应用会自动适配，开发者可以直接按照设计稿的尺寸来开发。 比如，设计稿是466*466，可以在`manifest.json`中配置`designWidth: 466`，然后css中尺寸相关的数值跟设计稿保持一致即可。 更多详细细节信息可以参考：[页面样式和布局](</vela/quickapp/zh/guide/framework/style/page-style-and-layout.html>)。

## [#](<#模拟器怎么跟手表通信>) 模拟器怎么跟手表通信？

模拟器跟手机通讯，需要外接蓝牙适配器，并且配置比较复杂，建议使用真机调试。

## [#](<#如何解决通信过程中提示签名不正确的问题>) 如何解决通信过程中提示签名不正确的问题？

手表和手机通信前会检查应用的签名，如果签名不正确通信会被拒绝。所以调试通信时需要手机app和手表rpk使用配套的证书打包。  
遇到签名不正确的错误时，请检查导出rpk时使用的证书是否和打包手机app时的证书相同。

## [#](<#如何排查通信-interconnect-相关的问题>) 如何排查通信(interconnect)相关的问题？

首先检查手表端发送数据的数据结构是否正确（请参考发送数据）、send方法回调行数执行情况。 其次可以排查手机端打印的日志（使用adb logcat工具），看手机端接受的数据情况。

## [#](<#如何解决列表数据更新时闪烁的问题>) 如何解决列表数据更新时闪烁的问题？

通过for循环渲染的列表，在数据更新时，如果出现闪烁，可以增加tid来解决。详细文档可以参考：[循环指令](</vela/quickapp/zh/guide/framework/template/for.html>)。

## [#](<#构建release版本rpk时打包证书有什么要求>) 构建release版本rpk时打包证书有什么要求？

  1. 如果涉及手表跟手机通信，打包rpk时的证书需要跟打包手机app的证书一致，否则无法通信；
  2. 如果不涉及通信，对证书无特殊要求，按照文档中的步骤生成即可；


> 注意：请妥善保管证书，并且保证每次使用相同的证书打release版本rpk包。如果证书改变，可能无法上架。

## [#](<#如何解决手表和手机连接状态获取问题>) 如何解决手表和手机连接状态获取问题？

进入页面直接获取状态往往会拿到`DISCONNECTED`，因此需要轮询获取状态，根据`getApkStatus()`的返回值，判断手表和手机的连接状态。

## [#](<#模拟器支持哪些平台>) 模拟器支持哪些平台？

模拟器支持Windows，Mac和Ubuntu三个平台，其中Windows支持Win10+，Mac支持macOS12+

## [#](<#windows和mac是否可以打包rpk>) Windows和Mac是否可以打包rpk？

Windows和Mac可以打包rpk。

## [#](<#如何将rpk上传到手表真机运行>) 如何将rpk上传到手表真机运行?

  1. 手机安装小米运动健康(目前是通过商务拉群对接的方式提供。开发vela三方应用需求，请邮件联系常健：[changjian@xiaomi.com](<mailto:changjian@xiaomi.com>))；
  2. 点击【小米运动健康】-->【我的】-->【关于】-->【Debug】；
  3. 点击【第三方应用】；
  4. 点击【Click to input package name】；
  5. 随便输个字符（只有卸载时要详细包名）；
  6. 选择【Install third app】；
  7. 选择本地rpk文件安装；
  8. 安装成功会有Toast提示。


## [#](<#如何查看手表真机上的日志>) 如何查看手表真机上的日志？

  1. 手机安装小米运动健康(目前是通过商务拉群对接的方式提供。开发vela三方应用需求，请邮件联系常健：[changjian@xiaomi.com](<mailto:changjian@xiaomi.com>))；
  2. 小米运动健康与手表进行同步；
  3. 在手表上复现问题；
  4. 点击【小米运动健康】-->【我的】-->【关于】-->【Debug】-->【拉取固件日志】；
  5. 拉取成功后保存在手机，日志文件目录: `/sdcard/Android/data/com.mi.health/files/log`。

---

## #注意事项

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/other/tips.html](https://iot.mi.com/vela/quickapp/zh/guide/other/tips.html)

# [#](<#注意事项>) 注意事项

## [#](<#手表中的异常场景>) 手表中的异常场景

  1. 网络异常，在没有网络的情况下提示
  2. 数据异常（没有获取到数据，或者后端接口返回错误）处理
  3. JS代码错误处理
  4. 按钮防止重复点击（点击后发请求的操作尤其要注意）
  5. 息屏后重新亮屏会重新触发onShow生命周期函数，此生命周期函数中如果有fetch请求，亮屏时会再次发起请求，需谨慎使用


## [#](<#代码规范>) 代码规范

  1. app.ux文件中的代码，必须写到`<script></script>`中，否则代码不会执行！
  2. *.ux文件中，`template`节点只能有一个根节点
  3. 角度相关的css属性必须书写单位，比如`total-angle: 360deg`
  4. `list-item`中，谨慎使用`if`/`else`/`show`等条件判断，保证所有的`list-item`结构一致
  5. `image`的`src`属性不要使用变量拼接（比如 `src="/common/{{type}}`），否则编译器打包代码会显示警告，建议直接使用变量`src="{{imgPath}}"`


## [#](<#常见优化>) 常见优化

  1. 减少网络请求次数和并发数
  2. 数据实时性要求不高的接口考虑做本地缓存（缓存也要考虑数据大小）
  3. 控制本地文件数量，避免直接遍历文件获取所有文件大小
  4. 尽可能使用低分辨率的网络图片
  5. 列表使用分页，每一页保持在20个item以内比较好
  6. 网络请求的数据，不要直接存储在内存中，只存储需要用到的字段
  7. 谨慎使用三方依赖，使用轻量级的依赖
  8. 公共代码可以考虑放到全局，不要多次引入
  9. 添加loading态，防止按钮频繁点击后发起多次网络请求


## [#](<#选择器使用建议>) 选择器使用建议

详情见：[style 样式](</vela/quickapp/zh/guide/framework/style/>)

---

## #拓展组件

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/developer-materials/extension-components.html](https://iot.mi.com/vela/quickapp/zh/guide/developer-materials/extension-components.html)

# [#](<#拓展组件>) 拓展组件

## [#](<#input-method>) input-method

### [#](<#概述>) 概述

输入法组件，适配不同屏幕形状，支持两种主流键盘布局——全键盘模式和九键模式下的中英文输入

### [#](<#示例预览>) 示例预览

#### [#](<#全键盘模式>) 全键盘模式

  * 圆形屏幕


![](/vela/quickapp/images/guide/input-method-qwerty.png)

  * 矩形屏幕


![](/vela/quickapp/images/guide/input-method-qwerty-rect.png)

  * 胶囊屏幕


![](/vela/quickapp/images/guide/input-method-qwerty-pill-shaped.png)

#### [#](<#九键模式>) 九键模式

  * 圆形屏幕


![](/vela/quickapp/images/guide/input-method-t9.png)

### [#](<#项目地址>) 项目地址

  * [Github (opens new window)](<https://github.com/NEORUAA/Vela_input_method>)

---

