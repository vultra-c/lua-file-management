# 快应用_设计规范

> 来源: 小米快应用官方
> 共 3 篇文档

---

## #多屏设计

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/design/multi-screens.html](https://iot.mi.com/vela/quickapp/zh/guide/design/multi-screens.html)

# [#](<#多屏设计>) 多屏设计

## [#](<#小米智能穿戴设备>) 小米智能穿戴设备

目前搭载vela系统的小米可穿戴设备主要为智能手表、手环产品。手表屏幕形状为圆形或矩形，手环产品为矩形和胶囊型屏幕为主。

已发布的vela穿戴设备数据参考：

设备类型 | 设备型号 | 屏幕形状 | 屏幕尺寸 | 分辨率 | PPI | DPR  
---|---|---|---|---|---|---  
手表 | Xiaomi Watch S1 Pro | 圆形 | 1.47英寸 | 480x480 | 326 | 2.0  
手表 | Xiaomi Watch H1 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0  
手表 | Xiaomi Watch S3 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0  
手表 | Xiaomi Watch S4 sport | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0  
手表 | Xiaomi Watch S4 | 圆形 | 1.43英寸 | 466x466 | 326 | 2.0  
手表 | REDMI Watch 5 | 矩形 | 2.07英寸 | 432x514 | 324 | 2.0  
手环 | 小米手环8 Pro | 矩形 | 1.74英寸 | 336x480 | 336 | 2.1  
手环 | 小米手环9 | 胶囊形 | 1.62英寸 | 192x490 | 325 | 2.0  
手环 | 小米手环9 Pro | 矩形 | 1.74英寸 | 336x480 | 336 | 2.1  
手环 | 小米手环10 | 胶囊形 | 1.725英寸 | 212x520 | 326 | 2.0  
手表 | Xiaomi Watch S5 | 圆形 | 1.485英寸 | 480x480 | 323 | 2.0  
  
## [#](<#设计建议>) 设计建议

产品接入时可以根据应用场景及可适配的产品形态来做设计决策。若所属产品场景在手环、手表等多种屏幕形态都能很好的交互，建议出三类设计稿满足胶囊形、圆形、矩形屏的交互方案。

不同形状屏幕数据参考：

屏幕形状 | 圆屏 | 矩形屏 | 胶囊屏  
---|---|---|---  
长宽比范围 | W/H=1 | 0.5<=W/H<1 | 0.3<W/H<0.5  
推荐长宽比例 | 1 | 0.7 | 0.39  
推荐分辨率 | 466x466 | 336x480 | 192x490  
  
推荐设计三套UI交互适配三类主要屏幕，若圆屏矩形屏能够复用的话可以设计圆形、矩形屏采用一套，胶囊屏采用一套。

## [#](<#弧形屏幕适配安全区域>) 弧形屏幕适配安全区域

对于圆形以及胶囊形屏幕，弧形的屏幕边缘会带来一些显示问题，在UI设计时需要考虑屏幕的安全区域问题，将主体功能设计在屏幕安全区域内。

比如，文本显示或内容列表，需要考虑边缘位置的显示完整性和可交互性。

图示里灰色区域分别为圆屏、胶囊屏安全区。

![](/vela/quickapp/images/multi-screens/multi-safe-area.png)

---

## #适配规范

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/multi-screens/specs.html](https://iot.mi.com/vela/quickapp/zh/guide/multi-screens/specs.html)

# [#](<#适配规范>) 适配规范

Vela OS 支持一系列适配多种屏幕的技术能力。

## [#](<#自适应布局>) 自适应布局

系统提供的容器组件均默认遵循 Flex 弹性布局规则，使用弹性布局可以实现屏幕自适应布局。

比如以下代码可以实现行内多个 item 平均分布。
    
    
    <div>
      <text style="flex-grow: 1; background-color:aqua;">1</text>
      <text style="flex-grow: 1; background-color:yellow;">2</text>
      <text style="flex-grow: 1; background-color:red;">3</text>
    </div>
    

![](/vela/quickapp/images/multi-screens/flex-items.png)

更多说明请参考[Flex 布局示例](</vela/quickapp/zh/guide/framework/style/page-style-and-layout.html#flex-布局示例>)

## [#](<#自适应单位>) 自适应单位

在编写 UI 样式时，可以采用系统提供的自适应长度单位，包括：

  * px
  * %


### [#](<#px>) px

px 在 Vela 应用中不表示屏幕的物理像素，而是相对于项目配置基准宽度的单位，其原理类似于rem。

开发者在 manifest 文件中将 designWidth 字段配置为设计基准宽度（设计稿宽度），然后在样式描述中使用该长度单位，数值直接使用设计稿中的像素值，系统将自动计算使 Vela 应用 UI 在不同屏幕上进行等比缩放。
    
    
    {
      "config": {
        "designWidth": 336
      }
    }
    
    
    
    <template>
      <div class="demo-page">
        <div class="container"></div>
      </div>
    </template>
    
    <style>
    .demo-page {
      justify-content: center;
      align-items: center;
    }
    .container {
      width: 168px;
      height: 168px;
      background-color: aquamarine;
    }
    </style>
    

如上示例中将 designWidth 配置为 336px，那么所有的 px 值使用都会按照 336px 的基准宽度换算。 假设设备屏幕实际宽度为 336 像素，则 container 元素的实际宽度也为 168 像素；如果设备屏幕实际宽度为 192 像素，则 container 元素的实际宽度为 96 像素。

336*480 屏幕 / 192*490 屏幕

![](/vela/quickapp/images/multi-screens/px-demo2.png) ![](/vela/quickapp/images/multi-screens/px-demo1.png)

更多说明请参考[长度单位](</vela/quickapp/zh/guide/framework/style/page-style-and-layout.html#长度单位>)

### [#](<#百分比>) 百分比%

% 表示百分比，许多样式属性可以取百分比值，经常用以根据父对象来确定大小。

比如以下代码可以实现行内多个 item 按百分比占据父容器宽度，
    
    
    <div>
      <text style="width: 20%; background-color:aqua;">1</text>
      <text style="width: 40%; background-color:yellow;">2</text>
      <text style="width: 40%; background-color:red;">3</text>
    </div>
    

![](/vela/quickapp/images/multi-screens/percent.png)

更多说明请参考[CSS 百分比单位 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/percentage>)

## [#](<#固定长度单位>) 固定长度单位[3+](</vela/quickapp/zh/guide/version/APILevel3>)

在有的布局场景下，需要使用固定长度单位，系统支持的 dp 长度单位可满足这个需求。

DP 长度单位表示设备独立像素（device-independent pixel），也叫密度无关像素，可以认为是计算机坐标系统中的一个点，这个点代表一个可以由程序使用的逻辑像素，是一个近似物理尺寸的单位，其计算公式为：
    
    
    屏幕宽度的 DP 值 = 屏幕分辨率的宽度 / DPR
    元素宽/高度的 DP 值 = 元素宽/高度的物理像素数 / DPR
    

DPR 表示设备像素比（device pixel ratio），是设备物理像素和逻辑像素（DP）的比值，其计算公式为：
    
    
    DPR = 设备 PPI / 160
    

PPI（pixels per inch）表示每英寸的像素数，表征屏幕的物理密度，因此 DPR 又被称为逻辑密度。 设备屏幕的逻辑密度值（DPR）可以通过 device 接口获取。

比如以下代码可以实现元素在不同尺寸屏幕上保持近似的物理尺寸，从而在大屏幕上呈现更多的元素。
    
    
    <template>
      <div class="container">
        <div class="text-box">
          <text style="background-color: aquamarine;">
            A
          </text>
          <text style="background-color: #ff0000;">
            B
          </text>
          <text style="background-color: #00ff00;">
            C
          </text>
          <text style="background-color: #0000ff;">
            D
          </text>
        </div>
      </div>
    </template>
    
    <style>
      .container {
        justify-content: center;
        align-items: center;
      }
      .text-box {
        justify-content: center;
        flex-wrap: wrap;
      }
      text {
        width:116dp;
        height: 30dp;
        font-size: 15dp;
        text-align: center;
      }
    </style>
    

466*466 屏幕 / 192*490 屏幕

![](/vela/quickapp/images/multi-screens/dp-demo1.png) ![](/vela/quickapp/images/multi-screens/dp-demo2.png)

## [#](<#媒体查询>) 媒体查询

媒体查询是 CSS3 引入的一个功能，用于根据不同的屏幕尺寸和设备类型，为网页应用不同的样式。

在 Vela JS 应用中，也可以使用类似的媒体查询规范来针对不同屏幕和设备编写样式，详细介绍请参考[媒体查询](</vela/quickapp/zh/guide/framework/style/media-query.html>)。

比如以下代码可以实现根据屏幕形状来应用不同的样式。

注意: 以下示例代码的`designWidth`为`466`
    
    
    <template>
      <div class="container">
        <text>10:30</text>
        <text>我的待办</text>
      </div>
    </template>
    
    <style>
      /* 当屏幕为圆形屏幕时 */
      @media screen and (shape: circle) {
        .container {
          padding-left: 80px;
          padding-right: 80px;
          padding-top: 40px;
          flex-direction: row;
          align-items: flex-start;
          justify-content: space-between;
        }
        text {
          font-size: 40px;
        }
      }
      /* 当屏幕为胶囊形屏幕时 */
      @media screen and (shape: pill-shaped) {
        .container {
          padding-top: 50px;
          flex-direction: column;
          align-items: center;
        }
        text {
          margin-top: 10px;
        }
      }
    </style>
    

466*466 屏幕 / 192*490 屏幕

![](/vela/quickapp/images/multi-screens/mediaquery-demo2.png) ![](/vela/quickapp/images/multi-screens/mediaquery-demo1.png)

## [#](<#获取屏幕信息>) 获取屏幕信息

在 Vela JS 应用中，可以通过 device feature 接口获取屏幕信息，包括屏幕形状、屏幕分辨率等。根据获取到的结果可以进行相应的样式适配。

比如以下代码可以实现根据屏幕形状决定 progress 组件的类型（是否是弧形）。
    
    
    <template>
      <div class="container">
        <progress percent="80" type="{{progressType}}"></progress>
      </div>
    </template>
    
    <script>
      import device from '@system.device'
    
      export default {
        data: {
          progressType: "horizontal"
        },
        onInit() {
          const that = this
          device.getInfo({
            success: function(ret) {
              that.progressType = ret.screenShape === "circle" ? "arc" : "horizontal"
            }
          })
        }
      }
    </script>
    
    <style>
      .container {
        padding: 20px;
      }
    </style>
    

圆形屏幕 / 矩形屏幕

![](/vela/quickapp/images/multi-screens/shape-circle.png) ![](/vela/quickapp/images/multi-screens/shape-rect.png)

详细介绍请参考 [设备信息 device](</vela/quickapp/zh/features/basic/device.html>)

---

## #代码示例

> 来源: [https://iot.mi.com/vela/quickapp/zh/guide/multi-screens/samples.html](https://iot.mi.com/vela/quickapp/zh/guide/multi-screens/samples.html)

# [#](<#代码示例>) 代码示例

## [#](<#页面布局及元素适配>) 页面布局及元素适配

一些开发中常见的跨屏适配示例。

### [#](<#自适应容器大小>) 自适应容器大小

使用百分比或flex样式替代px写固定容器大小的布局方式可以在多屏适时有更好的兼容性。比如长列表滚动的场景，示例如下：
    
    
    <template>
      <div class="demo-page">
        <text class="title"> 长列表 </text>
        <list class="list">
          <list-item class="item" type="custom" for="{{listData}}">
            <text>{{$item.name}}</text>
          </list-item>
        </list>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          listData: [
            {
              name: 'TEST1 TEST1 TEST1'
            }, {
              name: 'TEST2 TEST2 TEST2'
            }, {
              name: 'TEST3 TEST3 TEST3'
            }, {
              name: 'TEST4 TEST4 TEST4'
            }, {
              name: 'TEST5 TEST5 TEST5'
            }, {
              name: 'TEST6 TEST6 TEST6'
            }, {
              name: 'TEST7 TEST7 TEST7'
            }, {
              name: 'TEST8 TEST8 TEST8'
            }, {
              name: 'TEST9 TEST9 TEST9'
            }, {
              name: 'TEST10 TEST10 TEST10'
            }
          ]
        }
      }
    </script>
    
    <style>
    .demo-page {
      flex-direction: column;
      align-items: center;
      background-color: #fff;
    }
    
    .title {
      margin-top: 50px;
      padding: 20px 0;
      font-size: 32px;
    }
    .list {
      flex: 1;
      width: 340px;
      margin-bottom: 5px;
      align-items: center;
    }
    .item {
      width: 100%;
      height: 100px;
      margin-bottom: 20px;
      border-radius: 20px;
      background-color: #ccc;
      text-align: center;
    }
    
    text {
      width: 100%;
      font-size: 30px;
      text-align: center;
      color: #000;
    }
    </style>
    

效果展示：

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/multi-samples-list-1.png) ![](/vela/quickapp/images/multi-screens/multi-samples-list-2.png) ![](/vela/quickapp/images/multi-screens/multi-samples-list-3.png)

### [#](<#单页三行布局>) 单页三行布局

手表、手环场景下单页面三行布局是比较常用的一种设计方式，页面结构大致分为顶部标题栏，底部按钮交互区域以及中部主体内容区。建议采用顶部底部高度固定，主体部分高度自适应的方式来做整体布局。

代码示例：
    
    
    <template>
      <div class="demo-page">
        <div class="header">
          <text>header</text>
        </div>
        <div class="content">
          <text>content</text>
        </div>
        <div class="footer">
          <text>footer</text>
        </div>
      </div>
    </template>
    
    <script>
      export default {}
    </script>
    
    <style>
    .demo-page {
      width: 466px;
      height: 466px;
      flex-direction: column;
    }
    
    .header {
      width: 100%;
      height: 100px;
      background-color: red;
    }
    
    .content {
      flex: 1;
      background-color: yellow;
    }
    
    .footer {
      width: 100%;
      height: 100px;
      background-color: blue;
    }
    
    text {
      width: 100%;
      font-size: 30px;
      color: black;
      text-align: center;
    }
    
    </style>
    

效果展示：

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/multi-samples-layout-c.png) ![](/vela/quickapp/images/multi-screens/multi-samples-layout-r.png) ![](/vela/quickapp/images/multi-screens/multi-samples-layout-s.png)

### [#](<#px自动缩放计算>) px自动缩放计算

px长度单位会根据配置的项目配置基准宽度进行换算，过程中产生的小数位会做四舍五入处理。因此，在一些需要精准计算的场景中需要考虑到换算带来的误差值（通常为+-1px）。

比如下面这个示例， 在计算行宽的时候没考虑误差，导致某些设备上产生渲染错行的问题：

![](/vela/quickapp/images/multi-screens/multi-samples-px-1.png) ![](/vela/quickapp/images/multi-screens/multi-samples-px-2.png) ![](/vela/quickapp/images/multi-screens/multi-samples-px-3.png)

代码示例：
    
    
    <template>
      <div class="demo-page">
        <div class="item" for="nums">
          <text>{{$item}}</text>
        </div>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          nums: [1, 2, 3, 4]
        }
      }
    </script>
    
    <style>
    .demo-page {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      align-items: center;
    }
    
    .item {
      width: 110px;
      height: 110px;
      margin: 2px;
      background-color: #ccc;
    }
    
    text {
      color: #000;
      font-size: 30px;
    }
    
    </style>
    

效果展示：

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/multi-samples-px-4.png) ![](/vela/quickapp/images/multi-screens/multi-samples-px-5.png) ![](/vela/quickapp/images/multi-screens/multi-samples-px-6.png)

### [#](<#全屏背景图>) 全屏背景图

使用全屏背景图需要考虑到图片在不同尺寸的屏幕下是否都能有比较好的展示效果。 如果背景图片中有一些交互性或严格要求位置的部分，建议作为单独的元素与背景图拆分处理。

效果展示：

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/background-image1.png) ![](/vela/quickapp/images/multi-screens/background-image2.png) ![](/vela/quickapp/images/multi-screens/background-image3.png)

### [#](<#页面标题栏>) 页面标题栏

页面标题通常位于页面顶部，在不同屏幕形状的设备上，需要考虑内容显示的美观性与完整性。通常在圆屏、胶囊屏等存在边缘剪切的设备上，标题栏会使用多行设计，保证顶部的展示内容长度不会超出屏幕；而在矩形屏幕上则做单行左右布局让整体设计更为舒展。

代码示例：
    
    
    <template>
      <div class="demo-page">
        <div class="title">
          <text class="title-text">{{text1}}</text>
          <text class="title-text">{{text2}}</text>
        </div>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          text1: '09:28',
          text2: '文案'
        }
      }
    </script>
    
    <style>
    .demo-page {
      justify-content: center;
      background-color: #5c5c5c;
    }
    
    .title {
      width: 90%;
    }
    
    .title-text {
      font-size: 36px;
      color: #fff;
    }
    
    @media (shape: circle){
      .title {
        flex-direction: column;
        align-items: center;
      }
    }
    
    @media (shape: rect) {
      .title {
        margin-top: 10px;
        justify-content: space-between;
        align-items: flex-start;
        flex-direction: row-reverse;
      }
      .title-text {
        font-size: 46px;
      }
    }
    
    @media (shape: pill-shaped) {
      .title {
        flex-direction: column;
        align-items: center;
      }
      .title-text {
        font-size: 72px;
      }
    }
    </style>
    

效果展示：

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/multi-samples-title-c.png) ![](/vela/quickapp/images/multi-screens/multi-samples-title-r.png) ![](/vela/quickapp/images/multi-screens/multi-samples-title-s.png)

## [#](<#跨屏应用项目示例>) 跨屏应用项目示例

### [#](<#清单应用>) 清单应用

圆形屏幕 / 矩形屏 / 胶囊屏

![](/vela/quickapp/images/multi-screens/demo-todoList3.png) ![](/vela/quickapp/images/multi-screens/demo-todoList1.png) ![](/vela/quickapp/images/multi-screens/demo-todoList2.png)

项目地址：[点击下载 (opens new window)](<https://quickapp-vela.cnbj3-fusion.mi-fds.com/quickapp-vela/multi-screen-todoList.zip>)

### [#](<#计算器>) 计算器

圆形屏幕 / 矩形屏

![](/vela/quickapp/images/multi-screens/demo-calculator1.png) ![](/vela/quickapp/images/multi-screens/demo-calculator2.png)

项目地址：[点击下载 (opens new window)](<https://quickapp-vela.cnbj3-fusion.mi-fds.com/quickapp-vela/multi-screen-calculator.zip>)

---

