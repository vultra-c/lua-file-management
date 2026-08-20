# 快应用_组件_通用

> 来源: 小米快应用官方
> 共 7 篇文档

---

## #动画样式

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/animation-style.html](https://iot.mi.com/vela/quickapp/zh/components/general/animation-style.html)

# [#](<#动画样式>) 动画样式

Vela JS 应用支持开发者制作动画，提供了`transform`类、`transform-origin`类、`animation`类与`transition`类的动画样式属性，且参数格式与 CSS 对齐，更方便开发者上手适配动画。

`transform`可参考此[文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/transform>)。

`transform-origin`可参考此[文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/transform-origin>)。

`animation`可参考此[文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/animation>)。

`transition` 可参考此[文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/transition>)。

## [#](<#动画样式列表>) 动画样式列表

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
transform | `<string>` | - | 见下面 transform 操作  
transform-origin | `<string>` | - | 见下面 transform-origin 操作  
animation-name | `<string>` | - | 与@keyframes 的 name 相呼应，见下面@keyframes 属性  
animation-delay | `<time>` | 0 | 目前支持的单位为[ s(秒) | ms(毫秒) ]  
animation-duration | `<time>` | 0 | 目前支持的单位为[ s(秒) | ms(毫秒) ]  
animation-iteration-count | `<integer>` | `infinite` | 1 | 定义动画播放的次数，可设置为`infinite`无限次播放  
animation-timing-function | linear | ease | ease-in | ease-out | ease-in-out | cubic-bezier(`<number>`, `<number>`, `<number>`, `<number>`) | step-start | step-end | steps(number_of_steps[, step-direction]?) | ease | -  
transition-property | `<string>` | all | 指定执行 transition 效果的通用样式属性名称，参见[详情](<#transition-property-%E6%94%AF%E6%8C%81%E7%9A%84%E9%80%9A%E7%94%A8%E6%A0%B7%E5%BC%8F%E5%B1%9E%E6%80%A7>)  
transition-duration | `<time>` | 0s | 指定 transition 执行时间  
transition-timing-function | linear | ease | ease-in | ease-out | ease-in-out | cubic-bezier(`<number>`, `<number>`, `<number>`, `<number>`) | step-start | step-end | steps(number_of_steps[, step-direction]?) | ease | 指定 transition 执行时的时间函数。该参数释义与 animation 相同  
transition-delay | `<time>` | 0s | 指定 transition 开始执行的时间，即当改变元素属性值后多长时间开始执行 transition 效果  
  
**注** ：

  * animation-timing-function 类型


cubic-bezier(`<number>`, `<number>`, `<number>`, `<number>`) | step-start | step-end | steps(number_of_steps[, step-direction]?)其中：

steps(number_of_steps，step-direction)

名称 | 类型 | 默认值  | 必填  | 描述  
---|---|---|---|---  
number_of_steps | `<integer>` | - | 是 | 表示等间隔步数的正整数  
step-direction | jump-start | jump-end | jump-none | jump-both | start | end | end | 否 | 指示函数左连续或右连续的关键字  
  
  * cubic-bezier(x1, y1, x2, y2)


参数 x1, y1, x2, y2 是 `<number>` 类型的值，代表当前定义的立方贝塞尔曲线中的 P1 和 P2 点的横坐标和纵坐标，x1 和 x2 必须在 [0，1] 范围内，否则当前值无效。

## [#](<#transform-操作>) transform 操作

向元素应用 2D 转换。该属性允许我们对元素进行旋转、缩放、移动。 支持的样式属性列表如下：

名称 | 类型  
---|---  
translate | `<length>` | `<percent>`  
translateX | `<length>` | `<percent>`  
translateY | `<length>` | `<percent>`  
scale | `<number>`  
scaleX | `<number>`  
scaleY | `<number>`  
rotate | `<deg>`  
  
## [#](<#transform-origin-操作>) transform-origin 操作

更改一个元素变形的原点，目前支持改变元素的 X 和 Y 轴。

**注意：**

  * 使用此属性必须先使用 transform 属性。


示例代码：
    
    
    /* 使用 % 值 */
    div {
      transform: rotate(30deg); 
      transform-origin: 20% 40%;
    }
    /* 使用 px 值 */
    div {
      transform: rotate(30deg); 
      transform-origin: 100px 100px;
    }
    

## [#](<#animation-name-属性>) animation-name 属性

指定所采用的一系列动画，属性值的每个名称代表一个由 @keyframes 属性定义的关键帧序列。该属性支持在组件中应用单个动画或多个动画 `1070+` ，应用多个动画时动画同时开始执行。

示例代码：
    
    
    /* 单个动画 */
    animation-name: Color;
    animation-name: translate;
    animation-name: rotate;
    
    /* 多个动画 1070+ */
    animation-name: Color, Opacity;
    animation-name: Width, translate, rotate;
    

## [#](<#keyframes-属性>) @keyframes 属性

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
background-color | `<color>` | - | -  
background-position | `<length>` |`<percentage>`| left | right | top | bottom | center | 0px 0px | 描述了背景图片在容器中绘制的位置，支持 1-4 个参数，详情见[背景图样式](</vela/quickapp/zh/components/general/background-img-styles.html>)  
opacity | `<number>` | - | -  
width/height | `<length>` | - | 暂不支持百分比  
transform | `<string>` | - | 可以对元素进行旋转、缩放、移动  
  
**注** ：

暂时不支持起始值(0%)或终止值(100%)缺省的情况，都需显式指定。

## [#](<#transition-过渡动画>) transition 过渡动画

transition 过渡动画是实现动画的另一种方式。过渡动画可以为元素定义在不同状态之间切换时的过渡效果，比如通过 JavaScript 实现的状态变化。

### [#](<#transition-使用示例>) transition 使用示例

共 4 个样式属性：transition-property、transition-duration、transition-timing-function、transition-delay，直接写在样式当中，使用示例如下：
    
    
    <template>
      <div class="page">
        <div class="div {{otherClass}}"></div>
      </div>
    </template>
    
    <script>
      export default {
        data: {
          otherClass: ""
        },
        onShow() {
          const that = this
          setTimeout(() => {
            that.otherClass = "new-width"
          }, 1000);
        }
      };
    </script>
    
    <style>
    .page {
      padding: 60px;
      align-items: center;
    }
    .div {
      width: 100px;
      height: 200px;
      background-color: red;
      transition-property: width;
      transition-duration: 2000ms;
      transition-timing-function: ease-in;
      transition-delay: 500ms;
    }
    .new-width {
      width: 300px;
    }
    </style>
    

上述 4 个样式属性可简写到一个中，表示当触发 div 的 width 变化后 0.5s，以加速的方式变化至新的 width 值，过渡动画持续 2s：
    
    
    .div {
      transition: width 2000ms ease-in 500ms;
    }
    

### [#](<#transition-property-支持的通用样式属性>) transition-property 支持的通用样式属性

JS 应用中 transition-property 支持的通用样式属性列表如下：

样式名称 | 备注  
---|---  
width | √  
height | √  
opacity | √  
visibility | √  
color | 暂不支持  
transform-origin | 暂不支持  
transform | 暂不支持  
padding | 暂不支持  
padding-[left|top|right|bottom] | 暂不支持  
margin | 暂不支持  
margin-[left|top|right|bottom] | 暂不支持  
border | 暂不支持  
border-[left|top|right|bottom] | 暂不支持  
border-width | √  
border-[left|top|right|bottom]-width | 暂不支持  
border-color | √  
border-[left|top|right|bottom]-color | 暂不支持  
border-radius | 暂不支持  
border-[top|bottom]-[left|right]-radius | 暂不支持  
background | 暂不支持  
background-color | √  
background-size | 暂不支持  
background-position | √  
flex | 暂不支持  
flex-grow | 暂不支持  
flex-shrink | 暂不支持  
flex-basis | 暂不支持  
[left|top|right|bottom] | 暂不支持

---

## #背景图样式

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/background-img-styles.html](https://iot.mi.com/vela/quickapp/zh/components/general/background-img-styles.html)

# [#](<#背景图样式>) 背景图样式

当需要往页面组件内添加一个图片作为组件背景的时候，开发者可以对这个图片背景的大小、重复放置的模式、放置位置进行调整。

## [#](<#background-size-属性>) background-size 属性

该属性定义了背景图片的大小。

参数的个数可以是一个或两个。

有效参数列表如下：

参数 | 描述  
---|---  
`contain` | 等比例缩放背景图片以完全装入容器，可能容器部分显示空白（仅作为单一参数）  
`cover` | 等比例缩放背景图片以完全覆盖容器，可能背景图片部分不可见（仅作为单一参数）  
`auto` | 表示保持原图的尺寸不变。注意，此时原图的尺寸单位为物理分辨率，与手机屏幕分辨率单位一致，非JS 应用内的`1px`长  
`<length>` | 描述图片的具体尺寸，单位：px或dp，不支持浮点计算设置浮点值会被向下取整  
`<percent>` | 描述图片的尺寸占容器对应方向尺寸的百分比，不支持浮点计算设置浮点值会被向下取整  
  
当参数为两个的时候，第一个参数默认解析为水平轴的宽，第二个参数默认解析为竖直轴的高，如果只有一个参数，则将`auto`补充为第二个参数，然后按照双参数的规则解析。

无效参数统一解析为默认值`auto`，即原图尺寸。

**示例**
    
    
    <template>
      <div class="page">
        <text>图片大小 128 * 128</text>
        <text>背景容器 300 * 200</text>
        <image src= "../../common/logo.png">
        <div class="imgBg"></div>
      </div>
    </template>
    <style>
      .page {
        flex-direction: column;
        align-items: center;
        background-color: #000;
      }
      text {
        color: #fff;
        font-size: 24px;
      }
      .imgBg {
        width: 300px;
        height: 200px;
        margin-top: 20px;
        border: 2px solid yellowgreen;
        background-color: yellowgreen;
        background-image: url('../../common/logo.png');
        background-size: 300px 200px;
        background-repeat: no-repeat; // 暂未支持，以防支持之后样式显示异常建议加上
      }
    </style>
    
    

**效果**

![](/vela/quickapp/images/components/background-size.jpeg)

## [#](<#background-repeat-属性-暂未实现>) background-repeat 属性（暂未实现）

该属性定义了背景图片在组件中的重复方式，背景图片可以沿着水平轴、竖直轴、两个轴重复，或者不重复。

参数的个数为一个。

有效参数列表如下：

参数 | 描述  
---|---  
`repeat` | 在水平轴和竖直轴上同时重复绘制图片  
`repeat-x` | 只在水平轴上重复绘制  
`repeat-y` | 只在竖直轴上重复绘制  
`no-repeat` | 不会重复绘制图片  
  
无效参数会被解析为默认值，即`repeat`。

**示例**
    
    
    <div class="container">
      <div class="img"></div>
    </div>
    
    <style>
      .container {
        width: 365px;
        height: 365px;
        background-color: #c7c7c7;
      }
      .img {
        width: 100%;
        height: 100%;
        background-image: url('../common/logo.png');
        /* 等比例缩放背景图片到宽度为组件宽的一半 */
        background-size: 50%;
        /* 在水平方向和竖直方向上重复绘制 */
        background-repeat: repeat;
        /* 背景图片处于组件中央 */
        background-position: center;
      }
    </style>
    
    
    
    .img {
      width: 100%;
      height: 100%;
      background-image: url('../common/logo.png');
      /* 等比例缩放背景图片到宽度为100px */
      background-size: 100px;
      /* 背景图片不重复绘制 */
      background-repeat: no-repeat;
      /* 背景图片距离组件左边缘20px，和上下边缘的距离比为3:7 */
      background-position: left 20px top 30%;
    }
    

## [#](<#background-position-属性>) background-position 属性

该属性定义了背景图片在组件中的位置。

它可以使用1-4个值进行定义。如果使用两个非关键字值，第一个值表示水平位置，第二个值表示垂直位置。如果仅指定一个值，则第二个值默认是 center。如果使用三个或四个值，则长度百分比值是前面关键字值的偏移量。

**一个值的语法：**

值可能是：

  * 关键字 `center`，用来居中背景图片。
  * 关键字 `top`、`left`、`bottom`、`right` 中的一个。用来指定把背景图放在哪一个边界。另一个维度被设置成50%，所以背景图在此维度居中显示。
  * `<length>` 或 `<percentage>`。指定相对于左边界的 x 坐标，y 坐标被设置成 50%，背景图在y轴居中。


**两个值的语法：**

一个定义 x 坐标，另一个定义 y 坐标。每个值可以是：

  * 关键字 `top`、`left`、`bottom`、`right` 中的一个。如果这里给出 `left` 或 `right`，那么这个值定义 x 轴位置，另一个值定义 y 轴位置。如果这里给出 `top` 或 `bottom`，那么这个值定义 y 轴位置，另一个值定义 x 轴位置。
  * `<length>` 或 `<percentage>`。如果另一个值是 `left` 或 `right`，则该值定义相对于顶部边界的 Y。如果另一个值是 `top` 或 `bottom`，则该值定义相对于左边界的 X。如果两个值都是 `<length>` 或 `<percentage>` 值，则第一个定义 X，第二个定义 Y。


_**注意：**_ 如果一个值是 `top` 或 `bottom`，那么另一个值不可能是 `top` 或 `bottom`。如果一个值是 `left` 或 `right`，那么另一个值不可能是 `left` 或 `right`。也就是说，例如，`top top` 和 `left right` 是无效的。

_**排序：**_ 配对关键字时，位置并不重要，写成 `top left` 或 `left top` 其产生的效果是相同的。 使用 `<length>` 或 `<percentage>` 与关键字配对时顺序非常重要，定义 X 的值放在前面，然后是定义 Y 的值， `right 20px` 和 `20px right` 的效果是不相同的，前者有效但后者无效。`left 20%` 或 `20% bottom` 是有效的，因为 X 和 Y 值已明确定义且位置正确。

_**默认值**_ 是 `left top` 或者 `0% 0%`。

**三个值的语法：**

两个值是关键字值，第三个是前面值的偏移量：

  * 第一个值是关键字 `top`、`left`、`bottom`、`right`，或者 `center`。如果设置为 `left` 或 `right`，则定义了 X。如果设置为 `top` 或 `bottom`，则定义了 Y，另一个关键字值定义了 X。
  * `<length>` 或 `<percentage>`，如果是第二个值，则是第一个值的偏移量。如果是第三个值，则是第二个值的偏移量。
  * 单个长度或百分比值是其前面的关键字值的偏移量。一个关键字与两个 `<length>` 或 `<percentage>` 值的组合无效。


**四个值的语法：**

第一个和第三个值是定义 X 和 Y 的关键字值。第二个和第四个值是前面 X 和 Y 关键字值的偏移量：

  * 第一个值和第三个值是关键字值 `top`、`left`、`bottom`、 `right` 之一。如果设置为 `left` 或 `right`，则定义了 X。如果设置为 `top` 或 `bottom`，则定义了 Y，另一个关键字值定义了 X。
  * 第二个和第四个值是 `<length>` 或 `<percentage>`。第二个值是第一个关键字的偏移量。第四个值是第二个关键字的偏移量。


无效参数全部解析为默认值（0px, 0px），即图片显示在组件的左上角。

**示例**
    
    
    <template>
      <div class="page">
        <text>图片大小 128 * 128</text>
        <text>背景容器 300 * 200</text>
        <image src= "../../common/logo.png">
        <div class="imgBg"></div>
      </div>
    </template>
    <style>
      .page {
        flex-direction: column;
        align-items: center;
        background-color: #000;
      }
      text {
        color: #fff;
        font-size: 24px;
      }
      .imgBg {
        width: 300px;
        height: 200px;
        margin-top: 20px;
        border: 2px solid yellowgreen;
        background-color: yellowgreen;
        background-image: url('../../common/logo.png');
        background-size: cover;
        background-position: right bottom;
        background-repeat: no-repeat; // 暂未支持，以防支持之后样式显示异常建议加上
      }
    </style>
    

**效果**

![](/vela/quickapp/images/components/background-position.jpeg)

## [#](<#支持明细>) 支持明细

设备产品 | 说明  
---|---  
小米 S1 Pro 运动健康手表 | 不支持  
小米手环 8 Pro | 不支持  
小米手环 9 / 9 Pro | 不支持  
Xiaomi Watch S3 | 不支持  
Redmi Watch 4 | 不支持  
小米腕部心电血压记录仪 | 不支持  
小米手环 10 | 支持  
Xiaomi Watch S4 | 支持  
REDMI Watch 5 | 支持  
REDMI Watch 6 | 支持  
Xiaomi Watch S5 | 支持

---

## #颜色配置

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/color.html](https://iot.mi.com/vela/quickapp/zh/components/general/color.html)

# [#](<#颜色配置>) 颜色配置

Vela JS 应用支持 `rgb()` and `rgba()` 颜色值设置，

开发者可参考[MDN 文档 (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/color_value>)了解更多颜色值的信息。

## [#](<#颜色值格式示例>) 颜色值格式示例

  * `'#f0f'` (#rgb)
  * `'#ff00ff'` (#rrggbb)
  * `'rgb(255, 0, 255)'`
  * `'rgba(255, 255, 255, 1.0)'`
  * `'#f0ff'` (#rgba)
  * `'#ff00ff00'` (#rrggbbaa)


## [#](<#透明>) 透明

`rgba(0,0,0,0)`还有另外一个简写版本：

  * `'transparent'`


## [#](<#颜色名字>) 颜色名字

你也可以用下面的颜色配置：

  * __aliceblue (#f0f8ff)
  * __antiquewhite (#faebd7)
  * __aqua (#00ffff)
  * __aquamarine (#7fffd4)
  * __azure (#f0ffff)
  * __beige (#f5f5dc)
  * __bisque (#ffe4c4)
  * __black (#000000)
  * __blanchedalmond (#ffebcd)
  * __blue (#0000ff)
  * __blueviolet (#8a2be2)
  * __brown (#a52a2a)
  * __burlywood (#deb887)
  * __cadetblue (#5f9ea0)
  * __chartreuse (#7fff00)
  * __chocolate (#d2691e)
  * __coral (#ff7f50)
  * __cornflowerblue (#6495ed)
  * __cornsilk (#fff8dc)
  * __crimson (#dc143c)
  * __cyan (#00ffff)
  * __darkblue (#00008b)
  * __darkcyan (#008b8b)
  * __darkgoldenrod (#b8860b)
  * __darkgray (#a9a9a9)
  * __darkgreen (#006400)
  * __darkgrey (#a9a9a9)
  * __darkkhaki (#bdb76b)
  * __darkmagenta (#8b008b)
  * __darkolivegreen (#556b2f)
  * __darkorange (#ff8c00)
  * __darkorchid (#9932cc)
  * __darkred (#8b0000)
  * __darksalmon (#e9967a)
  * __darkseagreen (#8fbc8f)
  * __darkslateblue (#483d8b)
  * __darkslategrey (#2f4f4f)
  * __darkturquoise (#00ced1)
  * __darkviolet (#9400d3)
  * __deeppink (#ff1493)
  * __deepskyblue (#00bfff)
  * __dimgray (#696969)
  * __dimgrey (#696969)
  * __dodgerblue (#1e90ff)
  * __firebrick (#b22222)
  * __floralwhite (#fffaf0)
  * __forestgreen (#228b22)
  * __fuchsia (#ff00ff)
  * __gainsboro (#dcdcdc)
  * __ghostwhite (#f8f8ff)
  * __gold (#ffd700)
  * __goldenrod (#daa520)
  * __gray (#808080)
  * __green (#008000)
  * __greenyellow (#adff2f)
  * __grey (#808080)
  * __honeydew (#f0fff0)
  * __hotpink (#ff69b4)
  * __indianred (#cd5c5c)
  * __indigo (#4b0082)
  * __ivory (#fffff0)
  * __khaki (#f0e68c)
  * __lavender (#e6e6fa)
  * __lavenderblush (#fff0f5)
  * __lawngreen (#7cfc00)
  * __lemonchiffon (#fffacd)
  * __lightblue (#add8e6)
  * __lightcoral (#f08080)
  * __lightcyan (#e0ffff)
  * __lightgoldenrodyellow (#fafad2)
  * __lightgray (#d3d3d3)
  * __lightgreen (#90ee90)
  * __lightgrey (#d3d3d3)
  * __lightpink (#ffb6c1)
  * __lightsalmon (#ffa07a)
  * __lightseagreen (#20b2aa)
  * __lightskyblue (#87cefa)
  * __lightslategrey (#778899)
  * __lightsteelblue (#b0c4de)
  * __lightyellow (#ffffe0)
  * __lime (#00ff00)
  * __limegreen (#32cd32)
  * __linen (#faf0e6)
  * __magenta (#ff00ff)
  * __maroon (#800000)
  * __mediumaquamarine (#66cdaa)
  * __mediumblue (#0000cd)
  * __mediumorchid (#ba55d3)
  * __mediumpurple (#9370db)
  * __mediumseagreen (#3cb371)
  * __mediumslateblue (#7b68ee)
  * __mediumspringgreen (#00fa9a)
  * __mediumturquoise (#48d1cc)
  * __mediumvioletred (#c71585)
  * __midnightblue (#191970)
  * __mintcream (#f5fffa)
  * __mistyrose (#ffe4e1)
  * __moccasin (#ffe4b5)
  * __navajowhite (#ffdead)
  * __navy (#000080)
  * __oldlace (#fdf5e6)
  * __olive (#808000)
  * __olivedrab (#6b8e23)
  * __orange (#ffa500)
  * __orangered (#ff4500)
  * __orchid (#da70d6)
  * __palegoldenrod (#eee8aa)
  * __palegreen (#98fb98)
  * __paleturquoise (#afeeee)
  * __palevioletred (#db7093)
  * __papayawhip (#ffefd5)
  * __peachpuff (#ffdab9)
  * __peru (#cd853f)
  * __pink (#ffc0cb)
  * __plum (#dda0dd)
  * __powderblue (#b0e0e6)
  * __purple (#800080)
  * __rebeccapurple (#663399)
  * __red (#ff0000)
  * __rosybrown (#bc8f8f)
  * __royalblue (#4169e1)
  * __saddlebrown (#8b4513)
  * __salmon (#fa8072)
  * __sandybrown (#f4a460)
  * __seagreen (#2e8b57)
  * __seashell (#fff5ee)
  * __sienna (#a0522d)
  * __silver (#c0c0c0)
  * __skyblue (#87ceeb)
  * __slateblue (#6a5acd)
  * __slategray (#708090)
  * __snow (#fffafa)
  * __springgreen (#00ff7f)
  * __steelblue (#4682b4)
  * __tan (#d2b48c)
  * __teal (#008080)
  * __thistle (#d8bfd8)
  * __tomato (#ff6347)
  * __turquoise (#40e0d0)
  * __violet (#ee82ee)
  * __wheat (#f5deb3)
  * __white (#ffffff)
  * __whitesmoke (#f5f5f5)
  * __yellow (#ffff00)
  * __yellowgreen (#9acd32)

---

## #通用事件

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/events.html](https://iot.mi.com/vela/quickapp/zh/components/general/events.html)

# [#](<#通用事件>) 通用事件

通用事件，即所有组件都支持的`事件回调`。

开发者可以在组件标签上使用`on{eventName}`（如`onclick`）或`@{eventName}`（如`@click`）注册回调事件。

更详细的讲解，可查阅[事件绑定](</vela/quickapp/zh/guide/framework/template/event.html>)文档了解。

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
          <text onclick="clickFunction1">line 1</text>
          <text @click="clickFunction2">line 2</text>
      </div>
    </template>
    

## [#](<#通用事件列表>) 通用事件列表

名称 | 参数 | 描述 | 冒泡  
---|---|---|---  
touchstart | TouchEvent | 手指刚触摸组件时触发 | 支持  
touchmove | TouchEvent | 手指触摸后移动时触发 | 支持  
touchend | TouchEvent | 手指触摸动作结束时触发 | 支持  
click | MouseEvent | 组件被点击时触发 | 支持  
longpress | MouseEvent | 组件被长按时触发 | 支持  
swipe | { direction: <`"left"` | `"right"` | `"up"` | `"down"`> } | 组件上快速滑动后触发（滑动方向有滚动条时不触发该事件）  
参数说明：  
left： 向左滑动；  
right： 向右滑动；  
up： 向上滑动；  
down：向下滑动； | 不支持  
  
## [#](<#事件对象>) 事件对象

### [#](<#_1、touchevent-类型说明>) 1、TouchEvent 类型说明：

属性 | 类型 | 说明  
---|---|---  
touches | TouchList | 触摸事件，当前停留在屏幕中的触摸点信息的数组  
changedTouches | TouchList | 触摸事件，当前变化的触摸点信息的数组。changedTouches 数据格式同 touches， 表示有变化的触摸点，如从无变有（touchstart），位置变化（touchmove），从有变无（touchend），  
比如用户手指离开屏幕时，touches 数组中无数据，而 changedtouches 则会保存离开前的数据  
  
**其中，TouchList 是 Touch 对象的集合。**

### [#](<#_2、touch-类型说明>) 2、Touch 类型说明

属性 | 类型 | 说明  
---|---|---  
identifier | number | 触摸点的标识符。对于多点同时触摸则是 [0,1,2,3,...]，分别表示第一个手指、第二个手指...  
一次触摸动作(手指按下到手指离开的过程)，在整个屏幕移动过程中，该标识符不变，可以用来判断是否是同一次触摸过程  
clientX | number | 距离可见区域左边沿的 X 轴坐标，不包含任何滚动偏移  
clientY | number | 距离可见区域上边沿的 Y 轴坐标，不包含任何滚动偏移以及状态栏和 titlebar 的高度  
pageX | number | 距离可见区域左边沿的 X 轴坐标，包含任何滚动偏移  
pageY | number | 距离可见区域上边沿的 Y 轴坐标，包含任何滚动偏移。（不包含状态栏和 titlebar 的高度）  
offsetX | number | 距离事件触发对象左边沿 X 轴的距离  
offsetY | number | 距离事件触发对象上边沿 Y 轴的距离  
  
### [#](<#_3、mouseevent-类型说明>) 3、MouseEvent 类型说明

属性 | 类型 | 说明  
---|---|---  
clientX | number | 距离可见区域左边沿的 X 轴坐标，不包含任何滚动偏移  
clientY | number | 距离可见区域上边沿的 Y 轴坐标，不包含任何滚动偏移以及状态栏和 titlebar 的高度  
pageX | number | 距离可见区域左边沿的 X 轴坐标，包含任何滚动偏移  
pageY | number | 距离可见区域上边沿的 Y 轴坐标，包含任何滚动偏移。（不包含状态栏和 titlebar 的高度）  
offsetX | number | 距离事件触发对象左边沿 X 轴的距离  
offsetY | number | 距离事件触发对象上边沿 Y 轴的距离  
  
## [#](<#示例>) 示例

如下，在 div 上绑定了 click 和 touchmove 事件，触发事件时将事件打印出来。
    
    
    <template>
      <div class="root-page">
        <div class="touch-region" onclick="click" ontouchmove="move"></div>
      </div>
    </template>
    
    <style>
      .root-page {
        flex-direction: column;
        align-items: center;
      }
    
      .touch-region {
        width: 80%;
        height: 20%;
        background-color: #444444;
      }
    
    </style>
    
    <script>
      export default {
        private: {},
        click(event) {
          console.log("click event fired")
        },
        move(event) {
          console.log("move event touches:" + JSON.stringify(event.touches))
          console.log("move event changedTouches:" + JSON.stringify(event.changedTouches))
        }
      }
    
    </script>
    

**打印结果如下，click 事件：**
    
    
    move event touches:[
      {
        "offsetX": 296,
        "identifier": 0,
        "offsetY": 113.48148345947266,
        "clientY": 113.48148345947266,
        "clientX": 360,
        "pageY": 113.48148345947266,
        "pageX": 360
      }
    ]
    
    
    
    move event changedTouches:[
      {
        "offsetX": 296,
        "identifier": 0,
        "offsetY": 113.48148345947266,
        "clientY": 113.48148345947266,
        "clientX": 360,
        "pageY": 113.48148345947266,
        "pageX": 360
      }
    ]
    
    
    
    click event fired

---

## #通用方法

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/methods.html](https://iot.mi.com/vela/quickapp/zh/components/general/methods.html)

# [#](<#通用方法>) 通用方法

通用方法，是所有组件都可以调用的方法。在组件使用id标记 id 属性后，开发者可通过this.$element('idName')获取 dom 节点，再调用通用方法。

通过 this.$element 获取到的 dom 对象，提供两个 api 供调用：

### [#](<#getboundingclientrect-object-object>) getBoundingClientRect(Object object)[2+](</vela/quickapp/zh/guide/version/APILevel2>)

返回元素的大小及其相对于视窗的位置，需要在页面的 onShow 生命周期之后调用。

#### [#](<#参数>) 参数

Object object

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
success | function |  | 否 | 接口调用成功的回调函数  
fail | function |  | 否 | 接口调用失败的回调函数  
complete | function |  | 否 | 接口调用结束的回调函数（调用成功、失败都会执行）  
  
#### [#](<#object-success-回调函数参数说明>) object.success 回调函数参数说明

Object rect

属性 | 类型 | 描述  
---|---|---  
left | number | 元素的左边界坐标  
right | number | 元素的右边界坐标  
top | number | 元素的上边界坐标  
bottom | number | 元素的下边界坐标  
width | number | 元素的宽度  
height | number | 元素的高度  
  
#### [#](<#代码示例>) 代码示例
    
    
    <template>
      <div>
        <div id="box1" class="box-normal"></div>
        <div id="box2" class="box-normal"></div>
      </div>
    </template>
    <script>
      export default {
        onShow(){
          this.$element('box1').getBoundingClientRect({
            success: function(data) {
              const { top, bottom, left, right, width, height } = data;
              console.log(data);
            },
            fail: (errorData, errorCode) => {
              console.log(`错误原因：${JSON.stringify(errorData)}, 错误代码：${errorCode}`)
            },
            complete: function() {
              console.info('complete')
            }
          })
        }
      }
    </script>
    

### [#](<#focus-object-object>) focus(Object object)

使组件获得或者失去焦点的方法

#### [#](<#参数-2>) 参数

属性 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
focus | boolean | true | 否 | 使组件获得或者失去焦点，聚焦时可触发 focus 伪类效果（focus 伪类样式还未支持）  
  
#### [#](<#代码示例-2>) 代码示例
    
    
    <script>
      // 聚焦效果
      this.$element('box1').focus();
      // 聚焦效果
      this.$element('box2').focus({focus:true});
      // 失焦效果
      this.$element('box3').focus({focus:false});
    </script>

---

## #通用属性

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/properties.html](https://iot.mi.com/vela/quickapp/zh/components/general/properties.html)

# [#](<#通用属性>) 通用属性

通用属性，即所有组件都支持的属性。

开发者可以在所有的组件标签上都使用`通用属性`。

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div>
          <text id="text1" class="text-normal">line 1</text>
          <text id="text2" class="text-normal red">line 2</text>
      </div>
    </template>
    

## [#](<#常规属性>) 常规属性

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
id | `<string>` | - | 唯一标识  
style | `<string>` | - | 样式声明  
class | `<string>` | - | 引用样式表  
  
## [#](<#渲染属性>) 渲染属性

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
for | `<array>` | - | 根据数据列表，循环展开当前标签  
if | `<boolean>` | - | 根据数据 boolean 值，添加或移除当前标签  
show | `<boolean>` | - | 根据数据 boolean 值，显示或隐藏当前标签，相当于控制{ display: flex | none }  
  
渲染属性工作方式详见[template 模板](</vela/quickapp/zh/guide/framework/template/>)。

注意

属性和样式不能混用，不能在属性字段中进行样式设置。

## [#](<#data-属性>) data 属性

给组件绑定 data 属性，然后运行时通过 `dataset` 获取，方便进一步判断。

**示例：**
    
    
    <template>
      <div>
        <div id="elNode1" data-person-name="Jack"></div>
      </div>
    </template>
    
    <script>
      export default {
        onReady () {
          const el = this.$element('elNode1')
          const elData = el.dataset.personName
          console.info(`输出data属性： ${elData}`)
        }
      }
    </script>

---

## #通用样式

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/general/style.html](https://iot.mi.com/vela/quickapp/zh/components/general/style.html)

# [#](<#通用样式>) 通用样式

通用样式，即所有组件都可以支持的样式。

它们均与 css 的属性样式用法保持一致，开发者可写在`内联样式`或`<style>`标签里，实现组件样式的定制化。

关于组件样式的设置，可以参考此[文档](</vela/quickapp/zh/guide/framework/style/page-style-and-layout.html>)。

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <div class="box-normal" style="background-color:#f76160"></div>
        <div class="box-normal"></div>
      </div>
    </template>
    
    <style>
      .page {
        padding: 30px;
        background-color: white;
      }
    
      .box-normal {
        background-color: #09ba07;
        width: 100px;
        height: 100px;
        border-radius: 8px;
        margin-right: 10px;
      }
    </style>
    

![](/vela/quickapp/images/components/general-style.png)

## [#](<#属性列表>) 属性列表

**注** ：通用样式均为非必填项。

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
width | `<length>` | `<percentage>` | - | 未设置时使用组件自身内容需要的宽度  
height | `<length>` | `<percentage>` | - | 未设置时使用组件自身内容需要的高度  
min-width | auto | `<length>` | `<percentage>` | auto | 指定元素的最小宽度。该属性不能为负值，默认值 `auto` 为弹性元素的默认最小宽度，下同  
min-height | auto | `<length>` | `<percentage>` | auto | 指定元素的最小高度  
max-width | none | `<length>` | `<percentage>` | none | 指定元素的最大宽度。该属性不能为负值，默认值 `none` 表示不做限制，下同  
max-height | none | `<length>` | `<percentage>` | none | 指定元素的最大高度  
padding | `<length>` | 0 | 简写属性，在一个声明中设置所有的内边距属性，该属性可以有 1 到 4 个值，具体请参考[MDN (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/padding>)文档  
padding-[left|top|right|bottom] | `<length>` | 0 | 设置一个元素的某个方向的内边距，padding 区域指一个元素的内容和其边界之间的空间，该属性不能为负值  
margin | `<length>` | 0 | 简写属性，在一个声明中设置所有的外边距属性，该属性可以有 1 到 4 个值，具体请参考[MDN (opens new window)](<https://developer.mozilla.org/zh-CN/docs/Web/CSS/margin>)文档  
margin-[left|top|right|bottom] | `<length>` | 0 | 设置一个元素的某个方向的外边距，该属性不能为负值  
border | - | 0 | 简写属性，在一个声明中设置所有的边框属性，可以按顺序设置属性 width style color，不设置的值为默认值  
border-style | solid | solid | 暂时仅支持 1 个值，为元素的所有边框设置样式  
border-width | `<length>` | 0 | 设置元素的所有边框宽度  
border-color | `<color>` | black | 设置元素的所有边框颜色，颜色值的填入请参考 [颜色配置](</vela/quickapp/zh/components/general/color.html>)  
border-radius | `<length>` | `<percentage>` | 0 | border-radius 属性允许你设置元素的外边框圆角。设置时需要同时设置 border-width、border-color。radius 的幅度不会超过矩形较短边的一半  
background-color | `<color>` | - | 颜色值的填入请参考 [颜色配置](</vela/quickapp/zh/components/general/color.html>)  
color | `<color>` | - | 颜色值的填入请参考 [颜色配置](</vela/quickapp/zh/components/general/color.html>)  
background-image | `<uri>` | - | 支持本地图片资源与网络图片资源；使用`internal://`协议图片需将aiot-toolkit升级到1.1.2以上版本  
background-size | contain | cover | auto | `<length>` | `<percentage>` | auto auto | 设置背景图片大小，详情见[背景图样式](</vela/quickapp/zh/components/general/background-img-styles.html>)  
background-repeat | repeat | repeat-x | repeat-y | no-repeat | repeat | [暂不支持] 设置是否及如何重复绘制背景图像，详情见[背景图样式](</vela/quickapp/zh/components/general/background-img-styles.html>)  
background-position | `<length>` |`<percentage>`| left | right | top | bottom | center | 0px 0px | 设置背景图片在容器中绘制的位置，支持 1-4 个参数，详情见[背景图样式](</vela/quickapp/zh/components/general/background-img-styles.html>)  
box-shadow [3+](</vela/quickapp/zh/guide/version/APILevel3>) | `<length>` `<length>` `<color>` |  
`<length>` `<length>` `<length>` `<color>` |  
`<length>` `<length>` `<length>` `<length>` `<color>`  
| - | 设置元素的阴影效果，该属性可设置的值包括阴影的 X 轴偏移量、Y 轴偏移量、模糊半径、扩散半径和[颜色](</vela/quickapp/zh/components/general/color.html>)。  
写法举例：  
box-shadow: 60px -16px teal，值分别对应：x轴偏移量、y轴偏移量、[阴影颜色](</vela/quickapp/zh/components/general/color.html>)；  
box-shadow: 10px 5px 5px black，值分别对应：x轴偏移量、y轴偏移量、阴影模糊半径、[阴影颜色](</vela/quickapp/zh/components/general/color.html>)；  
box-shadow: 2px 2px 2px 1px rgba(0, 0, 0, 0.2)，值分别对应：x轴偏移量、y轴偏移量、阴影模糊半径、阴影扩散半径、[阴影颜色](</vela/quickapp/zh/components/general/color.html>)  
opacity | `<number>` | 1 | opacity 属性指定了一个元素的透明度  
display | flex | none | flex | JS 应用只支持 flex 布局；将当前元素的 display 设置为 none JS 应用页面将不渲染此元素  
visibility | visible | hidden | visible | visibility 属性控制显示或隐藏元素而不更改文档的布局  
flex | `<number>` | - | 父容器为`<div>、<list-item>`时生效  
flex-grow | `<number>` | 0 | 父容器为`<div>、<list-item>`时生效  
flex-shrink | `<number>` | 1 | 父容器为`<div>、<list-item>`时生效  
flex-basis | `<number>` | -1 | 父容器为`<div>、<list-item>`时生效  
flex-direction | `<string>` | row | 默认为横向`row`，父容器为`<div>、<list-item>`时生效  
align-items | `<string>` | flex-start | align-items 定义了伸缩项目可以在伸缩容器的当前行的侧轴上对齐方式。flex-start(默认值)：伸缩项目在侧轴起点边的外边距紧靠住该行在侧轴起始的边。flex-end：伸缩项目在侧轴终点边的外边距靠住该行在侧轴终点的边 。center：伸缩项目的外边距盒在该行的侧轴上居中放置。baseline：伸缩项目根据他们的基线对齐。stretch：伸缩项目拉伸填充整个伸缩容器。此值会使项目的外边距盒的尺寸在遵照「min/max-width/height」属性的限制下尽可能接近所在行的尺寸  
justify-content | `<string>` | flex-start | justify-content 定义了伸缩项目沿着主轴线的对齐方式。flex-start(默认值)：伸缩项目向一行的起始位置靠齐。flex-end：伸缩项目向一行的结束位置靠齐。center：伸缩项目向一行的中间位置靠齐。space-between：伸缩项目会平均地分布在行里。第一个伸缩项目一行中的最开始位置，最后一个伸缩项目在一行中最终点位置。space-around：伸缩项目会平均地分布在行里，两端保留一半的空间  
position | absolute | relative | relative | 支持 relative 和 absolute 属性值，且默认值为 relative；父容器为`<list>、<swiper>`时不生效  
[left|top|right|bottom] | `<length>` | - | 一般配合`absolute`布局使用，支持单位px，暂不支持百分比

---

