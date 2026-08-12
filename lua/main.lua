-- main.lua
-- DEEP_SCAN 表盘入口（小米手环 9 Pro / Vela Lua 5.4）
-- 表盘主界面 + 系统文件管理器（深度浏览 / 深度搜索 / 删除文件）

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

local ui = {}
local root
local wf, fm

local function showWatch()
  if fm then fm:hide() end
  if wf then wf:show() end
end

local function showFileManager()
  if wf then wf:hide() end
  if fm then fm:show() end
end

function ui.init(style)
  root = lvgl.Object(nil, {
    w = utils.constValue(lvgl.HOR_RES),
    h = utils.constValue(lvgl.VER_RES),
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
  -- 文件管理器
  fm = filemanager.create(root, showWatch)

  showWatch()
  return root
end

function pageOnPause()
  if wf then wf:pageOnPause() end
  if fm then fm:pageOnPause() end
end

function pageOnResume()
  if wf then wf:pageOnResume() end
  if fm then fm:pageOnResume() end
end

return ui
