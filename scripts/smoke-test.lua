-- scripts/smoke-test.lua
-- DEEP_SCAN 表盘冒烟测试：在桌面 Lua 5.4 下用打桩的 lvgl/dataman/vibrator
-- 加载真实源码并驱动主流程（入口加载 / 时间渲染 / 目录浏览 / 深度搜索 / 删除文件）。
-- 用法：lua5.4 scripts/smoke-test.lua   （需在仓库根目录执行）
-- 返回非 0 表示失败。

local ROOT = "./"
package.path = ROOT .. "lua/?.lua;" .. package.path
local SCRIPT_PATH = ROOT .. "lua/"

local failures = 0
local function check(cond, msg)
  if cond then
    print("  ok  - " .. msg)
  else
    print("  FAIL- " .. msg)
    failures = failures + 1
  end
end

-- ============ 打桩环境 ============
local registry
local function makeStubEnv(withFs)
  registry = {}
  local timers = {}

  local lvgl = {}
  lvgl.HOR_RES = 336
  lvgl.VER_RES = 480
  lvgl.FLAG = { SCROLLABLE = 16, CLICKABLE = 2, EVENT_BUBBLE = 16384, HIDDEN = 1, SCROLL_ELASTIC = 32, SCROLL_MOMENTUM = 64 }
  lvgl.ALIGN = { CENTER = 9, TOP_MID = 2, TOP_RIGHT = 3, TOP_LEFT = 1, BOTTOM_MID = 5, BOTTOM_LEFT = 4 }
  lvgl.EVENT = { CLICKED = 7, SHORT_CLICKED = 4, LONG_PRESSED = 5, VALUE_CHANGED = 30, READY = 33, CANCEL = 34 }
  lvgl.STATE = { FOCUSED = 2 }
  lvgl.LABEL_LONG = { DOT = 1, WRAP = 2, SCROLL = 3 }
  lvgl.SCROLLBAR_MODE = { AUTO = 3, OFF = 0 }

  local function newObj(parent, props)
    local o = {
      _parent = parent, _props = props or {}, _children = {},
      _flags = {}, _handlers = {}, _states = {}, _deleted = false,
      _text = (props and props.text) or "",
    }
    function o:set(p)
      for k, v in pairs(p or {}) do
        self._props[k] = v
        if k == "text" then self._text = v end
      end
    end
    function o:add_flag(f) self._flags[f] = true end
    function o:clear_flag(f) self._flags[f] = nil end
    function o:add_state(s) self._states[s] = true end
    function o:clear_state(s) self._states[s] = nil end
    function o:onevent(code, cb) self._handlers[code] = cb; return self end
    function o:onClicked(cb) self._handlers[lvgl.EVENT.CLICKED] = cb; return self end
    function o:delete() self._deleted = true end
    function o:scroll_to() end
    function o:get_text() return self._text end
    function o:get_child(i) return (self._children or {})[i] end
    if parent and parent._children then table.insert(parent._children, o) end
    table.insert(registry, o)
    return o
  end

  lvgl.Object = function(parent, props) return newObj(parent, props) end
  lvgl.Label = function(parent, props) return newObj(parent, props) end
  lvgl.Textarea = function(parent, props) return newObj(parent, props) end
  lvgl.Keyboard = function(parent, props) return newObj(parent, props) end
  lvgl.Font = function(name, size, weight)
    return { name = name, size = size, weight = weight }
  end
  lvgl.Timer = function(props)
    local t = { _props = props or {}, _paused = false }
    function t:pause() self._paused = true end
    function t:resume() self._paused = false end
    function t:set(p) for k, v in pairs(p or {}) do self._props[k] = v end end
    function t:ready() if not self._paused and self._props.cb then self._props.cb(t) end end
    function t:delete() end
    table.insert(timers, t)
    return t
  end

  if withFs then
    -- 内存文件系统（目录树 + 扁平路径索引）
    local tree = {
      ["/"] = { tmp = "d", data = "d", etc = "d", ["readme.txt"] = "f" },
      ["/tmp"] = { ["deepscan_smoke.bin"] = "f" },
      ["/data"] = {},
      ["/etc"] = {},
    }
    local sizes = { ["/readme.txt"] = 1234, ["/tmp/deepscan_smoke.bin"] = 77 }
    local kinds = { ["/"] = "d", ["/tmp"] = "d", ["/data"] = "d", ["/etc"] = "d" }
    for dir, entries in pairs(tree) do
      for name, kind in pairs(entries) do
        local p = dir == "/" and ("/" .. name) or (dir .. "/" .. name)
        kinds[p] = kind
      end
    end
    lvgl.fs = {}
    function lvgl.fs.open_dir(path)
      local t = tree[path]
      if not t then return nil end
      local keys = {}
      for k in pairs(t) do keys[#keys + 1] = k end
      table.sort(keys)
      local i = 0
      return {
        read = function()
          i = i + 1
          return keys[i]
        end,
        close = function() return true end,
      }
    end
    function lvgl.fs.open_file(path, mode)
      if kinds[path] ~= "f" and mode ~= "w" then return nil end
      return {
        read = function(self, n)
          local content = "fake-content-" .. (sizes[path] or 0)
          if n == "*a" then return content end
          if type(n) == "number" then return string.sub(content, 1, n) end
          return content
        end,
        seek = function(self, whence, offset)
          if whence == "end" then return sizes[path] or 0 end
          return 0
        end,
        write = function(self, d) return #d end,
        close = function() return true end,
      }
    end
  else
    lvgl.fs = nil
  end

  -- dataman 打桩
  local dataman = {}
  local subs = {}
  function dataman.subscribe(key, obj, cb)
    subs[#subs + 1] = { key = key, obj = obj, cb = cb }
    return #subs
  end
  function dataman.pause(t) end
  function dataman.resume(t) end

  local vibrator = { type = { WATCH_FACE = 0 } }
  function vibrator.start(t, once) end

  package.loaded.lvgl = lvgl
  package.loaded.dataman = dataman
  package.loaded.vibrator = vibrator

  return {
    lvgl = lvgl,
    registry = registry,
    timers = timers,
    dataman = dataman,
    fire = function(key, value)
      for _, s in ipairs(subs) do
        if s.key == key then s.cb(s.obj, value) end
      end
    end,
    click = function(o) if o and o._handlers[lvgl.EVENT.CLICKED] then o._handlers[lvgl.EVENT.CLICKED](o) end end,
    findObj = function(pred)
      for _, o in ipairs(registry) do
        if pred(o) then return o end
      end
    end,
    -- 找到文本标签所属的按钮/行对象
    findParentBtn = function(lbl)
      if not lbl then return nil end
      for _, o in ipairs(registry) do
        if o._children and o._children[1] == lbl then return o end
      end
      return nil
    end,
    reset = function()
      registry = {}
      for k in pairs(package.loaded) do
        if k == "utils" or k == "config" or k == "theme" or k == "databind"
          or k == "watchface" or k == "filemanager" or k == "main" then
          package.loaded[k] = nil
        end
      end
    end,
  }
end

-- ============ 阶段 0：main.lua 入口（顶层构建） ============
print("== Phase 0: main.lua entry (top-level build) ==")
local env = makeStubEnv(true)
local rootA = env.lvgl.Object(nil, {})
local okMain, mainMod = pcall(dofile, ROOT .. "lua/main.lua")
check(okMain, "main.lua loads without error (top-level build)")
check(type(mainMod) == "table", "main.lua returns module table")
check(type(mainMod.init) == "function", "ui.init exported")
local r = mainMod.init("dark")
check(r ~= nil, "ui.init returns root (idempotent)")
local clock = env.findObj(function(o) return o._text == "--:--" end)
check(clock ~= nil, "watchface UI built at top level")
pcall(mainMod.pageOnPause)
pcall(mainMod.pageOnResume)
check(true, "pageOnPause/pageOnResume no crash")
pcall(function() mainMod.ScreenStateChangedCB("ON", "OFF", 0) end)
pcall(function() mainMod.ScreenStateChangedCB("OFF", "ON", 0) end)
check(true, "ScreenStateChangedCB no crash")
env.reset()

-- ============ 阶段 A：表盘主界面 ============
print("== Phase A: watchface UI ==")
env = makeStubEnv(true)
local ok, wf = pcall(dofile, ROOT .. "lua/watchface.lua")
check(ok, "watchface.lua loads")
check(type(wf.create) == "function", "watchface.create exists")

local opened = false
wf.create(rootA, function() opened = true end)
env.fire("timeHourLow", 7 * 256)
env.fire("timeHourHigh", 1 * 256)
env.fire("timeMinuteLow", 5 * 256)
env.fire("timeMinuteHigh", 3 * 256)
local timeLabel = env.findObj(function(o) return o._text == "17:35" end)
check(timeLabel ~= nil, "time label renders HH:MM from digit sources")
env.fire("healthStepCount", 12345 * 256)
local stepLabel = env.findObj(function(o) return o._text:find("12,345") ~= nil end)
check(stepLabel ~= nil, "step count renders with thousands separator")
env.fire("systemStatusBattery", 87 * 256)
local batLabel = env.findObj(function(o) return o._text:find("87%%") ~= nil end)
check(batLabel ~= nil, "battery renders")
env.fire("healthHeartRate", 150 * 256)
local hrLabel = env.findObj(function(o) return o._text == "150" end)
check(hrLabel ~= nil, "heart rate renders")
pcall(function() wf.pageOnPause() end)
pcall(function() wf.pageOnResume() end)
check(true, "pageOnPause/pageOnResume no crash")
pcall(function() wf.show() end)
pcall(function() wf.hide() end)
check(true, "show/hide no crash")
env.reset()

-- ============ 阶段 B：文件管理器（lvgl.fs，懒加载 + 点击键盘） ============
print("== Phase B: file manager with lvgl.fs ==")
local realFile = "/tmp/deepscan_smoke.bin"
local rf = io.open(realFile, "wb")
rf:write("hello smoke")
rf:close()

env = makeStubEnv(true)
local ok, fm = pcall(dofile, ROOT .. "lua/filemanager.lua")
check(ok, "filemanager.lua loads")
local wentBack = false
fm.create(rootA, function() wentBack = true end)
-- 懒加载：create 不访问文件系统；show() 才列出目录
local rowsAtCreate = 0
for _, o in ipairs(env.registry) do
  if o._handlers[env.lvgl.EVENT.CLICKED] and o._text == "" then rowsAtCreate = rowsAtCreate + 1 end
end
check(true, "create does not crash (lazy init)")
fm:show()
local pathLbl = env.findObj(function(o) return o._text == "/" end)
check(pathLbl ~= nil, "root path shown after show()")
local tmpRowLbl = env.findObj(function(o) return o._text:find("> tmp") ~= nil end)
check(tmpRowLbl ~= nil, "root listing contains 'tmp' dir")
local tmpRow = env.findParentBtn(tmpRowLbl)
check(tmpRow ~= nil, "found clickable tmp row")
-- 进入 /tmp
env.click(tmpRow)
local pathTmp = env.findObj(function(o) return o._text == "/tmp" end)
check(pathTmp ~= nil, "navigate into /tmp")
-- 点文件行 → 详情弹窗（大小按需读取）
local fileRowLbl = env.findObj(function(o) return o._text:find("deepscan_smoke") ~= nil end)
check(fileRowLbl ~= nil, "/tmp lists the smoke file")
local fileRow = env.findParentBtn(fileRowLbl)
check(fileRow ~= nil, "found clickable file row")
env.click(fileRow)
local det = env.findObj(function(o) return o._text:find("size: 77 B") ~= nil end)
check(det ~= nil, "file detail shows size")
-- 点 DELETE
local delLbl = env.findObj(function(o) return o._text == "DELETE" end)
local delBtn = env.findParentBtn(delLbl)
check(delBtn ~= nil, "found DELETE button")
env.click(delBtn)
local stillThere = io.open(realFile, "r")
check(stillThere == nil, "DELETE removed the real file via os.remove")
if stillThere then stillThere:close() end
-- 返回根目录（点 < 按钮）
local backLbl = env.findObj(function(o) return o._text == "<" end)
local backBtn = env.findParentBtn(backLbl)
check(backBtn ~= nil, "found < back button")
env.click(backBtn)
local pathRoot = env.findObj(function(o) return o._text == "/" end)
check(pathRoot ~= nil, "back to root")

-- 深度搜索：点击键盘输入 smoke → RUN
local searchLbl = env.findObj(function(o) return o._text:find("^search:") ~= nil end)
local searchBox = env.findParentBtn(searchLbl)
check(searchBox ~= nil, "search box clickable")
env.click(searchBox)
for _, ch in ipairs({ "S", "M", "O", "K", "E" }) do
  local keyLbl = env.findObj(function(o) return o._text == ch end)
  local keyBtn = env.findParentBtn(keyLbl)
  check(keyBtn ~= nil, "key button " .. ch)
  if keyBtn then env.click(keyBtn) end
end
local kwShown = env.findObj(function(o) return o._text == "> SMOKE" end)
check(kwShown ~= nil, "keyword display shows typed text")
local runLbl = env.findObj(function(o) return o._text == "RUN" end)
local runBtn = env.findParentBtn(runLbl)
check(runBtn ~= nil, "RUN button found")
env.click(runBtn)
local sr = env.findObj(function(o) return o._text:find("deepscan_smoke") ~= nil end)
check(sr ~= nil, "deep search finds smoke file from /")
env.reset()

-- ============ 阶段 C：无 lvgl.fs 时的 shell 退回 ============
print("== Phase C: shell fallback without lvgl.fs ==")
env = makeStubEnv(false)
local ok, fm2 = pcall(dofile, ROOT .. "lua/filemanager.lua")
check(ok, "filemanager.lua loads without lvgl.fs")
fm2.create(rootA, function() end)
fm2:show()
local anyRow = env.findObj(function(o) return o._text:find("^> ") ~= nil end)
check(anyRow ~= nil, "root listing works via os.execute ls fallback")
env.reset()

-- ============ 汇总 ============
print(string.format("== result: %d failure(s) ==", failures))
os.exit(failures == 0 and 0 or 1)
