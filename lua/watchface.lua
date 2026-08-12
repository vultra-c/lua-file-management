-- watchface.lua
-- 表盘主界面：终端风格（DEEP_SCAN）
-- 显示 时间 / 秒 / 日期 / 星期 / 电量 / 步数 / 心率，
-- 底部提供一个可点击的终端卡片，点按进入文件管理器。

local lvgl = require("lvgl")

local function loadModule(name)
  local ok, mod = pcall(require, name)
  if ok and mod then return mod end
  local base = SCRIPT_PATH or ""
  for _, p in ipairs({ base .. name .. ".lua", base .. "lua/" .. name .. ".lua" }) do
    local ok2, m = pcall(dofile, p)
    if ok2 and m then return m end
  end
  return nil
end

local utils = loadModule("utils")
local theme = loadModule("theme")
local db = loadModule("databind")

local M = {}

local W, H = utils.constValue(lvgl.HOR_RES), utils.constValue(lvgl.VER_RES)
local fonts = {}

local function font(size)
  if not fonts[size] then
    fonts[size] = lvgl.Font("montserrat", size, "normal")
  end
  return fonts[size]
end

-- 大号时钟字体：按可用性依次尝试，失败则降级
local clockFont
local function initClockFont()
  local sizes = { 64, 48, 32 }
  for _, s in ipairs(sizes) do
    local ok, f = pcall(lvgl.Font, "montserrat", s, "normal")
    if ok and f then
      clockFont = f
      return
    end
  end
  clockFont = font(32)
end

-- ---- 数据状态 ----
local hourT, hourU, minT, minU, secT, secU
local month, day, week
local battery, charging, steps, hr

-- ---- 控件 ----
local page
local timeLabel, secLabel, dateLabel, batLabel, stepLabel, hrLabel
local promptLabel

local function renderTime()
  if hourT == nil or hourU == nil or minT == nil or minU == nil then return end
  local h = hourT * 10 + hourU
  if h > 23 then h = 23 end -- 容错
  local m = minT * 10 + minU
  timeLabel:set { text = string.format("%02d:%02d", h, m) }
end

local function renderSec()
  if secT == nil or secU == nil then return end
  secLabel:set { text = string.format("%02d", secT * 10 + secU) }
end

local function renderDate()
  if month == nil or day == nil then return end
  local w = week or "--"
  dateLabel:set { text = string.format("%s  %02d-%02d", w, month, day) }
end

local function renderBattery()
  if battery == nil then return end
  local text = string.format("%d%%", math.min(battery, 100))
  if charging then text = text .. " CHG" end
  batLabel:set { text = text }
end

local function renderSteps()
  if steps ~= nil then
    stepLabel:set { text = utils.thousands(steps) }
  end
end

local function renderHr()
  if hr == nil then return end
  local color = theme.CYAN
  if hr > 140 then color = theme.RED
  elseif hr > 100 then color = theme.AMBER end
  hrLabel:set { text = tostring(hr), text_color = color }
end

-- ---- 界面构建 ----
local function build(root)
  initClockFont()

  page = lvgl.Object(root, {
    x = 0, y = 0, w = W, h = H,
    bg_color = theme.BG,
    bg_opa = 255,
    border_width = 0,
  })
  page:clear_flag(lvgl.FLAG.SCROLLABLE)

  -- 状态栏：电量（左）、品牌（右）
  batLabel = lvgl.Label(page, {
    x = 16, y = 14,
    text = "--%",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
  })
  lvgl.Label(page, {
    align = { type = lvgl.ALIGN.TOP_RIGHT, x_ofs = -16, y_ofs = 14 },
    text = "DEEP_SCAN",
    text_color = theme.ACCENT_DIM,
    text_font = font(14),
  })

  -- 日期
  dateLabel = lvgl.Label(page, {
    align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 48 },
    text = "--  --",
    text_color = theme.TEXT_DIM,
    text_font = font(16),
  })

  -- 时间
  timeLabel = lvgl.Label(page, {
    align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 132 },
    text = "--:--",
    text_color = theme.TEXT,
    text_font = clockFont,
  })

  -- 秒
  secLabel = lvgl.Label(page, {
    align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 214 },
    text = "--",
    text_color = theme.CYAN,
    text_font = font(18),
  })

  -- 分隔线
  lvgl.Object(page, {
    x = 20, y = 252, w = W - 40, h = 1,
    bg_color = theme.BORDER,
    bg_opa = 255,
    border_width = 0,
  })

  -- 终端卡片（点击进入文件管理器）
  local card = lvgl.Object(page, {
    x = 12, y = 272, w = W - 24, h = 188,
    radius = 12,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.ACCENT_DIM,
  })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  card:add_flag(lvgl.FLAG.CLICKABLE)

  -- 卡片内的标签需要把点击冒泡到卡片本体
  local function cardLabel(opts)
    local lbl = lvgl.Label(card, opts)
    lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE)
    return lbl
  end

  -- 标题行
  cardLabel {
    x = 14, y = 10,
    text = "deep_scan@band9pro:~$",
    text_color = theme.ACCENT,
    text_font = font(14),
  }

  -- 统计行
  stepLabel = cardLabel {
    x = 22, y = 44,
    text = "steps    --",
    text_color = theme.TEXT,
    text_font = font(16),
  }
  hrLabel = cardLabel {
    x = 22, y = 76,
    text = "hr       -- bpm",
    text_color = theme.TEXT,
    text_font = font(16),
  }
  cardLabel {
    x = 22, y = 108,
    text = "fs       /data mounted",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
  }

  -- 提示 / CTA
  cardLabel {
    x = 14, y = 144,
    text = "tap to open file manager >",
    text_color = theme.ACCENT,
    text_font = font(16),
  }
  promptLabel = cardLabel {
    align = { type = lvgl.ALIGN.TOP_RIGHT, x_ofs = -14, y_ofs = 144 },
    text = "_",
    text_color = theme.ACCENT,
    text_font = font(16),
  }

  card:onevent(lvgl.EVENT.CLICKED, function()
    if M.onOpenFS then M.onOpenFS() end
  end)

  -- 光标闪烁
  local cursorOn = true
  M.blinkTimer = lvgl.Timer {
    period = 600,
    repeat_count = -1,
    cb = function()
      cursorOn = not cursorOn
      promptLabel:set { text = cursorOn and "_" or "" }
    end,
  }
end

-- ---- 数据订阅 ----
local function subscribe()
  db.subscribeQ("timeHourLow", timeLabel, function(obj, v) hourU = v; renderTime() end)
  db.subscribeQ("timeHourHigh", timeLabel, function(obj, v) hourT = v; renderTime() end)
  db.subscribeQ("timeMinuteLow", timeLabel, function(obj, v) minU = v; renderTime() end)
  db.subscribeQ("timeMinuteHigh", timeLabel, function(obj, v) minT = v; renderTime() end)
  db.subscribeQ("timeSecondLow", secLabel, function(obj, v) secU = v; renderSec() end)
  db.subscribeQ("timeSecondHigh", secLabel, function(obj, v) secT = v; renderSec() end)

  -- 部分固件仅提供组合值（0-23 / 0-59），作为低位/高位拆分的兜底
  db.subscribeQ("timeHour", timeLabel, function(obj, v)
    if hourT == nil then hourT = math.floor(v / 10); hourU = v % 10; renderTime() end
  end)
  db.subscribeQ("timeMinute", timeLabel, function(obj, v)
    if minT == nil then minT = math.floor(v / 10); minU = v % 10; renderTime() end
  end)
  db.subscribeQ("timeSecond", secLabel, function(obj, v)
    if secT == nil then secT = math.floor(v / 10); secU = v % 10; renderSec() end
  end)

  db.subscribeQ("dateMonth", dateLabel, function(obj, v) month = v; renderDate() end)
  db.subscribeQ("dateDay", dateLabel, function(obj, v) day = v; renderDate() end)
  db.subscribeString("dateWeekStringShortPascalEN", dateLabel, function(obj, s) week = s; renderDate() end)

  db.subscribeQ("systemStatusBattery", batLabel, function(obj, v) battery = v; renderBattery() end)
  db.subscribeQ("systemStatusCharge", batLabel, function(obj, v) charging = v > 0; renderBattery() end)

  db.subscribeQ("healthStepCount", stepLabel, function(obj, v) steps = v; renderSteps() end)
  db.subscribeQ("healthHeartRate", hrLabel, function(obj, v) hr = v; renderHr() end)
end

-- ---- 对外接口 ----
function M.create(root, onOpenFS)
  M.onOpenFS = onOpenFS
  build(root)
  subscribe()
  return M
end

function M.show()
  if page then page:set { hidden = false } end
end

function M.hide()
  if page then page:set { hidden = true } end
end

function M.pageOnPause()
  if M.blinkTimer then pcall(function() M.blinkTimer:pause() end) end
  db.pauseAll()
end

function M.pageOnResume()
  if M.blinkTimer then pcall(function() M.blinkTimer:resume() end) end
  db.resumeAll()
end

return M
