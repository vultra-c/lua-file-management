# 快应用_组件_容器组件

> 来源: 小米快应用官方
> 共 6 篇文档

---

## #div

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/div.html](https://iot.mi.com/vela/quickapp/zh/components/container/div.html)

# [#](<#div>) div

## [#](<#概述>) 概述

基础容器，用作页面结构的根节点或将内容进行分组。

## [#](<#子组件>) 子组件

支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <div style="flex-direction: row;">
          <text class="item color-1">1</text>
          <text class="item color-2">2</text>
          <text class="item color-3">3</text>
        </div>
      </div>
    </template>
    <style>
      .page {
        margin: 20px;
        flex-direction: column;
        background-color: white;
      }
    
      .item {
        height: 100px;
        width: 100px;
        text-align: center;
        margin-right: 10px;
      }
      
      .color-1 {
        background-color: #09ba07;
      }
      
      .color-2 {
        background-color: #f76160;
      }
      
      .color-3 {
        background-color: #0faeff;
      }
    </style>
    

![](/vela/quickapp/images/components/div.png)

---

## #list

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/list.html](https://iot.mi.com/vela/quickapp/zh/components/container/list.html)

# [#](<#list>) list

## [#](<#概述>) 概述

列表视图容器，包含一系列相同结构的列表项，连续、多行呈现同类数据。

## [#](<#子组件>) 子组件

仅支持[`<list-item>`](</vela/quickapp/zh/components/container/list-item.html>)

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
bounces | `<boolean>` | false | 否 | 是否边界回弹  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

使用时需要显式地设置高度。

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
scroll | {scrollX: `<number>`, scrollY: `<number>`, scrollState: `<stateValue>`} | 列表滑动；  
stateValue 取值说明：  
0：list停止滑动  
1：list正在通过用户的手势滑动  
2：list正在滑动，用户已松手  
scrollbottom | - | 列表滑动到底部  
scrolltop | - | 列表滑动到顶部  
scrollend | - | 列表滑动结束  
scrolltouchup | - | 列表滑动过程中手指抬起  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <list class="list" bounces="true" 
          onscroll="onScroll" 
          onscrolltop="onScrollTop" 
          onscrollbottom="onScrollBottom"
          onscrolltouchup="onScrollTouchup">
          <list-item for="{{productList}}" class="item" type="item">
            <text>{{$item.name}}: {{$item.price}}</text>
          </list-item>
        </list>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          productList: [
            { name: '衣服', price: '100' },
            { name: '裤子', price: '200' },
            { name: '鞋子', price: '300' },
            { name: '帽子', price: '60' },
            { name: '雨伞', price: '300' },
            { name: '书包', price: '60' },
            { name: '书本', price: '30' }
          ],
        },
        onScroll(e) {
          console.log('### list onScroll evt: ', e)
        },
        onScrollTop(e) {
          console.log('### list onScrollTop evt: ', e)
        },
        onScrollBottom(e) {
          console.log('### list onScrollBottom evt: ', e)
        },
        onScrollTouchup(e) {
          console.log('### list onScrollTouchup evt: ', e)
        }
      }
    </script>
    
    <style>
      .page {
        justify-content: center;
        align-items: center;
        background-color: #000;
      }
    
      .list {
        width: 300px;
        height: 200px;
        border: 1px solid #fff;
      }
    
      text {
       color: #fff;
      }
      .item {
        height: 40px;
        width: 100%;
        align-items: center;
        justify-content: center;
        border: 1px solid #fff;
      }
    </style>
    

### [#](<#效果展示>) 效果展示

![](/vela/quickapp/images/components/list-methods.jpeg)

## [#](<#方法>) 方法

名称 | 参数 | 描述  
---|---|---  
scrollTo | Object | list 滚动到指定 item 位置  
scrollBy | Object | 使 list 的内容滑动一定距离  
  
**scrollTo 的参数说明：**

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
index | number | 0 | 否 | list 滚动的目标 item 位置  
behavior | smooth / instant / auto | auto | 否 | 是否平滑滑动，支持参数 smooth (平滑滚动)，instant (瞬间滚动)，默认值 auto，效果等同于 instant  
  
**scrollBy 的参数说明：**

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
left | number | 0 | 否 | 从当前位置水平方向滑动距离，单位 px。值为正时向左滑动，为负时向右滑动。flex-direction 为 column 或 column-reverse 时不生效  
top | number | 0 | 否 | 从当前位置垂直方向滑动距离，单位 px。值为正时向上滑动，为负时向下滑动。flex-direction 为 row 或 row-reverse 时不生效  
behavior | smooth / instant / auto | auto | 否 | 是否平滑滑动，支持参数 smooth (平滑滚动)，instant (瞬间滚动)，默认值 auto，效果等同于 instant

---

## #list-item

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/list-item.html](https://iot.mi.com/vela/quickapp/zh/components/container/list-item.html)

# [#](<#list-item>) list-item

## [#](<#概述>) 概述

[`<list>`](</vela/quickapp/zh/components/container/list.html>)的子组件，用来展示列表具体 item，宽度默认充满 list 组件。

## [#](<#子组件>) 子组件

支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
type | `<string>` | - | 是 | list-item 类型，值为自定义的字符串，如'loadMore'。**相同的 type 的 list-item 必须具备完全一致的 DOM 结构** 。因此，在 list-item 内部需谨慎使用 if 和 for，因为 if 和 for 可能造成相同的 type 的 list-item 的 DOM 结构不一致，从而引发错误  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

为了达到组件复用、优化性能的目的，请显示指定宽度和高度。

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <list class="list">
          <list-item for="{{productList}}" class="item" type="list-item">
            <text>{{$item.name}}: {{$item.price}}</text>
          </list-item>
        </list>
      </div>
    </template>
    
    <script>
      export default {
        data: {
          productList: [
            { name: '衣服', price: '100' },
            { name: '裤子', price: '200' }
          ],
        }
      }
    </script>
    
    <style>
      .page {
        padding: 30px;
        background-color: white;
      }
    
      .list {
        width: 100%;
        height: 100%;
      }
    
      .item {
        height: 40px;
      }
    </style>
    

### [#](<#效果展示>) 效果展示

![](/vela/quickapp/images/components/list.png)

---

## #scroll2+

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/scroll.html](https://iot.mi.com/vela/quickapp/zh/components/container/scroll.html)

# [#](<#scroll>) scroll[2+](</vela/quickapp/zh/guide/version/APILevel2>)

## [#](<#概述>) 概述

滚动视图容器。竖向或水平方向滚动容器，竖向滚动需要设置定高，水平滚动需要设置定宽。

## [#](<#子组件>) 子组件

支持。也支持嵌套子 scroll。

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
scroll-x | `<boolean>` | false | 否 | 是否允许横向滚动  
scroll-y | `<boolean>` | false | 否 | 是否允许纵向滚动  
scroll-top | `<number>` | `<string>` |  | 否 | 设置竖向滚动条位置，内容顶部到 scroll 顶部的距离，如果有滚动吸附效果则先滚动再吸附  
scroll-bottom | `<number>` | `<string>` |  | 否 | 设置竖向滚动条位置，内容底部到 scroll 底部的距离，如果有滚动吸附效果则先滚动再吸附。同时设置 scroll-top 和scroll-bottom 以scroll-top为准  
scroll-left | `<number>` | `<string>` |  | 否 | 设置横向滚动条位置，内容左侧到 scroll 左侧的距离，如果有滚动吸附效果则先滚动再吸附  
scroll-right | `<number>` | `<string>` |  | 否 | 设设置横向滚动条位置，内容右侧到 scroll 右侧的距离，如果有滚动吸附效果则先滚动再吸附。同时设置 scroll-left 和scroll-right 以scroll-left为准  
bounces | `<boolean>` | false | 否 | 是否边界回弹  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 描述  
---|---|---|---  
scroll-snap-type[3+](</vela/quickapp/zh/guide/version/APILevel3>) | - | none | 与scroll-snap-align配合使用，作用在scroll组件上，表示scroll的滚动吸附类型。第一个参数为x或y，表示水平方向上滚动或竖直方向上滚动；第二个参数为 mandatory、proximity、 cross。mandatory：表示选择距离最近的锚点吸附；proximity：表示距离吸附锚点不到容器高度的 30% 时才会吸附；cross：表示子组件能够被吸附的边界出现在 scroll 视口内才会吸附。默认为 proximity   
aiot-toolkit最低版本：1.1.4  
scroll-snap-align[3+](</vela/quickapp/zh/guide/version/APILevel3>) | none | start | center | end | edge | none | 与scroll-snap-type配合使用，作用在scroll子组件上，表示子组件和scroll的对⻬形式。none：表示无需对⻬，默认值；start：表示组件和scroll起始边对⻬；center：表示组件和scroll中心对⻬；end：表示组件和scroll终止边对⻬；edge：在滚动方向上，组件和 scroll 起始边或者结束边对齐   
aiot-toolkit最低版本：1.1.4  
scroll-snap-stop[3+](</vela/quickapp/zh/guide/version/APILevel3>) | normal | always | normal | 值为 always 时不能跨越元素进行吸附   
aiot-toolkit最低版本：1.1.4  
  
### [#](<#示例代码>) 示例代码

  * scroll-snap-type & scroll-snap-align
        
        <template>
          <div class="page">
            <div class="scroll-container">
              <scroll class="box" scroll-x="true" style="scroll-snap-type: x proximity;">
                <text class="scroll-item color-1">A</text>
                <text class="scroll-item color-2">B</text>
                <text class="scroll-item color-1" style="scroll-snap-align: start;">C</text>
                <text class="scroll-item color-2">D</text>
                <text class="scroll-item color-1" style="scroll-snap-align: center;">E</text>
                <text class="scroll-item color-2">F</text>
                <text class="scroll-item color-1" style="scroll-snap-align: end;">G</text>
                <text class="scroll-item color-2">H</text>
              </scroll>
            </div>
          </div>
        </template>
        
        <script>
          export default {}
        </script>
        
        <style>
          .page {
            padding: 60px;
            flex-direction: column;
          }
        
          .scroll-container {
            width: 100%;
          }
        
          .box {
            margin-bottom: 30px;
            height: 100px;
            width: 200px;
          }
        
          .scroll-item {
            width: 80%;
            height: 100px;
            text-align: center;
          }
        
          .color-1 {
            background-color: cadetblue;
          }
        
          .color-2 {
            background-color: orangered;
          }
        </style>
        


![](/vela/quickapp/images/components/scroll.gif)

  * scroll-snap-stop
        
        <template>
          <div class="page">
            <div class="scroll-container">
              <scroll class="box" scroll-x="true" style="scroll-snap-type: x cross;scroll-snap-stop:always;">
                <text class="scroll-item color-1">A</text>
                <text class="scroll-item color-2" style="scroll-snap-align: center;">B</text>
                <text class="scroll-item color-1" style="scroll-snap-align: center;">C</text>
                <text class="scroll-item color-2" style="scroll-snap-align: center;">D</text>
                <text class="scroll-item color-1" style="scroll-snap-align: center;">E</text>
                <text class="scroll-item color-2" style="scroll-snap-align: center;">F</text>
                <text class="scroll-item color-1">G</text>
              </scroll>
            </div>
          </div>
        </template>
        
        <script>
          export default {}
        </script>
        
        <style>
          .page {
            padding: 60px;
            flex-direction: column;
          }
        
          .scroll-container {
            width: 100%;
          }
        
          .box {
            margin-bottom: 30px;
            height: 100px;
            width: 200px;
          }
        
          .scroll-item {
            width: 80%;
            height: 100px;
            text-align: center;
          }
        
          .color-1 {
            background-color: cadetblue;
          }
        
          .color-2 {
            background-color: orangered;
          }
        </style>
        


![](/vela/quickapp/images/components/scroll-snap-stop.gif)

## [#](<#事件>) 事件

名称 | 参数 | 描述  
---|---|---  
scrolltop | - | 滚动到顶部触发  
scrollbottom | - | 滚动到底部触发  
scroll | { scrollX, scrollY } | 滚动触发，scrollX 表示滚动的水平距离；scrollY 表示滚动的垂直距离  
  
## [#](<#方法>) 方法

名称 | 参数 | 返回值 | 描述  
---|---|---|---  
getScrollRect | 无 | `<object>` | 获取滚动内容的尺寸  
scrollTo | Object | 无 | 让滚动组件窗口滚动到某个坐标位置  
scrollBy | Object | 无 | 使滚动组件窗口滚动一定距离  
  
### [#](<#scrollto方法object参数>) scrollTo方法Object参数

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
left | number | - | 否 | 滚动组件的横轴坐标值，不传表示横轴不滚动，负数按0处理，超出滚动范围按滚动边界处理  
top | number | - | 否 | 滚动组件的纵轴坐标值，不传表示纵轴不滚动，负数按0处理，超出滚动范围按滚动边界处理  
behavior | smooth / instant / auto | auto | 否 | 滚动行为，smooth-平滑滚动，instant-瞬间滚动，auto-等同于instant  
  
### [#](<#scrollby方法object参数>) scrollBy方法Object参数

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
left | number | - | 否 | 滚动组件的横轴偏移量，可以是负数，超出滚动范围按滚动边界处理  
top | number | - | 否 | 滚动组件的纵轴偏移量，可以是负数，超出滚动范围按滚动边界处理  
behavior | smooth / instant / auto | auto | 否 | 滚动行为，smooth-平滑滚动，instant-瞬间滚动，auto-等同于instant  
  
### [#](<#返回值-异步>) 返回值（异步）

属性 | 类型 | 描述  
---|---|---  
width | `<number>` | 滚动内容的宽度，包含border和padding  
height | `<number>` | 滚动内容的高度，包含border和padding  
  
## [#](<#示例代码-2>) 示例代码
    
    
    <template>
      <div class="page">
          <scroll id="scrollId" scroll-y="true" onscrolltop="handleScrollTop">
              <div class="item">
                 <text>北京</text>
              </div>
              <div class="item">
                 <text>上海</text>
              </div>
              <div class="item">
                 <text>广州</text>
              </div>
              <div class="item">
                 <text>深圳</text>
              </div>
           </scroll>
      </div>
    </template>
    
    <script>
      export default {
        onShow() {
          this.$element('scrollId').getScrollRect({
            success({ width, height }) {
              console.log('宽度', width);
              console.log('高度', height);  
            }
          })
    
          // this.scrollTo()
          // this.scrollBy()
        },
        handleScrollTop() {
          console.info('scrolled top.')
        },
        scrollTo() {
          this.$element('scrollId').scrollTo({
            top: 1000,
            left: 0,
            behavior: 'smooth'
          })
        },
        scrollBy() {
          this.$element('scrollId').scrollBy({
            top: 1000,
            left: 0,
            behavior: 'smooth'
          })
        }
      }
    </script>
    <style>
      .page {
        justify-content: center;
        align-items: center;
      }
    
      #scrollId {
        width: 50%;
        height: 100px;
        flex-direction: column;
        background-color: yellowgreen;
      }
    
      .item {
        width: 100%;
        height: 50px;
        justify-content: center;
      }
    </style>

---

## #stack

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/stack.html](https://iot.mi.com/vela/quickapp/zh/components/container/stack.html)

# [#](<#stack>) stack

## [#](<#概述>) 概述

基本容器，子组件排列方式为层叠排列，每个直接子组件按照先后顺序依次堆叠，覆盖前一个子组件。

## [#](<#子组件>) 子组件

支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <stack class="stack">
          <div class="box box1"></div>
          <div class="box box2"></div>
          <div class="box box3"></div>
          <div class="box box4"></div>
        </stack>
      </div>
    </template>
    
    <style>
      .page {
        padding: 30px;
        background-color: white;
      }
    
      .box {
        border-radius: 8px;
        width: 100px;
        height: 100px;
      }
    
      .box1 {
        width: 200px;
        height: 200px;
        background-color: #3f56ea;
      }
    
      .box2 {
        left: 20px;
        top: 20px;
        background-color: #00bfc9;
      }
    
      .box3 {
        left: 50px;
        top: 50px;
        background-color: #47cc47;
      }
    
      .box4 {
        left: 80px;
        top: 80px;
        background-color: #FF6A00;
      }
    </style>
    

![](/vela/quickapp/images/components/stack.png)

---

## #swiper

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/container/swiper.html](https://iot.mi.com/vela/quickapp/zh/components/container/swiper.html)

# [#](<#swiper>) swiper

## [#](<#概述>) 概述

滑块视图容器。

## [#](<#子组件>) 子组件

支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
index | `<number>` | ０ | 否 | 当前显示的子组件索引  
autoplay | `<boolean>` | false | 否 | 渲染完成后，是否自动进行播放  
interval | `<number>` | 3000ms | 否 | 自动播放时的时间间隔，单位毫秒  
indicator | `<boolean>` | true | 否 | 是否启用 indicator，默认 true  
loop | `<boolean>` | true | 否 | 是否开启循环模式  
duration | `<number>` | - | 否 | 滑动动画时长（duration默认根据手指的速度动态计算）  
vertical | `<boolean>` | false | 否 | 滑动方向是否为纵向，纵向时indicator 也为纵向  
previousmargin | `<string>` | 0px | 否 | 前边距，可用于露出前一项的一小部分，支持单位：px和%  
nextmargin | `<string>` | 0px | 否 | 后边距，可用于露出后一项的一小部分，支持单位：px和%  
enableswipe | `<boolean>` | true | 否 | 是否支持手势滑动swiper  
  
**备注** ：`previousmargin`和`nextmargin`的总和不应该超过整个swiper大小的1/2，超过部分将会被截取。

## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
indicator-color | `<color>` | rgba(0, 0, 0, 0.5) | 否 | indicator 填充颜色  
indicator-selected-color | `<color>` | #33b4ff 或者 rgb(51, 180, 255) | 否 | indicator 选中时的颜色  
indicator-size | `<length>` | 20px | 否 | indicator 组件的直径大小  
indicator-[top|left|right|bottom] | `<length>` | `<percentage>` | - | 否 | indicator相对于swiper的位置  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
change | {index:currentIndex} | 当前显示的组件索引变化时触发  
swipestart[2+](</vela/quickapp/zh/guide/version/APILevel2>) | {index:currentIndex} | 子组件切换动画开始时触发（如果是手指拖动导致的切换，指的是手指按压开始拖动的时间点）  
swipeend[2+](</vela/quickapp/zh/guide/version/APILevel2>) | {index:currentIndex} | 子组件切换动画结束时触发  
  
## [#](<#方法>) 方法

名称 | 参数 | 描述  
---|---|---  
swipeTo | {index: number(指定位置)} | swiper 滚动到 index 位置  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <swiper class="swiper">
          <text class="item item-1">A</text>
          <text class="item item-2">B</text>
          <text class="item item-3">C</text>
          <text class="item item-4">D</text>
        </swiper>
        
      </div>
    </template>
    
    <style>
      .page {
        padding: 30px;
        background-color: white;
      }
    
      .swiper {
        width: 300px;
        height: 160px;
        indicator-size: 10px;
      }
    
      .item {
        text-align: center;
        color: white;
        font-size: 30px;
      }
    
      .item-1 {
        background-color: #3f56ea;
      }
    
      .item-2 {
        background-color: #00bfc9;
      }
    
      .item-3 {
        background-color: #47cc47;
      }
    
      .item-4 {
        background-color: #FF6A00;
      }
    </style>
    

![](/vela/quickapp/images/components/swiper.gif)

---

