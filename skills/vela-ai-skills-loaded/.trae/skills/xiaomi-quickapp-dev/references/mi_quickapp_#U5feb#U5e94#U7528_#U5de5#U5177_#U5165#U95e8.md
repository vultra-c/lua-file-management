# 快应用_工具_入门

> 来源: 小米快应用官方
> 共 4 篇文档

---

## #了解界面

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/start/project.html](https://iot.mi.com/vela/quickapp/zh/tools/start/project.html)

# [#](<#了解界面>) 了解界面

## [#](<#界面布局>) 界面布局

`AIoT-IDE` 的主窗口由几个主要区域构成，具体如下：

1.**侧边栏** ：提供资源管理器、搜索、Git 管理、插件市场、快捷入口等功能。  
2.**菜单栏** ：包含文件、编辑、选择、视图、转到、终端、窗口、帮助等菜单项。  
3.**工具栏** ：包含选择设备、开始调试、打包等功能按钮选项。  
4.**代码编辑区** ：包含代码编辑、定义跳转、代码补全、错误提示等功能，详情参阅代码补全。  
5.**功能面板** ：提供问题、输出、终端、调试等面板。  
6.**模拟器** ：包含引导页提示，仿真预览、模拟真机操作、截图等功能。

![alt text](/vela/quickapp/images/tools/ide-tools.png)

只有通过`AIoT-IDE` 打开的是一个**Xiaomi Vela JS应用** ，主窗口界面才会如上图所示，`AIoT-IDE`会通过打开的项目结构自动识别打开的项目是否为**Xiaomi Vela JS应用项目** 。

## [#](<#工具栏界面>) 工具栏界面

`AIoT-IDE` 工具栏界面中含有几个常用功能：

  * **选择设备** ：选择本地创建的模拟器供后续调试使用
  * **调试** ：使用所选的模拟器编译预览当前打开的**Xiaomi Vela JS** 应用项目，并打开调试面板
  * **设备** ：打开设备管理页面，创建不同镜像类型，设备类型的模拟器
  * **打包** ：将当前**Xiaomi Vela JS** 应用项目打包为rpk
  * **发布** ：生成 release类型的应用包（RPK）


另外，`AIoT-IDE`支持直接预览`Xiaomi Vela JS`应用项目打包后的rpk，可将rpk解压后的目录通过`AIoT-IDE`打开，可对rpk进行预览。

## [#](<#模拟器界面>) 模拟器界面

模拟器界面主要包含四部分:

  * **用户引导页**
  * **模拟器SDK管理页**
  * **设备管理页**
  * **模拟器运行预览页面**


## [#](<#用户引导页>) 用户引导页

模拟器**用户引导页** 会引导用户初始化**Xiaomi Vela JS** 应用模拟器运行环境。按引导页提示进行操作:

  * 1.**安装项目依赖** ，等待项目依赖和环境安装完成，才能正常编译预览**Xiaomi Vela JS** 应用项目
  * 2.**初始化模拟器环境** ，模拟器用户引导页会自动当前环境是否具备模拟器运行环境，如不具备可按用户引导页操作，**自动安装** 好模拟器环境


![alt text](/vela/quickapp/images/tools/ide-warning.png)

按照上图引导页提示**正确操作** 完毕后，引导页会给出项目可以**当前项目可以正常启动** 的提示，如下图中**标签1** 所示。

![alt text](/vela/quickapp/images/tools/ide-success.png)

注意：**出于性能考虑** ，引导页不会轮询监测项目依赖和模拟器运行环境是否已经具备，当用户选择**自行手动安装** 的方式，安装好项目依赖和模拟器运行环境时，可点击**引导页右上角刷新** 按钮，刷新引导页状态。

![alt text](/vela/quickapp/images/tools/ide-sx.png)

## [#](<#设备管理页>) 设备管理页

设备管理页主要分为两部分：

  * **1.模拟器管理和真机调试** ：提供对模拟器的增删改查和运行功能和真机调试
  * **2.模拟器SDK管理** ：提供对模拟器运行环境所需的SDK包的安装和更新


![alt text](/vela/quickapp/images/tools/ide-emulator-1.png)

![alt text](/vela/quickapp/images/tools/ide-emulator-19.png)

## [#](<#模拟器运行预览页面>) 模拟器运行预览页面

模拟器预览页将运行的模拟器内嵌到`AIoT-IDE`中，进行预览显示。当项目依赖和模拟器环境具备后，可按如下步骤预览当前项目：

  * 1.点击**顶部操作栏** 的**选择设备** 按钮，选择一个或多个要运行的**模拟器** 。
  * 2.点击****顶部操作栏**** 的**调试** 按钮，运行模拟器，按钮进入**loading状态** ，运行成功后，会变为蓝色。
  * 3.底部工具栏开始输出模拟器运行日志，页面从用户引导页自动切换模拟器预览页面。
  * 4.模拟器运行成功，模拟器预览页将出现对应模拟器，并将当前打开的**Xiaomi Vela JS应用** 推送到运行的模拟器中。


![alt text](/vela/quickapp/images/tools/ide-debugrun.png)

---

## #新建项目

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/project/creat-project.html](https://iot.mi.com/vela/quickapp/zh/tools/project/creat-project.html)

# [#](<#新建项目>) 新建项目

`AIoT-IDE`提供了对**Xiaomi Vela JS** 应用项目的新建和管理功能。

开发者初次使用`AIoT-IDE`时可按如下步骤打开新建项目弹窗创建项目：

  * 1.点击左上角文件按钮，出现下拉菜单。
  * 2.点击新建项目菜单，打开新建项目弹窗。


![alt text](/vela/quickapp/images/tools/ide-create-project.png)

在新建项目时可选择项目类型，并通过我们提供的模板创建基础的**Xiaomi Vela JS** 应用项目，目前提供了八种基础模板：

  * 1.**Xiaomi Vela JS** 应用项目基础模板
  * 2.**Xiaomi Vela JS** 应用项目日历模板
  * 3.**Xiaomi Vela JS** 应用项目图表模板
  * 4.**Xiaomi Vela JS** 应用项目列表模板
  * 5.**Xiaomi Vela JS** 应用项目音乐播放器模板
  * 6.**Xiaomi Vela JS** 应用项目开发示例模板
  * 7.**Xiaomi Vela JS** 应用项目计算器模板
  * 8.**Xiaomi Vela JS** 应用项目设置面板模板


![](/vela/quickapp/images/tools/ide-project-template.png) ![](/vela/quickapp/images/tools/ide-project-template1.png)

选择完模板后，点击下一步，请按下面步骤完成创建：

  * 1.输入项目名称
  * 2.选择创建目录(`AIoT-IDE`会记录用户曾选择过的创建目录，可直接选择)
  * 3.输入完相应表单内容，点击创建，即可创建成功。


![alt text](/vela/quickapp/images/tools/ide-create-project1.png)

创建成功后，`AIoT-IDE`会自动打开创建的项目，按引导页指示安装项目依赖后，即可运行项目(**下图标签1，2**)。

![alt text](/vela/quickapp/images/tools/ide-create-success.png)

---

## #管理项目

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/project/project.html](https://iot.mi.com/vela/quickapp/zh/tools/project/project.html)

# [#](<#管理项目>) 管理项目

对通过`AIoT-IDE`新建项目创建的**Xiaomi Vela JS** 应用项目，`AIoT-IDE`提供了删除和打开历史项目的功能。

## [#](<#打开历史项目>) 打开历史项目

在打开新建项目弹窗时，可查看到已创建项目的历史信息卡片，选中其中一个项目，通过右下角打开按钮打开项目，如下图1，2所示：

![alt text](/vela/quickapp/images/tools/ide-delete-project.png)

## [#](<#删除项目>) 删除项目

将鼠标移动至历史项目信息顶部的**管理** 按钮，点击后每个卡片的右上角会出现一个勾选按钮，选择一个或多个历史项目后，可点击右下角删除项目。如下图**标签1，2，3** 所示：

![alt text](/vela/quickapp/images/tools/ide-delete-project-1.png)

## [#](<#导入项目>) 导入项目

将鼠标移动至历史项目信息顶部的**导入** 按钮，点击后将会自动打开一个文件夹选择框，选择对应的项目类型进行导入，非qucikApp项目和**Xiaomi Vela JS** 应用项目将无法导入

![alt text](/vela/quickapp/images/tools/ide-delete-project-2.png)

---

## #项目类型

> 来源: [https://iot.mi.com/vela/quickapp/zh/tools/project/template.html](https://iot.mi.com/vela/quickapp/zh/tools/project/template.html)

# [#](<#项目类型>) 项目类型

`AIoT-IDE`不仅支持**Xiaomi Vela JS** 应用项目，还支持对快应用项目的创建.

![alt text](/vela/quickapp/images/tools/ide-project.png)

如上图**标签1，2** 所示，在打开**新建项目弹窗** 后，可左侧菜单栏选择**quickApp** ，再点击**创建** 进入创建页面，按输入提示输入创建信息，即可创建快应用项目。

![alt text](/vela/quickapp/images/tools/ide-project-1.png)

---

