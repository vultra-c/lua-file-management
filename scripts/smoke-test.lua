-- scripts/smoke-test.lua
-- DEEP_SCAN Files：桌面 Lua 5.4 + 打桩 LVGL/文件系统冒烟测试。

local ROOT = "./"
local failures = 0

local function check(condition, message)
  if condition then
    print("  PASS " .. message)
  else
    print("  FAIL " .. message)
    failures = failures + 1
  end
end

local function makeEnv(withFs)
  local registry = {}
  local lvgl = {
    HOR_RES = function() return 336 end,
    VER_RES = function() return 480 end,
    FLAG = { SCROLLABLE = 16, CLICKABLE = 2, EVENT_BUBBLE = 16384, HIDDEN = 1 },
    ALIGN = { CENTER = 9 },
    EVENT = { SHORT_CLICKED = 4 },
    BUILTIN_FONT = {
      DEFAULT = {}, MONTSERRAT_12 = {}, MONTSERRAT_13 = {},
      MONTSERRAT_14 = {}, MONTSERRAT_16 = {}, MONTSERRAT_18 = {},
      MONTSERRAT_24 = {}, MONTSERRAT_32 = {},
    },
  }

  local tree = {
    ["/"] = { data = "d", tmp = "d", etc = "d" },
    ["/data"] = { app = "d", ["notes.txt"] = "f", ["report.txt"] = "f" },
    ["/data/app"] = { ["config.json"] = "f" },
    ["/tmp"] = { ["deepscan_smoke.bin"] = "f" },
    ["/etc"] = {},
  }

  local function newObject(parent, props)
    local object = {
      _parent = parent, _props = props or {}, _children = {},
      _handlers = {}, _deleted = false,
      _text = props and props.text or "",
    }
    function object:set(values)
      for key, value in pairs(values or {}) do
        self._props[key] = value
        if key == "text" then self._text = value end
      end
    end
    function object:add_flag() end
    function object:clear_flag() end
    function object:onevent(code, callback) self._handlers[code] = callback end
    function object:delete()
      if self._deleted then return end
      self._deleted = true
      for _, child in ipairs(self._children) do child:delete() end
    end
    if parent and parent._children then parent._children[#parent._children + 1] = object end
    registry[#registry + 1] = object
    return object
  end

  lvgl.Object = function(parent, props) return newObject(parent, props) end
  lvgl.Label = function(parent, props) return newObject(parent, props) end

  if withFs then
    lvgl.fs = {}
    function lvgl.fs.open_dir(path)
      local entries = tree[path]
      if not entries then return nil end
      local names = {}
      for name in pairs(entries) do names[#names + 1] = name end
      table.sort(names)
      local index = 0
      return {
        read = function()
          index = index + 1
          return names[index]
        end,
        close = function() return true end,
      }
    end
    function lvgl.fs.open_file(path, mode)
      local known = false
      for directory, entries in pairs(tree) do
        for name in pairs(entries) do
          local full = directory == "/" and ("/" .. name) or (directory .. "/" .. name)
          if full == path then known = true end
        end
      end
      if not known and mode ~= "w" then return nil end
      return {
        read = function(_, amount)
          local content = "fake-content"
          if amount == "*a" then return content end
          if type(amount) == "number" then return content:sub(1, amount) end
          return content
        end,
        seek = function(_, offset, whence)
          if whence == "end" or offset == "end" then return 1234 end
          return 0
        end,
        write = function(_, value) return #value end,
        close = function() return true end,
      }
    end
  else
    lvgl.fs = nil
  end

  package.loaded.lvgl = lvgl
  FileManagerBackend = nil
  SCRIPT_PATH = ROOT .. "lua/"

  local function findLabel(text)
    for _, object in ipairs(registry) do
      if not object._deleted and object._text == text then return object end
    end
    return nil
  end

  local function findContains(text)
    for _, object in ipairs(registry) do
      if not object._deleted and object._text:find(text, 1, true) then return object end
    end
    return nil
  end

  local function tap(button)
    if button and button._handlers[lvgl.EVENT.SHORT_CLICKED] then
      button._handlers[lvgl.EVENT.SHORT_CLICKED](button)
      return true
    end
    return false
  end

  local function buttonFor(text)
    local label = findLabel(text)
    return label and label._parent or nil
  end

  local function deleteButtonFor(rowButton)
    if not rowButton then return nil end
    for _, object in ipairs(registry) do
      if not object._deleted and object._parent == rowButton then
        for _, child in ipairs(object._children or {}) do
          if child._text == "Delete" then return object end
        end
      end
    end
    return nil
  end

  return {
    findLabel = findLabel,
    findContains = findContains,
    buttonFor = buttonFor,
    deleteButtonFor = deleteButtonFor,
    tap = tap,
  }
end

print("== Phase 0: load + list ==")
local env = makeEnv(true)
local ok = pcall(dofile, ROOT .. "lua/main.lua")
check(ok, "main.lua loads")
check(type(ScreenStateChangedCB) == "function", "screen lifecycle callback exported")
check(type(pageOnPause) == "function", "pageOnPause exported")
check(type(pageOnResume) == "function", "pageOnResume exported")
check(env.findLabel("/data") ~= nil, "starts at /data")
check(env.findLabel("app/") ~= nil, "lists directory")
check(env.findLabel("notes.txt") ~= nil, "lists file")

print("== Phase A: navigation ==")
check(env.tap(env.buttonFor("app/")), "enters app directory")
check(env.findLabel("/data/app") ~= nil, "path changes")
check(env.findLabel("config.json") ~= nil, "lists nested file")
check(env.tap(env.buttonFor("<")), "returns to parent")
check(env.findLabel("/data") ~= nil, "parent path restored")

print("== Phase B: delete ==")
local smokePath = "/tmp/deepscan_smoke.bin"
local realFile = io.open(smokePath, "wb")
realFile:write("hello smoke")
realFile:close()
check(io.open(smokePath, "r") ~= nil, "real smoke file created")
check(env.tap(env.buttonFor("<")), "returns to root")
check(env.tap(env.buttonFor("tmp/")), "enters tmp")
local fileButton = env.buttonFor("deepscan_smoke.bin")
local deleteButton = env.deleteButtonFor(fileButton)
check(deleteButton ~= nil, "delete action exists")
check(env.tap(deleteButton), "delete confirmation opens")
check(env.findLabel("Delete this item?") ~= nil, "confirmation title shown")
check(env.tap(env.buttonFor("DELETE")), "delete confirmed")
local remains = io.open(smokePath, "r")
check(remains == nil, "file removed")
if remains then remains:close() end

print("== Phase C: missing filesystem API ==")
env = makeEnv(false)
local degraded = pcall(dofile, ROOT .. "lua/main.lua")
check(degraded, "loads without lvgl.fs")
check(env.findContains("cannot open") ~= nil, "shows graceful error")

print("== Phase D: backend info ==")
env = makeEnv(true)
local reloaded = pcall(dofile, ROOT .. "lua/main.lua")
check(reloaded, "reloads cleanly")
check(env.tap(env.buttonFor("i")), "info panel opens")
check(env.findLabel("FILES BACKEND") ~= nil, "backend information shown")

if failures > 0 then
  print(string.format("\n%d checks failed", failures))
  os.exit(1)
end
print("\nAll smoke checks passed")
