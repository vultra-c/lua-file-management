# 快应用_发布与版本

> 来源: 小米快应用官方
> 共 4 篇文档

---

## #验收标准

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/publish/acceptance-criteria.html](https://iot.mi.com/vela/quickapp/zh/guide/publish/acceptance-criteria.html)

# [#](<#验收标准>) 验收标准

为持续提升Vela快应用的用户体验，现正式将启动性能纳入质量验收标准：快应用首页渲染完成时间（FMP）≤2000ms。我们同步整理了快应用最佳实践，包含启动加速方案、资源加载策略等。开发者可参考：[最佳实践](</vela/quickapp/zh/guide/best-practice/>)进行针对性优化。

---

## #APILevel2

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel2.html](https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel2.html)

# [#](<#apilevel2>) APILevel2

## [#](<#框架>) 框架

  * 新增[媒体查询](</vela/quickapp/zh/guide/framework/style/media-query.html>)，支持media feature - shape


## [#](<#组件>) 组件

  * 新增[barcode](</vela/quickapp/zh/components/basic/barcode.html>)组件
  * 新增[qrcode](</vela/quickapp/zh/components/basic/qrcode.html>)组件
  * 新增[image-animator](</vela/quickapp/zh/components/basic/image-animator.html>)组件
  * 新增[scroll](</vela/quickapp/zh/components/container/scroll.html>)组件
  * 新增[getBoundingClientRect](</vela/quickapp/zh/components/general/methods.html>)通用方法
  * [swiper](</vela/quickapp/zh/components/container/swiper.html>)组件新增swipestart、swipeend事件


## [#](<#接口>) 接口

  * [@system.device](</vela/quickapp/zh/features/basic/device.html>) getInfo() 新增返回值：deviceType、APILevel

---

## #APILevel3

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel3.html](https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel3.html)

# [#](<#apilevel3>) APILevel3

## [#](<#框架>) 框架

  * 新增[通用样式](</vela/quickapp/zh/components/general/style.html>)：box-shadow
  * 新增[全局方法](</vela/quickapp/zh/guide/framework/script/global-data-method.html>)：$canIUse


## [#](<#组件>) 组件

  * scroll组件新增[边缘吸附](</vela/quickapp/zh/components/container/scroll.html>)样式


## [#](<#接口>) 接口

  * 新增接口：[@system.uploadtask](</vela/quickapp/zh/features/network/uploadtask.html>)
  * [@system.app](</vela/quickapp/zh/features/basic/app.html>)新增canIUse方法
  * [@system.device](</vela/quickapp/zh/features/basic/device.html>) getInfo() 新增返回值：screenDensity，screenShape新增pill-shaped胶囊形屏


## [#](<#样式>) 样式

  * 扩展[媒体查询](</vela/quickapp/zh/guide/framework/style/media-query.html>)，支持新特性以及逻辑运算
  * 新增[dp单位](</vela/quickapp/zh/guide/framework/style/page-style-and-layout.html>)

---

## #APILevel4

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel4.html](https://iot.mi.com/vela/quickapp/zh/guide/version/APILevel4.html)

# [#](<#apilevel4>) APILevel4

## [#](<#组件>) 组件

  * 新增接口：[@system.event](</vela/quickapp/zh/features/system/event.html>)

---

