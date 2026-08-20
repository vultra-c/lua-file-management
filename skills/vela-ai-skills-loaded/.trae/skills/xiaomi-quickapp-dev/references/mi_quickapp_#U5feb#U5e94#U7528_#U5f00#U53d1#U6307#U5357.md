# 快应用_开发指南

> 来源: 小米快应用官方
> 共 22 篇文档

---

## #快速入门

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start.html](https://iot.mi.com/vela/quickapp/zh/guide/start.html)

# [#](<#快速入门>) 快速入门

这部分主要适合 Vela JS 应用开发的初学者。通过实现一个简单的天气预报APP，来熟悉 Vela JS 应用开发的流程和基础知识。

---

## #项目概览

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/project-overview.html](https://iot.mi.com/vela/quickapp/zh/guide/start/project-overview.html)

# [#](<#项目概览>) 项目概览

本章节基于[安装环境](</vela/quickapp/zh/guide/start/use-ide.html>)中初始化的项目，介绍 Vela JS 应用项目各部分的作用。

## [#](<#目录结构>) 目录结构

典型的项目目录结构如下：
    
    
    ├── README.md            # 项目说明文件
    ├── package.json         # 项目配置文件
    ├── build/               # 构建中间产物
    ├── dist/                # 最终构建产物
    ├── sign/                # 签名文件
    │   ├── certificate.pem
    │   └── private.pem
    └── src/                 # 源码目录
        ├── app.ux           # 应用入口文件
        ├── manifest.json    # 项目配置文件
        ├── common/          # 公共资源目录
        │   ├── components/  # 组件目录
        │   │   └── button.ux
        │   ├── images/      # 图片目录
        │   │   └── logo.png
        │   └── scripts/     # 脚本目录
        │       └── index.js
        ├── i18n/            # 多语言配置目录
        │   ├── defaults.json
        │   ├── en.json
        │   └── zh-CN.json
        └── pages/           # 页面目录
            ├── detail/detail.ux
            └── index/index.ux
    

## [#](<#各目录说明>) 各目录说明

### [#](<#src>) src/

源码目录，所有应用代码都放在这里。`src/` 是固定的目录名称，不可更改。

### [#](<#src-manifest-json>) src/manifest.json

项目配置文件，用于声明应用基本信息（包名、版本等）、系统接口权限以及页面路由。详细字段说明参考[项目配置](</vela/quickapp/zh/guide/framework/manifest.html>)。

### [#](<#src-app-ux>) src/app.ux

应用入口文件，用于定义应用级别的生命周期回调、全局数据和全局方法。详细用法参考 [app.ux](</vela/quickapp/zh/guide/framework/ux.html#appux>)。

### [#](<#src-pages>) src/pages/

页面目录，每个页面对应一个子目录。页面由 ux 文件描述，也可以将样式和逻辑拆分为独立的 css/js 文件。详细说明参考[项目结构](</vela/quickapp/zh/guide/framework/project-structure.html>)。

### [#](<#src-common>) src/common/

公共资源目录，用于存放跨页面共享的组件、图片、脚本和样式等资源。

### [#](<#src-i18n>) src/i18n/

多语言配置目录，存放各语言对应的 JSON 文件，用于实现应用的国际化。详细用法参考[多语言](</vela/quickapp/zh/guide/framework/other/i18n.html>)。

### [#](<#build-和-dist>) build/ 和 dist/

`build/` 存放构建过程中的中间产物，`dist/` 存放最终的构建输出文件（rpk 包）。这两个目录由构建工具自动生成，无需手动维护。

### [#](<#sign>) sign/

签名文件目录，包含 `certificate.pem`（证书）和 `private.pem`（私钥），用于对应用包进行签名。

### [#](<#package-json>) package.json

项目的 npm 配置文件，定义项目依赖和构建脚本。

---

## #使用 AIoT-IDE 来开发 JS 应用

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/use-ide.html](https://iot.mi.com/vela/quickapp/zh/guide/start/use-ide.html)

# [#](<#使用-aiot-ide-来开发-js-应用>) 使用 AIoT-IDE 来开发 JS 应用

## [#](<#下载-aiot-ide>) 下载 AIoT-IDE

本应用支持 **macOS** 、**Windows** 及 **Ubuntu** 系统，请确保设备满足以下最低系统版本要求。

* * *

## [#](<#系统要求>) 系统要求

操作系统 | 最低版本要求  
---|---  
**macOS** | 14（Sonoma）及以上  
**Windows** | 10 或更高版本  
**Ubuntu** | 20.04 LTS 或更高版本  
  
## [#](<#安装-aiot-ide>) 安装 AIoT-IDE

mac 版本下可能会遇到如下安装报错的问题:

![alt text](/vela/quickapp/images/ide/ide-download-1.png)

遇到此类问题，请按下面方法操作：

1.打开 shell 窗口，输入 ：`sudo xattr -r -d com.apple.quarantine`,如下图示例一。  
2.敲入空格 **再将应用程序拖入到窗口中** ，会得到下图示例二。  
3.点击回车，输入密码，再执行该程序即可。

![alt text](/vela/quickapp/images/ide/ide-download-2.png)

示例一

![alt text](/vela/quickapp/images/ide/ide-download-3.png)

示例二

## [#](<#历史版本>) 历史版本

历史版本地址：[点击查看 (opens new window)](<https://kpan.mioffice.cn/webfolder/ext/j6SfQsarf8I%40?n=0.18700074913007825>)  
密码：99E6

## [#](<#使用-aiot-ide>) 使用 AIoT-IDE

### [#](<#_1-初始化-vela-项目>) 1\. 初始化 Vela 项目

  * 通过点击左上角 「文件」 > 「新建项目」 打开项目初始化图形界面
  * 点击卡片左侧边栏的 watch，点击 「创建」
  * 选择一个项目模版，点击 「下一步」
  * 输入项目名称和项目保存路径后，点击「创建」，等待项目创建完成


![](/vela/quickapp/images/tools/ide-create-project.png)

![](/vela/quickapp/images/tools/ide-project-template.png)

### [#](<#_2-项目开发>) 2\. 项目开发

支持依赖安装、调试、模拟器管理和打包项目等功能。  
打开 Vela 快应用项目后，AIoT-IDE 会弹出顶部的 banner 操作按钮栏以及右侧的开发向导页，可根据开发向导的指引安装相关的依赖。  
依赖安装完成后，可点击 banner 栏里的操作按钮实现对应的功能。

![](/vela/quickapp/images/tools/ide-warning.png)

### [#](<#_3-开发向导指引>) 3\. 开发向导指引

打开 Vela 快应用项目，AIoT-IDE 右侧会弹出开发向导，用于指导开发。可以根据向导的提示完成对应的操作。

![](/vela/quickapp/images/tools/ide-success.png)

按向导提示遇到 npm i 下载 npm 包失败,可按如下方法解决：

![](/vela/quickapp/images/ide/ide-npm-0.png)

  * 检查当前项目根目录中是否有.npmrc 文件,如果没有则自己创建。

![alt text](/vela/quickapp/images/ide/ide-npm-1.png)

  * 打开.npmrc 文件,将下面内容复制到文件中

`registry="https://registry.npmmirror.com/"`

![alt text](/vela/quickapp/images/ide/ide-npm-2.png)

  * 打开终端,在终端重新运行 npm i

![alt text](/vela/quickapp/images/ide/ide-npm-3.png)


### [#](<#_4-模拟环境管理>) 4\. 模拟环境管理

AIoT-IDE 支持自动初始化模拟器环境，创建、删除和列表展示模拟器，以便在运行/调试时可以选择不同的模拟器查看效果。

**模拟器环境说明**

如果缺少模拟器环境和模拟器实例，开发向导中会给出需相应的提示

  * 点击下方的「检查模拟器环境，创建模拟器实例」按钮，在弹出的模态窗口中选择 「自动安装」，插件会自动帮助安装模拟器相关的依赖
  * 在模拟器列表页，点击左上角的「创建」按钮去生成一个模拟器实例


![](/vela/quickapp/images/tools/ide-warning-1.png)

**模拟器操作说明**

  * 查看已创建的模拟器  
点击 banner 栏的「模拟器」按钮，进入模拟器列表页，这里可以看到已经创建的模拟器的详细信息


![](/vela/quickapp/images/tools/ide-emulator-2.png)

  * 创建一个新的模拟器 
    * 点击**设备管理** 左上角的**新建** 按钮，进入模拟器表单页
    * 在模拟器表单页，填写要创建的模拟器信息，点击「创建」按钮，插件首先会下载 Vela 镜像并完成创建


![](/vela/quickapp/images/tools/ide-emulator-3.png)

### [#](<#_5-调试项目>) 5\. 调试项目

调试时需要先选择要在哪些模拟器上预览效果，选择设备后点击调试按钮则会将当前打开的快应用在模拟器中启动并显示项目 UI。

![](/vela/quickapp/images/tools/ide-debug-1.png)

快应用启动成功后，AIoT-IDE 底部会弹出调试面板，点击调试面板的 Tab 栏即可进行对应的操作，比如查看 DOM 树、查看 Console 以及断点调试。

![](/vela/quickapp/images/ide/ide-debug-0.png)

### [#](<#_6-打包项目>) 6\. 打包项目

**开发模式打包**  
开发完成后，可以点击 banner 栏的「打包」按钮来打包应用，默认会生成两个新的目录：dist、build；  
其中 dist 文件夹中会生成一个`.debug.rpk`文件，build 中会生成编译后的 js 文件。

**生产模式打包**

  * 打包前需要配置 signature private key ，生成签名文件

    * 自动生成：点击 banner 栏的「发布」按钮 > 填写相关信息 > 点击「完成」按钮，插件会在项目的 sign 目录下生成`private.pem`和`certificate.pem`两个文件。签名文件生成成功后，点击**顶部操作栏** 栏的「发布」按钮，打包生成的产物跟开发模式打包类似，但是 dist 文件夹中的 rpk 文件是 release 后缀。

![](/vela/quickapp/images/tools/ide-debug-11.gif)

    * 自动生成需要系统环境安装了 openssl，windows 系统可能遇到 openssl 缺失的问题，下面是具体解决方法。

      * 安装 openssl 并配置系统环境变量，并重启电脑。重启成功后，在 AIoT-IDE 中打开终端，输入 openssl，如下图所示，则是安装成功。

![](/vela/quickapp/images/ide/ide-openssl.png)

    * 手动生成：前提同样是系统环境安装了 openssl,然后打开终端运行以下命令生成签名文件，项目下新建 sign 目录，将生成的文件 private.pem 和 certificate.pem 放至该目录  
`openssl req -newkey rsa:2048 -nodes -keyout private.pem -x509 -days 3650 -out certificate.pem`

---

## #编译参数

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/toolkit-params.html](https://iot.mi.com/vela/quickapp/zh/guide/start/toolkit-params.html)

# [#](<#编译参数>) 编译参数

编译工具提供了多种编译能力，开发者可以根据项目需求进行设置。请**注意** ，编译参数仅在 `build`、`server`、`release` 命令中可用

## [#](<#如何设置编译参数>) 如何设置编译参数

通常有两种方式设置编译参数，以抽取单独的 source-map 文件为例：

  * 在命令行携带编译参数


    
    
    aiot build --devtool=source-map
    

  * 在项目根目录新建配置文件 quickapp.config.js，并配置 cli 属性；


    
    
    module.exports = {
      cli: {
        devtool: "source-map",
      },
    };
    

## [#](<#查看当前工具支持的全部编译参数>) 查看当前工具支持的全部编译参数
    
    
     npx aiot build -h
    

## [#](<#常见编译参数>) 常见编译参数

参数名 | 值类型 | 描述 | 默认值  
---|---|---|---  
\--devtool | `string` | sourcemap 的输出形式， 参数值及含义可以参考 [webpack/devtool (opens new window)](<https://www.webpackjs.com/configuration/devtool/#root>)   
示例：`aiot server --devtool=source-map` | none  
\--enable-jsc | `boolean` | 是否将 js 文件将转换为 jsc 文件，以提高运行性能   
示例：`aiot server --enable-jsc` | false  
\--enable-protobuf | `boolean` | 是否启用 protobuf 的二进制打包，以提高运行性能   
示例：`aiot server --enable-protobuf` | false  
\--enable-custom-component | `boolean` | 是否支持自定义组件   
示例：`aiot server --enable-custom-component` | false

---

## #添加交互

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/add-interactivity.html](https://iot.mi.com/vela/quickapp/zh/guide/start/add-interactivity.html)

# [#](<#添加交互>) 添加交互

在上一章节中，我们已经编写了两个页面的结构和样式，但是两个页面之间没有任何关联， 在本章中，我们会实现页面间的跳转。

## [#](<#注册事件>) 注册事件

页面跳转由用户触发，需要给页面的特定元素添加对应的事件，比如`click`/`touchstart`。 有关事件更多的细节，请参考[通用事件](</vela/quickapp/zh/components/general/events.html>)。

在这个天气预报App中，我们采用的交互是滑动切换页面：

  1. 在实时天气页面中，向上滑动进入未来3天天气页面；
  2. 在未来3天天气页面，向右滑动返回到实时天气页面。


我们希望在页面任何地方滑动都执行跳转动作，所以将滑动事件(`swipe`)注册到根节点上。

模板代码如下：
    
    
    <template>
      <div class="page column" @swipe="toListPage">
        <!-- 页面其它内容 -->
      </div>
    </template>
    

说明

`@swipe="toListPage"`也可以写成`onswipe="toListPage"`，详情请参考[事件绑定](</vela/quickapp/zh/guide/framework/template/event.html>)。

## [#](<#页面跳转>) 页面跳转

注册完事件后，需要在JavaScript代码中，定义`toListPage()`回调方法，通过判断滑动方向，决定是否做页面跳转。 页面跳转，需要使用到`@system.router`模块，使用前请先在`manifest.json`中声明：
    
    
    {
      // ...
      "features": [
        { "name": "system.router" }
      ]
    }
    

说明

更多router相关细节，请参考[页面切换](</vela/quickapp/zh/guide/framework/page-switch.html>)。

声明模块后，即可在JavaScript脚本中引入模块，然后使用`router`提供的API在页面间跳转：
    
    
    <script>
      import router from '@system.router'
    
      export default {
        // ...
        toListPage(eve) {
          if (eve.direction === 'up') {
            router.push({
              uri: '/pages/list'
            })
          }
        }
      }
    </script>
    

同样，在未来3天天气页面中，使用相同的方式来实现页面返回逻辑。对应的代码为：
    
    
    <template>
      <div class="page column" @swipe="toHomePage">
        <!-- 页面其它内容 -->
      </div>
    </template>
    
    
    
    <script>
      import router from '@system.router'
    
      export default {
        // ...
        toHomePage(eve) {
          if (eve.direction === 'right') {
            router.back()
          }
        }
      }
    </script>

---

## #数据获取

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/data-fetch.html](https://iot.mi.com/vela/quickapp/zh/guide/start/data-fetch.html)

# [#](<#数据获取>) 数据获取

在前面几个章节中，已经实现了天气预报App的UI，也添加了基本的交互。但页面中的数据 并非真实数据，接下来我们将从和风天气预报接口中请求真实数据并渲染。

## [#](<#请求接口数据>) 请求接口数据

网络请求需要使用到[数据请求fetch](</vela/quickapp/zh/features/network/fetch.html>)模块， 使用之前请在`manifest.json`中声明。

`fetch`模块提供了`fetch()`方法，详细使用方法请参考Vela文档。

每个页面都具有自己的[生命周期](</vela/quickapp/zh/guide/framework/script/lifecycle.html>)，可以在`onReady`中发送请求， 代码如下：
    
    
    <script>
      import router from '@system.router';
      import fetch from '@system.fetch';
    
      export default {
        private: {
          // ...
        },
    
        onReady() {
          let key = '<你的key>';
          // location，这里使用的是武汉的code
          // 更多的location code可以查看：https://github.com/qwd/LocationList
          fetch.fetch({
            url: `https://devapi.qweather.com/v7/weather/now?location=101010100&key=${key}`
          }).then(res => {
            const result = res.data;
            console.log('返回的数据:', JSON.stringify(result.data, null, 2));
          }).catch(error => {
            console.log(`数据请求失败:`, error);
          })
        },
    
        // ...
      }
    </script>
    

> 使用之前，请到和风天气开发平台中申请key，然后替换上面代码中的key。

添加上述代码并替换合法的key后，运行App，可以在控制台中看到类似下面的日志，说明请求成功。
    
    
    返回的数据: {
      "code": "200",
      "updateTime": "2022-01-04T10:07+08:00",
      "fxLink": "http://hfx.link/2ax1",
      "now": {
        "obsTime": "2022-01-04T09:54+08:00",
        "temp": "-1",
        "feelsLike": "-4",
        "icon": "100",
        "text": "晴",
        "wind360": "45",
        "windDir": "东北风",
        "windScale": "2",
        "windSpeed": "7",
        "humidity": "55",
        "precip": "0.0",
        "pressure": "1029",
        "vis": "15",
        "cloud": "10",
        "dew": "-17"
      },
      "refer": {
        "sources": [
          "QWeather",
          "NMC",
          "ECMWF"
        ],
        "license": [
          "no commercial use"
        ]
      }
    }
    

## [#](<#数据渲染>) 数据渲染

从后端请求到数据后，还需要将请求到的数据在页面上显示出来。要显示数据，只需要更改 [页面数据对象](</vela/quickapp/zh/guide/framework/script/page-data.html>)上的对应数据即可：
    
    
    this.weather = result.data.now;
    

最终页面完整的JavaScript代码如下：
    
    
    <script>
      import router from '@system.router';
      import fetch from '@system.fetch';
    
      export default {
        private: {
          city: '武汉市',
          province: '湖北省',
          country: '中国',
          weather: {
            obsTime: "12-21 09:05",
            temp: "13",
            feelsLike: "10",
            icon: "101",
            text: "多云",
            humidity: "72",
            vis: "16"
          }
        },
    
        onReady() {
          let key = '<你的key>';
          // location，这里使用的是武汉的code
          // 更多的location code可以查看：https://github.com/qwd/LocationList
          fetch.fetch({
            url: `https://devapi.qweather.com/v7/weather/now?location=101200101&key=${key}`
          }).then(res => {
            const result = res.data;
            console.log('返回的数据:', JSON.stringify(result.data, null, 2));
            this.weather = result.data.now;
          }).catch(error => {
            console.log(`数据请求失败:`, error);
          })
        },
    
        toListPage(eve) {
          console.log(eve);
          if (eve.direction === 'up') {
            router.push({
              uri: '/pages/list'
            })
          }
        }
      }
    </script>
    

页面运行结果：

![页面运行结果](/vela/quickapp/images/guide/api-wuhan-now.png)

未来3天天气预报界面的数据请求，跟实时天气页面一样，这里不再赘述。

在真实的项目中，还需要处理更多的页面细节，比如页面请求数据时添加loading状态、对日期做对应的格式化处理等。

为了给用户提供良好的体验，请严格按照设计稿编写页面结构和样式并对各种异常情况做相应的处理。

---

## #编写页面UI

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/start/user-interface.html](https://iot.mi.com/vela/quickapp/zh/guide/start/user-interface.html)

# [#](<#编写页面ui>) 编写页面UI

在上一节[项目结构](</vela/quickapp/zh/guide/start/project-overview.html>)中，介绍了 Vela JS 应用项目中各文件、目录的作用，对项目结构有了一定的了解之后，接下来我们会实现一个简单的天气预报App。

这个章节将实现这个App的页面UI，主要内容为：页面的基本结构、样式、数据结构定义以及数据渲染。

根据UI设计稿还原样式是一个比较细致并且耗时的工作，为了提高工作效率，一般情况下，我们推荐先整体构思页面的实现方式（页面结构、样式和交互等），然后编写页面结构、然后统一添加样式，最后添加数据渲染和交互。

这个使用指南中，为了方便展示 Vela JS 应用中页面结构，样式和交互的开发，采用了上述的开发流程。开发者在实际开发中，也可以根据自己的开发习惯，选择适合自己的工作流。

提示

这部分有比较多的代码片段，如果您已经对HTML/CSS/JavaScript很熟悉，您可以选择跳过此部分内容。 但我们还是建议您阅读本章的内容，以了解 Vela JS 应用开发和传统前端开发的一些区别。

## [#](<#功能需求>) 功能需求

我们将要实现的天气预报App由两个页面组成：**实时天气** 和**未来3天天气** 。实时天气界面展示当前天气情况，主要包括天气、温度、湿度和能见度等信息。未来3天天气页面用于展示未来三天的天气情况。

最终要实现的效果图如下：

![实时天气](/vela/quickapp/images/guide/ui-weather-now.png) ![7天预报](/vela/quickapp/images/guide/ui-weather-3d.png)

## [#](<#准备工作>) 准备工作

这个App使用**和风天气API** 获取天气数据，图标使用**和风天气图标** 。

该使用指南中的天气App仅用于演示 Vela JS 应用开发技术，如需在实际项目中使用相关接口和资源，请到和风天气开发平台注册并开通接口后使用。详细信息可在官网查看：

  * 和风天气开发平台: <https://dev.qweather.com/>[ (opens new window)](<https://dev.qweather.com/>)
  * 和风天气图标: <https://icons.qweather.com/>[ (opens new window)](<https://icons.qweather.com/>)
  * 图标下载地址: <https://github.com/qwd/WeatherIcon>[ (opens new window)](<https://github.com/qwd/WeatherIcon>)


## [#](<#页面结构>) 页面结构

在[项目结构](</vela/quickapp/zh/guide/start/project-overview.html>)章节中，我们介绍了一个页面(ux文件)包含三部分：`template`、`style`和`script` 。接下来分别编写这两个页面的模板（`template`）代码。

跟HTML非常类似，Vela的页面模板也是由标签和属性构成，并且语法也大部分与HTML保持一致。不一样的是Vela有自己的一系列内置组件，跟HTML支持的不完全相同。

接下来的代码中，我们使用到了`div`、`text`和`image`组件，关于组件详细的使用方法，可以参考[Vela官方文档 - 组件](</zh/components>)。

### [#](<#实时天气>) 实时天气

实时天气页面，从整体上可以划分为上中下三部分： `header`、`body`和`footer`，代码如下。
    
    
    <template>
      <div class="page">
        <!-- 头部城市信息 -->
        <div class="header"></div>
        <div class="body">
          <!-- 主要天气信息 -->
          <div class="info"></div>
          <!-- 体感温度等其他信息 -->
          <div class="more-info"></div>
        </div>
        <!-- 底部更新时间 -->
        <div class="footer"></div>
      </div>
    </template>
    

温馨提示

template只能有一个根节点。

头部信息，包含城市、省份和国家信息，结构相对简单，代码如下：
    
    
    <!-- 头部城市信息 -->
    <div class="header">
      <text class="city">武汉市</text>
      <text class="province">湖北省/中国</text>
    </div>
    

温馨提示

文本必须放在text组件中，否则文本将无法展示在界面中。

天气信息部分，相比头部要稍微复杂一点，总体可以分为左右两列，右侧部分又分为上下两行。代码如下：
    
    
    <!-- 主要天气信息 -->
    <div class="info">
      <image class="icon" src="/common/icons/101.png"></image>
      <div class="column center">
        <text class="temp">6°</text>
        <text class="weather">晴转多云</text>
      </div>
    </div>
    

接下来实现体感温度等其他信息模块，整体上可以分为三列，每一列又分成两行，代码如下：
    
    
    <!-- 体感温度等其他信息 -->
    <div class="more-info row">
      <div class="item column center">
        <text class="value">10°</text>
        <text class="label">体感温度</text>
      </div>
      <div class="item column center">
        <div><text class="value">67</text><text class="sub">%</text></div>
        <text class="label">湿度</text>
      </div>
      <div class="item column center">
        <div><text class="value">5</text><text class="sub">km</text></div>
        <text class="label">能见度</text>
      </div>
    </div>
    </div>
    

最后是底部更新时间模块，这个模块结构相对比较简单，代码如下：
    
    
    <!-- 底部更新时间 -->
    <div class="footer center">
      <text class="update-time">数据更新于12-20 09:15</text>
    </div>
    

### [#](<#未来3天天气>) 未来3天天气

这个页面跟实时天气页面整体结构相同，也分为上中下三部分，并且`header`以及`footer`内容一致，这里不再赘述。

接下来主要看中间部分的实现，主要包括**未来3天天气概况** 以及**天气列表** 。

天气概况分为上下两行，代码如下：
    
    
    <!-- 天气概况 -->
    <div class="info">
      <text class="title">未来3天预报</text>
      <text class="summary">最高温8° 最低温-6°</text>
    </div>
    

天气列表相对复杂一点，首先整体可以分为三列，每一列又可分成三行，代码如下：
    
    
    <!-- 未来3天天气 -->
    <div class="list">
      <div class="item">
        <text class="date">周日</text>
        <image class="icon" src="/common/icons/301.png"></image>
        <text class="temp">-6°~8°</text>
      </div>
      <div class="item">
        <text class="date">周一</text>
        <image class="icon" src="/common/icons/311.png"></image>
        <text class="temp">-9°~4°</text>
      </div>
      <div class="item">
        <text class="date">周二</text>
        <image class="icon" src="/common/icons/100.png"></image>
        <text class="temp">-3°~6°</text>
      </div>
    </div>
    

## [#](<#页面样式>) 页面样式

Vela支持常用的CSS特性，也进行了少量的扩充以及修改，默认支持对不同尺寸屏幕的适配。详细的属性支持情况可以在[属性列表](</vela/quickapp/zh/components/general/style.html#属性列表>)中查询。

Vela JS 应用采用`flex`布局，可以方便实现常用的布局样式，关于`flex`布局的技术细节，可以参考[MDN文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/flex>)。

目前只支持类选择器、ID选择器、分组选择器(,)和标签选择器，不支持后代选择器、属性选择器、通用选择器(*)、兄弟选择器(+)、直接父子选择器(>)、伪类和继承。

目前为止，我们已经完成了页面结构的代码编写，但是目前为止，还未涉及任何样式的设置。接下来我们将分别实现各个模块的样式。

### [#](<#公共样式>) 公共样式

编写样式代码之前，可以先提取出一些基础的公共样式，比如排列方式，颜色和对齐方式等。

在我们这个项目中，主要使用到了水平排列和垂直排列，居中等。 颜色方面，主要是白色，我们可以将text的颜色默认设置为白色。

提取出的基础样式为：
    
    
    /* 公共样式 */
    text {
      color: #ffffff;
    }
    
    .column {
      flex-direction: column;
    }
    
    .row {
      flex-direction: row;
    }
    
    .center {
      align-items: center;
      justify-content: center;
    }
    

### [#](<#page>) page

为了解决屏幕适配问题，所有与大小相关的样式（例如`width`、`font-size`）均以基准宽度（默认`480px`）为基础，根据实际屏幕宽度进行缩放，例如`width:100px`在`960px`宽度屏幕上，实际上为`200px`。

我们设计稿按照`480px`宽度进行设计，所以设计稿中的尺寸，可以直接在样式中使用。比如下图中，整体宽度为480，体感温度等信息模块的尺寸为`335*100`，那么CSS代码为：
    
    
    .info {
      width: 335px;
      height: 100px; 
    }
    

![设计稿尺寸](/vela/quickapp/images/guide/ui-figma-size.png)

对于整体页面，我们先将页面背景设置为黑色，形状设置为圆形，并设置页面宽度。
    
    
    .page {
      padding: 40px;
      background-color: #000000;
      width: 480px;
      border-radius: 240px;
    }
    

说明

如果设计稿基准宽度不是480，可以在`manifest.json`文件中通过`config.designWidth`字段配置：
    
    
    {
      // ...
      "config": {
        "designWidth": 360
      }
    }
    

### [#](<#头部信息>) 头部信息

头部信息竖向排列，并且居中，可以使用前面抽取的公共样式：`column`和`center`。然后给文本分别添加样式，控制字体大小和颜色。

修改后的模板代码如下：
    
    
    <!-- 头部城市信息 -->
    <div class="header column center">
      <text class="city">武汉市</text>
      <text class="province">湖北省/中国</text>
    </div>
    

CSS代码如下：
    
    
    /* 头部样式 */
    .city {
      font-size: 40px;
    }
    
    .province {
      font-size: 18px;
      color: #757575;
    }
    

实际运行结果：  
![头部信息运行结果](/vela/quickapp/images/guide/ui-header.png)

### [#](<#实时天气-2>) 实时天气

跟头部信息类似，首先添加基础样式`column`、`row`和`center`来实现基本的布局，然后对各个文本组件，针对性的编写CSS代码来实现文字颜色，尺寸等样式。

添加完成后的模板代码如下：
    
    
    <div class="body column center">
      <!-- 主要天气信息 -->
      <div class="info">
        <image class="icon" src="/common/icons/101.png"></image>
        <div class="column center">
          <text class="temp">6°</text>
          <text class="weather">晴转多云</text>
        </div>
      </div>
      <!-- 体感温度等其他信息 -->
      <div class="more-info row">
        <div class="item column center">
          <text class="value">10°</text>
          <text class="label">体感温度</text>
        </div>
        <div class="item column center">
          <div><text class="value">67</text><text class="sub">%</text></div>
          <text class="label">湿度</text>
        </div>
        <div class="item column center">
          <div><text class="value">5</text><text class="sub">km</text></div>
          <text class="label">能见度</text>
        </div>
      </div>
    </div>
    

体感温度等信息模块，首先水平方向排列(`flex-direction: row`)，然后各个item设置`flex: 1`，这样就实现了各个item宽度相等的效果。

具体到每个item里面，只需要分别设置各个文本字段的颜色和大小即可。

CSS代码如下：
    
    
    /* 天气数据样式 */
    .body {
      flex: 1;
    }
    
    .temp {
      font-size: 70px;
    }
    
    .icon {
      width: 170px;
      height: 170px;
      margin-right: 20px;
    }
    
    .weather {
      font-size: 24px;
    }
    
    /* 更多信息样式 */
    .more-info {
      width: 335px;
      height: 100px;
      background-color: rgba(255, 255, 255, 0.21);
      border-radius: 15px;
    }
    
    .item {
      flex: 1;
    }
    
    .value {
      font-size: 30px;
    }
    
    .sub {
      font-size: 14px;
      margin-top: 10px;
    }
    
    .label {
      color: #757575;
      margin-top: 5px;
    }
    

实际运行结果：  
![实时天气运行结果](/vela/quickapp/images/guide/ui-now-main.png)

### [#](<#未来3天天气-2>) 未来3天天气

天气概况信息模块样式比较简单，竖向排列即可。

跟体感温度等信息模块类似，未来三天天气列表也使用水平方向排列。不同的地方在于，各个item有背景颜色并且之间有间距，所以给各个item设置了固定的尺寸，然后根据剩下的空间 给各个item之间分配间距(`justify-content: space-between`)。

修改完成后的模板代码为：
    
    
    <!-- 未来3天天气 -->
    <div class="list row">
      <div class="item column center">
        <text class="date">周日</text>
        <image class="icon" src="/common/icons/301.png"></image>
        <text class="temp">-6°~8°</text>
      </div>
      <div class="item column center">
        <text class="date">周一</text>
        <image class="icon" src="/common/icons/311.png"></image>
        <text class="temp">-9°~4°</text>
      </div>
      <div class="item column center">
        <text class="date">周二</text>
        <image class="icon" src="/common/icons/100.png"></image>
        <text class="temp">-3°~6°</text>
      </div>
    </div>
    

CSS代码为：
    
    
    /* 天气数据样式 */
    .body {
      flex: 1;
    }
    
    .info {
      margin-bottom: 20px;
    }
    
    .title {
      font-size: 30px;
    }
    
    .summary {
      font-size: 24px;
      color: #757575;
    }
    
    /* 未来3天天气 */
    .list {
      width: 380px;
      justify-content: space-between;
    }
    
    .item {
      width: 120px;
      height: 175px;
      background-color: rgba(255, 255, 255, 0.2);
      border-radius: 15px;
    }
    
    .date {
      font-size: 28px;
    }
    
    .icon {
      width: 90px;
      height: 90px;
    }
    
    .temp {
      font-size: 24px;
    }
    

实际运行结果：  
![实时天气运行结果](/vela/quickapp/images/guide/ui-3d-list.png)

### [#](<#底部信息>) 底部信息

底部信息最终的模板代码如下：
    
    
    <!-- 底部更新时间 -->
    <div class="footer center">
      <text class="update-time">数据更新于 12-20 09:15</text>
    </div>
    

CSS代码如下：
    
    
    /* 底部样式 */
    .footer {
      margin-top: 20px;    
    }
    
    .update-time {
      color: #757575;
    }
    

实际运行结果：  
![实时天气运行结果](/vela/quickapp/images/guide/ui-footer.png)

## [#](<#页面效果>) 页面效果

完成页面结构和样式后，模拟器中实际运行的结果如下：

![实时天气运行结果](/vela/quickapp/images/guide/ui-now-result.png) ![未来3天天气运行结果](/vela/quickapp/images/guide/ui-3d-result.png)

## [#](<#页面数据>) 页面数据

我们已经实现了页面数据的渲染，但是目前所有的数据都是直接写到模板代码中，不能在程序中动态修改。

如果需要在程序中动态修改界面上展示的数据，需要将数据存储到[页面数据对象](</vela/quickapp/zh/guide/framework/script/page-data.html>)中，然后使用双大括号语法来引用数据，比如`{{ name }}`，详细使用方法可以参考[模板语法](</vela/quickapp/zh/guide/framework/template/>)。

数据定义，需要通过JavaScript脚本来实现。跟HTML一样，JavaScript代码需要放在`script`标签中：
    
    
    <script>
      export default {
        private: {
          city: '武汉市',
          province: '湖北省',
          country: '中国',
          weather: {
            // 数据观测时间
            obsTime: "12-21 09:05",
            // 温度
            temp: "13",
            // 体感温度
            feelsLike: "10",
            // 天气icon图标编号
            icon: "101",
            // 天气描述文本
            text: "多云",
            // 相对湿度
            humidity: "72",
            // 能见度，单位：公里
            vis: "16"
          }
        }
      }
    </script>
    

定义好数据之后，替换之前的模板代码，替换后为：
    
    
    <template>
      <div class="page column">
        <!-- 头部城市信息 -->
        <div class="header column center">
          <text class="city">{{city}}</text>
          <text class="province">{{province}}/{{country}}</text>
        </div>
        <div class="body column center">
          <!-- 主要天气信息 -->
          <div class="info">
            <image class="icon" src="/common/icons/{{weather.icon}}.png"></image>
            <div class="column center">
              <text class="temp">{{weather.temp}}°</text>
              <text class="weather">{{weather.text}}</text>
            </div>
          </div>
          <!-- 体感温度等其他信息 -->
          <div class="more-info row">
            <div class="item column center">
              <text class="value">{{weather.feelsLike}}°</text>
              <text class="label">体感温度</text>
            </div>
            <div class="item column center">
              <div><text class="value">{{weather.humidity}}</text><text class="sub">%</text></div>
              <text class="label">湿度</text>
            </div>
            <div class="item column center">
              <div><text class="value">{{weather.vis}}</text><text class="sub">km</text></div>
              <text class="label">能见度</text>
            </div>
          </div>
        </div>
        <!-- 底部更新时间 -->
        <div class="footer center">
          <text class="update-time">数据更新于 {{weather.obsTime}}</text>
        </div>
      </div>
    </template>
    

## [#](<#列表渲染>) 列表渲染

在未来3天天气预报页面中，使用到了数组存储未来3天的天气数据。可以使用`for`指令来渲染（详细的`for`指令用法，请参考[列表渲染](</vela/quickapp/zh/guide/framework/template/for.html>)）。

数据定义为：
    
    
    {
      list: [
        {
          "fxDate": "周日",
          "tempMax": "12",
          "tempMin": "-1",
          "iconDay": "101",
          "textDay": "多云",
        },
        {
          "fxDate": "周一",
          "tempMax": "13",
          "tempMin": "0",
          "iconDay": "100",
          "textDay": "晴"
        },
        {
          "fxDate": "周二",
          "tempMax": "13",
          "tempMin": "0",
          "iconDay": "302",
          "textDay": "晴",
          "iconNight": "150",
          "textNight": "晴"
        }
      ]
    }
    

模板代码：
    
    
    <!-- 未来3天天气 -->
    <div class="list row">
      <div class="item column center" for="{{list}}">
        <text class="date">{{$item.fxDate}}</text>
        <image class="icon" src="/common/icons/{{$item.iconDay}}.png"></image>
        <text class="temp">{{$item.tempMin}}°~{{$item.tempMax}}°</text>
      </div>
    </div>
    

运行结果：  
![列表渲染结果](/vela/quickapp/images/guide/ui-for-list-result.png)

### [#](<#条件渲染>) 条件渲染

实际项目中经常会需要使用到条件判断，根据不同的条件渲染不同的UI。要使用条件渲染，请参考[条件指令](</vela/quickapp/zh/guide/framework/template/if.html>)。

---

## #项目结构

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/project-structure.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/project-structure.html)

# [#](<#项目结构>) 项目结构

## [#](<#应用资源>) 应用资源

一个应用包含：描述项目配置信息的 [manifest 文件](</vela/quickapp/zh/guide/framework/manifest.html>)，放置项目公共资源脚本的 [app.ux 文件](</vela/quickapp/zh/guide/framework/ux.html>)，以及多个描述页面的 [ux 文件](</vela/quickapp/zh/guide/framework/ux.html>)。应用的源码统一放在 `src/` 目录下，典型结构如下：
    
    
    src/
    ├── manifest.json
    ├── app.ux
    ├── pages
    │   ├── index
    |   |   └── index.ux
    │   └── detail
    |       └── detail.ux
    ├── i18n
    |   ├── defaults.json
    |   ├── zh-CN.json
    |   └── en-US.json
    └── common
        ├── style.css
        ├── utils.js
        └── logo.png
    

提示

完整的项目目录结构（含 build、dist、sign 等）请参考[项目概览](</vela/quickapp/zh/guide/start/project-overview.html>)。

## [#](<#ux-模板>) ux 模板

一个页面通常由三部分组成：页面结构、样式和逻辑交互。这三部分可以放在一个 ux 文件中，也可以作为独立的文件。

如果放在一个 ux 文件中，则需要包含 `template`、`style` 和 `script` 三个标签：
    
    
    <template>
      <div class="page">
        <text class="title">欢迎打开{{title}}</text>
        <input class="btn" type="button" value="跳转到详情页" onclick="routeDetail">
      </div>
    </template>
    
    <style>
      .btn {
        width: 400px;
        height: 60px;
        background-color: #09ba07;
        color: #ffffff;
      }
    </style>
    
    <script>
      import router from '@system.router'
    
      export default {
        private: {
          title: '示例页面'
        },
        routeDetail() {
          router.push({
            uri: '/pages/detail'
          })
        }
      }
    </script>
    

如果将页面结构、样式和逻辑交互拆分为独立文件，目录结构如下：
    
    
    ├── pages
    │   └── detail
    |       ├── detail.ux
    |       ├── detail.css
    |       └── detail.js
    

说明

拆分为独立文件后，ux 文件中不能包含 `template` 标签。

## [#](<#文件存储>) 文件存储

在应用平台中按分区存储文件，目前支持以下分区：

  1. **Cache** ：用于存储缓存文件，如通过 fetch 接口下载的文件。该分区中的文件可能因存储空间不足被系统删除。
  2. **Files** ：用于存储较小的永久文件，由应用自行管理。
  3. **Mass** ：用于存储较大的文件，但该分区不保证一直可用。
  4. **Temp** ：从外部映射的临时文件，只读，只能通过特定 API 获取（如 file.readText）。应用重启后无法访问，需重新获取。


另外，应用资源也作为一个特殊的只读分区进行处理。

## [#](<#uri>) URI

URI 用于标识应用资源和文件，[组件](</vela/quickapp/zh/components/>)和[接口](</vela/quickapp/zh/features/>)通过 URI 来访问应用资源和文件。

资源类型 | URI | 只读 | 示例 | 说明  
---|---|---|---|---  
应用资源 | /path | 是 | /Common/header.png | -  
Cache | internal://cache/path | 否 | internal://cache/fetch-123456.png | -  
Files | internal://files/path | 否 | internal://files/image/demo.png | -  
Mass | internal://mass/path | 否 | internal://mass/video/demo.mp4 | -  
Temp | internal://tmp/path | 是 | internal://tmp/xxxxx | 由系统动态生成  
  
URI 允许的字符是 `0-9a-zA-Z_-./%:`（不包含引号），URI 中不能出现 `..`，目录由斜线 `/` 分隔。

internal URI 表示应用私有文件，无需指定应用标识，同一个 internal URI 对于不同应用会指向不同的文件。

## [#](<#资源和文件访问规则>) 资源和文件访问规则

应用资源路径分为绝对路径和相对路径：以 `/` 开头的为绝对路径（如 `/Common/a.png`），否则为相对路径（如 `a.png`、`../Common/a.png`）。

应用资源文件分为代码文件（.js/.css/.ux）和资源文件（图片、视频等），访问规则如下：

  1. 导入其他代码文件时，使用相对路径，如：`../Common/component.ux`；
  2. 引用资源文件时，一般使用相对路径，如：`./abc.png`；
  3. 当代码文件被其他文件导入时，如果两者不在同一目录，被导入文件中引用的资源必须使用绝对路径（因为编译时被导入文件会被复制到导入文件所在目录，相对路径会失效）。例如 `a.css` 被 `b.ux` 导入，若不在同一目录，`a.css` 中必须写 `/Common/abc.png`；
  4. 在 CSS 中使用 `url(PATH)` 访问资源文件，如：`url(/Common/abc.png)`。

---

## #UX 文件

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/ux.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/ux.html)

# [#](<#ux-文件>) UX 文件

APP，页面均通过 ux 后缀文件编写，ux 后缀文件由[template 模板](</vela/quickapp/zh/guide/framework/template/>)、[style 样式](</vela/quickapp/zh/guide/framework/style/>)和[script 脚本](</vela/quickapp/zh/guide/framework/script/>)3 个部分组成，一个典型的页面 ux 后缀文件示例如下：
    
    
    <template>
      <!-- template里只能有一个根节点 -->
      <div class="page">
        <text class="title">欢迎打开{{title}}</text>
        <!-- 点击跳转详情页 -->
        <input class="btn" type="button" value="跳转到详情页" onclick="routeDetail">
      </div>
    </template>
    
    <style>
      .page {
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
    
      .title {
        font-size: 30px;
        text-align: center;
      }
    
      .btn {
        width: 400px;
        height: 60px;
        margin-top: 75px;
        border-radius: 43px;
        background-color: #09ba07;
        font-size: 30px;
        color: #ffffff;
      }
    </style>
    
    <script>
      import router from '@system.router'
    
      export default {
        // 页面级组件的数据模型，影响传入数据的覆盖机制：private内定义的属性不允许被覆盖
        private: {
          title: '示例页面'
        },
        routeDetail () {
          // 跳转到应用内的某个页面，router用法详见：文档->接口->页面路由
          router.push ({
            uri: '/DemoDetail'
          })
        }
      }
    </script>
    

## [#](<#app-ux>) app.ux

当前`app.ux`编译后会包含`manifest配置信息`（可以在`npm run build`之后查看文件内容），所以请不要删除`/**manifest**/`的注释内容标识。

您可以在`<script>`中引入一些公共的脚本，并暴露在当前 app 的对象上，如下所示，然后就可以在页面 ux 文件的 ViewModel 中，通过`this.$app.$def.util`访问。
    
    
    <script>
      /**
       * 应用级别的配置，供所有页面公用
       */
      import util from './util'
    
      export default {
        showMenu: util.showMenu,
        createShortcut: util.createShortcut,
        util
      }
    </script>

---

## #项目配置

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/manifest.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/manifest.html)

# [#](<#项目配置>) 项目配置

`manifest.json`文件中包含了应用描述、接口声明、页面路由信息。

## [#](<#manifest>) manifest

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
package | String | - | 是 | 应用包名，**确认与原生应用的包名不一致** ，推荐采用 com.company.module 的格式，如：com.example.demo  
name | String | - | 是 | 应用名称，**6 个汉字以内，与应用商店保存的名称一致** ，用于在桌面图标、弹窗等处显示应用名称  
icon | String | - | 是 | 应用图标，提供 192x192 大小的即可  
versionName | String | - | 否 | 应用版本名称，如："1.0"  
versionCode | Integer | - | 是 | 应用版本号，从`1`自增，**推荐每次重新上传包时`versionCode`+1**  
minAPILevel | Integer | 1 | 否 | 支持的最小 API 标准版本号，**兼容性检查，避免上线后在低版本平台运行并导致不兼容** ；如果不填按照内测版本处理  
features | Array | - | 否 | 接口列表，绝大部分接口都需要在这里声明，否则不能调用，详见每个接口的文档说明  
config | Object | - | 是 | 系统配置信息，详见下面说明  
router | Object | - | 是 | 路由信息，详见下面说明  
display | Object | - | 否 | UI 显示相关配置，详见下面说明  
deviceTypeList | Array<String> | watch | 否 | 可选值有：watch、tv、car、phone，现只支持watch  
permissions | Array | - | 否 | 权限申请，示例：[{ "name": "hapjs.permission.LOCATION" }]  
  
### [#](<#config>) config

用于定义系统配置和全局数据。

属性 | 类型 | 默认值 | 描述  
---|---|---|---  
logLevel | String | log | 打印日志等级，分为 off、error、warn、info、log、debug  
designWidth | Integer | - | 页面设计基准宽度，根据实际设备宽度来缩放元素大小  
background | Object | - | 后台运行配置信息，可使用 features 字段申请需要在后台使用的接口（同时仍需在最外层的 features 字段中声明）。可申请的接口为：  
system.audio   
system.geolocation   
system.request 等   
详细用法参见 [后台运行](</vela/quickapp/zh/guide/framework/other/background-running.html>) 脚本  
  
### [#](<#minapilevel>) minAPILevel

支持的最小 API 标准版本号，标识开发者的 rpk 包能兼容运行在最小实现了该版本 API 标准的设备上，其值默认为1。当使用了 1 及以上的 API 标准版本新增特性时，就必须确保 minAPILevel 最低为该版本号，避免上线后在实现了更低版本 API 标准的设备上运行出错。

示例如下：
    
    
    {
      "minAPILevel": 1
    }
    

### [#](<#router>) router

用于定义页面的组成和相关配置信息，如果页面没有配置路由信息，则在编译打包时跳过。

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
entry | String | - | 是 | 首页名称，使用分包功能时，建议将首页定义在基础包  
pages | Object | - | 是 | 页面配置列表，key 值为页面名称（对应页面目录名，例如 Hello 对应'Hello'目录），value 为页面详细配置 page，详见下面说明  
  
示例代码：
    
    
    "router": {
      "entry": "Demo",
      "pages": {
        "Demo": {
          "component": "index"
        }
      }
    }
    

#### [#](<#router-pages>) router.pages

用于定义单个页面路由信息。

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
component | String | - | 是 | 页面对应的组件名，与 ux 文件名保持一致，例如"hello" 对应 "hello.ux"  
path | String | /<页面名称> | 否 | 页面路径，例如"/user",不填则默认为/<页面名称>  
path 必须唯一，不能和其他 page 的 path 相同  
下面 page 的 path 因为缺失，会被设置为"/Index"：  
`"Index": {"component": "index"}`  
launchMode | String | standard | 否 | 声明页面的启动模式，支持"singleTask"，"standard"两种页面启动模式  
标识为"singleTask"模式时每次打开目标页面都会打开已有的目标页面并回调 onRefresh 生命周期函数，清除该页面上打开的其他页面，没有打开过此页面时会创建新的目标页面实例  
标识为"standard"模式时会每次打开新的目标页面（多次打开目标页面地址时会存在多个相同页面）  
  
### [#](<#示例代码>) 示例代码
    
    
    {
      "package": "com.company.unit",
      "name": "appName",
      "icon": "/Common/icon.png",
      "versionName": "1.0",
      "versionCode": 1,
      "minPlatformVersion": 1000,
      "features": [{ "name": "system.network" }],
      "router": {
        "entry": "Hello",
        "pages": {
          "Hello": {
            "component": "hello",
            "path": "/"
          }
        }
      }
    }
    

### [#](<#display>) display

用于定义与 UI 显示相关的配置。

如果在 display 对象下定义以下属性值，则生效范围为此JS 应用全部页面；

属性 | 类型 | 默认值 | 描述  
---|---|---|---  
backgroundColor | String | #ffffff | 窗口背景颜色  
  
### [#](<#权限说明>) 权限说明

权限名 | feature | api | 描述 | 权限错误码  
---|---|---|---|---  
hapjs.permission.LOCATION | system.geolocation | getLocation   
subscribe   
unsubscribe | 地理位置 | 400： 拒绝授予权限   
402： 权限错误（未声明该权限）  
hapjs.permission.DEVICE_INFO | system.device | getSerial   
getDeviceId | 获取设备信息 | 400： 拒绝授予权限   
402： 权限错误（未声明该权限）

---

## #页面切换

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/page-switch.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/page-switch.html)

# [#](<#页面切换>) 页面切换

## [#](<#通过接口-router-切换页面和传递参数>) 通过接口 router 切换页面和传递参数

### [#](<#切换页面>) 切换页面

router 接口在使用前，需要先导入模块。

通过`router.push(OBJECT)`可以完成页面切换，其支持的参数`uri`的格式详细描述参见[页面路由](</vela/quickapp/zh/features/basic/router.html>)。

**示例如下：**
    
    
    <template>
      <div class="page">
        <input class="btn" type="button" value="跳转到新页面" onclick="routePage"></input>
      </div>
    </template>
    
    <style>
      .page {
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
      .btn {
        width: 400px;
        height: 60px;
        margin-top: 70px;
        border-radius: 30px;
        background-color: #09ba07;
        font-size: 30px;
        color: #ffffff;
      }
    </style>
    
    <script>
      // 导入模块
      import router from '@system.router'
    
      export default {
        routePage () {
          // 跳转到应用内的某个页面，当前页面无法返回
          router.replace({
            uri: '/Pages/newPage'
          })
        }
      }
    </script>
    

### [#](<#传递参数>) 传递参数

`router`接口的参数`params`可配置页面跳转时需要传递的参数。

**示例如下：**
    
    
    <template>
      <div class="page">
        <input class="btn" type="button" value="携带参数跳转页面" onclick="routePageReplaceWithParams"></input>
      </div>
    </template>
    
    <style>
      .page {
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
      .btn {
        width: 400px;
        height: 60px;
        margin-top: 70px;
        border-radius: 30px;
        background-color: #09ba07;
        font-size: 30px;
        color: #ffffff;
      }
    </style>
    
    <script>
      // 导入模块
      import router from '@system.router'
    
      export default {
        private: {
          title: 'Hello, world!'
        },
    
        onInit () {
          console.info('接口router切换页面并传递参数')
        },
    
        routePageReplaceWithParams () {
          // 跳转到应用内的某个页面
          router.replace({
            uri: '/PageParams/receiveparams',
            params: { key: this.title }
          })
        }
      }
    </script>
    

## [#](<#接收参数>) 接收参数

现在，开发者已经了解了通过接口`router`在页面之间传递参数的方法，如何接收参数呢？

其实很简单，接口`router`传递的参数的接收方法完全一致：在页面的 ViewModel 的`protected`属性中声明使用的属性。

注意

  * `protected`内定义的属性，允许被应用内部页面请求传递的数据覆盖，不允许被应用外部请求传递的数据覆盖
  * 若希望参数允许被应用外部请求传递的数据覆盖，请在页面的 ViewModel 的`public`属性中声明使用的属性


**示例如下：**
    
    
    <template>
      <div class="page">
        <text>page</text>
        <!-- template中显示页面传递的参数 -->
        <text>{{key}}</text>
      </div>
    </template>
    
    <style>
      .page {
        flex-direction: column;
        justify-content: center;
        align-items: center;
      }
    </style>
    
    <script>
      export default {
        protected: {
          key: ''
        },
        onInit () {
          // js中输出页面传递的参数
          console.info('key: ' + this.key)
        }
      }
    </script>

---

## #组件

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/template/component.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/template/component.html)

# [#](<#组件>) 组件

## [#](<#组件自定义>) 组件自定义

开发页面时开发者必须用到 Native 组件，如：`text`、`div`，这些组件是由各平台 Native 底层渲染出来的；如果开发一个复杂的页面，开发者把所有的 UI 部分写在一个文件的`<template>`，那代码的可维护性将会很低，并且模块之间容易产生不必要的耦合关系。

为了更好的组织逻辑与代码，可以把页面按照功能拆成多个模块，每个模块负责其中的一个功能部分，最后页面将这些模块引入管理起来，传递业务与配置数据完成代码分离，那么这就是自定义组件的意义。

自定义组件是一个开发者编写的组件，使用起来和 Native 一样，最终按照组件的`<template>`来渲染；同时开发起来又和页面一样，拥有 ViewModel 实现对数据、事件、方法的管理。

提示

由于自定义组件拥有独立的ViewModel，因此存在一定内存开销，在手表手环等轻量级设备上不建议使用。

**示例如下：**
    
    
    <template>
      <div class="tutorial-page">
        <text class="tutorial-title">自定义组件:</text>
        <text>{{ say }}</text>
        <text>{{ obj.name }}</text>
      </div>
    </template>
    
    <style lang="less">
      .tutorial-page {
        flex-direction: column;
        padding-top: 20px;
    
        .tutorial-title {
          font-weight: bold;
        }
      }
    </style>
    
    <script>
      // 子组件
      export default {
        data: {
          say: 'hello',
          obj: {
            name: 'quickApp'
          }
        },
        onInit() {
          console.log('我是子组件')
        }
      }
    </script>
    

自定义组件中数据模型只能使用**data 属性** ，data 类型是 **Object** 。

### [#](<#自定义组件生命周期>) 自定义组件生命周期：

`onInit` ：表示组件ViewModel的数据已经准备好，可以开始使用页面中的数据。

`onReady` ：表示组件ViewModel的模板已经编译完成，可以开始获取 DOM 节点。

`onDestroy` ：组件被销毁时调用，组件销毁时应该做一些释放资源的操作，例如释放定时器等。

## [#](<#组件引入>) 组件引入

vela中是通过`<import>`标签引入组件，如下面代码所示：
    
    
    <import name="XXX" src="XXX"></import>
    

`<import>`标签中的`src`属性指定自定义组件的地址，`name`属性指定在父组件中引用该组件时使用的 **标签名称** 。

**示例如下：**
    
    
    <import name="comp-part1" src="./part1"></import>
    
    <template>
      <div class="tutorial-page">
        <text class="tutorial-title">引入组件：</text>
        <comp-part1></comp-part1>
      </div>
    </template>
    
    <style lang="less">
      .tutorial-page {
        flex-direction: column;
        padding: 20px 10px;
      }
      .tutorial-title {
          font-weight: bold;
      }
    </style>
    
    <script>
      // 父组件
      export default {
        private: {},
        onInit() {
          console.log('引入组件')
        }
      }
    </script>
    

## [#](<#父子组件通信>) 父子组件通信

### [#](<#父组件通过-prop-向子组件传递数据>) 父组件通过 Prop 向子组件传递数据

父组件向子组件传递数据，通过在子组件的`props`属性中声明对外暴露的属性名称，然后在组件引用标签上声明传递的父组件数据，详见[Props](</vela/quickapp/zh/guide/framework/template/Props.html>)部分。

**示例如下：**
    
    
    <!-- 子组件 -->
    <template>
      <div class="child-demo">
        <text class="title">子组件:</text>
        <text>{{ say }}</text>
        <text>{{ propObject.name }}</text>
      </div>
    </template>
    <script>
      export default {
        props: ['say', 'propObject'],
        onInit() {
          console.info(`外部传递的数据：`, this.say, this.propObject)
        }
      }
    </script>
    
    
    
    <!-- 父组件 -->
    <import name="comp" src="./comp"></import>
    <template>
      <div class="parent-demo">
        <comp say="{{say}}" prop-object="{{obj}}"></comp>
      </div>
    </template>
    <script>
      export default {
        private: {
          say:'hello'
          obj:{
            name:'child-demo'
          }
        }
      }
    </script>
    

### [#](<#子组件对父组件通信>) 子组件对父组件通信

  * 子组件通过`$emit()`触发在节点上绑定的自定义事件来执行父组件的方法，如父组件与组件一；
  * 子组件通过`$dispatch()`触发自定义事件，父组件通过`$on()`监控自定义事件的触发，如父组件与组件二；


**示例如下：**
    
    
     <!-- 父组件 -->
    <import name="comp1" src="./comp1.ux"></import>
    <import name="comp2" src="./comp2.ux"></import>
    <import name="comp3" src="./comp3.ux"></import>
    <template>
      <div class="parent-demo">
        <text>我是父组件count:{{count}}</text>
        <comp1 count="{{count}}" onemit-evt="emitEvt"></comp1>
    
        <text>我是父组件num:{{num}}</text>
        <comp2 num="{{num}}"></comp2>
    
        <text>我是父组件age:{{age}}</text>
        <input type="button" onclick="evtTypeEmit" value="触发$broadcast()"></input>
        <comp3></comp3>
      </div>
    </template>
    
    <script>
      export default {
        private:{
          count:20,
          num:20,
          age:18
        },
        onInit(){
          this.$on('dispatchEvt',this.dispatchEvt)
        },
        emitEvt(evt){
          this.count = evt.detail.count
        },
        dispatchEvt(evt){
          this.num = evt.detail.num
        },
        evtTypeEmit(){
          this.$broadcast('broadevt',{
            age:19
          })
        },
      }
    </script>
    
    
    
    <!-- comp1 -->
    <template>
      <div class="child-demo">
        <text>我是子组件一count:{{compCount}}</text>
        <input type="button" onclick='addHandler' value='add'></input>
      </div>
    </template>
    <script>
      export default {
        props: ['count'],
        data: {
          compCount:this.count
        },
        addHandler(){
          this.compCount ++
          this.$emit('emitEvt',{
            count:this.compCount
          })
        },
      }
    </script>
    
    
    
    <!-- comp2 -->
    <template>
      <div class="child-demo">
        <text>我是子组件二num:{{compNum}}</text>
        <input type="button" onclick='delHandler' value='del'></input>
      </div>
    </template>
    <script>
      export default {
        props: ['num'],
        data: {
          compNum:this.num
        },
        delHandler(){
          this.compNum --
          this.$dispatch('dispatchEvt',{
            num:this.compNum
          })
        },
      }
    </script>
    
    
    
    <!-- comp3 -->
    <template>
      <div class="child-demo">
        <text>我是子组件三age:{{compAge}}</text>
      </div>
    </template>
    <script>
      export default {
        props:[],
        data: {
          compAge: null
        },
        onInit(){
          this.$on('broadevt',this.broadevt)
        },
        broadevt(evt){
          this.compAge = evt.detail.age
        }
      }
    </script>
    

框架向开发者提供了双向的事件传递

  * 向下传递：父组件触发，子组件响应；调用`parentVm.$broadcast()`完成向下传递，如：broadevt
  * 向上传递：子组件触发，父组件响应；调用`childVm.$dispatch()`完成向上传递，如：dispatchEvt


**提示：**

  * 触发时传递参数，再接收时使用`evt.detail`来获取参数
  * 当传递结束后，可以调用`evt.stop()`来结束传递,否则会一直传递下去

---

## #生命周期

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/script/lifecycle.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/script/lifecycle.html)

# [#](<#生命周期>) 生命周期

  * [页面的生命周期](<#%E9%A1%B5%E9%9D%A2%E7%9A%84%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F>)：`onInit`、`onReady`、`onShow`、`onHide`、`onDestroy`、`onBackPress`、`onRefresh`、`onConfigurationChanged`
  * 页面的状态：`显示`、`隐藏`、`销毁`
  * [APP 的生命周期](<#app%E7%9A%84%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F>)：`onCreate`、`onShow`、`onHide`、`onDestroy` 、`onError`


## [#](<#生命周期图>) 生命周期图

![生命周期图](/vela/quickapp/images/components/life.png)

## [#](<#页面的生命周期>) 页面的生命周期

由于页面通过`ViewModel`渲染，那么页面的生命周期指的也就是`ViewModel`的生命周期，包括常见的：onInit, onReady, onShow 在**页面创建** 时触发调用。

### [#](<#oninit>) onInit()

**表示`ViewModel`的数据已经准备好**，可以开始使用页面中的数据。

**示例如下：**
    
    
    private: {
      // 生命周期的文本列表
      lcList: []
    },
    onInit () {
      this.lcList.push('onInit')
    
      console.info(`触发：onInit`)
      // 执行：获取ViewModel的lcList属性：onInit
      console.info(`执行：获取ViewModel的lcList属性：${this.lcList}`)
      // $app信息
      console.info(`获取：manifest.json的config.data的数据：${this.$app.$data.name}`)
      console.info(`获取：APP文件中的数据：${this.$app.$def.data1.name}`)
      console.info(`执行：APP文件中的方法`, this.$app.$def.method1())
    }
    

### [#](<#onready>) onReady()

**表示`ViewModel`的模板已经编译完成**，可以开始获取 DOM 节点（如：`this.$element(idxxx)`）。

**示例如下：**
    
    
    onReady () {
      this.lcList.push('onReady')
      console.info(`触发：onReady`)
    }
    

### [#](<#onshow-onhide>) onShow(), onHide()

APP 中可以同时运行多个页面，但是**每次只能显示其中一个页面** ；这点不同于纯前端开发，浏览器页面中每次只能有一个页面，当前页面打开另一个页面，上个页面就销毁了；不过和 SPA 开发有点相似，切换页面但浏览器全局 Context 是共享的。

所以页面的切换，就产生了新的事件：页面被切换隐藏时调用 onHide()，页面被切换重新显示时调用 onShow()。

**示例如下：**
    
    
    onShow () {
      this.lcList.push('onShow')
      console.info(`触发：onShow`)
    },
    onHide () {
      this.lcList.push('onHide')
      console.info(`触发：onHide`)
    }
    

### [#](<#ondestroy>) onDestroy()

页面被销毁时调用，被销毁的可能原因有：用户从当前页面返回到上一页，或者用户打开了太多的页面，框架自动销毁掉部分页面，避免占用资源。

所以，页面销毁时应该做一些**释放资源** 的操作，如：取消接口订阅监听`geolocation.unsubscribe()`。

判断页面是否处于被销毁状态，可以调用 `ViewModel` 的 `$valid` 属性：`true` 表示存在，`false` 表示销毁。

**示例如下：**
    
    
    onDestroy () {
      console.info(`触发：onDestroy`)
      console.info(`执行：页面要被销毁，销毁状态：${this.$valid}，应该做取消接口订阅监听的操作: geolocation.unsubscribe() `) // true，即将销毁
      setTimeout(function () {
        // 页面已销毁，不会执行
        console.info(`执行：页面已被销毁，不会执行`)
      }.bind(this), 0)
    }
    

**提示：**

  * `setTimeout`之类的异步操作绑定在了当前页面上，因此当页面销毁之后异步调用不会执行。


### [#](<#onbackpress>) onBackPress()

当用户`右滑返回`或点击`返回实体按键`时触发该事件。

如果事件响应方法最后返回`true`表示不返回，自己处理业务逻辑（完毕后开发者自行调用 API 返回）；否则：不返回数据，或者返回其它数据，表示遵循系统逻辑：返回到上一页。

**示例如下：**
    
    
    onBackPress () {
      console.info(`触发：onBackPress`)
      // true：表示自己处理；否则默认返回上一页
      // return true
    }
    

### [#](<#onrefresh-query>) onRefresh(query)

监听页面重新打开。

1.当页面在 manifest 中 launchMode 标识为'singleTask'时，仅会存在一个目标页面实例，用户多次打开目标页面时触发此函数。  
2.打开目标页面时在 push 参数中携带 flag 'clearTask'，且页面实例已经存在时触发。该回调中参数为重新打开该页面时携带的参数，详见[页面启动模式](</vela/quickapp/zh/guide/framework/other/launch-mode.html>)。

**示例如下：**
    
    
    onRefresh(query) {
      // launchMode 为 singleTask 时，重新打开页面时携带的参数不会自动更新到页面 this 对象上
      // 需要在此处从 query 中拿到并手动更新
      console.log('page refreshed!!!')
    }
    

### [#](<#onconfigurationchanged-event>) onConfigurationChanged(event)

监听应用配置发生变化。当应用配置发生变化时触发，如系统语言改变。

**参数**

参数名 | 类型 | 描述  
---|---|---  
event | Object | 应用配置发生变化的事件  
  
**event参数**

参数名 | 类型 | 描述  
---|---|---  
type | String | 应用配置发生变化的原因类型，支持的 type 值如下所示  
  
**event 中 type 现在支持的参数值如下**

参数名 | 描述  
---|---  
locale | 应用配置因为语言、地区变化而发生改变  
  
**示例如下：**
    
    
    onConfigurationChanged(evt) {
      console.log(`触发生命周期onConfigurationChanged, 配置类型：${evt.type}`)
    }
    

## [#](<#app的生命周期>) APP的生命周期

当前为 APP 的生命周期提供了五个回调函数：onCreate()、onShow()、onHide()、onDestroy()、onError(e)。

**示例如下：**
    
    
    export default {
      // 监听应用创建,应用创建时调用
      onCreate() { 
        console.info('Application onCreate')
      },
      // 监听应用返回前台,应用返回前台时调用
      onShow() { 
        console.info('Application onShow')
      },
      // 监听应用退到后台,应用退到后台时调用
      onHide() { 
        console.info('Application onHide')
      },
      // 监听应用销毁,应用销毁时调用
      onDestroy() { 
        console.info('Application onDesteroy')
      },
      // 监听应用报错,应用捕获异常时调用,参数为Error对象。
      onError(e) {
        console.log('Application onError', e)
      },
      // 暴露给所有页面，在页面中通过：this.$app.$def.method1()访问
      method1() {
        console.info('这是APP的方法')
      },
      // 暴露给所有页面，在页面中通过：this.$app.$def.data1访问
      data1: {
        name: '这是APP存的数据'
      }
    }

---

## #页面数据对象

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/script/page-data.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/script/page-data.html)

# [#](<#页面数据对象>) 页面数据对象

属性 | 类型 | 描述  
---|---|---  
data | Object | 组件级的数据模型，属性名不能以$或_开头，不要使用 for, if, show, tid 等保留字  
public | Object | 页面级组件的数据模型，影响传入数据的覆盖机制：public 内定义的属性允许被传入的数据覆盖，如果外部传入数据的某个属性未被声明，在 public 中不会新增这个属性  
protected | Object | 页面级组件的数据模型，影响传入数据的覆盖机制：protected 内定义的属性，允许被应用内部页面请求传递的数据覆盖，不允许被应用外部请求传递的数据覆盖  
private | Object | 页面级组件的数据模型，影响传入数据的覆盖机制：private 内定义的属性不允许被覆盖  
computed | Object | 计算属性，属性名不能以$或_开头, 不要使用 for, if, show, tid 等保留字  
  
温馨提示

**注意 public，protected，private 不能与 data 同时使用。**

---

## #全局属性和方法

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/script/global-data-method.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/script/global-data-method.html)

# [#](<#全局属性和方法>) 全局属性和方法

## [#](<#对象>) 对象

### [#](<#公共对象>) 公共对象

属性 | 类型 | 描述  
---|---|---  
$app | Object | 应用对象  
$page | Object | 页面对象  
$valid | Boolean | 页面对象是否有效  
  
#### [#](<#应用对象>) 应用对象

在页面中可通过 $app 访问到全局应用对象。

在`app.ux`文件中，开发者可以定义全局可访问的数据和方法，在页面中通过`this.$app.$def`访问，在`app.ux`文件中，直接通过`this`访问。例如在`app.ux`文件中定义如下：
    
    
    <script>
    /**
     * 应用级别的配置，供所有页面公用
     */
    export default {
      data: {
        a: 1
      },
      func: function() {
        console.log(this.data.a)
        console.log(`function executed!`)
      }
    }
    </script>
    

在其他页面可以这样调用：
    
    
    this.$app.$def.data
    this.$app.$def.func()
    

可通过 $app 访问如下内置方法：

属性 | 类型 | 描述  
---|---|---  
exit | Function | 退出 JS 应用，结束应用生命周期。调用方法：this.$app.exit()  
  
#### [#](<#页面对象>) 页面对象

在页面中可通过this.$page访问到当前页面对象，该对象上可访问到如下属性：

属性 | 类型 | 描述  
---|---|---  
name | String | 获取当前页面路由的名称，与manifest 文件中router.pages 中对应的属性名一致  
path | String | 获取当前页面路由的 path，与manifest 文件中router.pages 中对应的 path 一致  
component | String | 获取当前页面路由的 component，与manifest 文件中router.pages 中对应的 component 一致  
  
## [#](<#方法>) 方法

### [#](<#this-caniuse>) this.$canIUse[3+](</vela/quickapp/zh/guide/version/APILevel3>)

在页面中可通过 this.$canIUse 进行可使用的能力查询，包括接口和组件。

#### [#](<#参数>) 参数:

类型 | 描述  
---|---  
String | 要查询的能力，格式见下方  
  
#### [#](<#返回值>) 返回值：

类型 | 描述  
---|---  
Boolean | 查询的能力是否支持  
  
#### [#](<#入参格式>) 入参格式

##### [#](<#查询接口>) 查询接口
    
    
    // 查询feature下的方法是否支持
    `@${featureName}.${method}`
    // 查询某个feature是否支持
    `@${featureName}`
    

**示例**
    
    
    if (this.$canIUse('@system.router.push')) {
      // 可以使用方法@system.router.push
    }
    if (this.$canIUse('@system.router')) {
      // 可以使用@system.router接口
    }
    

##### [#](<#查询组件>) 查询组件

type取值可以是`'attr'`、`'style'`、`'method'`，分别对应组件的属性、样式、方法。
    
    
    // 查询组件下的属性、样式、方法是否支持
    `${componentName}.${type}.${name}`
    // 查询组件是否支持
    `${componentName}`
    

**示例**
    
    
    if (this.$canIUse('scroll')) {
      // 可以使用scroll组件
    }
    if (this.$canIUse('scroll.attr.scroll-x')) {
      // 可以使用scroll组件的scroll-x属性
    }
    

### [#](<#this-watch>) this.$watch

监控数据改变。动态添加属性/事件绑定，属性必须在 data 中定义，handler 函数必须在`<script>`定义，当属性值发生变化时事件被触发。  
如果是监听对象中的属性，参数请使用.分割，如：$watch(xxx.xxx.xxx, methodName)。

#### [#](<#参数-2>) 参数

属性 | 类型 | 描述  
---|---|---  
data | String | 属性名，支持'a.b.c'格式，不支持数组索引  
handler | String | 事件句柄函数名，函数的第一个参数为新属性值，第二个参数为旧的属性值  
  
#### [#](<#代码示例>) 代码示例
    
    
    <script>
      export default {
        props: ['propObject'],
        data {
          say: '',
          propSay: ''
        },
        onInit() {
          // 监听数据变化
          this.$watch('say', 'watchDataChange')
          this.$watch('propObject.name', 'watchPropsChange')
        },
        /**
         * 监听数据变化，你可以对数据处理后，设置值到data上
         * @param newV
         * @param oldV
         */
        watchPropsChange(newV, oldV) {
          console.info(`监听数据变化：`, newV, oldV)
          this.propSay = newV && newV.toUpperCase()
        },
        watchDataChange(newV, oldV) {
          console.info(`监听数据变化：`, newV, oldV)
        }
      }
    </script>
    

### [#](<#this-element>) this.$element

获取指定 id 的组件 dom 对象，如果没有指定 id，则返回根组件 dom 对象。

#### [#](<#参数-3>) 参数

类型 | 描述  
---|---  
String | this.$element('idName')获取 dom 节点  
  
#### [#](<#代码示例-2>) 代码示例
    
    
    <template>
      <div>
        <div id='xxx'></div>
      </div>
    </template>
    
    <script>
      export default {
        onReady() {
          const el = this.$element('xxx')
          console.log(`输出xxx节点信息： ${el}`)
        }
      }
    </script>
    

this.$element('xxx') 获取 id 为 xxx 的 div 组件实例对象， this.$element() 获取模板中的根组件实例对象。

`id`属性赋值可以查看此[文档](</vela/quickapp/zh/components/general/properties.html>)。

### [#](<#this-nexttick>) this.$nextTick

在下次 DOM 更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，可以获取更新后DOM。

#### [#](<#参数-4>) 参数

类型 | 描述  
---|---  
Function | 回调函数中执行的是会对DOM进行操作的处理  
  
#### [#](<#代码示例-3>) 代码示例
    
    
    <template>
      <div class="page">
        <text @click="onAddClick">添加项目</text>
        <div class="list" id="list">
          <div class="item" for="{{list}}">
            <text>{{ $item }}</text>
          </div>
        </div>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          list: ["项目1", "项目2"]
        },
        onAddClick() {
          this.list.push(Math.random())
          // 更新数据后,DOM没有立即发生变化。
          this.$element("list").getBoundingClientRect({
            success: (rect) => {
              console.log("getBoundingClientRect.height=", rect.height)
            }
          })
          this.$nextTick(() => {
            // 更新数据后,DOM发生变化。
            this.$element("list").getBoundingClientRect({
              success: (rect) => {
                console.log("$nextTick getBoundingClientRect.height=", rect.height)
              }
            })
          })
        }
      }
    </script>
    <style>
      .page {
        padding-top: 20px;
        width: 100%;
        height: 100%;
        flex-direction: column;
        justify-content: flex-start;
        align-items: center;
      }
    
      .list {
        width: 200px;
        flex-direction: column;
        align-items: center;
        border: 2px solid red;
      }
    </style>
    

除了以上公共方法，还有this.$on、this.$off、this.$dispatch、this.$broadcast、this.$emit等事件方法用于父子组件通信。方法说明如下：

方法 | 参数 | 描述  
---|---|---  
this.$on | type: String 事件名  
handler: Function 事件句柄函数 | 添加事件处理句柄用法：this.$on('xxxx', this.fn)，fn 是在<script>中定义的函数  
this.$off | type: String 事件名  
handler: Function 事件句柄函数 | 删除事件处理句柄用法：this.$off('xxxx', this.fn) this.$off('xxx') 删除指定事件的所有处理句柄  
this.$dispatch | type: String 事件名 | 向上层组件发送事件通知用法：this.$dispatch('xxx')正常情况下，会一直向上传递事件（冒泡）如果要停止冒泡，在事件句柄函数中调用evt.stop()即可  
this.$broadcast | type: String 事件名 | 向子组件发送事件通知用法：this.$broadcast('xxx')正常情况下，会一直向下传递事件如果要停止传递，在事件句柄函数中调用evt.stop()即可  
this.$emit | type: String 事件名  
data: Object 事件参数 | 触发事件，对应的句柄函数被调用用法：this.$emit('xxx') this.$emit('xxx', {a:1})传递的事件参数可在事件回调函数中，通过evt.detail来访问，例如evt.detail.a  
  
事件方法使用示例可参考[文档](</vela/quickapp/zh/guide/framework/template/component.html#父子组件通信>)。

---

## #页面样式与布局

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/style/page-style-and-layout.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/style/page-style-and-layout.html)

# [#](<#页面样式与布局>) 页面样式与布局

## [#](<#盒模型>) 盒模型

JS 应用布局框架使用 border-box 模型，具体表现与宽高边距计算可参考 MDN 文档[box-sizing (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/box-sizing>)，暂不支持 content-box 模型与手动指定 box-sizing 属性。

![](/vela/quickapp/images/components/border-box.png)

布局所占宽度 Width：

`Width = width(包含padding-left + padding-right + border-left + border-right)`

布局所占高度 Height：

`Height = height(包含padding-top + padding-bottom + border-top + border-bottom)`

## [#](<#长度单位>) 长度单位

框架对长度单位的支持，支持长度单位`px`、`%`、`dp`。

### [#](<#px>) px

与传统 web 页面不同，`px`是相对于`项目配置基准宽度`的单位，已经适配了移动端屏幕，其原理类似于`rem`。

开发者只需按照设计稿确定框架样式中的 px 值即可。

首先，我们需要定义`项目配置基准宽度`，它是项目的配置文件（`<ProjectName>/src/manifest.json`）中`config.designWidth`的值，默认不填则为 480。

然后， `设计稿1px`与`框架样式1px`转换公式如下：
    
    
    设计稿1px / 设计稿基准宽度 = 框架样式1px / 项目配置基准宽度
    

**示例如下：**

若设计稿宽度为 640px，元素 A 在设计稿上的宽度为 100px，实现的两种方案如下：

**方案一：**

修改`项目配置基准宽度`：将`项目配置基准宽度`设置为`设计稿基准宽度`，则`框架样式1px`等于`设计稿1px`

  * 设置`项目配置基准宽度`，在项目的配置文件（`<ProjectName>/src/manifest.json`）中，修改`config.designWidth`：


    
    
    {
      "config": {
        "designWidth": 640
      }
    }
    

  * 设置元素 A 对应的框架样式：


    
    
    width: 100px;
    

**方案二：**

不修改`项目配置基准宽度`：若当前项目配置的`项目配置基准宽度`为 480，设元素 A 的框架样式 x`px`，由转换公式得：`100 / 640 = x / 480`。

  * 设置元素 A 对应的框架样式：


    
    
    width: 75px;
    

### [#](<#百分比>) 百分比%

JS 应用的百分比计算规则与 css 类似，可参考[MDN 文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/percentage>)。

### [#](<#dp>) dp[3+](</vela/quickapp/zh/guide/version/APILevel3>)

dp 单位，全称为 device independent pixels，即设备独立像素。

计算公式：dp 数值 = 物理分辨率 / 设备像素比(device pixel ratio)

举例：一个设备分辨率为 480*480，设备像素比 = 2，屏幕宽度 = 480 像素 = 240dp

示例代码：
    
    
    <style>
      .dp-box{
        width:360dp;
        height:360dp;
        background-color:green;
        margin-bottom:40px;
      }
    </style>
    

## [#](<#设置定位>) 设置定位

position 支持2种属性值：relative、absolute，并且默认值为 relative，可以参考[MDN 文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/position>)。

## [#](<#设置样式>) 设置样式

开发者可以使用`内联样式`、`tag选择器`、`class选择器`、`id选择器`来为组件设置样式

同时也可以使用`并列选择`设置样式，暂时不支持`后代选择器`。

详细的文档可以查看[此处](</vela/quickapp/zh/guide/framework/style/>)。

**示例如下：**
    
    
    <template>
      <div class="page">
        <text style="color: #FF0000;">内联样式</text>
        <text id="title">ID选择器</text>
        <text class="title">class选择器</text>
        <text>tag选择器</text>
      </div>
    </template>
    
    <style>
      .page {
        flex-direction: column;
      }
      /* tag选择器 */
      text {
        color: #0000FF;
      }
      /* class选择器（推荐） */
      .title {
        color: #00FF00;
      }
      /* ID选择器 */
      #title {
        color: #00A000;
      }
      /* 并列选择 */
      .title, #title {
        font-weight: bold;
      }
    
    </style>
    

## [#](<#通用样式>) 通用样式

通用样式如 margin，padding 等属性可以点击[此处](</vela/quickapp/zh/components/general/style.html>)查询。

## [#](<#flex-布局示例>) Flex 布局示例

框架使用`Flex布局`，关于`Flex布局`可以参考外部文档[A Complete Guide to Flexbox (opens new window)](<https://css-tricks.com/snippets/css/a-guide-to-flexbox/>)。

`Flex布局`的支持也可以在官网文档的[通用样式](</vela/quickapp/zh/components/general/style.html>)查询。

div 组件为最常用的 Flex 容器组件，具有 Flex 布局的特性；text、span组件为文本容器组件，**其它组件不能直接放置文本内容** 。

**示例如下：**
    
    
    <template>
      <div class="page">
        <div class="item">
          <text>item1</text>
        </div>
        <div class="item">
          <text>item2</text>
        </div>
      </div>
    </template>
    
    <style>
      .page {
        /* 交叉轴居中 */
        align-items: center;
        /* 纵向排列 */
        flex-direction: column;
      }
      .item {
        /* 有剩余空间时，允许被拉伸 */
        /*flex-grow: 1;*/
        /* 空间不够用时，不允许被压缩 */
        flex-shrink: 0;
        /* 主轴居中 */
        justify-content: center;
        width: 200px;
        height: 100px;
        margin: 10px;
        background-color: #FF0000;
      }
    </style>
    

## [#](<#动态修改样式>) 动态修改样式

动态修改样式有多种方式，与传统前端开发习惯一致，包括但不限于以下：

  * **修改 class** ：更新组件的 class 属性中使用的变量的值
  * **修改内联 style** ：更新组件的 style 属性中的某个 CSS 的值
  * **修改绑定的对象** ：通过绑定的对象控制元素的样式 


**示例如下：**
    
    
    <template>
      <div style="flex-direction: column;">
        <!-- 修改 class -->
        <text class="normal-text {{ className }}" onclick="changeClassName">点击我修改文字颜色</text>
        <!-- 修改内联 style -->
        <text style="color: {{ textColor }}" onclick="changeInlineStyle">点击我修改文字颜色</text>
        <!-- 修改绑定的对象 -->
        <text style="{{ styleObj }}" onclick="changeStyleObj">点击我修改文字颜色</text>
      </div>
    </template>
    
    <style>
      .normal-text {
        font-weight: bold;
      }
      .text-blue {
        color: #0faeff;
      }
      .text-red {
        color: #f76160;
      }
    </style>
    
    <script>
      export default {
        private: {
          className: 'text-blue',
          textColor: '#0faeff',
          styleObj: {
            color: 'red'
          }
        },
        onInit () {
          console.info('动态修改样式')
        },
        changeClassName () {
          this.className = 'text-red'
        },
        changeInlineStyle () {
          this.textColor = '#f76160'
        },
        changeStyleObj () {
          this.styleObj = {
            color: 'yellow'
          }
        }
      }
    </script>
    

## [#](<#引入-less-scss-预编译>) 引入 less/scss 预编译

### [#](<#less-篇>) less 篇

less 语法入门请参考[less 中文官网 (opens new window)](<https://less.bootcss.com/>)。

使用 less 请先安装相应的类库：`less`、`less-loader`：
    
    
    npm i less less-loader
    

详见文档[样式语法 --> 样式预编译](</vela/quickapp/zh/guide/framework/style/#样式预编译>)；然后在`<style>`标签上添加属性`lang="less"` **示例如下：**
    
    
    <template>
      <div class="page">
        <text id="title">less示例!</text>
      </div>
    </template>
    <style lang="less">
      /* 引入外部less文件 */
      @import './style.less';
      /* 使用less */
    </style>
    

### [#](<#scss-篇>) scss 篇

scss 语法入门请参考[scss 中文官网 (opens new window)](<https://www.sasscss.com/>)。

使用 scss 请在JS 应用项目下执行以下命令安装相应的类库：`node-sass`、`sass-loader`：
    
    
    npm i node-sass sass-loader
    

详见文档[style 样式 --> 样式预编译](</vela/quickapp/zh/guide/framework/style/#样式预编译>)；然后在`<style>`标签上添加属性`lang="scss"`。 **示例如下：**
    
    
    <template>
      <div class="page">
        <text id="title">less示例!</text>
      </div>
    </template>
    
    <style lang="scss">
      /* 引入外部scss文件 */
      @import './style.scss';
      /* 使用scss */
    </style>
    

## [#](<#使用-postcss-解析-css>) 使用 postcss 解析 css

JS 应用支持 postcss 来解析 css，postcss 可以采用类似 less，sass 的语法来解析 css 了，比如支持变量，嵌套，定义函数等功能了。

使用 postcss 解析 css 分为 3 个步骤：

1.安装对应的 loader：

> npm i postcss-loader precss@3.1.2 -D

2.在项目的根目录新建一个 postcss.config.js，增加如下内容：
    
    
    module.exports = {
      plugins: [require('precss')]
    }
    

其中 precss 为 postcss 的插件。

3.在页面对应的 style 标签上增加 lang="postcss"，如下：
    
    
    <style lang="postcss">
      /* 使用postcss */
      .page {
        justify-content: center;
        background-color: #00beaf;
      }
      
      #title {
        color: #FF0000;
      }
    </style>
    

这样就可以在 css 里面书写对应的代码了。

说明

如果想支持更多的语法格式，可以在 postcss.config.js 文件里面添加更多的插件，关于 postcss 的插件见[插件地址 (opens new window)](<https://github.com/postcss/postcss/blob/master/docs/plugins.md>)。

---

## #媒体查询2+

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/style/media-query.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/style/media-query.html)

# [#](<#媒体查询>) 媒体查询[2+](</vela/quickapp/zh/guide/version/APILevel2>)

通过媒体查询(media query)，开发者可以根据各种设备特征和参数的值或者是否存在来调整JS 应用的样式。

媒体查询是响应式设计的一部分。和 css 类似，可使用 @media at-rule 根据媒体查询的结果，有条件地应用样式表的一部分；也可使用 @import 有条件地应用整个样式表。

aiot-toolkit最低版本：1.1.3

## [#](<#语法>) 语法

每条媒体查询语句都由一个可选的媒体类型和任意数量的媒体特性表达式构成，可以使用多种逻辑操作符合并多条媒体查询语句，媒体查询语句不区分大小写。

有两种方法可以执行媒体查询：

### [#](<#media-方式引入媒体查询>) @media 方式引入媒体查询
    
    
    @media [media type] [and|not|only] [(media feature)] {
      CSS-Code;
    }
    

### [#](<#举例>) 举例

  * @media (max-width: 30) { ... } // level3的写法。
  * @media (width <= 30) { ... } // level4的写法，比level3更清晰简洁。
  * @media screen and (min-width: 400) and (max-width: 700) { ... } // 多条件写法。
  * @media (400 <= width <= 700) { ... } // 多条件level4写法。


### [#](<#import-方式引入媒体查询>) @import 方式引入媒体查询[3+](</vela/quickapp/zh/guide/version/APILevel3>)
    
    
    @import './css_file_name.css' [media type] [and|not|only] [(media feature) ];
    

## [#](<#媒体类型>) 媒体类型

媒体类型（Media types）描述设备的类别。除了在使用 not 或 only 逻辑操作符必须一并填上媒体类型；其他时候，媒体类型是可选择是否填入的。目前JS 应用支持的媒体类型如下：

媒体类型 | 简介  
---|---  
screen | 主要用于屏幕。  
  
## [#](<#媒体特性>) 媒体特性

媒体特性表达式是完全可选的，它负责测试这些特性或特征是否存在、值为多少。

每条媒体特性表达式都必须用括号括起来。

目前JS 应用支持的媒体特性如下：

类型 | 描述 | 查询时是否需带单位 | 支持单位  
---|---|---|---  
height[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域高度 | 否 | dp  
min-height[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域最小高度 | 否 | dp  
max-height[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域最大高度 | 否 | dp  
width[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域宽度 | 否 | dp  
min-width[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域最小宽度 | 否 | dp  
max-width[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可视区域最大宽度 | 否 | dp  
aspect-ratio[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可见区域宽高比，比例值需要按照 x / y 的格式，例如 1 / 2 | 否 | 无  
min-aspect-ratio[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可见区域最小宽高比，参数要求同上 | 否 | 无  
max-aspect-ratio[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 定义输出设备中的页面可见区域最大宽高比，参数要求同上 | 否 | 无  
device-type[3+](</vela/quickapp/zh/guide/version/APILevel3>) | device-type 的可选值为：watch、band、smartspeaker，默认值：watch | 否 | 无  
shape[2+](</vela/quickapp/zh/guide/version/APILevel2>) | 屏幕形状，可选值：circle、rect、pill-shaped[3+](</vela/quickapp/zh/guide/version/APILevel3>) | 否 | 无  
  
### [#](<#注意>) 注意

1.在媒体特性列表中，标记了“查询时不带单位”的媒体特性，如 width、height 的查询，都不带长度单位，且长度单位只能为dp

dp 数值 = 物理分辨率 / 设备像素比(device pixel ratio)

举例：一个设备分辨率为 480*480，设备像素比 = 2，屏幕宽度 = 480 像素 = 240dp

各设备数据参考

设备类型 | 设备型号 | 屏幕形状 | 屏幕尺寸 | 分辨率 | PPI | DPR | 水平DP值  
---|---|---|---|---|---|---|---  
手表 | Xiaomi Watch S1 Pro | 圆形 | 1.47英寸 | 480x480 | 326 | 2.0 | 240  
手表 | Xiaomi Watch H1 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0 | 233  
手表 | Xiaomi Watch S3 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0 | 233  
手表 | Xiaomi Watch S4 sport | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0 | 233  
手表 | Xiaomi Watch S4 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0 | 233  
手表 | REDMI Watch 5 | 矩形 | 2.07英寸 | 432x514 | 324 | 2.0 | 216  
手环 | 小米手环8 Pro | 矩形 | 1.74英寸 | 336x480 | 336 | 2.1 | 168  
手环 | 小米手环9 | 胶囊形 | 1.62英寸 | 192x490 | 325 | 2.0 | 96  
手环 | 小米手环9 Pro | 矩形 | 1.74英寸 | 336x480 | 336 | 2.1 | 168  
手环 | 小米手环10 | 胶囊形 | 1.725英寸 | 212x520 | 326 | 2.0 | 106  
手表 | Xiaomi Watch S5 | 圆形 | 1.485英寸 | 480x480 | 323 | 2.0 | 240  
  
示例代码：
    
    
    //以下media query会在屏幕宽度为80dp ~ 160dp范围设备上生效
    @media (min-width: 80) and (max-width: 160) {
      .box {
        background-color: green;
      }
    }
    
    //以下media query会在屏幕宽度为160dp ~ 200dp范围设备上生效
    @media (min-width: 160) and (max-width: 200) {
      .box {
        background-color: yellow;
      }
    }
    
    //以下media query会在屏幕宽度为200dp ~ 300dp范围设备上生效
    @media (min-width: 200) and (max-width: 300) {
      .box {
        background-color: red;
      }
    }
    

## [#](<#逻辑操作符>) 逻辑操作符[3+](</vela/quickapp/zh/guide/version/APILevel3>)

开发者可以使用逻辑操作符组合多个媒体特性的查询条件，编写复杂的媒体查询。

类型 | 描述  
---|---  
and | and 运算符用于将多个媒体特性组合到一个单独的媒体查询中，要求每个链接的特性返回 true，则此时查询为真  
not | not 运算符用于否定媒体查询，如果查询不返回 false，则返回 true。如果出现在逗号分隔的列表中，它只会否定应用它的特定查询。如果使用 not 运算符，则必须指定显式媒体类型。例如：not screen and (min-width: 400) and (max-width: 700)注：not 关键字不能用于否定单个功能表达式，它会作用于整个媒体查询  
only | only 运算符仅用于整个查询匹配应用样式，手表应用处理以 only 开头的关键词时将会忽略 only。如果使用 only 运算符，必须指定媒体类型。例如：only screen and (min-width: 400) and (max-width: 700)  
,(逗号) | 逗号分隔效果等同于 or 逻辑操作符。当使用逗号分隔的媒体查询时，如果任何一个媒体查询返回真，样式就是有效的。例如：(width >= 192), (height >= 490)  
or | or 运算符用于将多个媒体特性比较语句组合到一个媒体查询语句中，只要有其中一条媒体特性比较语句返回 true，查询成立。例如：(min-width: 400) or (max-width: 700)  
<= | 小于等于。例如： (400 <= width)  
>= | 大于等于。例如： (500 >= height)  
< | 小于。例如： (400 < width)  
> | 大于。例如： (500 > height)  
  
## [#](<#示例代码>) 示例代码

  * 查询形状为圆形或胶囊形
        
        .box {
            width: 100px;
            height: 100px;
            background-color: black;
          }
        
          @media (shape: circle) or (shape: pill-shaped) {
            .box {
              background-color: green;
            }
          }
        
        

  * 同时查询设备类型为手表，屏幕形状为圆形
        
        .box {
            width: 100px;
            height: 100px;
            background-color: black;
          }
        
          @media (device-type: watch) and (shape: circle) {
            .box {
              background-color: green;
            }
          }
        


## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 支持2+特性  
Xiaomi Watch S3 | 支持2+特性  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #页面启动模式

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/other/launch-mode.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/other/launch-mode.html)

# [#](<#页面启动模式>) 页面启动模式

用于定义页面的启动行为。

## [#](<#静态声明>) 静态声明

在 manifest 文件中页面路由信息 router.page 可增加启动模式字段 launchMode，用于声明该页面的启动模式。

### [#](<#页面启动模式参数>) 页面启动模式参数：

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
launchMode | String | standard | 否 | 声明页面的启动模式，支持"singleTask"，"standard"两种页面启动模式。  
标识为"singleTask"模式时每次打开目标页面都会打开已有的目标页面并回调 onRefresh 生命周期函数，清除该页面上打开的其他页面，没有打开过此页面时会创建新的目标页面实例。  
标识为"standard"模式时会每次打开新的目标页面（多次打开目标页面地址时会存在多个相同页面）  
  
### [#](<#示例>) 示例：
    
    
    "router": {
        "entry": "PageA",
        "pages": {
          "PageA": {
            "launchMode": "singleTask",
            "component": "index"
          },
          "PageB": {
            "launchMode": "standard",
            "component": "index"
          },
          "PageC": {
            "launchMode": "singleTask",
            "component": "index"
          }
        }
      }
    

打开页面的行为逻辑：

若按顺序启动 PageA -> PageB -> PageC -> PageB -> PageC -> PageA

  * 打开 PageA，首次打开时页面栈为空 页面栈为PageA
  * 打开 PageB，PageB 的启动模式为 standard，即在 PageA 之上新建 PageB 的页面实例并显示 页面栈为PageA,PageB
  * 打开 PageC，首次打开 PageC，即在 PageB 之上新建 PageC 的页面实例并显示 页面栈为PageA,PageB,PageC
  * 打开 PageB，PageB 的启动模式为 standard，即在 PageC 之上新建 PageB 的页面实例并显示 页面栈为PageA,PageB,PageC,PageB
  * 打开 PageC，PageC 页面实例已存在，即销毁 PageC 之上的页面实例 PageB，回到之前打开的 PageC 的页面实例并回调此页面生命周期的 onRefresh 函数 页面栈为PageA,PageB,PageC
  * 打开 PageA，PageA 页面实例已存在，即销毁 PageA 之上的页面实例 PageB 和 PageC，回到之前打开的 PageA 的页面实例并回调此页面生命周期的 onRefresh 函数 页面栈为PageA


## [#](<#动态声明>) 动态声明

动态声明有两种方式。一种是在 router.push 中携带启动标识参数，另一种是在打开页面的链接中携带启动标识参数。启动标识参数可以控制页面打开行为。

### [#](<#页面启动模式参数-2>) 页面启动模式参数：

参数 | 类型 | 必填 | 说明  
---|---|---|---  
___PARAM_LAUNCH_FLAG___ | String | 否 | 跳转 JS 应用页面时传递的页面参数。携带 clearTask 时启动目标页面会清除此页面外的其他页面，存在多个目标页面时只保留最先打开的目标页面并回调 onRefresh 生命周期。如不存在目标页面时将清除所有页面并新建目标页面实例  
  
### [#](<#示例-2>) 示例：
    
    
    router.push({
      uri: '/PageB',
      params: {
        ___PARAM_LAUNCH_FLAG___: 'clearTask'
      }
    })
    

打开页面的行为逻辑：

若已经打开页面栈为 PageA -> PageB -> PageC，此时以 clearTask 标识启动 PageB

  * 销毁 PageC 页面实例
  * 销毁 PageA 页面实例
  * PageB 页面实例已存在，回到此页面实例并回调此页面生命周期的 onRefresh 函数


若已经打开页面栈为 PageA -> PageC，此时以 clearTask 标识启动 PageB

  * 销毁 PageC 页面实例
  * 销毁 PageA 页面实例
  * PageB 页面实例不存在，新建 PageB 页面实例并显示

---

## #后台运行

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/other/background-running.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/other/background-running.html)

# [#](<#后台运行>) 后台运行

为了节省系统资源，通常情况下，应用切换到后台后将会停止运行，等到再次切换回前台时重新运行。但音乐\运动等类型的应用，退到后台后可能仍然需要继续运行，为满足此类需求，加入了对后台运行的支持。后台运行模式的工作原理如下：

在应用切换到后台时，系统将会检查是否满足后台运行的条件，如果满足，应用将继续运行，否则将被停止。此条件包括：

  1. `manifest.json`中声明了后台运行接口

  2. 当前至少有一个（已在`manifest.json`中声明的）后台运行接口正在运行


实践建议：

  * 后台运行需要消耗较多的系统资源，应用需要根据自身需求审慎使用。针对申请后台运行的应用，上线审核时将会审核其后台运行的需求是否合理。
  * 后台运行接口的导入和后台执行的工作放到`app.ux`中，而不是放到页面中，以免避免页面切换和销毁的影响。


## [#](<#配置方法>) 配置方法

manifest.json 中声明所需的后台运行接口。后台运行接口包括：

  1. 音频播放： `system.audio`
  2. 上传下载： `system.request`
  3. 地理位置： `system.geolocation`


    
    
    {
      "package": "com.hybrid.demo.sample",
      //  ......
    
      "config": {
        "logLevel": "trace",
        "background": {
          "features":[
            "system.audio",
            "system.request"
          ]
        }
      }
      //  ......
    }

---

## #动态组件

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/other/dynamic-component.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/other/dynamic-component.html)

# [#](<#动态组件>) 动态组件

提示

通过本节，你将学会如何使用动态组件，减少模板的代码量，提高代码的可读性。

当页面中引入多个组件并需要动态切换组件时，绝大数情况下推荐在模板上使用 `if` 等指令进行逻辑判断，改变视图结构。

**示例如下：**
    
    
    <import src="./part1.ux" name="part1"></import>
    <import src="./part2.ux" name="part2"></import>
    <import src="./part3.ux" name="part3"></import>
    <template>
      <div>
        <part1 if="{{status === 1}}"></part1>
        <part2 elif="{{status === 2}}"></part2>
        <part3 else></part3>
      </div>
    </template>
    
    <script>
      export default {
        data: {
          status: 1
        }
      }
    </script>
    

但当组件较多时，模板的代码量会变得很大，不利于维护。此时可以使用 **动态组件** 来减少模板的代码量，通过在 `<component>` 元素加一个特殊的 `is` 属性来实现，`is` 的值表示组件名，只需修改 `is` 属性即可切换组件。

**示例如下：**
    
    
    <import src="./part1.ux" name="part1"></import>
    <import src="./part2.ux" name="part2"></import>
    <import src="./part3.ux" name="part3"></import>
    <import src="./part4.ux" name="part4"></import>
    <import src="./part5.ux" name="part5"></import>
    <import src="./part6.ux" name="part6"></import>
    
    <template>
      <div>
        <component is="{{'part' + status}}"></component>
      </div>
    </template>
    
    <script>
      export default {
        data: {
          status: 1
        }
      }
    </script>

---

## #多语言覆盖

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/other/i18n.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/other/i18n.html)

# [#](<#多语言覆盖>) 多语言覆盖

Vela 的能力会覆盖多个国家地区，框架支持多语言的能力后，可以做到让一个JS 应用产品（一个 RPK 文件）同时支持多个语言版本的切换，开发者无需开发多个不同语言的源码项目，避免给项目维护带来困难。

使用系统默认的语言，开发者配置多语言的方式非常简单，只需要`定义资源`与`引用资源`两个步骤即可。

## [#](<#定义资源文件>) 定义资源文件

资源文件用于存放多个语言的业务信息定义，与其它技术平台类似（它们使用`properties文件`或者`xml文件`的格式），JS 应用平台使用`JSON文件`保存资源定义；

在项目源码`src目录`下定义`i18n文件夹`，内部放置每个语言地区下的资源定义文件即可。

### [#](<#资源文件命名查找规则及建议>) 资源文件命名查找规则及建议

文件命名可使用当前系统获取到的语言以及国家信息，例如文件名可定义为：`zh-CN.json`、`zh.json`。

如果开发者当前产品仅计划支持一种语言，同时还希望用到多语言能力，那么仅声明一个名称为`defaults.json`的文件即可。

JSON文件名匹配优先级，优先级高的匹配到就停止查找，否则就向下一级查找。

**优先级匹配规则** 如下：

`<语言代码>-<国家代码>`

`<语言代码>`

`defaults`

默认i18n配置文件首个文件

**命名建议** ：

  * 如果需要精确匹配语言+地区进行多语言配置建议使用`<语言代码>-<国家代码>.json`命名资源文件；

  * 不需要匹配地区的建议使用`<语言代码>.json`命名资源文件；

  * `defaults.json`可以作为默认选项单独使用，也可配合以上两种方式结合使用；

  * 不推荐使用系统最终的兜底默认首个文件的方案，可能会造成不符合预期的显示结果。


温馨提示

`<语言代码>-<国家代码>` 可参考：[支持的语言列表](</vela/quickapp/zh/guide/framework/other/language-list.html>)。

### [#](<#资源文件支持的配置语法>) 资源文件支持的配置语法

#### [#](<#基础文本配置>) 基础文本配置
    
    
    {
      "message": {
        "hello": "hello world"
      }
    }
    

#### [#](<#数组配置>) 数组配置

匹配到会把数据内容序列化转成文本输出，此种配置不支持与插值语法混用。
    
    
    {
      "message": {
        "array": ["a", 2, {"c": 3}]
      }
    }
    

#### [#](<#命名插值配置>) 命名插值配置

支持使用`{}`占位符进行命名插值，调用时通过具名参数传入替代占位内容。
    
    
    {
      "message": {
        "hello": "{msg} world"
      }
    }
    

#### [#](<#列表插值配置>) 列表插值配置

支持使用`{}`占位符进行列表插值，通过配置列表取值索引，在调用时传入备选列表进行取值替代占位内容。
    
    
    {
      "message": {
        "hello": "{0} world"
      }
    }
    

#### [#](<#单复数语法配置>) 单复数语法配置

支持使用`|`占位符进行单复数语法配置，不同的选择项使用占位符分隔。
    
    
    {
      "message": {
        car: 'car | cars',
      }
    }
    

## [#](<#页面中引用资源>) 页面中引用资源

使用多语言配置的方式主要通过ViewModel 实例上`$t`与`$tc`函数实现，这些方法可以在`<template>`或`<script>`中使用。

### [#](<#简单格式化方法>) 简单格式化方法

this.$t(path, opts)

**参数说明** ：

参数 | 类型 | 是否必填 | 说明  
---|---|---|---  
path | String | 是 | 获取多语言配置的资源路径，对象取值通过.连接，例如：”message.hello“  
opts | Array | Object | 否 | 进行插值替换的配置项，可以传入对象或数组，配合配置中的差值配置使用  
若传入对象则需要指定配置的命名key进行传参  
若传入数组取值为传入列表对应的列表插值配置的index值  
  
**使用示例** ：

使用**基础文本配置** 对应取值示例：
    
    
    <template>
      <div>
        <!-- 显示结果 hello world -->
        <text>{{ $t('message.hello') }}</text>
      </div>
    </template>
    
    <script>
      export default {
        onInit () {
          // 简单格式化：
          console.log(this.$t('message.hello')) // hello world
        }
      }
    </script>
    

使用**数组配置** 对应取值示例：
    
    
    <template>
      <div>
        <!-- 直接显示数组，显示结果 ["a", 2, {"c": 3}] -->
        <text>{{ $t('message.array') }}</text>
      </div>
    </template>
    
    <script>
      export default {
        onInit () {
          // 简单格式化：
          console.log(this.$t('message.array')) // ["a", 2, {"c": 3}]
        }
      }
    </script>
    

使用**命名插值配置** 对应取值示例：
    
    
    <template>
      <div>
        <!-- 显示结果 hello world -->
        <text>{{ $t('message.hello', { msg: 'hello' }) }}</text>
      </div>
    </template>
    
    <script>
      export default {
        onInit () {
          // 简单格式化：
          console.log(this.$t('message.hello', { msg: 'hello' }))  // hello world
        }
      }
    </script>
    

使用**列表插值配置** 对应取值示例：
    
    
    <template>
      <div>
        <!-- 显示结果 hello world -->
        <text>{{ $t('message.hello', ['hello', 'hi']) }}</text>
      </div>
    </template>
    
    <script>
      export default {
        onInit () {
          // 简单格式化：
          console.log(this.$t('message.hello', ['hello', 'hi'])) // hello world
        }
      }
    </script>
    

### [#](<#单复数格式化方法>) 单复数格式化方法

this.$tc(path, choice, opts)

**参数说明** ：

参数 | 类型 | 是否必填 | 说明  
---|---|---|---  
path | String | 是 | 获取多语言配置的资源路径，对象取值通过.连接，例如：”message.hello“  
choice | Number | 否 | 用于判断使用第几个选项的值，不传具体值时默认单数，在不传入第三个参数时也可用作插值显示  
**特殊值说明** ：  
值必须是整数，错参报错不显示返回空字符串  
单复数判断忽略正负符号  
两段式0作为偶数处理  
opts | Array | Object | 否 | 进行插值替换的配置项，可以传入对象或数组，配合配置中的差值配置使用  
若传入对象则需要指定配置的命名key进行传参  
若传入数组取值为传入列表对应的列表插值配置的index值  
  
**choice单复数配置说明** ：

目前单复数在资源文件中支持两种写法并支持与插值语法混用。

两段式配置：单数|复数；

三段式配置：空值|单数|复数。

**配置示例** ：
    
    
    {
      "message": {
        car: 'car | cars', // 两段式配置
        apple: 'no apples | one apple | {count} apples' // 三段式配置
      }
    }
    

**使用示例** ：
    
    
    <template>
      <div>
        <!-- 两段单复数 -->
        <!-- 显示结果 cars -->
        <text>{{ $tc('message.car', 0) }}</text>
        <!-- 显示结果 car -->
        <text>{{ $tc('message.car', 1) }}</text>
        <!-- 显示结果 cars -->
        <text>{{ $tc('message.car', 2) }}</text>
    
        <!-- 三段单复数 -->
        <!-- 显示结果 no apples -->
        <text>{{ $tc('message.apple', 0) }}</text>
        <!-- 显示结果 one apple -->
        <text>{{ $tc('message.apple', 1) }}</text>
        <!-- 显示结果 2 apples -->
        <text>{{ $tc('message.apple', 2) }}</text>
        <!-- 三段单复数混合插值使用 -->
        <!-- 显示结果 6 apples -->
        <text>{{ $tc('message.apple', 2, {count: 6}) }}</text>
      </div>
    </template>
    
    <script>
      export default {
        onInit () {
          // 两段单复数：
          console.log(this.$tc('message.car', 0)) // cars
          console.log(this.$tc('message.car', 1)) // car
          console.log(this.$tc('message.car', 2)) // cars
    
          // 三段单复数：
          console.log(this.$tc('message.apple', 0)) // no apples
          console.log(this.$tc('message.apple', 1)) // one apple
          console.log(this.$tc('message.apple', 2)) // 2 apples
          console.log(this.$tc('message.apple', 2, {count: 6})) // 6 apples
        }
      }
    </script>
    

## [#](<#获取系统语言>) 获取系统语言

上面的能力用于资源内容的格式化，在某些场景下开发者可能需要获取当前系统的地区语言`locale`并进行更改，来完成不同的逻辑处理。比如：

  * 不同的 locale 对应的页面布局不同；

  * 开发者为用户提供设置某种语言的能力；


框架`system.configuration`提供了相关功能，文档参考：[应用配置 configuration](</vela/quickapp/zh/features/basic/configuration.html>)。

## [#](<#修改地区语言后的回调>) 修改地区语言后的回调

当用户在系统设置切换地区语言，会触发 onConfigurationChanged 回调，且返回来的 event.type 值为locale。

详情可参考[文档](</vela/quickapp/zh/guide/framework/script/lifecycle.html#onconfigurationchangedevent>)。

示例代码：
    
    
    // 监听语言变化
    onConfigurationChanged(event) {
      if (event && event.type && event.type === 'locale') {
        console.log('locale or language changed!')
      }
    }

---

## #hap 链接

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/framework/other/hap-schema.html](https://iot.mi.com/vela/quickapp/zh/guide/framework/other/hap-schema.html)

# [#](<#hap-链接>) hap 链接

hap链接 指在router模块中支持的以hap://开头的uri，使用场景见[页面路由](</vela/quickapp/zh/features/basic/router.html>)。

目前支持的 hap 链接以`hap://app/`开头，支持打开指定的JS 应用，格式如下：

`hap://app/<package>/[path][?key=value]`

参数说明：

  * package: 应用包名，必选
  * path: 应用内页面的 path，可选，默认为首页
  * key-value: 希望传给页面的参数，可选，可以有多个

---

