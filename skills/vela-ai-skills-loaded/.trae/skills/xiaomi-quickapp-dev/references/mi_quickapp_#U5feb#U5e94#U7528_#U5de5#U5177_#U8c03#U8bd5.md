# 快应用_工具_调试

> 来源: 小米快应用官方
> 共 8 篇文档

---

## #编译预览

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/start.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/start.html)

# [#](<#编译预览>) 编译预览

运行，调试，发布，打包vela项目主要靠**顶部操作栏** 中的按钮来实现，同时依赖右侧**用户引导页** 和**设备管理页** 来保证当前开发环境具备**模拟器运行环境** ，同时展示效果具体显示在右侧的**模拟器预览界面** 。

## [#](<#运行项目>) 运行项目

点击`选择设备`按钮，选择要运行的模拟器，点击确定后，再点击`调试`将启动模拟器。

![alt text](/vela/quickapp/images/tools/ide-debug-5.png)

模拟器启动运行成功后，模拟器会推送当前项目，推送成功后，可在模拟器预览页预览效果，如下动态图所示：

![alt text](/vela/quickapp/images/tools/ide-run-1.gif)

再次点击运行，将停止向模拟器推送当前项目，**但模拟器依然保持运行** 。

---

## #调试运行

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/debug.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/debug.html)

# [#](<#调试运行>) 调试运行

点击`选择设备`按钮，选择要运行模拟器，点击确定，再点击`调试`按钮将启动对应模拟器。

![alt text](/vela/quickapp/images/tools/ide-debug-1.png)

模拟器启动成功后，将打开调试页面，当运行多个模拟器时。调试窗口对应的是(**如下图标签1，2，3** 所示)模拟器运行页面中**标题有选中效果** 的模拟器

![alt text](/vela/quickapp/images/tools/ide-debug-2.png)

点击模拟器，可切换调试服务，进行对应调试。

![alt text](/vela/quickapp/images/tools/ide-debug-3.png)

![alt text](/vela/quickapp/images/tools/ide-debug-4.png)

---

## #优化评分

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/audit.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/audit.html)

# [#](<#优化评分>) 优化评分

为了优化开发者开发体验，`AIoT-IDE`中内置了生成优化评分报告功能，点击`生成报告`按钮即可根据当前打开的应用生成优化报告。

![alt text](/vela/quickapp/images/tools/ide-debug-14.png)

整体分为动态分析和静态分析2部分，每个检测项会包括：触发条目的具体信息（例如代码位置/文件url/网络url），优化建议等。

## [#](<#文件分析>) 文件分析

  1. 用来帮助用户比较直观地了解当前包体积占比过高的文件，优化包体积

  2. 后续也规划提供类似treeMap的依赖占比可视化分析


![alt text](/vela/quickapp/images/tools/ide-debug-15.png)

## [#](<#性能指标>) 性能指标

优化报告中有给出多维度的性能指标，给出优化建议,以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-16.png)

## [#](<#优化检测项>) 优化检测项

  * 一个统一的、汇总式地检测入口，目前共计上线9则检查项： 
    * 多次引用代码检测
    * 大型依赖替换检测
    * 未使用依赖检测
    * 未使用系统功能检测
    * 网络请求耗时检测
    * 网络请求https使用检测
    * 网络请求次数检测
    * 网络请求异常检测
    * 代码执行报错检测


### [#](<#多次引用代码检测>) 多次引用代码检测

优化报告中会标出多次引用的代码，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-17.png)

### [#](<#大型依赖替换检测>) 大型依赖替换检测

优化报告中会标出体积过大的依赖项，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-18.png)

### [#](<#未使用依赖检测>) 未使用依赖检测

优化报告中会标出未使用的依赖项，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-19.png)

### [#](<#未使用系统功能检测>) 未使用系统功能检测

优化报告中会标出未使用的系统功能，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-20.png)

### [#](<#网络请求耗时检测>) 网络请求耗时检测

优化报告中会标出请求响应耗时过长的请求，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-21.png)

### [#](<#网络请求https使用检测>) 网络请求https使用检测

优化报告中会标出请求响应中未使用https的，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-22.png)

### [#](<#网络请求次数检测>) 网络请求次数检测

优化报告中会标出请求响应中频繁请求的，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-23.png)

### [#](<#网络请求异常检测>) 网络请求异常检测

优化报告中会标出请求响应异常，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-24.png)

### [#](<#代码执行报错检测>) 代码执行报错检测

优化报告中会标出项目中代码执行报错的，给出优化建议，以便开发者进行优化。

![alt text](/vela/quickapp/images/tools/ide-debug-25.png)

---

## #内存分析

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/memory.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/memory.html)

# [#](<#内存分析>) 内存分析

进行**内存泄漏** 排查时，您可以通过两次内存快照(dump)来协助分析。例如排查页面内存泄漏，先在进入页面前 dump 一次，再在推出页面后 dump 一次。排查内存泄漏有两种场景：

对于不依赖底层能力的应用：如果您的应用不需要诸如底层能力，您可以直接在 `AIoT-IDE` 中测试。在问题场景的前后分别点击 位置 4 来进行内存快照。

对于依赖底层能力的应用：您需要安装可以执行 js 堆内存快照的固件，运行命令 dump_js_heap /sdcard，然后将快照文件从真机设备拷贝到计算机上，在 `AIoT-IDE` 中通过 位置 3 加载进行分析。

在 `AIoT-IDE` 中，JavaScript 堆分析和导出的工具位于功能面板区域选择 **调试 - > Snapshot -> Profile**，如下图标签1，2，3所示：

![alt text](/vela/quickapp/images/tools/ide-debug-9.png)

---

## #多屏适配

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/multi-screens.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/multi-screens.html)

# [#](<#多屏适配>) 多屏适配

为了提升开发者开发体验，`AIoT-IDE`内置了****功能，可将一套代码跑在多个不同的设备屏幕上，以测试在不同屏幕上的适配效果。

## [#](<#多设备模拟器创建>) 多设备模拟器创建

为了还原最真实的多屏适配开发场景，`AIoT-IDE`提供了多个不同设备尺寸配置的模拟器和不同的镜像版本，以便在多种设备，不同镜像系统上测试应用。

`目前提供三种镜像可供选择`

  * `vela-miwear-watch-5.0` vela5.0稳定发布版本

  * `vela-miwear-watch-4.0` vela4.0稳定发布版本

  * `vela-watch-4.0` vela开发版本


**目前提供六种不同屏幕尺寸的设备可供创建：**

![alt text](/vela/quickapp/images/tools/s3-watch.png)

xiaomiWatch 466*466

![alt text](/vela/quickapp/images/tools/s4-watch.png)

redmiWatch

![alt text](/vela/quickapp/images/tools/8-band.png)

xiaomiBand

![alt text](/vela/quickapp/images/tools/8pro-band.png)

xiaomiBandpro

![alt text](/vela/quickapp/images/tools/10-band.png)

xiaomi10Band

![alt text](/vela/quickapp/images/tools/sound-mini.png)

xiaomiSoundMini

目前创建模拟器时，`vela-miwear-watch-5.0`和`vela-miwear-watch-4.0`只支持xiaomiWatch(466*466)尺寸一种设备，`vela-watch-4.0`支持上面全部设备类型，并且可自定义设备类型进行创建。

注意

模拟器与真实设备之间是有性能差异的

## [#](<#自定义模拟器>) 自定义模拟器

此外，为了支持更多尺寸的设备，创建模拟器时还可以选择**custom** 自定义模拟器时，提供以下自定义配置：

  * 1.可自定义模拟器宽高(宽高小于800大于100)，模拟器形状，模拟器密度等操作。
  * 2.可自定义并设置模拟器类型，目前主要为**watch** ，**band** ，**smartspeaker**
  * 3.可自定义模拟器形状，目前主要有两种形状**圆形** 和**矩形** ，矩形可自定义圆角
  * 4.可自定义模拟器屏幕dpi


![alt text](/vela/quickapp/images/tools/ide-emulator-4.png)

点击底部新建按钮，完成模拟器创建后，`AIoT-IDE`右下角会弹出创建成功提示，设备管理页面会实时更新创建的模拟器。

![alt text](/vela/quickapp/images/tools/ide-emulator-5.png)

## [#](<#多屏预览>) 多屏预览

在创建完不同设备类型的模拟器后，通过`调试`或`运行`按钮启动模拟器时，**选择对应不同设备的模拟器** 点击确定，即可同时运行。

![alt text](/vela/quickapp/images/tools/ide-debug-13.png)

运行成功后，模拟器预览页将出现不同设备屏幕的预览效果

![alt text](/vela/quickapp/images/tools/ide-debug-12.gif)

## [#](<#自定义模拟器皮肤>) 自定义模拟器皮肤

此外，如果用户不仅仅满足于自定义模拟器的显示效果，希望能更逼真的预览模拟器设备，我们还提供了自定义皮肤的功能。

## [#](<#vela-模拟器皮肤组>) Vela 模拟器皮肤组

制作一款皮肤共需要两张图片和一个配置文件：

  * `background.png` 是设备主体图，要求屏幕区域为黑色
  * `foreground.png` 用于遮挡模拟器画面以外的部分。
  * **layout配置文件** ，主要是用来配置皮肤所需的`background.png`，`foreground.png`布局信息


![alt text](/vela/quickapp/images/tools/ide-skin-1.png)

其中`foreground.png` 一般由背景图片中扣出模拟器画面部分并将屏幕部分修改为透明色。没有 `foreground.png` 与有 `foreground.png` 的对比如下:

![alt text](/vela/quickapp/images/tools/ide-skin-2.png)

未配置foreground.png

![alt text](/vela/quickapp/images/tools/ide-skin-3.png)

配置了foreground.png

## [#](<#layout-文件的制作>) Layout 文件的制作

拷贝以下代码并按照注释修改信息即可，其余部分保持不变
    
    
      parts {
        device {
          display {
            # 模拟器尺寸 
            width 466
            # 模拟器尺寸
            height 466
            # x和y填 0
            x 0
            y 0
          }
        }
        portrait {
          background {
            # 背景图片的名称
            image background.png
          }
          foreground {
            # 前景图片的名称
            mask foreground.png
          }
        }
      }
      layouts {
        portrait {
          // 整个皮肤的大小，一般使用背景图片的像素尺寸
          width 572
          height 938
          event EV_SW:0:1 
          part1 {
            name portrait
            x 0
            y 0
          }
          part2 {
            name device
            # 前景图片从背景图片中扣图时的起始坐标，以左上角为0，0计算
            x 54
            y 236
          }
        }
      }
    
      // 将会在创建模拟器时透传给底层配置的字段
      props {
        // 屏幕形状。可选值： circle（圆形）、rect(矩形)、pill-shaped（胶囊形屏eg: 全面屏手环）
        shape circle
        // 屏幕密度，可选值： ['120'，'140'，'160'，'180'，'213'，'240'，'280'，'320'，'340'，'360'，'400'，'420'，'440'，'480'，'560'，'640']
        density 320
        // 设备类型，可选值：phone（手机）、watch（手表）、pad（平板）、car（车机）、tv（电视）、band（手环）smartspeaker（音响），默认watch
        flavor watch
      }
    

## [#](<#应用皮肤文件>) 应用皮肤文件

在通过通过 `AIoT-IDE` 打开 `SKD` 目录，该目录下有一个 **skins** 目录，在 **skins/user** 目录下新建一个文件夹名称为你的皮肤名称，将制作好的文件放入其中，如果 skins下没有user，则先创建 user 目录 ，再次使用 IDE 创建模拟器时即可选择应用该皮肤。

注意

SDK目录是一个以点开头的目录，请提前打开操作系统的隐藏文件后再进行操作。

![alt text](/vela/quickapp/images/tools/ide-skin-4.png)

## [#](<#layout详解>) layout详解

其中的 layout 文件中的内容如下：

![alt text](/vela/quickapp/images/tools/ide-skin-5.png)

**layout** 配置内容详解：

  * **layout** 中可定义 **portrait** 和 **landscape** 两种布局方式，即竖屏和横屏其中的**width** 和 **height** 为你的**background.png** 的像素大小

  * **event** 固定值填 **EV_SW:0:0**

  * **part1** 引用上方 parts 中定义背景图片和前景图的那个，name 表示 引用 part 的名称，x，y 表示布局开始的左边，以左上角开始为0，0

  * **part2** 引用上方 parts 中定义 **dispaly** 的那个，name 表示 引用 part 的名称，x，y 表示布局开始的坐标，以左上角开始为0，0

  * **parts** 定义皮肤的组成部分，一般又两部分组成，即皮肤和模拟器画面，带 **display** 的表示模拟器画面，带 **background** 和 **foreground** 的表示皮肤。

---

## #功能按钮

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/toolbar.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/toolbar.html)

# [#](<#功能按钮>) 功能按钮

在模拟器启动成功，进入模拟器运行页面后。`AIoT-IDE`提供了一些功能按钮方便开发者开发调试应用。

## [#](<#关闭所有模拟器>) 关闭所有模拟器

**关闭所有模拟器** ，位于模拟器运行页面右上角，点击后可关闭所有正在运行的模拟器，如下图中序号1所示。

![alt text](/vela/quickapp/images/tools/ide-debug-26.png)

## [#](<#自定义模拟器显示>) 自定义模拟器显示

**自定义模拟器显示** ，位于模拟器运行页面右上角，点击后可在弹出框中自定义已运行的模拟器的显示顺序，如下图序号1，序号2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-27.png)

## [#](<#关机>) 关机

关机，每个模拟器显示区域都会在右侧配置一个关机按钮，可关闭单个运行的模拟器，如下图序号1所示。

![alt text](/vela/quickapp/images/tools/ide-debug-28.png)

## [#](<#首页>) 首页

首页，每个模拟器显示区域都会在右侧配置一个首页按钮，点击后可回到当前模拟器首页，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-29.png)

## [#](<#终端>) 终端

终端，每个模拟器显示区域都会在右侧配置一个终端按钮，点击进入模拟器命令行终端，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-35.png)

## [#](<#查看日志>) 查看日志

查看日志，每个模拟器显示区域都会在右侧配置一个查看日志按钮，点击进入可查看日志，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-36.png)

## [#](<#菜单>) 菜单

菜单，每个模拟器显示区域都会在右侧配置一个菜单按钮，点击后可回到当前模拟器菜单页，如下图序号1所示。

![alt text](/vela/quickapp/images/tools/ide-debug-30.png)

## [#](<#截图>) 截图

截图，每个模拟器显示区域都会在右侧配置一个截图按钮，点击可对当前模拟器效果进行截图，并选择有皮肤，无皮肤两种模式，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-31.png)

## [#](<#尺寸>) 尺寸

尺寸，每个模拟器显示区域都会在右侧配置一个尺寸按钮，可动态调整当前模拟器显示大小，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-32.png)

## [#](<#安装rpk>) 安装rpk

安装rpk，每个模拟器显示区域都会在右侧配置一个安装rpk按钮，点击后选择本地rpk文件进行安装，如下图序号1，2所示。

![alt text](/vela/quickapp/images/tools/ide-debug-33.png)

## [#](<#运行rpk>) 运行rpk

运行rpk，每个模拟器显示区域都会在右侧配置一个运行rpk按钮，点击后在已安装的rpk列表中，切换运行的rpk或卸载已安装的rpk。如下图序号1，2，3所示。

![alt text](/vela/quickapp/images/tools/ide-debug-34.png)

---

## #日志查看

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/watch-log.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/watch-log.html)

# [#](<#日志查看>) 日志查看

借助各项日志（如编译日志和模拟器日志），您可以迅速了解应用当前状态，从而提高开发效率。要查看日志，只需在`功能面板`中点击`输出`选项即可。日志输出面板提供了一系列实用功能，包括：`切换日志类型`、`清空日志`、`开启/关闭自动滚动`、`导出日志` 和 `筛选日志`等。

  * **切换日志类型** ：选择需要查看的日志类型，如模拟器日志、编译日志等。
  * **清空日志** ：一键清除当前类型的所有日志。
  * **开启/关闭自动滚动** ：当启用时，新日志添加到输出面板时，视图将自动滚动到最新的日志条目；关闭该功能后，自动滚动将停止，日志停留在上次查看的位置。
  * **导出日志** ：将当前类型的日志导出，保存至当前项目的 logs 目录下。
  * **筛选日志** ：在「输出」面板聚焦状态下，使用 `Command`\+ `F`（在Windows上使用 `Ctrl`\+ `F`）即可触发日志关键词搜索，支持正则表达式。


![alt text](/vela/quickapp/images/tools/ide-debug-8.png)

温馨提示：如果在开发中遇到异常，如预览黑屏或渲染内容与代码不一致，请首先查看**编译日志** 以确认应用是否构建成功，然后检查 **模拟器日志** 以判断应用是否正常运行。如果两者均无问题，请参阅文档或向`AIoT-IDE`官方寻求技术支持。

---

## #概述

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/debug/setting.html](https://iot.mi.com/vela/quickapp/zh/tools/debug/setting.html)

# [#](<#概述>) 概述

Xiaomi Vela JS 应用是小米公司开发的一种应用类型，它是基于小米的物联网嵌入式软件平台 Xiaomi Vela OS 开发的。本文将介绍 Xiaomi Vela JS 应用的特点、应用场景以及开发支持，帮助开发者更好地了解和使用这一应用类型。

如果您想快速了解如何开发 Xiaomi Vela JS 应用，并且希望快速上手，请直接访问 [快速入门](</vela/quickapp/zh/guide/start.html>) 章节。

## [#](<#应用特点>) 应用特点

Xiaomi Vela JS 应用是一种基于 Xiaomi Vela OS 操作系统的轻量级应用模式，旨在为智能穿戴设备提供更加流畅和便捷的用户体验。它具备以下显著特点：

  * **轻量化：** Xiaomi Vela JS 应用采用了轻量级的架构设计，与传统的应用程序相比，Xiaomi Vela JS 应用具有更小的体积，这使得它们能够快速加载和运行，尤其适合内存和处理能力有限的穿戴设备。
  * **跨平台兼容性：** Xiaomi Vela JS 应用支持跨端运行，开发者可以一次开发，实现在多种设备上的运行，这大大提高了开发效率和应用的普及率。
  * **高性能渲染：** 系统优化了渲染能力，使得应用的动画和交互更为流畅，提升了用户的使用体验。
  * **安全性能：** Xiaomi Vela OS 通过三重隔离机制确保了应用的安全性，保护了用户数据和设备的安全。
  * **开发支持：** 小米提供了全面的开发支持 Xiaomi Vela JS 应用的开发工具和文档齐全，开发者可以轻松上手，快速构建高质量的应用。小米提供了包括AIoT-IDE在内的一系列开发工具，支持开发者在Ubuntu、Windows、MacOS等操作系统上进行Xiaomi Vela JS 应用的开发和调试。


## [#](<#应用场景>) 应用场景

Xiaomi Vela JS 应用的应用场景广泛，已落地多款产品，覆盖了智能穿戴设备上的多种使用情形：

  * **健康监测：** 应用可以实时监测用户的心率、睡眠质量等健康数据，为用户提供健康建议和预警。
  * **运动辅助：** 在用户进行运动时，应用能够记录运动数据，提供运动指导和健康管理。
  * **消息提醒：** 应用能够显示手机等设备的消息提醒，方便用户在不拿出手机的情况下查看重要信息。
  * **移动支付：** 应用可以集成支付功能，用户可以直接在穿戴设备上完成支付操作，提高支付的便捷性。
  * **智能控制：** 作为智能家居的控制中心，应用可以远程操控家中的智能设备，如灯光、空调等。
  * **日常工具：** 提供天气预报、闹钟、计时器等日常工具功能，满足用户的多样化需求。


## [#](<#技术优势>) 技术优势

相较于传统的应用框架，Xiaomi Vela JS 应用具有以下技术优势：

### [#](<#前端开发范式>) 前端开发范式

Xiaomi Vela JS 应用采用JavaScript语言开发，并且支持前端MVVM高效的开发范式，响应式UI框架，易学易用。使得开发者可以降低上手难度，缩短开发周期。这种模式贴合主流前端开发者的思维习惯，使得开发者能够快速构建出功能丰富、交互友好的应用，同时降低了学习成本。参考[开发语法](</vela/quickapp/zh/guide/framework/>)。

### [#](<#统一的api和组件>) 统一的API和组件

Xiaomi Vela JS 应用提供了统一的[JS接口](</vela/quickapp/zh/features/>)和[UI组件](</vela/quickapp/zh/components/>)，使得开发者无需关心底层硬件和操作系统的差异，简化了开发流程，同时保证了应用的质量和用户体验。

### [#](<#高性能渲染>) 高性能渲染

  * 通过架构优化，让复杂计算下沉到原生层，解决 JS 语言的性能瓶颈，从而拥有媲美原生的运行效率和流畅体验。
  * 提供丰富的动效能力，包括30+插值和物理动效，可用于过渡、转场等动画效果，使用户界面更加生动、有趣和富有表现力。
  * 充分挖掘硬件性能，最大限度利用 GPU 和 CPU 的硬件加速能力，让复杂UI 界面和动画更加流畅，达到 60 fps 满帧效果。


### [#](<#多屏适配>) 多屏适配

[多屏适配](</vela/quickapp/zh/guide/multi-screens/>)是Xiaomi Vela JS 应用框架的另一大特色，具体表现在：

  * **[适配规范](</vela/quickapp/zh/guide/multi-screens/specs.html>)：** 框架支持不同形状、尺寸和分辨率的屏幕自适应，确保应用在各种设备上都能提供良好的视觉体验。
  * **[设计规范](</vela/quickapp/zh/guide/design/multi-screens.html>)：** Vela提供了一套多屏设计的技术规范，帮助开发者按照设计稿完成应用的多屏适配。
  * **[多屏UI模拟器](</vela/quickapp/zh/guide/multi-screens/simulator.html>)：** AIoT-IDE提供了多屏UI模拟器，使开发者能够快速预览应用在不同屏幕上的效果，进行必要的调整。
  * **[适配案例](</vela/quickapp/zh/guide/multi-screens/samples.html>)：** 提供了对常见页面元素进行多屏适配的代码示例以及整站案例，供开发者参考和学习。


## [#](<#应用开发流程>) 应用开发流程

### [#](<#环境搭建>) 环境搭建

小米提供了包括AIoT-IDE在内的一系列开发工具，支持开发者在Ubuntu、Windows、MacOS等操作系统上进行Xiaomi Vela JS 应用的开发和调试。 AIoT-IDE是Xiaomi Vela JS 应用的集成开发环境，提供了项目初始化、编码、调试等一系列功能。请参考[安装环境](</vela/quickapp/zh/guide/start/use-ide.html>)初始化项目。

### [#](<#应用开发>) 应用开发

初始化项目后请参考[项目结构](</vela/quickapp/zh/guide/start/project-overview.html>)了解项目中各文件和目录的作用。项目由配置文件（manifest.json）、模板代码（ux文件）、 样式代码（css文件）、逻辑代码（js文件）以及资源文件（图片、音频等）组成。请参考[项目配置](</vela/quickapp/zh/guide/framework/manifest.html>)对项目相关信息进行配置。

应用开发范式遵循声明式UI，和传统Web开发范式类似。项目中的页面以及组件均由`ux`后缀文件编写，文件由[template 模板](</vela/quickapp/zh/guide/framework/template/>)、[style 样式](</vela/quickapp/zh/guide/framework/style/>)和[script 脚本](</vela/quickapp/zh/guide/framework/script/>)3 个部分组成。开发者可以通过编写`ux`文件使用[UI组件](</vela/quickapp/zh/components/>)、[自定义组件](</vela/quickapp/zh/guide/framework/template/component.html>)和样式描述页面结构和呈现效果，使用js脚本定义页面数据、实现生命周期接口、通用方法、事件处理等。 请参考[编写页面UI](</vela/quickapp/zh/guide/start/user-interface.html>)进一步了解页面开发。

### [#](<#运行调试>) 运行调试

AIoT-IDE提供内置的模拟器，支持开发者启动模拟器在IDE中直接运行和调试应用，实时查看运行效果。请参考[运行调试](</vela/quickapp/zh/guide/start/use-ide.html#_5-运行项目.html>)了解如何运行和调试应用。

### [#](<#打包发布>) 打包发布

应用开发完成后，开发者可以使用AIoT-IDE提供的打包功能将应用打包成安装包，请参考[打包项目](</vela/quickapp/zh/guide/start/use-ide.html#_7-打包项目.html>)了解如何打包应用。项目打包成功后请参考[发布](</vela/quickapp/zh/guide/publish/>)进行应用发布。

---

