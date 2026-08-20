# 快应用_工具_模拟器与设备调试

> 来源: 小米快应用官方
> 共 3 篇文档

---

## #设备管理

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/emulator/create-emulator.html](https://iot.mi.com/vela/quickapp/zh/tools/emulator/create-emulator.html)

# [#](<#设备管理>) 设备管理

设备管理页主要分为两部分：

  * **1.模拟器版本管理** ：提供对模拟器的增删改查和运行功能，如下图1所示。
  * **2.Vela镜像版本管理** ：提供对模拟器运行环境所需的SDK包的安装和更新，如下图2所示。


![alt text](/vela/quickapp/images/tools/ide-emulator-1.png)

## [#](<#模拟器设备管理>) 模拟器设备管理

模拟器设备管理，主要展示模拟器的基本信息：

  * 名称
  * 镜像版本
  * 屏幕尺寸
  * 构建时间
  * 操作栏（提供删除，运行等功能）


此外，用户可以点击左上角新建按钮进入模拟器创建页面。

![alt text](/vela/quickapp/images/tools/ide-emulator-20.png)

### [#](<#自动创建模拟器>) 自动创建模拟器

在初次使用 `AIoT-IDE`开发工具时，在初始化模拟器环境时，会检测本地是否已经创建过模拟器，若本地没有创建过模拟器将会提示开发者是否要自动创建模拟器。

![alt text](/vela/quickapp/images/tools/ide-emulator-13.png)

选择确定，将会在初始化环境后自动创建一个正式版模拟器。

![alt text](/vela/quickapp/images/tools/ide-emulator-15.png)

选择创建所有设备模拟器，将会自动创建所有设备类型的模拟器。

![alt text](/vela/quickapp/images/tools/ide-emulator-14.png)

### [#](<#新建模拟器>) 新建模拟器

点击上图**新建** 按钮打开模拟器创建页面。首次进入**创建模拟器页面** ，镜像版本默认为`vela-miwear-watch-5.0`，输入模拟器名称后，点击**新建** 即可完成创建。如下图**标签1，2，3，4** 所示：

![alt text](/vela/quickapp/images/tools/ide-emulator-3.png)

除了默认的`vela-miwear-watch-5.0`镜像，还可以在上图**标签3** 中，下拉选择`vela-miwear-watch-4.0`镜像和`vela-watch-4.0`镜像，如下图**标签1，2** 所示：

![alt text](/vela/quickapp/images/tools/ide-emulator-10.png)

在设备管理列表中，可对已创建的模拟器进行操作，目前提供了运行，暂停，删除等操作按钮。

  * 此外，在设备管理列表中，为了方便用户操作，还提供了多个快捷配置：

    * **复制启动命令** ：复制当前模拟器的启动命令，方便用户通过命令行自启模拟器和模拟器启动失败时进行排查。

    * **打开模拟器目录** ：打开模拟器文件存放目录，方便直接查看模拟器配置文件。

    * **打开镜像文件** ：打开模拟器SDK包存放目录，方便直接查看模拟器SDK包文件。

    * **安装Rpk** ：在模拟器运行成功后，用于可选择本地环境里Rpk包，直接安装预览（模拟器非运行状态时禁用）。

    * **自定义镜像目录** ：当用于本地多有个镜像文件时，用户可以自定义镜像目录，运行自己本地的镜像文件。

    * **重置镜像目录为默认** ：用户自定义镜像目录后，可以通过重置镜像目录为将镜像运行目录重置为系统默认目录。


![alt text](/vela/quickapp/images/tools/ide-emulator-9.png)

## [#](<#模拟器sdk管理>) 模拟器SDK管理

模拟器SDK管理主要分为两部分：

  * 模拟器内核，如下图1所示
  * 模拟器镜像，如下图2所示


![alt text](/vela/quickapp/images/tools/ide-emulator-16.png)

模拟器SDK管理页面中主要从四个维度展示模拟器信息

  * 名称
  * 版本
  * 构建时间
  * 状态


每次启动`AIoT-IDE`时，会自动检测模拟器内核和模拟器镜像版本是否需要更新或安装，用户可以在列表的状态一栏中，查看到模拟器内核或被模拟器镜像是否安装或是否需要升级，可手动点击安装或升级，如下图1所示

![alt text](/vela/quickapp/images/tools/ide-emulator-17.png)

## [#](<#设备使用配置>) 设备使用配置

除了上面的基础功能，模拟器设备管理页面提供可一项单的的设备使用配置（如下图1所示）：

  * Adb Mode: 是否优先使用插件内置的adb模块，还是使用主机本地的adb模块（如下图2所示）
  * Hide Qt Window: 是否使用GRPC技术将模拟器嵌入到IDE中显示，否则在IDE外部弹出显示（如下图3所示）。


![alt text](/vela/quickapp/images/tools/ide-emulator-18.png)

---

## #运行模拟器

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/emulator/emulator-run.html](https://iot.mi.com/vela/quickapp/zh/tools/emulator/emulator-run.html)

# [#](<#运行模拟器>) 运行模拟器

在设备管理页面的模拟器列表中，点击`运行`图标，会自动运行模拟器，并且按钮进入**loading** 状态。不过通过设备管理页运行模拟器成功后，并不会推送当前打开的**Xiaomi Vela JS应用项目** ，还是需要点击顶部****顶部操作栏**** 的 `选择设备`按钮选择已运行的模拟器再点击`调试`按钮，运行当前项目。

![alt text](/vela/quickapp/images/tools/ide-emulator-11.png)

  * 通过设备管理页运行成功后，不同的镜像将有不同的表现：

    * `vela-miwear-watch-5.0`镜像版本的模拟器将显示表盘页面。

    * `vela-miwear-watch-4.0`镜像版本的模拟器将显示表盘页面。

    * `vela-watch-4.0`的镜像版本的模拟器，由于将显示为黑屏。


如下图**标签1，2** 所示：

![alt text](/vela/quickapp/images/tools/ide-emulator-12.png)

---

## #功能介绍

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/devicedebug/start.html](https://iot.mi.com/vela/quickapp/zh/tools/devicedebug/start.html)

# [#](<#功能介绍>) 功能介绍

支持开发**Xiaomi Vela JS** 应用时进行真机调试，在`AIoT-IDE`可通过设备ID连接真机，将应用推送到真机进行调试

## [#](<#设备升级>) 设备升级

目前真机调试只支持 `Xiaomi Watch S4` 设备，请先联系小米工作人员获取`小米Vela设备真机调试全流程指南` 文档,按照文档内容，获取对应ota包将设备升级到支持真机调试的指定版本。注：升级固件存在一定风险，目前真机调试仅对特定合作方开放。

## [#](<#环境准备>) 环境准备

  1. 请使用测试版小米运动健康，连接测试用机
  2. 请保证电脑网络和手机网络在一个局域网下


## [#](<#连接>) 连接

1.打开rpk 先在真机上打开安装好的真机调试debug-app（图中红框标记的）

![alt text](/vela/quickapp/images/tools/ide-emulator-22.png)

2.进行连接 打开debug-app后，点击开启调试，debug-app的中间按钮状态进入到【等待IDE连接】 ![alt text](/vela/quickapp/images/tools/ide-emulator-23.png)

3.IDE端连接 在电脑端打开AIOT-IDE，进入真机调试界面 ![alt text](/vela/quickapp/images/tools/ide-emulator-24.png)

4.开始连接 点击连接设备，输入设备IDE（设备ID从上面的debug-App中的设备ID获取），点击连接

![alt text](/vela/quickapp/images/tools/ide-emulator-25.png)

5.连接成功 连接成功后，按钮下面列表中出现一条真机信息，状态显示为Connected

![alt text](/vela/quickapp/images/tools/ide-emulator-26.png)

## [#](<#调试>) 调试

在真机连接成功后，可进入调试阶段，将当前开发的vela应用在真机上调试。

1.选择设备 在顶部tab栏中点击连接设备，选择真机设备，然后点击调试，进入真机调试模式。

![alt text](/vela/quickapp/images/tools/ide-emulator-27.png)

![alt text](/vela/quickapp/images/tools/ide-emulator-28.png)

![alt text](/vela/quickapp/images/tools/ide-emulator-29.png)

2.进入真机调试 调试运行成功后，真机上会自动打开当前应用，AIOT-IDE底部会直接打开调试面板

![alt text](/vela/quickapp/images/tools/ide-emulator-30.png)

3 获取日志 在真机调试面板中点击获取日志，可直接拉取真机上的日志，获取的日志数量取决于该设备内核日志的缓冲区的大小。

![alt text](/vela/quickapp/images/tools/ide-emulator-31.png)

4.推送其他rpk 在真机调试页面中可点击推送rpk按钮，选择要推送的非当前项目rpk进行推送，进行真机调试。

![alt text](/vela/quickapp/images/tools/ide-emulator-32.png)

5.真机调试效果 在AIOT-IDE调试面板上进行调试，真机会实时显示调试效果(但不支持热更新，如要修改源码可点击打包按钮打包当前应用，通过第四步进行rpk安装)

![alt text](/vela/quickapp/images/tools/ide-emulator-33.png) ![alt text](/vela/quickapp/images/tools/ide-emulator-34.png)

---

