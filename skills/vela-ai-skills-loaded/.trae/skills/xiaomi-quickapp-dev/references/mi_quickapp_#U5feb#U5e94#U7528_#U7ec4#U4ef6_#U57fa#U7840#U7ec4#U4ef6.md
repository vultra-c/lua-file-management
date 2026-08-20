# 快应用_组件_基础组件

> 来源: 小米快应用官方
> 共 10 篇文档

---

## #a

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/a.html](https://iot.mi.com/vela/quickapp/zh/components/basic/a.html)

# [#](<#a>) a

## [#](<#概述>) 概述

超链接（默认不带下划线）

## [#](<#子组件>) 子组件

仅支持[`<span>`](</vela/quickapp/zh/components/basic/span.html>)

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
href | `string` | - | 否 | 支持的格式参见[页面路由](</vela/quickapp/zh/features/basic/router.html>)中的 uri 参数。  
额外的：  
href 还可以通过“?param1=value1”的方式添加参数，参数可以在页面中通过`this.param1`的方式使用。使用`this.param1`变量时，需要在目标页面中在 `public`（应用外传参）或 `protected`（应用内传参）下定义 key 名相同的属性  
示例：  
`<a href="/about?param1=value1">关于</a>`  
  
## [#](<#样式>) 样式

支持[text样式](</vela/quickapp/zh/components/basic/text.html>)

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <a class="link" href="/home">goHome</a>
        <a href="/home">
          <span class="link">使用span子组件</span>
        </a>
      </div>
    </template>

---

## #barcode2+

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/barcode.html](https://iot.mi.com/vela/quickapp/zh/components/basic/barcode.html)

# [#](<#barcode>) barcode[2+](</vela/quickapp/zh/guide/version/APILevel2>)

## [#](<#概述>) 概述

条形码，将文本内容转换为条形码展示。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
value | `string` | - | 是 | 条形码内容，码制为Code128码，长度小于等于20字节  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | #000000 | 否 | 条形码颜色  
background-color | `<color>` | #ffffff | 否 | 条形码背景颜色  
  
注意

  * 当设置transform的rotate属性时，该组件只能旋转为垂直或者水平状态；
  * 当设置transform的scale属性时，该组件只能支持整数倍缩放。


## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <barcode value="barcodetest" style="color: #008cff;"></barcode>
      </div>
    </template>
    

![](/vela/quickapp/images/components/barcode.png)

---

## #chart

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/chart.html](https://iot.mi.com/vela/quickapp/zh/components/basic/chart.html)

# [#](<#chart>) chart

## [#](<#概述>) 概述

图表组件，用于呈现线形图、柱状图界面。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
type | `<string>` | line | 否 | 设置图表类型（不支持动态修改），可选项有：bar（柱状图） \ line（线形图）  
options | [ChartOptions](<#chartoptions-%E8%AF%B4%E6%98%8E>) | - | 是 | 图表参数设置，柱状图和线形图必须设置参数。可以设置x轴、y轴的最小值、最大值、刻度数、是否显示、线条宽度、是否平滑等。（不支持动态修改）  
datasets | Array<[ChartDataset](<#chartdataset-%E8%AF%B4%E6%98%8E>)> | - | 是 | 数据集合，柱状图和线形图必须设置，可以设置多条数据集及其背景色  
  
### [#](<#chartoptions-说明>) ChartOptions 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
xAxis | [ChartAxis](<#chartaxis-%E8%AF%B4%E6%98%8E>) | line | 是 | x轴参数设置。可以设置x轴最小值、最大值、刻度数以及是否显示  
yAxis | [ChartAxis](<#chartaxis-%E8%AF%B4%E6%98%8E>) | - | 是 | y轴参数设置。可以设置y轴最小值、最大值、刻度数以及是否显示  
series | [ChartSeries](<#chartseries-%E8%AF%B4%E6%98%8E>) | - | 否 | 数据序列参数设置。可以设置 1）线的样式，如线宽、是否平滑；2）设置线最前端位置白点的样式和大小（仅线形图支持）  
  
### [#](<#chartdataset-说明>) ChartDataset 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
strokeColor | `<color>` | #ff6384 | 否 | 线条颜色。（仅线形图支持）  
fillColor | `<color>` | #ff6384 | 否 | 填充颜色。线形图表示填充的渐变颜色  
data | Array<`<number`> | - | 是 | 设置绘制线或柱中的点集  
gradient | `<boolean>` | false | 否 | 设置是否显示填充渐变颜色。（仅线形图支持）  
  
### [#](<#chartaxis-说明>) ChartAxis 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
min | `<number>` | 0 | 否 | 轴的最小值。（不支持负数。仅线形图支持）  
max | `<number>` | dataset 数据个数-1 | 否 | 轴的最大值。（不支持负数。仅线形图支持）  
axisTick | `<number>` | 10 | 否 | 轴显示的刻度数量。（仅支持1~20，且具体显示的效果与如下计算值有关（图的宽度所占的像素/（max-min））。因轻量级智能穿戴为整型运行，在除不尽的情况下会有误差产生，具体的表现形式是x轴末尾可能会空出一段。在柱状图中，每组数据显示的柱子数量与刻度数量一致，且柱子显示在刻度处。）  
display | `<boolean>` | false | 否 | 是否显示轴  
color | `<color>` | #c0c0c0 | 否 | 轴颜色  
  
### [#](<#chartseries-说明>) ChartSeries 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
lineStyle | [ChartLineStyle](<#chartlinestyle-%E8%AF%B4%E6%98%8E>) | - | 否 | 线样式设置，如线宽、是否平滑  
loop | [ChartLoop](<#chartloop-%E8%AF%B4%E6%98%8E>) | - | 否 | 设置屏幕显示满时，是否需要重头开始绘制  
  
### [#](<#chartlinestyle-说明>) ChartLineStyle 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
width | `<length>` | 2px | 否 | 线宽设置  
  
### [#](<#chartloop-说明>) ChartLoop 说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
margin | `<length>` | 1px | 否 | 擦除点的个数（最新绘制的点与最老的点之间的横向距离）。注意：轻量设备margin和topPoint/bottomPoint/headPoint同时使用时，有概率出现point正好位于擦除区域的情况，导致point不可见，因此不建议同时使用  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码

### [#](<#线形图>) 线形图
    
    
    <template>
      <chart type="line" options="{{lineOpts}}" datasets="{{lineData}}"></chart>
    </template>
    
    <script>
      export default {
        data: {
          lineData: [
            {
              strokeColor: '#f07826',
              data: [763, 550, 551, 554, 731, 654, 525, 696, 595, 628],
            },
            {
              strokeColor: '#cce5ff',
              fillColor: '#cce5ff', 
              data: [535, 776, 615, 444, 694, 785, 677, 609, 562, 410],
            },
            {
              strokeColor: '#ff88bb',
              data: [673, 500, 574, 483, 702, 583, 437, 506, 693, 657]
            },
          ],
          lineOpts: {
            xAxis: {
              min: 0,
              max: 10,
              display: true,
              axisTick: 10
            },
            yAxis: {
              min: 400,
              max: 900,
              display: true,
            }
          }
        }
      }
    </script>
    

![](/vela/quickapp/images/components/line-chart.png)

### [#](<#柱状图>) 柱状图
    
    
    <template>
      <chart type="bar" options="{{barOpts}}" datasets="{{barData}}"></chart>
    </template>
    
    <script>
      export default {
        data: {
          barData: [
            {
              fillColor: '#f07826',
              data: [763, 550, 551, 554, 731, 654, 525]
            },
            {
              fillColor: '#cce5ff',
              data: [535, 776, 615, 444, 694, 785, 677]
            }
          ],
          barOpts: {
            xAxis: {
              min: 0,
              max: 7,
              display: false,
              axisTick: 7
            },
            yAxis: {
              min: 0,
              max: 800,
              display: false,
            }
          }
        }
      }
    </script>
    

![](/vela/quickapp/images/components/bar-chart.png)

---

## #image-animator2+

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/image-animator.html](https://iot.mi.com/vela/quickapp/zh/components/basic/image-animator.html)

# [#](<#image-animator>) image-animator[2+](</vela/quickapp/zh/guide/version/APILevel2>)

## [#](<#概述>) 概述

图片帧动画播放器。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
images | `Array<ImageFrame>` | - | 是 | 设置图片帧信息集合。每一帧的帧信息包含图片路径、图片大小和图片位置信息  
iteration | `<number>`|`<string>` | `infinite` | 否 | 设置帧动画播放次数。number表示固定次数，infinite枚举表示无限次数播放  
reverse | `<boolean>` | `false` | 否 | 设置播放顺序。false表示从第1张图片播放到最后1张图片； true表示从最后1张图片播放到第1张图片  
fixedsize | `<boolean>` | `true` | 否 | 设置图片大小是否固定为组件大小。 true表示图片大小与组件大小一致，此时设置图片的width 、height 、top 和left属性是无效的。false表示每一张图片的 width 、height 、top和left属性都要单独设置  
duration | `<string>` | - | 否 | 设置单次播放时长。单位支持[s(秒)|ms(毫秒)]，默认单位为ms  
fillmode | `<string>` | `forwards` | 否 | 指定帧动画执行结束后的状态。可选项有：none：恢复初始状态。forwards：保持帧动画结束时的状态（在最后一个关键帧中定义）  
  
ImageFrame说明

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
src | `<uri>` | - | 是 | 图片路径  
width | `<length>` | 0 | 否 | 图片宽度  
height | `<length>` | 0 | 否 | 图片高度  
top | `<length>` | 0 | 否 | 图片相对于组件左上角的纵向坐标  
left | `<length>` | 0 | 否 | 图片相对于组件左上角的横向坐标  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

## [#](<#方法>) 方法

支持[通用方法](</vela/quickapp/zh/components/general/methods.html>)

名称 | 参数 | 描述  
---|---|---  
start | - | 开始播放图片帧动画。再次调用，重新从第1帧开始播放  
pause | - | 暂停播放图片帧动画  
stop | - | 停止播放图片帧动画  
resume | - | 继续播放图片帧  
getState | - | 获取播放状态。- playing：播放中 - paused：已暂停 - stopped：已停止  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="container">
      <image-animator class="animator" id="animator" images="{{frames}}" duration="1s" />
      <div class="btn-box">
        <input class="btn" type="button" value="start" @click="handleStart" />
        <input class="btn" type="button" value="stop" @click="handleStop" />
        <input class="btn" type="button" value="pause" @click="handlePause" />
        <input class="btn" type="button" value="resume" @click="handleResume" />
      </div>
    </div>
    </template>
    
    
    
    .container {
      flex-direction: column;
      justify-content: center;
      align-items: center;
      left: 0px;
      top: 0px;
      width: 454px;
      height: 454px;
      background-color: black;
    }
    .animator {
      width: 70px;
      height: 70px;
    }
    .btn-box {
      width: 264px;
      height: 120px;
      flex-wrap: wrap;
      justify-content: space-around;
      align-items: center;
    }
    .btn {
      border-radius: 8px;
      width: 120px;
      margin-top: 8px;
    }
    
    
    
    export default {
      data: {
        frames: [
          {
            src: "/common/asserts/001.png",
          },
          {
            src: "/common/asserts/002.png",
          },
          {
            src: "/common/asserts/003.png",
          },
          {
            src: "/common/asserts/004.png",
          },
          {
            src: "/common/asserts/005.png",
          }
        ],
      },
      handleStart() {
        this.$element('animator').start();
      },
      handlePause() {
        this.$element('animator').pause();
      },
      handleResume() {
        this.$element('animator').resume();
      },
      handleStop() {
        this.$element('animator').stop();
      },
    };
    

![](/vela/quickapp/images/components/image_animator.gif)

---

## #image

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/image.html](https://iot.mi.com/vela/quickapp/zh/components/basic/image.html)

# [#](<#image>) image

## [#](<#概述>) 概述

渲染图片

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
src | `<uri>` | - | 否 | 图片的 uri，同时支持本地和云端路径，支持的图片格式包括png，jpg  
alt | `<uri>` | 'blank' | - | 否 | 加载时显示的占位图；只支持本地图片资源  
  
注意：alt 属性详情如下：

  * 如果 Image 组件没有设置 alt 值，终端会加上默认的灰色占位图；

  * src 为本地图片地址时，不会有占位图；

  * src 为远程图片地址时，如果之前已经成功加载过图片，有本地缓存，则不会有占位图；

  * src 为远程图片地址时，且 Image 组件 的 alt 值传入字符串 "blank" 值，不会有占位图（可避免一些远程地址的小图标第一次加载时瞬间闪烁的现象）；

  * 设置 alt 为本地图片地址时，占位图缩放模式由原来的居中不缩放改为居中保持宽高比缩放，减少了占位图资源文件的分辨率与体积大小。


注：缩放模式可以通过样式值`object-fit`配置，默认值为`cover`（居中保持宽高比缩放），详情查看[样式](<#%E6%A0%B7%E5%BC%8F>)一节

## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
object-fit | contain | cover | none | scale-down | cover | 否 | 图片的缩放类型  
  
注意：

  1. object-fit参数列表如下：

类型 | 描述  
---|---  
contain | 保持宽高比，缩小或者放大，使得图片完全显示在显示边界内，居中显示  
cover | 保持宽高比，缩小或者放大，使得两边都大于或等于显示边界，居中显示  
none | 居中，无缩放  
scale-down | 保持宽高比，缩小或保持不变，取 `contain` 和 `none`中显示较小的一个，居中显示  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
complete | {width: widthValue(px), height: heightValue(px)} | 图片加载完成时触发  
error | - | 图片加载失败时触发  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <image src="/common/logo.png" />
      </div>
    </template>
    

![](/vela/quickapp/images/components/image-example.png)

---

## #marquee

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/marquee.html](https://iot.mi.com/vela/quickapp/zh/components/basic/marquee.html)

# [#](<#marquee>) marquee

## [#](<#概述>) 概述

跑马灯，用来插入一段滚动的文字，默认为单行。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
scrollamount | `<number>` | 6 | 否 | 设置每次滚动时移动的长度，单位：px  
loop | `<number>` | -1 | 否 | 设置 marquee 滚动的次数。如果未指定值，默认值为 −1，表示 marquee 将连续滚动  
direction | `<string>` | left | 否 | 文字滚动方向，支持 left，right  
text-offset | `<number>` | - | 否 | 设置跑马灯首尾相接时，上一段的尾和下一段的头之间的距离，属性值为大于 0 的整数，单位：px  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | rgba(0, 0, 0, 0.54) | 否 | 文本颜色  
font-size | `<length>` | 30px | 否 | 文本尺寸  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
bounce | - | 当 marquee 滚动到结尾时触发  
finish | - | 当 marquee 完成设置的 loop 次数时触发，loop > 0 时有效  
start | - | 当 marquee 开始滚动时触发  
  
## [#](<#方法>) 方法

名称 | 参数 | 描述  
---|---|---  
start | - | 开始滚动 marquee  
stop | - | 停止滚动 marquee  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <marquee id="marquee" scrollamount={{6}} loop={{-1}}>
          scrollamount控制滚动速度，默认值为6（6像素/秒）
        </marquee>
      </div>
    </template>
    
    <script>
      export default {
        onReady() {
          this.$element('marquee').start()
        }
      }
    </script>
    

![](/vela/quickapp/images/components/marquee.gif)

---

## #progress

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/progress.html](https://iot.mi.com/vela/quickapp/zh/components/basic/progress.html)

# [#](<#progress>) progress

## [#](<#概述>) 概述

进度条

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
percent | `<number>` | 0 | 否 | -  
type | horizontal | arc | horizontal | 否 | 进度条类型，不支持动态修改  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

注：horizontal progress 底色为#f0f0f0；height 属性失效

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | #33b4ff 或者 rgb(51, 180, 255) | 否 | 进度条的颜色  
stroke-width | `<length>` | 32px | 否 | 进度条的宽度  
layer-color | `<color>` | #f0f0f0 或者 rgb(240, 240, 240) | 否 | 进度条的背景颜色  
  
type=arc时生效：

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
start-angle | `<deg>` | 240 | 否 | 弧形进度条起始角度，以时钟0点为基线。范围为0到360（顺时针）  
total-angle | `<deg>` | 240 | 否 | 弧形进度条总长度，范围为-360到360，负数表示起点到终点为逆时针  
center-x | `<length>` | 组件宽度的一半 | 否 | 弧形进度条中心位置，（坐标原点为组件左上角顶点）。该样式需要和 center-y \ radius 一起使用  
center-y | `<length>` | 组件高度的一半 | 否 | 弧形进度条中心位置，（坐标原点为组件左上角顶点）。该样式需要和 center-x \ radius 一起使用  
radius | `<length>` | 组件宽高较小值的一半 | 否 | 弧形进度条半径，该样式需要和 center-x \ center-y 一起使用  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div style="flex-direction: column">
        <progress class="p1" percent="40"></progress> 
        <progress class="p2" percent="80" type="arc"></progress>
      </div>
    </template>
    <style>
      .p1 {
        margin-bottom: 10px;
        stroke-width: 12px;
      }
    
      .p2 {
        margin-bottom: 10px;
        stroke-width: 12px;
        start-angle: 0;
        total-angle: 360deg;
      }
    </style>
    

![](/vela/quickapp/images/components/progress.png)

---

## #qrcode2+

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/qrcode.html](https://iot.mi.com/vela/quickapp/zh/components/basic/qrcode.html)

# [#](<#qrcode>) qrcode[2+](</vela/quickapp/zh/guide/version/APILevel2>)

## [#](<#概述>) 概述

生成并显示二维码。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
value | `string` | - | 是 | 用来生成二维码的内容  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | #000000 | 否 | 二维码颜色  
background-color | `<color>` | #ffffff | 否 | 二维码背景颜色  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <qrcode value="https://iot.mi.com" style="color: #008cff;"></qrcode>
      </div>
    </template>
    

![](/vela/quickapp/images/components/qrcode.png)

---

## #span

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/span.html](https://iot.mi.com/vela/quickapp/zh/components/basic/span.html)

# [#](<#span>) span

## [#](<#概述>) 概述

格式化的文本，只能作为[`<text>`](</vela/quickapp/zh/components/basic/text.html>)、[`<a>`](</vela/quickapp/zh/components/basic/a.html>)和`<span>`的子组件。

## [#](<#子组件>) 子组件

仅支持`<span>`

## [#](<#属性>) 属性

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
id | `<string>` | - | 否 | 唯一标识  
style | `<string>` | - | 否 | 样式声明  
class | `<string>` | - | 否 | 引用样式表  
for | `<array>` | - | 否 | 根据数据列表，循环展开当前标签  
if | `<boolean>` | - | 否 | 根据数据 boolean 值，添加或移除当前标签  
  
## [#](<#样式>) 样式

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | rgba(0, 0, 0, 0.54) | 否 | 文本颜色  
font-size | `<length>` | 30px | 否 | 文本尺寸  
font-style | normal | italic | normal | 否 | -  
font-weight | normal | bold | `<number>` | normal | 否 | 当前平台仅支持`normal`与`bold`两种效果，当值为数字时，低于`550`为前者，否则为后者  
text-decoration | underline | line-through | none | none | 否 | -  
  
## [#](<#事件>) 事件

不支持

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <text>
          <span>I am span,</span>
          <span style="color: #f76160">I am span,</span>
          <span style="color: #f76160;text-decoration: underline;">I am span,</span>
        </text>
      </div>
    </template>
    

![](/vela/quickapp/images/components/span.png)

---

## #text

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/basic/text.html](https://iot.mi.com/vela/quickapp/zh/components/basic/text.html)

# [#](<#text>) text

## [#](<#概述>) 概述

文本内容写在标签内容区，支持转义字符`"\"`。

## [#](<#子组件>) 子组件

仅支持`<span>`

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
lines | `<number>` | -1 | 否 | 文本行数，-1 代表不限定行数  
color | `<color>` | rgba(0, 0, 0, 0.54) | 否 | 文本颜色  
font-size | `<length>` | 30px | 否 | 文本尺寸  
font-style | normal | italic | normal | 否 |   
font-weight | normal | bold | `<number>` | normal | 否 | 当前平台仅支持`normal`与`bold`两种效果，当值为数字时，低于`550`为前者，否则为后者  
text-decoration | underline | line-through | none | none | 否 |   
text-align | left | center | right | left | 否 |   
text-indent | `<length>` | `<percentage>` | - | 否 | 规定文本块首行的缩进  
line-height | `<length>` | - | 否 | 文本行高  
text-overflow | clip | ellipsis | clip | 否 | 在设置了行数的情况下生效  
  
**示例**

  * 单行省略
        
        text {
          width: 150px;
          lines: 1;
          text-overflow: ellipsis;
        }
        

![](/vela/quickapp/images/components/text-overflow.png)

  * 多行省略，以两行为例
        
        text {
          width: 100px;
          lines: 2;
          text-overflow: ellipsis;
        }
        

![](/vela/quickapp/images/components/text-overflow-2.png)


## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
        <text>这是一段文本</text>
      </div>
    </template>
    

![](/vela/quickapp/images/components/text-example.png)

---

