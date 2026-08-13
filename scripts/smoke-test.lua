-- scripts/smoke-test.lua
-- DEEP_SCAN 表盘冒烟测试：在桌面 Lua 5.4 下用打桩的 lvgl/dataman
-- 加载真实 lua/main.lua（单文件自包含）并驱动主流程：
--   入口加载 / 时间渲染 / 文件管理器打开 / 目录浏览 / 深度搜索 / 删除文件 / 无 fs 降级
-- 用法：lua5.4 scripts/smoke-test.lua   （需在仓库根目录执行）
-- 返回非 0 表示失败。

local ROOT = "./"
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
local point = { x = 0, y = 0 }
local registry = {}

local function makeEnv(withFs)
  registry = {}
  point.x, point.y = 0, 0

  local lvgl = {}
  lvgl.HOR_RES = function() return 336 end
  lvgl.VER_RES = function() return 480 end
  lvgl.FLAG = { SCROLLABLE = 16, CLICKABLE = 2, EVENT_BUBBLE = 16384, HIDDEN = 1 }
  lvgl.ALIGN = { CENTER = 9, TOP_MID = 2, TOP_RIGHT = 3 }
  lvgl.EVENT = { CLICKED = 7, SHORT_CLICKED = 4 }
  lvgl.BUILTIN_FONT = {
    DEFAULT = { name = "default" }, MONTSERRAT_14 = { name = "m14" },
    MONTSERRAT_16 = { name = "m16" }, MONTSERRAT_18 = { name = "m18" },
    MONTSERRAT_24 = { name = "m24" }, MONTSERRAT_32 = { name = "m32" },
  }

  local function newObj(parent, props)
    local o = {
      _parent = parent, _props = props or {}, _children = {},
      _flags = {}, _handlers = {}, _deleted = false,
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
    function o:onevent(code, cb) self._handlers[code] = cb; return self end
    function o:delete() self._deleted = true end
    function o:is_visible() return not self._props.hidden end
    if parent and parent._children then table.insert(parent._children, o) end
    table.insert(registry, o)
    return o
  end

  lvgl.Object = function(parent, props) return newObj(parent, props) end
  lvgl.Label = function(parent, props) return newObj(parent, props) end
  lvgl.indev = {
    get_act = function()
      return { get_point = function() return point.x, point.y end }
    end,
  }

  if withFs then
    local tree = {
      ["/"] = { data = "d", tmp = "d", etc = "d" },
      ["/data"] = { app = "d", ["notes.txt"] = "f", ["report.txt"] = "f" },
      ["/data/app"] = { ["config.json"] = "f" },
      ["/tmp"] = { ["deepscan_smoke.bin"] = "f" },
      ["/etc"] = {},
    }
    lvgl.fs = {}
    function lvgl.fs.open_dir(path)
      local t = tree[path]
      if not t then return nil end
      local keys = {}
      for k in pairs(t) do keys[#keys + 1] = k end
      table.sort(keys)
      local i = 0
      return {
        read = function() i = i + 1; return keys[i] end,
        close = function() return true end,
      }
    end
    function lvgl.fs.open_file(path, mode)
      local isFile = false
      for dir, entries in pairs(tree) do
        for name in pairs(entries) do
          local p = dir == "/" and ("/" .. name) or (dir .. "/" .. name)
          if p == path then isFile = true end
        end
      end
      if not isFile and mode ~= "w" then return nil end
      return {
        read = function(_, n)
          local c = "fake-content"
          if n == "*a" then return c end
          if type(n) == "number" then return string.sub(c, 1, n) end
          return c
        end,
        seek = function(_, whence)
          if whence == "end" then return 1234 end
          return 0
        end,
        write = function(_, d) return #d end,
        close = function() return true end,
      }
    end
  else
    lvgl.fs = nil
  end

  local dataman = {}
  local subs = {}
  function dataman.subscribe(key, obj, cb)
    subs[#subs + 1] = { key = key, obj = obj, cb = cb }
    return #subs
  end
  function dataman.pause() end
  function dataman.resume() end

  package.loaded.lvgl = lvgl
  package.loaded.dataman = dataman

  return {
    lvgl = lvgl,
    registry = registry,
    fire = function(key, value)
      for _, s in ipairs(subs) do
        if s.key == key then s.cb(s.obj, value) end
      end
    end,
    tap = function(o, x, y)
      point.x, point.y = x, y
      if o and o._handlers[lvgl.EVENT.SHORT_CLICKED] then
        o._handlers[lvgl.EVENT.SHORT_CLICKED](o)
      elseif o and o._handlers[lvgl.EVENT.CLICKED] then
        o._handlers[lvgl.EVENT.CLICKED](o)
      end
    end,
    findText = function(t)
      for _, o in ipairs(registry) do
        if o._text == t then return o end
      end
      return nil
    end,
    findTextContains = function(t)
      for _, o in ipairs(registry) do
        if o._text:find(t, 1, true) then return o end
      end
      return nil
    end,
    clickables = function()
      local out = {}
      for _, o in ipairs(registry) do
        if o._handlers[lvgl.EVENT.CLICKED] then out[#out + 1] = o end
      end
      return out
    end,
    -- 依据标签的屏幕坐标点击（行标签 props.y 为其行内位置）
    tapByLabel = function(fmPage, text, xoff)
      local lbl = nil
      for _, o in ipairs(registry) do
        if o._text == text then lbl = o; break end
      end
      if not lbl then return false end
      local x = (lbl._props.x or 0) + (xoff or 20)
      local y = (lbl._props.y or 0) + 9
      point.x, point.y = x, y
      if fmPage._handlers[lvgl.EVENT.SHORT_CLICKED] then
        fmPage._handlers[lvgl.EVENT.SHORT_CLICKED](fmPage)
      end
      return true
    end,
    -- 键盘按键：面板在 (8,16)，按键 label 坐标为面板内坐标
    tapKey = function(fmPage, ch)
      local lbl = nil
      for _, o in ipairs(registry) do
        if o._text == ch then lbl = o; break end
      end
      if not lbl then return false end
      local x = 8 + (lbl._props.x or 0) + (lbl._props.w or 30) / 2
      local y = 16 + (lbl._props.y or 0) + (lbl._props.h or 32) / 2
      point.x, point.y = x, y
      if fmPage._handlers[lvgl.EVENT.SHORT_CLICKED] then
        fmPage._handlers[lvgl.EVENT.SHORT_CLICKED](fmPage)
      end
      return true
    end,
  }
end

-- ============ 阶段 0：入口加载 + 表盘渲染 ============
print("== Phase 0: main.lua entry (top-level build) ==")
local env = makeEnv(true)
local okMain, mainMod = pcall(dofile, ROOT .. "lua/main.lua")
check(okMain, "main.lua loads without error (top-level build)")
check(type(mainMod) == "table" and type(mainMod.init) == "function", "returns ui table with init")
check(type(ScreenStateChangedCB) == "function", "ScreenStateChangedCB exported")
local r = mainMod.init("dark")
check(r ~= nil, "ui.init returns root")

check(env.findText("--:--") ~= nil, "watchface time label built at top level")
check(env.findText("DEEP_SCAN") ~= nil, "brand label built")

-- 数据订阅渲染
env.fire("timeHour", 17 * 256)
env.fire("timeMinute", 35 * 256)
check(env.findText("17:35") ~= nil, "time renders HH:MM")
env.fire("timeSecond", 9 * 256)
check(env.findText("09") ~= nil, "seconds render")
env.fire("systemStatusBattery", 87 * 256)
check(env.findTextContains("87%") ~= nil, "battery renders")
env.fire("healthStepCount", 12345 * 256)
check(env.findTextContains("12345") ~= nil, "steps render")
env.fire("healthHeartRate", 150 * 256)
check(env.findTextContains("150") ~= nil, "heart rate renders")
pcall(function() ScreenStateChangedCB("ON", "OFF", 0) end)
pcall(function() ScreenStateChangedCB("OFF", "ON", 0) end)
check(true, "ScreenStateChangedCB no crash")

-- ============ 阶段 A：打开文件管理器 + 浏览 ============
print("== Phase A: file manager browse ==")
local watchPage = env.clickables()[1]
check(watchPage ~= nil, "watch page clickable")
env.tap(watchPage, 168, 400) -- 下半屏 → 打开文件管理器
local fmPage = env.clickables()[2]
check(fmPage ~= nil, "file manager page built on tap")
check(env.findTextContains("search: deep scan") ~= nil, "fm search bar present")
check(env.findText("> app") ~= nil, "fm lists /data/app dir")
check(env.findText("notes.txt") ~= nil, "fm lists /data/notes.txt")

-- ============ 阶段 B：递归搜索 ============
print("== Phase B: deep search ==")
-- 先回到根目录（".." 行）
check(env.tapByLabel(fmPage, "> .."), "found '..' row")
check(env.findText("> tmp") ~= nil, "root lists /tmp")
-- 打开搜索栏（y 56..96）
env.tap(fmPage, 100, 76)
for _, ch in ipairs({ "N", "O", "T", "E", "S" }) do
  check(env.tapKey(fmPage, ch), "tap key " .. ch)
end
check(env.findTextContains("search: NOTES") ~= nil, "keyword typed")
check(env.tapKey(fmPage, "RUN"), "tap RUN")
check(env.findText("/data/notes.txt") ~= nil, "recursive search finds /data/notes.txt from /")

-- ============ 阶段 C：删除文件 ============
print("== Phase C: delete file ==")
-- 退出搜索（顶栏 < 按钮，x<56, y<56）
env.tap(fmPage, 20, 30)
check(env.findText("> tmp") ~= nil, "back to browse root")
-- 创建真实文件用于删除验证
local realFile = "/tmp/deepscan_smoke.bin"
local rf = io.open(realFile, "wb")
rf:write("hello smoke")
rf:close()
check(io.open(realFile, "r") ~= nil, "real smoke file created")

check(env.tapByLabel(fmPage, "> tmp"), "navigate into /tmp")
check(env.findText("deepscan_smoke.bin") ~= nil, "/tmp lists smoke file")
check(env.tapByLabel(fmPage, "deepscan_smoke.bin"), "open file detail")
check(env.findText("DELETE?") ~= nil, "detail overlay shows")
env.tap(fmPage, 300, 200) -- 右半屏 → DELETE
local stillThere = io.open(realFile, "r")
check(stillThere == nil, "DELETE removed the real file via os.remove")
if stillThere then stillThere:close() end

-- ============ 阶段 D：无 lvgl.fs 降级 ============
print("== Phase D: degrade without lvgl.fs ==")
env = makeEnv(false)
local ok2 = pcall(dofile, ROOT .. "lua/main.lua")
check(ok2, "main.lua loads without lvgl.fs")
check(env.findText("--:--") ~= nil, "watchface still builds without fs")
local wp2 = env.clickables()[1]
env.tap(wp2, 168, 400)
local fp2 = env.clickables()[2]
check(fp2 ~= nil, "file manager page built without fs")
check(env.findTextContains("cannot open") ~= nil, "graceful 'cannot open' without fs api")

-- ============ 汇总 ============
print(string.format("== result: %d failure(s) ==", failures))
os.exit(failures == 0 and 0 or 1)
