-- scripts/smoke-test.lua
-- DEEP_SCAN 文件管理器表盘冒烟测试：桌面 Lua 5.4 + 打桩 lvgl/fs
-- 驱动真实 lua/main.lua（简洁版文件管理器）主流程：
--   初始列表 / 目录导航 / 删除文件 / 无 fs 降级
-- 用法：lua5.4 scripts/smoke-test.lua
-- 返回非 0 表示失败。

local ROOT = "./"

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
local registry = {}

local function makeEnv(withFs)
  registry = {}

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
    function o:delete()
      if self._deleted then return end
      self._deleted = true
      for _, c in ipairs(self._children) do c:delete() end
      for i = #registry, 1, -1 do
        if registry[i] == self then table.remove(registry, i); break end
      end
    end
    function o:is_visible() return not self._props.hidden end
    if parent and parent._children then table.insert(parent._children, o) end
    table.insert(registry, o)
    return o
  end

  lvgl.Object = function(parent, props) return newObj(parent, props) end
  lvgl.Label = function(parent, props) return newObj(parent, props) end

  if withFs then
    local tree = {
      ["/"] = { data = "d", tmp = "d", etc = "d" },
      ["/data"] = { app = "d", ["notes.txt"] = "f", ["report.txt"] = "f" },
      ["/data/app"] = { ["config.json"] = "f" },
      ["/tmp"] = { ["deepscan_smoke.bin"] = "f" },
      ["/etc"] = {},
    }
    lvgl.fs = {}
    function lvgl.fs.open_dir(p)
      local t = tree[p]
      if not t then return nil end
      local keys = {}
      for k in pairs(t) do keys[#keys + 1] = k end
      table.sort(keys)
      local i = 0
      return { read = function() i = i + 1; return keys[i] end, close = function() return true end }
    end
    function lvgl.fs.open_file(p, mode)
      local isFile = false
      for dir, ents in pairs(tree) do
        for name in pairs(ents) do
          local fp = dir == "/" and ("/" .. name) or (dir .. "/" .. name)
          if fp == p then isFile = true end
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
        seek = function(_, whence) if whence == "end" then return 1234 end return 0 end,
        write = function(_, d) return #d end,
        close = function() return true end,
      }
    end
  else
    lvgl.fs = nil
  end

  package.loaded.lvgl = lvgl

  local function findLabel(text)
    for _, o in ipairs(registry) do
      if not o._deleted and o._text == text then return o end
    end
    return nil
  end

  local function findLabelContains(text)
    for _, o in ipairs(registry) do
      if not o._deleted and o._text:find(text, 1, true) then return o end
    end
    return nil
  end

  return {
    lvgl = lvgl,
    registry = registry,
    findLabel = findLabel,
    findLabelContains = findLabelContains,
    -- 触发某对象的 SHORT_CLICKED 回调（按钮）
    tapBtn = function(btn)
      if btn and btn._handlers[lvgl.EVENT.SHORT_CLICKED] then
        btn._handlers[lvgl.EVENT.SHORT_CLICKED](btn)
        return true
      end
      return false
    end,
    -- 找到某名称标签所属的（可点击）按钮
    nameBtnOf = function(labelText)
      local lbl = findLabel(labelText)
      if not lbl then return nil end
      return lbl._parent
    end,
    -- 找到某行右侧的 DEL 按钮：与名称按钮同 y 的 DEL 按钮
    delBtnFor = function(nameBtn)
      if not nameBtn then return nil end
      for _, o in ipairs(registry) do
        if not o._deleted and o._parent == nameBtn and o._children then
          for _, c in ipairs(o._children) do
            if not c._deleted and c._text == "Delete" then return o end
          end
        end
      end
      return nil
    end,
  }
end

-- ============ 阶段 0：入口加载 + 初始列表 ============
print("== Phase 0: entry load + initial list ==")
local env = makeEnv(true)
local okMain, mainMod = pcall(dofile, ROOT .. "lua/main.lua")
check(okMain, "main.lua loads without error")
check(mainMod == nil, "top-level entry (Monika convention, no ui module)")
check(type(ScreenStateChangedCB) == "function", "ScreenStateChangedCB exported")
check(env.findLabel("/data") ~= nil, "initial path label shows /data")
check(env.findLabel("app/") ~= nil, "lists folder app/")
check(env.findLabel("notes.txt") ~= nil, "lists file notes.txt")
check(env.findLabel("report.txt") ~= nil, "lists file report.txt")

-- ============ 阶段 A：目录导航 ============
print("== Phase A: navigate ==")
local appBtn = env.nameBtnOf("app/")
check(appBtn ~= nil, "found app/ name button")
check(env.tapBtn(appBtn), "tap app/ navigates")
check(env.findLabel("/data/app") ~= nil, "path label shows /data/app")
check(env.findLabel("config.json") ~= nil, "lists config.json")

local upBtn = env.nameBtnOf("..  (up)")
check(upBtn ~= nil, "found up button")
check(env.tapBtn(upBtn), "tap up")
check(env.findLabel("/data") ~= nil, "back to /data")

-- ============ 阶段 B：删除文件 ============
print("== Phase B: delete file ==")
-- 创建真实文件用于删除验证
local realFile = "/tmp/deepscan_smoke.bin"
local rf = io.open(realFile, "wb")
rf:write("hello smoke")
rf:close()
check(io.open(realFile, "r") ~= nil, "real smoke file created")

-- 从 /data 上到 /，进入 /tmp
check(env.tapBtn(env.nameBtnOf("..  (up)")), "up to /")
check(env.findLabel("tmp/") ~= nil, "root lists tmp/")
check(env.tapBtn(env.nameBtnOf("tmp/")), "enter /tmp")
check(env.findLabel("deepscan_smoke.bin") ~= nil, "/tmp lists smoke file")

-- 点 DEL → 弹窗 → DELETE
local fileBtn = env.nameBtnOf("deepscan_smoke.bin")
local delBtn = env.delBtnFor(fileBtn)
check(delBtn ~= nil, "found DEL button for smoke file")
check(env.tapBtn(delBtn), "tap DEL opens confirm dialog")
check(env.findLabel("Delete this item?") ~= nil, "confirm dialog shows")

local deleteBtn = env.nameBtnOf("DELETE")
check(deleteBtn ~= nil, "found DELETE confirm button")
check(env.tapBtn(deleteBtn), "tap DELETE")
local stillThere = io.open(realFile, "r")
check(stillThere == nil, "os.remove deleted the real file")
if stillThere then stillThere:close() end

-- ============ 阶段 C：无 fs 降级 ============
print("== Phase C: degrade without lvgl.fs ==")
env = makeEnv(false)
local ok2 = pcall(dofile, ROOT .. "lua/main.lua")
check(ok2, "main.lua loads without lvgl.fs")
check(env.findLabelContains("cannot open") ~= nil, "graceful 'cannot open' without fs api")

-- ============ 阶段 D：能力面板 + 注入实验 ============
print("== Phase D: capability panel + inject experiment ==")
env = makeEnv(true)
local ok3 = pcall(dofile, ROOT .. "lua/main.lua")
check(ok3, "main.lua re-loads")
check(env.tapBtn(env.nameBtnOf("i")), "tap i opens capability panel")
check(env.findLabel("SYSTEM CAPABILITIES") ~= nil, "capability panel shows")
local injBtn = env.nameBtnOf("INJECT")
check(injBtn ~= nil, "found INJECT button")
check(env.tapBtn(injBtn), "tap INJECT runs pipeline")
check(env.findLabel("NATIVE INJECT") ~= nil, "inject result panel shows (no payload)")

-- ============ 阶段 E：注入链路（insmod → lsmod 解析基址 → exec）============
-- 打桩 os.execute / io.popen 模拟实机验证过的调用链，验证解析逻辑正确。
print("== Phase E: injection chain (write -> insmod -> lsmod -> exec) ==")
env = makeEnv(true)

PAYLOAD = "fake .ko bytes"
local realExecute = os.execute
local realPopen = io.popen
os.execute = function(cmd)
  if cmd:find("insmod", 1, true) then
    return true, "exit", 0
  elseif cmd:find("exec ", 1, true) then
    return true, "exit", 0
  end
  return true, "exit", 0
end
io.popen = function(cmd, mode)
  if cmd:find("lsmod", 1, true) then
    return {
      read = function(_, n)
        return "NAME INIT UNINIT ARG NEXPORTS TEXT SIZE DATA SIZE\n" ..
               "deepscan 0 0 0 0x3D3B1D90 1000 500\n"
      end,
      close = function() return true end,
    }
  elseif cmd:find("mw ", 1, true) then
    return { read = function() return "0x5EED0001" end, close = function() return true end }
  end
  return nil
end

local ok4 = pcall(dofile, ROOT .. "lua/main.lua")
check(ok4, "main.lua loads with embedded payload + stubbed shell")
check(env.tapBtn(env.nameBtnOf("i")), "tap i opens capability panel")
check(env.tapBtn(env.nameBtnOf("INJECT")), "tap INJECT runs full chain")
check(env.findLabel("NATIVE INJECT") ~= nil, "inject result panel shows")
check(env.findLabelContains("base 0x3D3B1D90") ~= nil, "lsmod parsed module base 0x3D3B1D90")
check(env.findLabelContains("exit 0") ~= nil, "insmod/exec returned clean exit 0")

os.execute = realExecute
io.popen = realPopen
PAYLOAD = nil

-- ============ 阶段 F：RE DUMP（目录树 + 文件拷贝 + shell 捕获）============
-- 打桩 io.open 捕获写入，验证 tree_root/tree_data 目录树生成 + 结果面板。
print("== Phase F: RE dump (tree walk + copy + shell capture) ==")
env = makeEnv(true)
local written = {}
local realIOOpen = io.open
io.open = function(path, mode)
  if mode == "wb" then
    return {
      write = function(_, d) written[path] = d; return #d end,
      close = function() return true end,
    }
  end
  return nil
end
os.execute = function() return true, "exit", 0 end
io.popen = function() return nil end

local ok5 = pcall(dofile, ROOT .. "lua/main.lua")
check(ok5, "main.lua loads for RE dump")
check(env.tapBtn(env.nameBtnOf("i")), "tap i opens capability panel")
check(env.tapBtn(env.nameBtnOf("DUMP")), "tap DUMP runs RE dump")
check(env.findLabelContains("RE DUMP") ~= nil, "dump result panel shows")

local treeRoot = written["/data/deepscan_re/tree_root.txt"]
local treeData = written["/data/deepscan_re/tree_data.txt"]
check(treeRoot and treeRoot:find("tmp/", 1, true) ~= nil, "tree_root.txt lists tmp/")
check(treeData and treeData:find("app/", 1, true) ~= nil, "tree_data.txt lists app/")

io.open = realIOOpen
os.execute = realExecute
io.popen = realPopen

-- ============ 汇总 ============
print(string.format("== result: %d failure(s) ==", failures))
os.exit(failures == 0 and 0 or 1)
