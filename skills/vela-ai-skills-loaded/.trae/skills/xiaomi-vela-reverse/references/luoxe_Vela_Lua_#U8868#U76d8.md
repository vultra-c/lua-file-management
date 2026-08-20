# Vela_Lua_表盘

> 来源: 洛汐文档库
> 共 11 篇文档

---

# Lua 表盘开发总览

> 来源: [https://docs.luoxe.cn/docs/vela/lua/](https://docs.luoxe.cn/docs/vela/lua/)

Xiaomi Vela 穿戴设备提供 Lua 5.4 表盘运行环境。脚本通过 `lvgl` 创建界面，通过 `dataman` 订阅时间、健康、天气和系统数据，通过 `animengine` 或 LVGL 动画驱动效果。

## [最小模块列表](<#最小模块列表>)
    
    
    local lvgl = require("lvgl")
    local dataman = require("dataman")
    local topic = require("topic")
    local activity = require("activity")
    local animengine = require("animengine")
    local navigator = require("navigator")
    local vibrator = require("vibrator")
    local screen = require("screen")

`screen` 当前返回空表；屏幕状态由宿主内部处理，不应假定存在 `screen.ON`、`screen.OFF` 等常量。

## [最小表盘](<#最小表盘>)
    
    
    local lvgl = require("lvgl")
    local dataman = require("dataman")
    
    local ui = {}
    local tokens = {}
    
    function ui.init(style)
      local root = lvgl.Object(nil, {
        w = lvgl.HOR_RES(),
        h = lvgl.VER_RES(),
        bg_color = 0x000000,
        bg_opa = 255,
        border_width = 0,
        pad_all = 0,
      })
    
      root:clear_flag(lvgl.FLAG.SCROLLABLE)
    
      local label = root:Label {
        text = "--:--",
        align = lvgl.ALIGN.CENTER,
        text_color = 0xFFFFFF,
      }
    
      tokens[#tokens + 1] = dataman.subscribe(
        "timeHour",
        label,
        function(obj, value)
          obj:set { text = string.format("%02d", value // 256) }
        end
      )
    
      ui.root = root
      return root
    end
    
    function pageOnPause()
      for _, token in ipairs(tokens) do dataman.pause(token) end
    end
    
    function pageOnResume()
      for _, token in ipairs(tokens) do dataman.resume(token) end
    end
    
    return ui

表盘包通常由入口脚本、资源目录和样式资源组成。资源路径可使用绝对路径，也可由宿主注入的 `SCRIPT_PATH` 拼接：
    
    
    local function asset(name)
      return SCRIPT_PATH .. name
    end

## [生命周期](<#生命周期>)

函数| 调用时机| 应做的工作  
---|---|---  
`ui.init(style)`| 创建表盘| 创建根对象、控件、订阅与动画  
`pageOnPause()`| 表盘隐藏或进入编辑态| 暂停定时器和订阅、移除动画  
`pageOnResume()`| 表盘重新显示| 恢复订阅、计时和必要动画  
  
页面退出后不要继续持有 LVGL userdata。定时器、动画、topic、文件和目录句柄都应主动停止或关闭。

## [运行环境限制](<#运行环境限制>)

  * Lua 版本为 5.4.0；
  * 动态库加载关闭，不能用 `package.loadlib()` 加载 `.so`；
  * `io.popen()` 不可用；
  * 模块与 Lua state 由表盘宿主创建，不能在快应用 RPK 中直接 `require`；
  * 文件读写受进程权限和挂载属性限制；
  * 运行复杂探测代码时，优先放到按钮事件或短周期定时器中，避免初始化失败导致整个表盘无法显示。


## [文档导航](<#文档导航>)

  * [表盘结构与生命周期](</docs/vela/lua/watchface-development/>)
  * [dataman 数据源](</docs/vela/lua/dataman/>)
  * [topic 消息订阅](</docs/vela/lua/topic/>)
  * [animengine 动画引擎](</docs/vela/lua/animengine/>)
  * [Activity、导航、振动与屏幕](</docs/vela/lua/vendor-modules/>)
  * [LVGL 控件与属性](</docs/vela/lua/lvgl-widgets/>)
  * [LVGL 样式、动画与常量](</docs/vela/lua/lvgl-style-animation/>)
  * [LVGL 显示、输入与文件系统](</docs/vela/lua/lvgl-modules/>)
  * [Lua 5.4 标准库](</docs/vela/lua/standard-library/>)


## [获取源代码](<#获取源代码>)

  * [社区 Lua 表盘开发文档](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua>)
  * [Lua 5.4 参考手册](<https://www.lua.org/manual/5.4/manual.html>)
  * [LVGL 源码](<https://github.com/lvgl/lvgl>)

---

# animengine 动画引擎

> 来源: [https://docs.luoxe.cn/docs/vela/lua/animengine/](https://docs.luoxe.cn/docs/vela/lua/animengine/)

`animengine` 使用 JSON 字符串描述一组对象属性动画。
    
    
    local animengine = require("animengine")

## [create](<#create>)
    
    
    animengine.create(object, configString) -> animation

参数| 类型| 说明  
---|---|---  
`object`| LVGL userdata| 动画目标  
`configString`| string| JSON 动画描述  
  
返回 animation userdata：

方法| 参数| 说明  
---|---|---  
`start()`| 无| 启动动画  
`remove()`| 无| 停止并释放动画  
`modify(json)`| JSON string| 修改已有动画配置  
  
## [JSON 格式](<#json-格式>)
    
    
    {
      "fromState": {
        "rotate": 0
      },
      "toState": {
        "rotate": 3600
      },
      "config": {
        "duration": 1.0,
        "interations": "1"
      }
    }

内置表盘使用过的属性包括：

属性| 说明  
---|---  
`x` / `y`| 坐标  
`rotate`| 旋转；常见单位为 0.1 度  
`opacity`| 不透明度  
`scale` / `img_zoom`| 缩放  
`start_angle` / `end_angle`| 弧线角度  
`custom_translate`| 自定义平移  
`custom_rotate`| 自定义旋转  
  
`duration` 和 `delay` 在不同生成器中可能使用秒或毫秒。内置表盘模板以浮点秒传入；复杂状态对象也可能在单项中使用 `duration`、`delay` 和 `ease`。

拼写兼容

部分内置表盘使用 `interations`，而其他资料写作 `iterations`。目标设备可能只识别其中一种。新脚本应先用单次短动画验证，再决定采用哪一拼写。

## [旋转示例](<#旋转示例>)
    
    
    local template = [[
    {
      "fromState": { "rotate": %d },
      "toState": { "rotate": %d },
      "config": { "duration": %f, "interations": "1" }
    }
    ]]
    
    local config = string.format(template, 0, 3600, 1.0)
    local anim = assert(animengine.create(image, config))
    anim:start()

## [多属性示例](<#多属性示例>)
    
    
    local config = [[
    {
      "fromState": {
        "x": { "value": 0, "ease": ["ease_in_out", 5.0] },
        "y": { "value": 0, "ease": ["ease_in_out", 5.0] }
      },
      "toState": {
        "x": { "value": 120, "delay": 0, "duration": 1000 },
        "y": { "value": 40, "delay": 0, "duration": 1000 }
      },
      "config": { "iterations": "1" }
    }
    ]]
    
    local anim = animengine.create(obj, config)
    anim:start()

## [生命周期](<#生命周期>)
    
    
    local animations = {}
    
    local function start(obj, json)
      local anim = animengine.create(obj, json)
      animations[#animations + 1] = anim
      anim:start()
      return anim
    end
    
    function pageOnPause()
      for _, anim in ipairs(animations) do anim:remove() end
      animations = {}
    end

动画目标被删除后，animation userdata 不能继续使用。重复 `remove()` 或在对象销毁后 `modify()` 可能报错。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 animengine 文档](<https://github.com/FangAiden/Vela_Application_Documentation/blob/main/docs-lua/animengine/overview.md>)

---

# dataman 数据订阅

> 来源: [https://docs.luoxe.cn/docs/vela/lua/dataman/](https://docs.luoxe.cn/docs/vela/lua/dataman/)

`dataman` 把表盘数据源绑定到一个 LVGL 对象。数据变化时，宿主把对象和值传给回调。

## [subscribe](<#subscribe>)
    
    
    dataman.subscribe(key, object, callback) -> token

参数| 类型| 必填| 说明  
---|---|---|---  
`key`| string| 是| 数据源名称  
`object`| LVGL userdata| 是| 与订阅绑定的对象  
`callback`| function| 是| `function(object, value)`  
      
    
    local token = dataman.subscribe("timeHour", label, function(obj, value)
      local hour = value // 256
      obj:set { text = string.format("%02d", hour) }
    end)

大多数数值采用 Q24.8 定点格式，即真实值乘以 256。使用整数除法 `value // 256` 解码。无效值通常为该运行环境的整数最大值；使用数据前应按数据源定义判断。

## [pause 与 resume](<#pause-与-resume>)
    
    
    dataman.pause(token)
    dataman.resume(token)

`pause` 暂停派发但保留订阅；`resume` 恢复。页面隐藏时暂停，显示时恢复。

## [时间与日期数据源](<#时间与日期数据源>)

数据源| 含义  
---|---  
`timeHourLow` / `timeHourHigh`| 小时低位/高位  
`timeMinuteLow` / `timeMinuteHigh`| 分钟低位/高位  
`timeSecondLow` / `timeSecondHigh`| 秒低位/高位  
`timeCentiSecond`| 厘秒  
`timeCentiSecondLow` / `timeCentiSecondHigh`| 厘秒低位/高位  
`dateYear`| 年  
`dateYearDigit1..4`| 年的各位数字  
`dateMonth` / `dateMonthLow` / `dateMonthHigh`| 月及拆分位  
`dateDay` / `dateDayLow` / `dateDayHigh`| 日及拆分位  
`dateWeek`| 星期  
`dateLunarYear` / `dateLunarMonth` / `dateLunarDay`| 农历年月日  
`dateWeekStringShortCN` / `dateWeekStringFullCN`| 中文星期文本  
`dateWeekStringFullPascalEN` / `FullUpperEN` / `FullLowerEN`| 英文完整星期文本  
`dateWeekStringShortPascalEN` / `ShortUpperEN` / `ShortLowerEN`| 英文短星期文本  
`dateMonthStringShortCN`| 中文月份文本  
`dateMonthStringFullPascalEN` / `FullUpperEN` / `FullLowerEN`| 英文完整月份文本  
`dateMonthStringShortPascalEN` / `ShortUpperEN` / `ShortLowerEN`| 英文短月份文本  
`miscIsPM`| 是否下午  
`miscIs24H`| 是否 24 小时制  
`miscTimeSection`| 时间段  
`miscdateYestarday` / `miscdateTomorrow`| 昨日/明日标识；拼写以接口为准  
`dualtimeHour` / `dualtimeMinute` / `dualtimeSecond`| 第二时区时间  
`dualtimeHour12H` / `dualtimeHour24H`| 第二时区小时格式  
`dualtimeCity`| 第二时区城市  
  
部分环境还提供 `timeHour`、`timeMinute`、`timeSecond` 组合值。

## [健康数据源](<#健康数据源>)

分类| 数据源  
---|---  
步数| `healthStepCount`、`healthStepCountDigit1..5`、`healthStepProgress`、`healthStepKiloMeter`、`healthStepTarget`  
心率| `healthHeartRate`、`healthHeartRateZone`、`healthHeartRateMin`、`healthHeartRateMax`  
热量| `healthCalorie`、`healthCalorieValue`、`healthCalorieProgress`、`healthCalorieTarget`  
站立| `healthStandCount`、`healthStandProgress`、`healthStandTarget`  
血氧/压力| `healthOxygenSpO2`、`healthPressureIndex`  
血压| `healthBloodDiastolicPressureMmhg`、`healthBloodSystolicPressureMmhg`、`healthBloodDiastolicPressureKpa`、`healthBloodSystolicPressureKpa`、`healthBloodPressureUnit`  
睡眠| `healthSleepDuration`、`healthSleepDurationMinute`、`healthSleepScore`、`healthSleepQuality`、`healthSleepTargetProgress`  
运动| `healthExerciseDuration`、`healthExerciseProgress`、`healthExerciseTarget`、`healthEnergyConsumed`  
其他| `healthMiscRecoveryTime`、`healthMiscRunPowerIndex`、`healthMiscTodayVitalityValue`、`healthMiscSevenDaysVitalityValue`  
血糖| `healthBloodSugarValue`、`healthBloodSugarUpdateTsString`  
  
## [天气数据源](<#天气数据源>)

分类| 数据源  
---|---  
日出日落| `weatherCurrentSunRise`、`weatherCurrentSunSet`、`weatherCurrentSunRiseHour`、`weatherCurrentSunRiseMinute`、`weatherCurrentSunSetHour`、`weatherCurrentSunSetMinute`  
温度| `weatherTemperatureUnit`、`weatherCurrentTemperature`、`weatherCurrentTemperatureFahrenheit`、`weatherCurrentTemperatureFeel`  
当前天气| `weatherCurrentHumidity`、`weatherCurrentWeather`、`weatherCurrentWindDirection`、`weatherCurrentWindAngle`、`weatherCurrentWindSpeed`、`weatherCurrentWindLevel`  
环境| `weatherCurrentAirQualityIndex`、`weatherCurrentAirQualityLevel`、`weatherCurrentChanceOfRain`、`weatherCurrentPressure`、`weatherCurrentVisibility`、`weatherCurrentUVIndex`、`weatherCurrentDressIndex`  
今日| `weatherTodayTemperatureMax`、`weatherTodayTemperatureMin`、`weatherTodayTemperatureMaxFahrenheit`、`weatherTodayTemperatureMinFahrenheit`  
明日| `weatherTomorrowTemperatureMax`、`weatherTomorrowTemperatureMin`、`weatherTomorrowTemperatureMaxFahrenheit`、`weatherTomorrowTemperatureMinFahrenheit`  
  
## [系统与闹钟数据源](<#系统与闹钟数据源>)

`systemStatusBattery`、`systemStatusCharge`、`systemStatusDisturb`、`systemStatusBluetooth`、`systemStatusWifi`、`systemStatusScreenLock`、`systemSensorFusionAltitude`、`appAlarmHour`、`appAlarmMinute`。

## [完整示例](<#完整示例>)
    
    
    local tokens = {}
    
    local function bind(key, obj, render)
      tokens[#tokens + 1] = dataman.subscribe(key, obj, function(target, raw)
        render(target, raw // 256)
      end)
    end
    
    bind("systemStatusBattery", batteryLabel, function(obj, value)
      obj:set { text = string.format("%d%%", value) }
    end)
    
    function pageOnPause()
      for _, token in ipairs(tokens) do dataman.pause(token) end
    end
    
    function pageOnResume()
      for _, token in ipairs(tokens) do dataman.resume(token) end
    end

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 dataman 文档](<https://github.com/FangAiden/Vela_Application_Documentation/blob/main/docs-lua/dataman/overview.md>)

---

# Lua LVGL 图形绑定

> 来源: [https://docs.luoxe.cn/docs/vela/lua/lvgl-binding/](https://docs.luoxe.cn/docs/vela/lua/lvgl-binding/)

MiWear Lua 宿主提供 LVGL Lua 绑定。以下是公共对象方法与模块索引；控件属性见 [LVGL 控件与属性](</docs/vela/lua/lvgl-widgets/>)，样式与动画见 [样式、事件与动画](</docs/vela/lua/lvgl-style-animation/>)，辅助模块见 [LVGL 辅助模块](</docs/vela/lua/lvgl-modules/>)。

## [对象与组件](<#对象与组件>)

标准对象类型：`Object`、`Image`、`Label`、`Led`、`List`、`Textarea`、`Calendar`、`Checkbox`、`Dropdown`、`Keyboard`、`Roller`。

扩展组件：`Pointer`、`AnalogTime`、`ImageLabel`、`ImageBar`、`CurvedLabel`、`Thumbnail`、`ImageLineBar`、`imggroup`、`frameanim`、`xcanvas`。

## [Object 通用方法](<#object-通用方法>)

类别| 方法  
---|---  
树与生命周期| `delete`、`clean`、`set_parent`、`get_parent`、`get_child`、`get_child_cnt`、`get_screen`  
几何与布局| `set_style`、`align_to`、`center`、`invalidate`、`get_coords`、`get_pos`、`mark_layout_as_dirty`、`is_layout_positioned`  
状态与 flag| `get_state`、`add_flag`、`clear_flag`、`add_state`、`clear_state`、`is_visible`、`is_editable`、`is_group_def`  
样式| `add_style`、`remove_style`、`remove_style_all`  
滚动| `scroll_to`、`is_scrolling`、`scroll_by`、`scroll_by_bounded`、`scroll_to_view`、`scroll_to_view_recursive`、`scroll_by_raw`、`scrollbar_invalidate`、`readjust_scroll`  
Flex| `set_flex_flow`、`set_flex_align`、`set_flex_grow`  
输入/事件| `indev_search`、`onevent`、`onPressed`、`onClicked`  
动画| `anim`、`remove_all_anim`  
  
通用形态示例：
    
    
    obj:set_parent(parent)
    obj:align_to(base, align, x_offset, y_offset)
    obj:scroll_to(x, y, anim_enable)
    obj:add_flag(lvgl.FLAG.CLICKABLE)
    obj:clear_state(lvgl.STATE.DISABLED)
    obj:onevent(event_code, callback)

## [组件专用方法](<#组件专用方法>)

对象| 方法  
---|---  
Image| `set_src`、`set_offset`、`set_pivot`、`get_img_size`  
Label| `set_text_static`、`get_text`、`get_long_mode`、`ins_text`、`cut_text`  
Led| `on`、`off`、`toggle`、`get_brightness`  
List| `add_text`、`add_btn`、`get_btn_text`  
Calendar| `set`、`get_today`、`get_showed`、`get_pressed`、`get_btnm`  
Dropdown| `get_options`、`get_selected`、`get_selected_str`、`get_options_cnt`、`is_open`、`add_option`、`clear_option`  
Textarea| `get_text`、`remove_prop`  
Frame animation| `set`、`pause`、`resume`、`delete`、`ready`  
  
大量属性由统一 `set`/property 描述器处理。已确认的属性包括 `text`、`placeholder`、`long_mode`、`selected`、`visible_cnt`、`password_mode`、`password_bullet`、`accepted_chars`、`max_length`、`angle`、`zoom`、`pivot`、`offset_x`、`offset_y`、`recolor`、`img_opa`、`radius`、`bar_width` 等。

## [屏幕与显示模块](<#屏幕与显示模块>)

成员| 说明  
---|---  
`lvgl.disp.get_default`| 默认显示设备  
`lvgl.disp.get_next`| 遍历显示设备  
`lvgl.disp.get_scr_act`| 当前活动 screen  
`lvgl.disp.get_scr_prev`| 上一个 screen  
`lvgl.disp.load_scr`| 切换 screen  
`display:get_layer_top`| 顶层 layer  
`display:get_layer_sys`| 系统 layer  
`display:set_bg_color`| 设置背景色  
`display:set_bg_image`| 设置背景图  
`display:set_bg_opa`| 设置背景透明度  
`display:get_chroma_key_color`| 获取色键  
`display:set_rotation`| 设置显示旋转  
没有确认到公开 Lua `take_snapshot` 方法。系统截屏方式见 [截屏](</docs/vela/system/screenshot/>)。|   
  
## [输入设备](<#输入设备>)

方法| 说明  
---|---  
`get_type`| 输入设备类型  
`reset`、`reset_long_press`| 重置状态  
`set_cursor`| 设置指针光标  
`set_group`| 绑定 group  
`get_point`| 当前坐标  
`get_gesture_dir`| 手势方向  
`get_key`| 当前键值  
`get_scroll_dir`、`get_scroll_obj`| 滚动信息  
`get_vect`| 输入向量  
`wait_release`| 等待释放  
`on_event`| 注册输入事件  
  
## [Group](<#group>)

模块方法：`get_default`、`create`。对象方法：`delete`、`set_default`、`add_obj`、`remove_obj`、`remove_objs`、`focus_obj`、`focus_next`、`focus_prev`、`focus_freeze`、`send_data`、`set_focus_cb`、`set_edge_cb`、`get_focus_cb`、`get_edge_cb`、`set_editing`、`set_wrap`、`get_wrap`、`get_obj_count`、`get_focused`。

## [文件/目录 userdata](<#文件-目录-userdata>)

类型| 方法  
---|---  
目录| `lvgl.fs.open_dir`、`read`、`close`  
文件| `lvgl.fs.open_file`、`read`、`write`、`seek`、`close`  
  
两类 userdata 都实现 `__gc`、`__close`、`__tostring`、`__index`，可配合 Lua 5.4 to-be-closed 变量使用，但仍建议显式关闭。

## [常量组](<#常量组>)

固件导出以下常量组/值：

  * Object flags：`HIDDEN`、`CLICKABLE`、`CLICK_FOCUSABLE`、`CHECKABLE`、`SCROLLABLE`、`SCROLL_ELASTIC`、`SCROLL_MOMENTUM`、`SCROLL_ONE`、`SCROLL_CHAIN_HOR/VER`、`SCROLL_CHAIN`、`SCROLL_ON_FOCUS`、`SCROLL_WITH_ARROW`、`SNAPPABLE`、`PRESS_LOCK`、`EVENT_BUBBLE`、`GESTURE_BUBBLE`、`ADV_HITTEST`、`IGNORE_LAYOUT`、`FLOATING`、`OVERFLOW_VISIBLE`、`LAYOUT_1/2`、`WIDGET_1/2`、`USER_1..4`；
  * States/parts：`CHECKED`、`FOCUS_KEY`、`EDITED`、`HOVERED`、`SCROLLED`、`DISABLED`、`SCROLLBAR`、`INDICATOR`、`KNOB`、`SELECTED`、`ITEMS`、`TICKS`、`CURSOR`、`CUSTOM_FIRST`；
  * Align：`CENTER` 以及 `OUT_TOP_LEFT/MID/RIGHT`、`OUT_BOTTOM_LEFT/MID/RIGHT`、`OUT_LEFT_TOP/MID/BOTTOM`、`OUT_RIGHT_TOP/MID/BOTTOM`；
  * Label：`LONG_WRAP`、`LONG_DOT`、`LONG_SCROLL`、`LONG_SCROLL_CIRCULAR`、`LONG_CLIP`；
  * Flex：`COLUMN`、`ROW_WRAP`、`ROW_REVERSE`、`ROW_WRAP_REVERSE`、`COLUMN_WRAP`、`COLUMN_REVERSE`、`COLUMN_WRAP_REVERSE`、`SPACE_EVENLY`、`SPACE_AROUND`、`SPACE_BETWEEN`、`STRETCH`；
  * 动画：`OVER_LEFT/RIGHT/TOP/BOTTOM`、`MOVE_LEFT/RIGHT/TOP/BOTTOM`、`FADE_IN`、`FADE_ON`、`FADE_OUT`、`OUT_LEFT/RIGHT/TOP/BOTTOM`；
  * 特殊值：`ANIM_REPEAT_INFINITE`、`ANIM_PLAYTIME_INFINITE`、`SIZE_CONTENT`、`RADIUS_CIRCLE`、`COORD_MAX`、`COORD_MIN`、`IMG_ZOOM_NONE`、`BTNMATRIX_BTN_NONE`、`CHART_POINT_NONE`、`DROPDOWN_POS_LAST`、`LABEL_DOT_NUM`、`LABEL_POS_LAST`、`LABEL_TEXT_SELECTION_OFF`、`TABLE_CELL_NONE`、`TEXTAREA_CURSOR_LAST`、`LAYOUT_FLEX`、`LAYOUT_GRID`、`HOR_RES`、`VER_RES`。


常量的数值跟随固件所带 LVGL ABI。脚本必须使用导出的符号，不能复制另一版 LVGL 的枚举整数。

## [生命周期规则](<#生命周期规则>)

  * Lua userdata 保存的是原生 LVGL 对象引用；对象被页面或父对象删除后，旧引用立即失效；
  * `set_text_static` 不复制文本，传入字符串的存储期必须覆盖 Label 使用期；普通脚本优先使用会复制文本的 setter；
  * 动画与 event callback 会持有原生资源，页面退出时先停止动画、解除事件、再删除对象；
  * 固件会记录 “Null root object”“dsc is null”“draw_buf is null”等错误，但不能保证所有悬空指针都被拦截。


## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [LVGL 文档](<https://docs.lvgl.io/master/>)
  * [LVGL 源码](<https://github.com/lvgl/lvgl>)

---

# LVGL 辅助模块

> 来源: [https://docs.luoxe.cn/docs/vela/lua/lvgl-modules/](https://docs.luoxe.cn/docs/vela/lua/lvgl-modules/)

除控件外，Lua 绑定还提供 Timer、Group、输入设备、文件系统、颜色和字体等模块。

## [Timer](<#timer>)
    
    
    local timer = lvgl.Timer {
      period = 1000,
      repeat_count = -1,
      cb = function(timer)
        print("tick")
      end,
    }
    
    timer:pause()
    timer:resume()
    timer:set { period = 500 }
    timer:ready()
    timer:delete()

成员| 说明  
---|---  
`period`| 触发周期，毫秒  
`repeat_count`| 剩余次数；`-1` 表示无限  
`cb`| 定时回调  
`pause` / `resume`| 暂停和恢复  
`set`| 更新 `period`、`paused`、`repeat_count` 或 `cb`  
`ready`| 令定时器尽快执行一次  
`delete`| 删除定时器  
  
## [Group](<#group>)
    
    
    local group = lvgl.Group.create()
    group:add_obj(object)
    group:focus_obj(object)
    group:set_editing(true)
    group:set_wrap(true)

模块函数：`get_default`、`create`。

对象方法：`delete`、`set_default`、`add_obj`、`remove_obj`、`remove_objs`、`focus_obj`、`focus_next`、`focus_prev`、`focus_freeze`、`send_data`、`set_focus_cb`、`set_edge_cb`、`get_focus_cb`、`get_edge_cb`、`set_editing`、`set_wrap`、`get_wrap`、`get_obj_count`、`get_focused`。

## [输入设备](<#输入设备>)

模块函数：
    
    
    lvgl.indev.get_act()
    lvgl.indev.get_next([indev])
    lvgl.indev.get_obj_act()

输入设备对象提供：

方法| 说明  
---|---  
`get_type`| 输入设备类型  
`reset`| 重置输入状态  
`reset_long_press`| 清除长按状态  
`set_cursor`| 设置指针光标对象  
`set_group`| 绑定 Group  
`get_point`| 当前触点坐标  
`get_gesture_dir`| 当前手势方向  
`get_key`| 当前按键值  
`get_scroll_dir`| 滚动方向  
`get_scroll_obj`| 当前滚动对象  
`get_vect`| 输入移动向量  
`wait_release`| 等待松开  
`on_event`| 注册输入设备事件  
  
返回坐标或向量时，宿主可能返回 table 或多个数值。调用方可先打印返回值形态，再做兼容封装。

## [屏幕与显示](<#屏幕与显示>)

函数| 说明  
---|---  
`lvgl.disp.get_default()`| 默认显示设备  
`lvgl.disp.get_next([display])`| 遍历显示设备  
`lvgl.disp.get_scr_act(display)`| 当前活动 screen  
`lvgl.disp.get_scr_prev(display)`| 上一个 screen  
`lvgl.disp.load_scr(screen [, options])`| 切换 screen  
  
显示设备对象提供 `get_res`、`set_rotation`、`get_layer_top`、`get_layer_sys`、`get_next`、`set_bg_opa`、`set_bg_color`、`set_bg_image` 和 `get_chroma_key_color`。

切屏参数：
    
    
    lvgl.disp.load_scr(screen, {
      anim = "over_left",
      time = 500,
      delay = 0,
      auto_del = 1,
    })

`HOR_RES`、`VER_RES` 在部分脚本中是函数，在部分模拟环境中是数值。可统一读取：
    
    
    local function constValue(value)
      return type(value) == "function" and value() or value
    end
    
    local width = constValue(lvgl.HOR_RES)
    local height = constValue(lvgl.VER_RES)

## [颜色](<#颜色>)

颜色属性通常接受十六进制整数：
    
    
    label:set {
      text_color = 0xffffff,
      bg_color = 0x000000,
    }

透明度使用 `lvgl.OPA` 常量或数值。常见常量包括 `TRANSP`、`COVER` 以及分级透明度值。

## [字体](<#字体>)

字体构造：
    
    
    lvgl.Font(name [, size [, weight]]) -> light userdata

已验证的名称包括 `montserrat`；常见尺寸为 14、16、18、24、32，`weight` 可用 `normal`。字体可作为 `text_font` 属性传入：
    
    
    label:set { text_font = font }

系统字体对象和资源字体的加载方式取决于表盘包。不要把宿主字体指针保存到页面销毁之后。

## [文件与目录 userdata](<#文件与目录-userdata>)

目录接口：
    
    
    local dir = lvgl.fs.open_dir(path)
    local name = dir:read()
    dir:close()

文件接口：
    
    
    local file = lvgl.fs.open_file(path, mode)
    local data = file:read(size)
    file:seek(offset, whence)
    file:write(data)
    file:close()

`mode` 支持 `"r"` 和 `"w"`。文件的 `read` 支持整数长度与 `"*a"`，不支持 `"*l"`、`"*n"`；`seek` 的 `whence` 为 `"set"`、`"cur"` 或 `"end"`。

文件与目录对象实现 `__gc`、`__close`、`__tostring`、`__index`。仍应显式 `close()`，因为表盘 Lua state 可能长期不触发垃圾回收。

## [常量组](<#常量组>)

常用分组包括：

  * `lvgl.ALIGN`：对象对齐；
  * `lvgl.FLAG`：对象标志；
  * `lvgl.STATE`：对象状态；
  * `lvgl.PART`：控件部件；
  * `lvgl.EVENT`：事件码；
  * `lvgl.FLEX_FLOW`、`lvgl.FLEX_ALIGN`：Flex 布局；
  * `lvgl.LABEL_LONG`：长文本模式；
  * `lvgl.OPA`：透明度；
  * `lvgl.DIR`：方向；
  * `lvgl.ANIM`：动画开关或类型。


特殊值包括 `ANIM_REPEAT_INFINITE`、`ANIM_PLAYTIME_INFINITE`、`SIZE_CONTENT`、`RADIUS_CIRCLE`、`COORD_MAX`、`COORD_MIN`、`IMG_ZOOM_NONE`、`BTNMATRIX_BTN_NONE`、`CHART_POINT_NONE`、`DROPDOWN_POS_LAST`、`LABEL_POS_LAST`、`TEXTAREA_CURSOR_LAST`、`LAYOUT_FLEX`、`LAYOUT_GRID`。

## [机型可用性](<#机型可用性>)

模块| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
Timer| ✅| ✅  
Group 与输入设备| ✅| ✅  
显示辅助函数| ✅| ✅  
文件与目录 userdata| ✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 LVGL Lua 文档](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua/lvgl>)
  * [LVGL 文档](<https://docs.lvgl.io/master/>)

---

# LVGL 样式、事件与动画

> 来源: [https://docs.luoxe.cn/docs/vela/lua/lvgl-style-animation/](https://docs.luoxe.cn/docs/vela/lua/lvgl-style-animation/)

## [Style](<#style>)

创建样式：
    
    
    local style = lvgl.Style {
      bg_color = 0x101010,
      bg_opa = lvgl.OPA(255),
      radius = 20,
      border_width = 0,
      text_color = 0xffffff,
    }
    
    object:add_style(style, lvgl.PART.MAIN)

样式对象支持批量 `set`：
    
    
    style:set {
      pad_all = 8,
      shadow_width = 12,
      shadow_opa = 80,
    }

对象侧的样式方法：
    
    
    object:add_style(style, part)
    object:remove_style(style, part)
    object:remove_style_all()
    object:set_style(properties [, selector])

`selector` 由 part 与 state 组合。优先使用固件导出的 `lvgl.PART`、`lvgl.STATE`，不要复制桌面版 LVGL 的整数枚举。

## [常用样式属性](<#常用样式属性>)

分类| 属性  
---|---  
尺寸| `width`、`height`、`min_width`、`max_width`、`min_height`、`max_height`  
背景| `bg_color`、`bg_opa`、`bg_img_src`、`bg_img_opa`、`bg_img_recolor`、`bg_img_tiled`  
边框| `border_color`、`border_width`、`border_opa`、`border_side`、`border_post`  
外轮廓| `outline_color`、`outline_width`、`outline_opa`、`outline_pad`  
阴影| `shadow_color`、`shadow_width`、`shadow_opa`、`shadow_ofs_x`、`shadow_ofs_y`、`shadow_spread`  
内边距| `pad_top`、`pad_bottom`、`pad_left`、`pad_right`、`pad_row`、`pad_column`、`pad_all`、`pad_gap`  
文本| `text_color`、`text_opa`、`text_font`、`text_letter_space`、`text_line_space`、`text_decor`、`text_align`  
图片| `img_opa`、`img_recolor`、`img_recolor_opa`  
变换| `transform_zoom`、`transform_angle`、`transform_pivot_x`、`transform_pivot_y`、`translate_x`、`translate_y`  
其他| `radius`、`opa`、`clip_corner`、`blend_mode`、`anim_time`、`anim_speed`、`transition`  
  
## [状态与标志](<#状态与标志>)
    
    
    object:add_state(lvgl.STATE.CHECKED)
    object:clear_state(lvgl.STATE.CHECKED)
    local state = object:get_state()
    
    object:add_flag(lvgl.FLAG.CLICKABLE)
    object:clear_flag(lvgl.FLAG.SCROLLABLE)

常用 state：`CHECKED`、`FOCUSED`、`FOCUS_KEY`、`EDITED`、`HOVERED`、`PRESSED`、`SCROLLED`、`DISABLED`。

常用 flag：`HIDDEN`、`CLICKABLE`、`CLICK_FOCUSABLE`、`CHECKABLE`、`SCROLLABLE`、`SCROLL_ELASTIC`、`SCROLL_MOMENTUM`、`SCROLL_ONE`、`SCROLL_CHAIN`、`EVENT_BUBBLE`、`GESTURE_BUBBLE`、`IGNORE_LAYOUT`、`FLOATING`、`OVERFLOW_VISIBLE`。

## [事件](<#事件>)

便捷回调：
    
    
    object:onPressed(function(target, code)
      print("pressed", target, code)
    end)
    
    object:onClicked(function(target, code)
      print("clicked", target, code)
    end)

指定事件：
    
    
    object:onevent(lvgl.EVENT.VALUE_CHANGED, function(target, code)
      print("value changed")
    end)

回调执行时对象可能在回调中被删除。删除后不要继续调用 `target`，也不要在闭包中长期保存已退出页面的 userdata。

## [控件动画 `object:anim`](<#控件动画-object-anim>)

预装脚本使用以下形式：
    
    
    image:anim {
      property = "x",
      from = -100,
      to = 100,
      duration = 800,
      repeat_count = -1,
      path = "linear",
    }

常见字段：

字段| 类型| 说明  
---|---|---  
`property`| string| 要变化的属性，如 `x`、`y`、`opa`、`angle`、`zoom`  
`from` / `to`| number| 起始值与结束值  
`duration`| integer| 单程时长，毫秒  
`delay`| integer| 开始延迟，毫秒  
`repeat_count`| integer| 重复次数；`-1` 表示无限  
`repeat_delay`| integer| 每轮重复前延迟  
`playback_duration`| integer| 回放时长  
`playback_delay`| integer| 回放前延迟  
`path`| string/function| 插值路径  
`ready_cb`| function| 动画结束回调  
  
停止对象上的动画：
    
    
    object:remove_all_anim()

## [Anim 对象](<#anim-对象>)
    
    
    lvgl.Anim(object, options) -> animation
    object:Anim(options) -> animation

字段| 类型| 说明  
---|---|---  
`start_value`| integer| 起始值  
`end_value`| integer| 结束值  
`time` / `duration`| integer| 动画时长，毫秒  
`delay`| integer| 启动延迟，毫秒  
`repeat_count`| integer| 重复次数；`-1` 为无限  
`repeat_delay`| integer| 重复间延迟  
`early_apply`| boolean/integer| 是否立即应用首帧  
`playback_time`| integer| 反向回放时长  
`playback_delay`| integer| 回放前延迟  
`path`| string| `linear`、`ease_in`、`ease_out`、`ease_in_out`、`overshoot`、`bounce` 或 `step`  
`exec_cb`| function| `function(object, value)`，应用当前值  
`done_cb`| function| `function(animation, object)`，完成回调  
`run`| boolean| 创建后立即启动  
  
实例方法：

方法| 说明  
---|---  
`animation:set(options)`| 更新参数  
`animation:start()`| 启动  
`animation:stop()`| 停止  
`animation:delete()`| 删除  
      
    
    local animation = object:Anim {
      start_value = 0,
      end_value = 120,
      duration = 1000,
      path = "ease_out",
      exec_cb = function(target, value)
        target:set { x = value }
      end,
      run = true,
    }

需要 JSON 状态动画时使用 [animengine](</docs/vela/lua/animengine/>)。

## [页面生命周期](<#页面生命周期>)
    
    
    function pageOnPause()
      object:remove_all_anim()
    end
    
    function pageOnResume()
      -- 按当前状态重新建立动画
    end

无限动画会持续唤醒 UI 线程。页面隐藏后应停止，回到页面时重新创建。

## [机型可用性](<#机型可用性>)

能力| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
Style 与对象样式| ✅| ✅  
对象事件| ✅| ✅  
对象属性动画| ✅| ✅  
Anim 对象| ✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 LVGL Style 文档](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua/lvgl>)
  * [LVGL Styles](<https://docs.lvgl.io/master/details/common-widget-features/styles/>)
  * [LVGL Animations](<https://docs.lvgl.io/master/details/main-modules/animation.html>)

---

# LVGL 控件与属性

> 来源: [https://docs.luoxe.cn/docs/vela/lua/lvgl-widgets/](https://docs.luoxe.cn/docs/vela/lua/lvgl-widgets/)

## [创建语法](<#创建语法>)

两种写法等价：
    
    
    local image1 = lvgl.Image(parent, { src = "asset/a.bin" })
    local image2 = parent:Image { src = "asset/b.bin" }

所有控件继承 Object，可在构造时传属性，也可稍后批量设置：
    
    
    obj:set { x = 10, y = 20, hidden = false }

## [Object 属性](<#object-属性>)

分类| 属性  
---|---  
几何| `x`、`y`、`w`、`h`、`align`、`min_width`、`max_width`、`min_height`、`max_height`  
背景| `bg_color`、`bg_opa`、`bg_img_src`、`bg_img_opa`、`bg_img_recolor`、`bg_img_recolor_opa`、`bg_img_tiled`  
边框| `border_width`、`border_color`、`border_opa`、`border_side`、`border_post`  
外轮廓| `outline_width`、`outline_color`、`outline_opa`、`outline_pad`  
阴影| `shadow_width`、`shadow_color`、`shadow_opa`、`shadow_ofs_x`、`shadow_ofs_y`、`shadow_spread`  
内边距| `pad_all`、`pad_top`、`pad_bottom`、`pad_left`、`pad_right`、`pad_row`、`pad_column`、`pad_gap`  
变换| `transform_zoom`、`transform_angle`、`transform_pivot_x`、`transform_pivot_y`、`translate_x`、`translate_y`  
文本| `text_color`、`text_opa`、`text_font`、`text_letter_space`、`text_line_space`、`text_decor`、`text_align`  
其他| `radius`、`opa`、`clip_corner`、`blend_mode`、`scrollbar_mode`、`scroll_snap_x`、`scroll_snap_y`  
  
## [Object 方法](<#object-方法>)

分类| 方法  
---|---  
生命周期| `delete`、`clean`、`get_parent`、`set_parent`、`get_child`、`get_child_cnt`、`get_screen`  
样式| `set_style`、`add_style`、`remove_style`、`remove_style_all`  
几何| `align_to`、`center`、`invalidate`、`get_coords`、`get_pos`  
状态| `get_state`、`add_flag`、`clear_flag`、`add_state`、`clear_state`、`is_visible`  
滚动| `scroll_to`、`scroll_by`、`scroll_by_bounded`、`scroll_by_raw`、`scroll_to_view`、`scroll_to_view_recursive`、`is_scrolling`、`readjust_scroll`  
布局| `set_flex_flow`、`set_flex_align`、`set_flex_grow`、`mark_layout_as_dirty`、`is_layout_positioned`  
事件| `onevent`、`onPressed`、`onClicked`、`indev_search`  
动画| `anim` / `Anim`、`remove_all_anim`  
  
## [标准控件](<#标准控件>)

控件| 主要属性| 专用方法  
---|---|---  
`Image`| `src`、`zoom`、`angle`、`pivot`、`offset_x`、`offset_y`| `set_src`、`set_offset`、`set_pivot`、`get_img_size`  
`Label`| `text`、`long_mode`、文本样式| `set_text_static`、`get_text`、`get_long_mode`、`ins_text`、`cut_text`  
`Led`| `brightness`| `on`、`off`、`toggle`、`get_brightness`  
`List`| 列表样式| `add_text`、`add_btn`、`get_btn_text`  
`Textarea`| `text`、`placeholder`、`password_mode`、`password_bullet`、`accepted_chars`、`max_length`、`one_line`| `get_text`、`remove_prop`  
`Dropdown`| `options`、`selected`| `get_options`、`get_selected`、`get_selected_str`、`get_options_cnt`、`is_open`、`add_option`、`clear_option`  
`Calendar`| 日期属性| `get_today`、`get_showed`、`get_pressed`、`get_btnm`  
`Checkbox`| `text`、checked state| Object 状态方法  
`Keyboard`| `mode`、`textarea`| 通过属性绑定 Textarea  
`Roller`| `options`、`selected`、`visible_cnt`| 通用 `set` 与选择读取  
  
## [扩展控件](<#扩展控件>)

### [AnalogTime](<#analogtime>)
    
    
    local clock = root:AnalogTime {
      hands = { second = image("second.bin") },
      period = 33,
      w = 466, h = 466,
      align = lvgl.ALIGN.CENTER,
    }
    
    clock:set { pivot = { second = { 16, 232 } } }
    clock:set { fake_time = { second = 30 } }
    clock:pause()
    clock:resume()

属性：`hands.hour/minute/second`、`pivot`、`period`、`fake_time`。

### [Pointer](<#pointer>)
    
    
    local pointer = root:Pointer {
      range = {
        valueStart = 0, valueRange = 100,
        angleStart = -120, angleRange = 240,
      },
      value = 75,
    }

### [CurvedLabel](<#curvedlabel>)

属性：`text`、`radius`、`angle_start`、`angle_range`、`font`、`text_color`。

### [ImageLabel](<#imagelabel>)

属性包括 `src`、`text`、`font`、`suffix`、`spacing` 与文本样式。

### [ImageBar](<#imagebar>)

范围属性包括 `center_x`、`center_y`、`linecap`、`bar_width`、`value` 和进度映射参数。

### [ImageLineBar](<#imagelinebar>)

范围属性包括 `start_x`、`start_y`、`end_x`、`end_y`、`value` 和图片源。

### [Thumbnail](<#thumbnail>)

用于缩略图预览，支持 `src` 以及 Object 通用属性和事件。

## [事件示例](<#事件示例>)
    
    
    button:onClicked(function(obj, code)
      print("clicked", obj, code)
    end)
    
    button:onevent(lvgl.EVENT.PRESSED, function(obj, code)
      print("pressed", code)
    end)

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 LVGL 控件文档](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua/lvgl/widgets>)
  * [LVGL Widgets 文档](<https://docs.lvgl.io/master/details/widgets/>)

---

# Lua 5.4 标准库

> 来源: [https://docs.luoxe.cn/docs/vela/lua/standard-library/](https://docs.luoxe.cn/docs/vela/lua/standard-library/)

下表列出 Lua 表盘宿主提供的脚本级接口。参数和返回语义遵循 Lua 5.4.0；这里给出完整成员索引，详细语义直接以官方手册为准。

## [基础库](<#基础库>)

函数| 典型签名  
---|---  
`assert`| `assert(value [, message]) -> value, ...`  
`collectgarbage`| `collectgarbage([opt [, arg]]) -> result`  
`dofile`| `dofile([filename]) -> ...`  
`error`| `error(message [, level])`  
`getmetatable`| `getmetatable(object) -> table/nil`  
`ipairs`| `ipairs(t) -> iterator, t, 0`  
`load`| `load(chunk [, chunkname [, mode [, env]]]) -> function/error`  
`loadfile`| `loadfile([filename [, mode [, env]]]) -> function/error`  
`next`| `next(table [, index]) -> key, value`  
`pairs`| `pairs(t) -> iterator, t, nil`  
`pcall`| `pcall(f [, args...]) -> ok, ...`  
`print`| `print(...)`  
`rawequal`| `rawequal(v1, v2) -> boolean`  
`rawget`| `rawget(table, index) -> value`  
`rawlen`| `rawlen(v) -> integer`  
`rawset`| `rawset(table, index, value) -> table`  
`select`| `select(index, ...) -> ...`  
`setmetatable`| `setmetatable(table, metatable) -> table`  
`tonumber`| `tonumber(e [, base]) -> number/nil`  
`tostring`| `tostring(v) -> string`  
`type`| `type(v) -> string`  
`warn`| `warn(msg1, ...)`  
`xpcall`| `xpcall(f, msgh [, args...]) -> ok, ...`  
  
全局值还包括 `_G` 和 `_VERSION`。

## [Coroutine](<#coroutine>)

`coroutine.close`、`create`、`isyieldable`、`resume`、`running`、`status`、`wrap`、`yield`。

## [Package](<#package>)

全局 `require(name)`；`package.config`、`cpath`、`loaded`、`loadlib`、`path`、`preload`、`searchers`、`searchpath`。

注意

`package.loadlib` 虽然被注册，但固件关闭动态库加载，会返回“dynamic libraries not enabled”。厂商模块由宿主静态放入 `package.preload`。

## [String](<#string>)

`string.byte`、`char`、`dump`、`find`、`format`、`gmatch`、`gsub`、`len`、`lower`、`match`、`pack`、`packsize`、`rep`、`reverse`、`sub`、`unpack`、`upper`。

## [UTF-8](<#utf-8>)

`utf8.char`、`charpattern`、`codes`、`codepoint`、`len`、`offset`。

## [Table](<#table>)

`table.concat`、`insert`、`move`、`pack`、`remove`、`sort`、`unpack`。

## [Math](<#math>)

`math.abs`、`acos`、`asin`、`atan`、`ceil`、`cos`、`deg`、`exp`、`floor`、`fmod`、`huge`、`log`、`max`、`maxinteger`、`min`、`mininteger`、`modf`、`pi`、`rad`、`random`、`randomseed`、`sin`、`sqrt`、`tan`、`tointeger`、`type`、`ult`。

嵌入式产品可能以 32 位整数/浮点配置编译。脚本启动时用 `math.maxinteger`、`math.type(1)` 和 `string.packsize('j')` 读取实际 ABI，不要假定桌面 Lua 的 64 位配置。

## [IO 与文件对象](<#io-与文件对象>)

模块函数：`io.close`、`flush`、`input`、`lines`、`open`、`output`、`popen`、`read`、`tmpfile`、`type`、`write`。

文件对象方法：`close`、`flush`、`lines`、`read`、`seek`、`setvbuf`、`write`，以及 `__gc`、`__close`、`__tostring`。

`io.popen()` 不受支持。文件路径仍受当前进程权限和系统分区只读属性限制。

## [OS](<#os>)

`os.clock`、`date`、`difftime`、`execute`、`exit`、`getenv`、`remove`、`rename`、`setlocale`、`time`、`tmpname`。

`os.execute` 是否允许启动任意命令由 Lua 宿主和系统 shell 配置决定；不要据函数名推断第三方脚本一定有该权限。

## [Debug](<#debug>)

`debug.debug`、`gethook`、`getinfo`、`getlocal`、`getmetatable`、`getregistry`、`getupvalue`、`getuservalue`、`setcstacklimit`、`sethook`、`setlocal`、`setmetatable`、`setupvalue`、`setuservalue`、`traceback`、`upvalueid`、`upvaluejoin`。

Debug 库可越过普通封装边界，系统应用不应把不可信脚本放进共享 Lua state。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [Lua 5.4 参考手册：标准库](<https://www.lua.org/manual/5.4/manual.html#6>)
  * [Lua 5.4 C API](<https://www.lua.org/manual/5.4/manual.html#4>)

---

# topic 消息订阅

> 来源: [https://docs.luoxe.cn/docs/vela/lua/topic/](https://docs.luoxe.cn/docs/vela/lua/topic/)

`topic` 用于订阅系统 uORB 主题。它适合传感器与系统事件流；表盘常规时间、天气和健康值优先使用 `dataman`。
    
    
    local topic = require("topic")

## [subscribe](<#subscribe>)
    
    
    topic.subscribe(name, callback) -> subscription

参数| 类型| 说明  
---|---|---  
`name`| string| uORB 主题名  
`callback`| function| 接收主题数据  
  
返回值是 `miwear.topic` userdata。
    
    
    local sub = topic.subscribe("sensor_temp", function(data)
      print(data.timestamp, data.temperature)
    end)

## [subscription 方法](<#subscription-方法>)

方法| 说明  
---|---  
`sub:unsubscribe()`| 取消订阅；重复取消会报错  
`sub:frequency(...)`| 查询或设置频率；参数格式随主题与系统版本变化  
  
离开页面前应主动取消：
    
    
    function pageOnPause()
      if sub then
        sub:unsubscribe()
        sub = nil
      end
    end

## [主题名](<#主题名>)

类别| 主题  
---|---  
传感器| `sensor_accel`、`sensor_accel_uncal`、`sensor_gyro`、`sensor_gyro_uncal`、`sensor_mag`、`sensor_mag_uncal`、`sensor_orientation`、`sensor_baro`、`sensor_temp`、`sensor_humi`、`sensor_light`、`sensor_prox`、`sensor_hrate`、`sensor_hinge_angle`、`sensor_wrist_tilt`、`sensor_ots`  
GNSS| `sensor_gnss`、`sensor_gnss_clock`、`sensor_gnss_measurement`、`sensor_gnss_satellite`、`sensor_gnss_geofence_event`  
算法| `algo_manager`、`algo_sleep`、`algo_off_body`、`algo_wrist_tilt`  
时间与数据事件| `event_basic_timer`、`event_time`、`event_new_day`、`event_data_sync`  
系统状态| `screen_status`、`battery_state`、`bt_stack_state`、`activity_manager`、`miwear_event`、`system_event`、`cpevent`  
业务数据| `topic_data_vigor`、`topic_data_hr`、`phone_sport_data_v2a`、`phone_sport_data_v2d`、`data_triple_loop`、`app_data_update`  
其他| `sport_notify`、`daily_remind`、`deco_report`  
  
主题存在不代表当前设备拥有对应传感器。订阅未知主题会失败；没有宿主事件循环时会出现 `null uv loop`。

## [数据结构探测](<#数据结构探测>)

payload 可能是 table、userdata 或标量。先做安全枚举：
    
    
    local function dump(value)
      print("payload type", type(value))
      if type(value) == "table" then
        for k, v in pairs(value) do print(k, v) end
      end
    end
    
    local sub = topic.subscribe("battery_state", dump)

不要把某一主题的字段布局套用到另一机型；元数据大小不匹配时宿主会拒绝派发。

## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 topic 文档](<https://github.com/FangAiden/Vela_Application_Documentation/blob/main/docs-lua/topic/overview.md>)

---

# MiWear Lua 原生模块

> 来源: [https://docs.luoxe.cn/docs/vela/lua/vendor-modules/](https://docs.luoxe.cn/docs/vela/lua/vendor-modules/)

Lua 表盘宿主提供 `activity`、`dataman`、`topic`、`animengine`、`navigator`、`vibrator`、`screen` 与初始化模块 `miwear`。
    
    
    local activity = require("activity")
    local dataman = require("dataman")
    local topic = require("topic")
    local animengine = require("animengine")
    local navigator = require("navigator")
    local vibrator = require("vibrator")
    local screen = require("screen")

不要使用 `require("miwear.topic")`；表盘实际加载名是 `topic`。

## [activity](<#activity>)

### [isShown](<#isshown>)
    
    
    activity.isShown(options) -> boolean

参数| 类型| 必填| 说明  
---|---|---|---  
`options.appID`| integer| 是| Activity 应用类型  
`options.pageID`| integer| 是| 页面编号  
      
    
    local editing = activity.isShown {
      appID = activity.APPID.WATCHFACE,
      pageID = 2,
    }

可用常量：

常量| 值| 说明  
---|---|---  
`activity.APPID.WATCHFACE`| `2`| 表盘 Activity  
`activity.APPID.LUA`| `56`| Lua Activity  
  
## [dataman](<#dataman>)
    
    
    dataman.subscribe(key, object, callback) -> token
    dataman.pause(token)
    dataman.resume(token)

`callback` 的实际参数是 `(object, value)`。完整键名、定点数格式和示例见 [dataman 数据订阅](</docs/vela/lua/dataman/>)。

## [topic](<#topic>)
    
    
    local handle = topic.subscribe(name, callback)
    handle:frequency(hz)
    handle:unsubscribe()

topic 句柄只有订阅管理与频率设置；`start`、`remove`、`modify` 属于 `animengine` 动画对象，不属于 topic。详见 [topic 消息订阅](</docs/vela/lua/topic/>)。

## [animengine](<#animengine>)
    
    
    local animation = animengine.create(object, json)
    animation:start()
    animation:modify(json)
    animation:remove()

详见 [animengine 动画](</docs/vela/lua/animengine/>)。

## [navigator](<#navigator>)
    
    
    navigator.finish()

结束当前 Lua 页面或 Activity。调用后应立即停止继续访问页面控件。

## [miwear](<#miwear>)

`miwear` 用于初始化宿主，没有确认到稳定的业务成员。表盘功能应从其他模块调用。

## [vibrator](<#vibrator>)
    
    
    vibrator.start(type [, repeat])
    vibrator.cancel(type)

参数| 类型| 说明  
---|---|---  
`type`| integer| `vibrator.type` 中的振动类型  
`repeat`| boolean| 是否重复，省略时为单次  
  
确认导出的类型：

常量| 说明  
---|---  
`CROWN`| 表冠反馈  
`KEY_BOARD`| 键盘反馈  
`WATCH_FACE`| 表盘反馈  
`SYSTEM_OPRATION`| 系统操作，接口原拼写  
`HEALTH_ALERT`| 健康提醒  
`SYSTEM_EVENT`| 系统事件  
`TARGET_DONE`| 目标完成  
`BREATHING_TRAINING`| 呼吸训练  
`INCOMING_CALL`| 来电  
`CLOCK_ALARM`| 闹钟  
`SLEEP_ALARM`| 睡眠闹钟  
      
    
    vibrator.start(vibrator.type.WATCH_FACE, false)

## [screen](<#screen>)

`require("screen")` 返回一个空 table。没有确认到 `screen.ON`、`screen.OFF`、状态订阅函数或截图函数。不要根据原生层的 `ScreenStateChangedCB` 字符串自行构造 Lua API。

## [机型可用性](<#机型可用性>)

模块| Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---|---  
`activity`| ✅| ✅  
`dataman`| ✅| ✅  
`topic`| ✅| ✅  
`animengine`| ✅| ✅  
`navigator`| ✅| ✅  
`vibrator`| ✅| ✅  
`screen`| ✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区 Lua 模块文档](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua>)

---

# Lua 表盘结构与生命周期

> 来源: [https://docs.luoxe.cn/docs/vela/lua/watchface-development/](https://docs.luoxe.cn/docs/vela/lua/watchface-development/)

## [目录布局](<#目录布局>)

推荐把脚本与资源放在同一表盘目录：
    
    
    mywatchface/
    ├── main.lua
    └── asset/
        ├── background.bin
        └── second.bin

表盘宿主可注入 `SCRIPT_PATH`。使用它可避免把安装目录写死：
    
    
    local ROOT = SCRIPT_PATH
    local function image(name)
      return ROOT .. "asset/" .. name
    end

部分预装表盘直接使用 `/watchface/lua/{name}/asset/`。第三方表盘应优先使用宿主提供的路径。

## [入口约定](<#入口约定>)

入口模块返回一个 table，并提供 `init(style)`：
    
    
    local lvgl = require("lvgl")
    local ui = {}
    
    function ui.init(style)
      local root = lvgl.Object(nil, {
        w = lvgl.HOR_RES(), h = lvgl.VER_RES(),
        bg_color = 0, bg_opa = 0,
        border_width = 0, pad_all = 0,
      })
      root:clear_flag(lvgl.FLAG.SCROLLABLE)
      root:add_flag(lvgl.FLAG.EVENT_BUBBLE)
      ui.root = root
      return root
    end
    
    return ui

`style` 由表盘配置传入，可作为主题目录名或颜色方案标识。

## [控件包装模式](<#控件包装模式>)

复杂表盘可把一组对象包装为普通 Lua table：
    
    
    local function ImageComponent(root, src, x, y)
      local component = { childs = {} }
      local img = root:Image { src = src, x = x, y = y }
      component.childs[1] = img
      return component
    end

这种模式便于批量切换主题、暂停动画或释放对象。`childs` 不是 LVGL 固有字段，只是脚本自己的容器。

## [页面暂停与恢复](<#页面暂停与恢复>)
    
    
    local timers = {}
    local subscriptions = {}
    local animations = {}
    
    function pageOnPause()
      for _, timer in ipairs(timers) do timer:pause() end
      for _, token in ipairs(subscriptions) do dataman.pause(token) end
      for _, anim in ipairs(animations) do anim:remove() end
      animations = {}
    end
    
    function pageOnResume()
      for _, timer in ipairs(timers) do timer:resume() end
      for _, token in ipairs(subscriptions) do dataman.resume(token) end
    end

进入表盘编辑页时，可用 `activity.isShown` 判断：
    
    
    local editing = activity.isShown {
      appID = activity.APPID.WATCHFACE,
      pageID = 2,
    }

## [编辑状态轮询](<#编辑状态轮询>)
    
    
    local lastEditing = false
    
    local editTimer = lvgl.Timer {
      period = 200,
      repeat_count = -1,
      cb = function()
        local editing = activity.isShown {
          appID = activity.APPID.WATCHFACE,
          pageID = 2,
        }
        if editing ~= lastEditing then
          if editing then pageOnPause() else pageOnResume() end
          lastEditing = editing
        end
      end,
    }

## [错误隔离](<#错误隔离>)

加载可选模块时使用 `pcall`：
    
    
    local ok, vibrator = pcall(require, "vibrator")
    if ok then
      vibrator.start(vibrator.type.WATCH_FACE)
    end

回调中也可用 `xpcall` 保留堆栈：
    
    
    local function safeCall(fn, ...)
      return xpcall(fn, debug.traceback, ...)
    end

## [性能建议](<#性能建议>)

  * 不要每帧重新创建控件；创建一次后用 `obj:set{}` 更新。
  * 高频数据只更新发生变化的属性。
  * 页面暂停后停止动画与高频 Timer。
  * 图片优先使用设备支持的 `.bin` 资源，避免运行时解码大图。
  * 列表和回调中不要形成 `Lua table → userdata → callback → table` 的长期循环引用。


## [机型可用性](<#机型可用性>)

Xiaomi Smart Band 10 Pro| Xiaomi Watch S4 41mm  
---|---  
✅| ✅  
  
## [获取源代码](<#获取源代码>)

  * [社区表盘入门与约定](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua/intro>)
  * [社区 Lua 表盘示例接口](<https://github.com/FangAiden/Vela_Application_Documentation/tree/main/docs-lua>)

---

