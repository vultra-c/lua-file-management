# 快应用_组件_表单组件

> 来源: 小米快应用官方
> 共 4 篇文档

---

## #input

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/form/input.html](https://iot.mi.com/vela/quickapp/zh/components/form/input.html)

# [#](<#input>) input

## [#](<#概述>) 概述

提供可交互的界面，接收用户的输入。

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
type | button | checkbox | radio | | button | 否 | 支持动态修改  
checked | `<boolean>` | false | 否 | 当前组件的 checked 状态，type 为 checkbox 时生效，可触发 checked 伪类（checked 伪类样式还未支持）  
name | `<string>` | - | 否 | input 组件名称  
value | `<string>` | - | 否 | input 组件的值  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | rgba(0, 0, 0, 0.87) | 否 | 文本颜色  
font-size | `<length>` | 37.5px | 否 | 文本尺寸  
width | `<length>` | `<percentage>` | - | 否 | type 为 button 时，默认值为 128px  
height | `<length>` | `<percentage>` | - | 否 | type 为 button 时，默认值为 70px  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
change | 不同 type 参数不同，具体见下方 change 事件参数 | input 组件的值、状态发生改变时触发，type 为 button 时无 change 事件  
  
### [#](<#change-事件参数>) change 事件参数

参数 | checkbox | radio | 备注  
---|---|---|---  
name | √ | √ | -  
value | √ | √ | -  
checked | √ | - | -  
  
## [#](<#方法>) 方法

名称 | 参数 | 描述  
---|---|---  
focus | {focus:true|false}，focus 不传默认为 true | 使组件获得或者失去焦点，可触发 focus 伪类（focus 伪类样式还未支持）  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <div class="section">
          <text class="title">input-button 组件</text>
          <input class="button" type="button" value="按钮" @click="onButtonClick" />
          <text>{{ buttonText }}</text>
        </div>
        <div class="section">
          <text class="title">input-checkbox 组件</text>
          <input class="checkbox" type="checkbox" checked="{{ checkboxChecked }}" @change="onCheckboxChange" />
          <text>我的勾选状态: {{ checkboxChecked }}</text>
        </div>
        <div class="section">
          <text class="title">input-radio 组件</text>
          <div>
            <input class="radio" type="radio" name="radio" value="1" checked="{{radioValue === '1'}}" @change="onRadioChange" />
            <input class="radio" type="radio" name="radio" value="2" checked="{{radioValue === '2'}}" @change="onRadioChange" />
            <input class="radio" type="radio" name="radio" value="3" checked="{{radioValue === '3'}}" @change="onRadioChange" />
          </div>
          <text>当前选中第{{ radioValue }}个</text>
        </div>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          buttonText: '',
          checkboxChecked: true,
          radioValue: '1'
        },
        onTextChange(e) {
          this.textValue = e.value
        },
        onButtonClick() {
          this.buttonText = '按钮被点击了'
        },
        onCheckboxChange(e) {
          this.checkboxChecked = e.checked
        },
        onRadioChange(e) {
          this.radioValue = e.value
        }
      }
    </script>
    
    <style>
      .page {
        flex-direction: column;
        padding: 30px;
        background-color: #ffffff;
      }
    
      .section {
        flex-direction: column;
        margin-bottom: 30px;
      }
    
      .title {
        font-weight: bold;
      }
    
      .button {
        width: 140px;
        height: 50px;
        font-size: 25px;
        color: white;
      }
    
      .checkbox, .radio {
        width: 40px;
        height: 40px;
        margin-right: 10px;
      }
    </style>
    

![](/vela/quickapp/images/components/input.gif)

---

## #picker

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/form/picker.html](https://iot.mi.com/vela/quickapp/zh/components/form/picker.html)

# [#](<#picker>) picker

## [#](<#概述>) 概述

滚动选择器，目前支持两种选择器，普通选择器，时间选择器。默认为普通选择器。 

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

**普通选择器**

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
type | text | - | 是 | 不支持动态修改  
range | `Array<string>` | - | 否 | 选择器的取值范围  
selected | `<number>` | 0 | 否 | 选择器的默认取值，取值为 range 的索引  
  
**时间选择器**

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
type | time | - | 是 | 不支持动态修改  
selected | `<string>` | 当前时间 | 否 | 选择器的默认取值，格式为 hh:mm  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | 主题色 | 否 | 候选项字体颜色  
font-size | `<length>` | 30px | 否 | 候选项字体尺寸，单位px  
selected-color | `<length>` | #ffffff | 否 | 选中项字体颜色  
selected-font-size | `<length>` | 20px | 否 | 选中项字体尺寸，单位px  
selected-background-color | `<color>` | - | 否 | 选中项背景颜色  
  
## [#](<#事件>) 事件

**普通选择器**

名称 | 参数 | 描述  
---|---|---  
change | {newValue:newValue, newSelected:newSelected} | 滚动选择器选择值后确定时触发（newSelected 为索引）  
  
**时间选择器**

名称 | 参数 | 描述  
---|---|---  
change | {hour:hour, minute:minute} | 滚动选择器选择值后确定时触发  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <text class="title">普通picker</text>
        <picker 
          class="picker" 
          type="text" 
          range="{{pickerList}}" 
          selected="1" 
          onchange="onPickerChange">
        </picker>
        <text class="value">选择的值：{{v1}}</text>
    
        <text class="title">时间picker</text>
        <picker 
          class="picker" 
          type="time"
          selected="12:00" 
          onchange="onTimePickerChange">
        </picker>
        <text class="value">选择的值：{{v2}}</text>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          pickerList: ['apple', 'peach', 'pear', 'banana'],
          v1: 'peach',
          v2: '12:00'
        },
        onPickerChange(e) {
          this.v1 = e.newValue;
        },
        onTimePickerChange(e) {
          this.v2 = e.hour + ':' + e.minute;
        }
      }
    </script>
    
    <style>
      .page {
        flex-direction: column;
        padding: 30px;
        background-color: #ffffff;
      }
    
      .title {
        font-weight: bold;
        color: #000;
      }
    
      .value {
        margin-top: 5px;
        margin-bottom: 30px;
        color: #090;
      }
    
      .picker {
        font-size: 25px;
        color: #000;
        selected-font-size: 30px;
        selected-color: #09f;
        selected-background-color: #ccc;
      }
    </style>
    

![](/vela/quickapp/images/components/picker.gif)

---

## #slider

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/form/slider.html](https://iot.mi.com/vela/quickapp/zh/components/form/slider.html)

# [#](<#slider>) slider

## [#](<#概述>) 概述

滑动选择器

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
min | `<number>` | ０ | 否 | -  
max | `<number>` | 100 | 否 | -  
step | `<number>` | 1 | 否 | -  
value | `<number>` | 0 | 否 | -  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
color | `<color>` | #f0f0f0 或者 rgb(240, 240, 240) | 否 | 背景条颜色  
selected-color | `<color>` | #009688 或者 rgb(0, 150, 136) | 否 | 已选择颜色  
block-color | `<color>` | - | 否 | 滑块的颜色  
padding-[left|right] | `<length>` | 32px | 否 | 左右边距  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
change | {progress:progressValue, isFromUser:isFromUserValue} | 完成一次拖动后触发的事件   
isFromUser说明：  
该事件是否由于用户拖动触发  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <text class="title">slider 组件</text>
        <slider class="slider" min="0" max="100" step="10" value="{{ initialSliderValue }}" onchange="onSliderChange"></slider>
        <text>slider的值：{{ sliderValue }}</text>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          initialSliderValue: 10,
          sliderValue: null
        },
        onSliderChange (e) {
          this.sliderValue = e.progress
        }
      }
    </script>
    
    <style>
      .page {
        flex-direction: column;
        padding: 30px;
        background-color: #ffffff;
      }
    
      .title {
        font-weight: bold;
      }
    
      .slider {
        margin-top: 20px;
        margin-bottom: 20px;
        padding-left: 0;
        padding-right: 0;
      }
    </style>
    

![](/vela/quickapp/images/components/slider.gif)

---

## #switch

> 来源: [https://iot.mi.com/vela/quickapp/zh/components/form/switch.html](https://iot.mi.com/vela/quickapp/zh/components/form/switch.html)

# [#](<#switch>) switch

## [#](<#概述>) 概述

开关选择

## [#](<#子组件>) 子组件

不支持

## [#](<#属性>) 属性

支持[通用属性](</vela/quickapp/zh/components/general/properties.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
checked | `<boolean>` | false | 否 | 可触发 checked 伪类（checked 伪类样式还未支持）  
  
## [#](<#样式>) 样式

支持[通用样式](</vela/quickapp/zh/components/general/style.html>)

名称 | 类型 | 默认值 | 必填 | 描述  
---|---|---|---|---  
thumb-color | `<color>` | #ffffff 或者 rgb(255, 255, 255) | 否 | 滑块颜色  
track-color | `<color>` | #0d84ff 或者 rgb(13, 132, 255) | 否 | 滑轨颜色  
  
## [#](<#事件>) 事件

支持[通用事件](</vela/quickapp/zh/components/general/events.html>)

名称 | 参数 | 描述  
---|---|---  
change | {checked:checkedValue} | checked 状态改变时触发  
  
## [#](<#示例代码>) 示例代码
    
    
    <template>
      <div class="page">
        <text class="title">switch 组件</text>
        <switch checked="{{ switchValue }}" class="switch" @change="onSwitchChange"></switch>
        <text>状态：{{ switchValue }}</text>
      </div>
    </template>
    
    <script>
      export default {
        private: {
          switchValue: true
        },
        onSwitchChange(e) {
          this.switchValue = e.checked
        }
      }
    </script>
    
    <style>
      .page {
        flex-direction: column;
        padding: 30px;
        background-color: #ffffff;
      }
    
      .title {
        font-weight: bold;
      }
    
      .switch {
        width: 100px;
        margin-top: 10px;
      }
    </style>
    

![](/vela/quickapp/images/components/switch.gif)

---

