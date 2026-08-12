-- main.lua
-- DEEP_SCAN 表盘入口（小米手环 9 Pro / Vela Lua 5.4）
-- 表盘主界面 + 系统文件管理器（深度浏览 / 深度搜索 / 删除文件）
--
-- 入口兼容策略：
--   1) 顶层直接构建 UI（9 Pro / EasyFace 生态约定，运行时只执行 main.lua 顶层代码）
--   2) 同时导出 ui.init(style)（新版 Vela 文档约定，运行时若调用则复用已构建界面）
--   3) 导出 pageOnPause/pageOnResume 与 ScreenStateChangedCB（屏幕状态回调）
-- 所有构建步骤均 pcall 包裹：任何单点失败都降级为最小界面，绝不导致 Lua VM 崩溃。

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
local config = loadModule("config")
local theme = loadModule("theme")
local watchface = loadModule("watchface")
local filemanager = loadModule("filemanager")

-- 打桩环境下可能缺失，给出兜底
if not utils then utils = { constValue = function(v) return v end } end
if not theme then theme = { BG = 0x07090D, ACCENT = 0x37E0A4 } end

local ui = {}
local root, wf, fm
local built = false

local function constValue(v)
  if type(v) == "function" then return v() end
  return v or 336
end

local function showWatch()
  pcall(function()
    if fm then fm:hide() end
    if wf then wf:show() end
  end)
end

local function showFileManager()
  pcall(function()
    if wf then wf:hide() end
    if fm then
      fm:show()
    else
      -- 懒创建：首次进入文件管理器时才构建（不扫描文件系统，避免加载期 I/O）
      local ok, mod = pcall(filemanager.create, root, showWatch)
      if ok and mod then
        fm = mod
        fm:show()
      end
    end
  end)
end

-- 构建界面；失败时降级为最小静态界面
local function buildUI(style)
  if built then return root end
  built = true
  local w = constValue(lvgl.HOR_RES)
  local h = constValue(lvgl.VER_RES)

  local ok = pcall(function()
    root = lvgl.Object(nil, {
      w = w,
      h = h,
      bg_color = theme.BG,
      bg_opa = 255,
      border_width = 0,
      pad_all = 0,
    })
    root:clear_flag(lvgl.FLAG.SCROLLABLE)
    root:add_flag(lvgl.FLAG.EVENT_BUBBLE)
    ui.root = root

    -- 表盘主界面
    wf = watchface.create(root, showFileManager)
    showWatch()
  end)

  if not ok then
    -- 最小兜底界面：纯静态文字
    pcall(function()
      root = lvgl.Object(nil, {
        w = w, h = h,
        bg_color = theme.BG,
        bg_opa = 255,
        border_width = 0,
      })
      root:clear_flag(lvgl.FLAG.SCROLLABLE)
      ui.root = root
      lvgl.Label(root, {
        align = { type = lvgl.ALIGN.CENTER },
        text = "DEEP_SCAN",
        text_color = theme.ACCENT,
        text_font = lvgl.Font("montserrat", 16, "normal"),
      })
    end)
  end
  return root
end

function ui.init(style)
  return buildUI(style)
end

function pageOnPause()
  pcall(function()
    if wf then wf:pageOnPause() end
    if fm then fm:pageOnPause() end
  end)
end

function pageOnResume()
  pcall(function()
    if wf then wf:pageOnResume() end
    if fm then fm:pageOnResume() end
  end)
end

-- 屏幕状态回调（9 Pro 运行时约定）：熄屏暂停，亮屏恢复
function ScreenStateChangedCB(pre, now, reason)
  if now and now ~= "ON" then
    pageOnPause()
  else
    pageOnResume()
  end
end

-- 顶层构建：9 Pro 运行时只执行 main.lua 顶层代码
buildUI()

return ui
