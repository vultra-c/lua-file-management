-- ============================================================
-- DeepScan — 小米手环 9 Pro 文件管理器表盘（336×480）
-- 原生深色系统 UI 风格（MiWear 扁平列表）：安装后直接进入文件管理器。
--   顶栏：返回 + 标题 Files + 路径面包屑 + 能力探测(i)
--   列表：全宽扁平行 + 细分隔线；左 = 文件夹/文件图标 + 名称，右 = 红色 Delete
--   底栏：条目统计 + 分页
--
-- 入口约定（与 9 Pro 运行时 / Monika 一致）：
--   * 顶层直接构建 UI
--   * 导出 ScreenStateChangedCB(pre, now, reason)
--
-- 点击可靠性：
--   * 可点元素显式 add_flag(CLICKABLE) 并只注册 SHORT_CLICKED
--   * 子元素加 EVENT_BUBBLE，点击冒泡到父级
--   * 文件系统 / 删除 / 能力探测全部 pcall 包裹
-- ============================================================

local lvgl = require("lvgl")

-- HOR_RES/VER_RES 在部分运行时是函数、部分模拟环境是数值，统一读取
local function constValue(value)
  return type(value) == "function" and value() or value
end
local W = constValue(lvgl.HOR_RES) or 336
local H = constValue(lvgl.VER_RES) or 480
if W == 0 then W = 336 end
if H == 0 then H = 480 end

-- ---- 配置 ----
local HOME = "/data"
local ROOT = "/"
local LIST_CAP = 300
local ROWS_PER_PAGE = 6
local ENTRIES_PER_PAGE = ROWS_PER_PAGE -- 每页条目数（无 ".." 行，返回上级用顶栏 <）
local ROW_H = 56
local HEADER_H = 64
local FOOTER_H = 44
local LIST_TOP = HEADER_H
local FOOTER_TOP = H - FOOTER_H
local NAME_X = 48
local DEL_W = 72
local DEL_H = 32

-- ---- 原生深色配色（MiWear 系统 UI）----
local C = {
  BG = 0x000000,           -- 纯黑背景
  SURFACE = 0x111113,      -- 弹窗/卡片抬升面
  TEXT = 0xFFFFFF,         -- 主文字
  DIM = 0x8E8E93,          -- 次要文字
  ACCENT = 0x0A84FF,       -- 系统蓝（文件夹/主色）
  DESTRUCTIVE = 0xFF453A,  -- 系统红（删除）
  DESTRUCTIVE_BG = 0x2A1114,
  SEP = 0x1C1C1E,          -- 细分隔线
  BTN = 0x1C1C1E,          -- 次级按钮底
  FILE_ICON = 0x3A3A3C,    -- 文件图标
}

-- ---- 字体（仅用已验证尺寸 14/16/18/24/32）----
local function font(size)
  local ok, f = pcall(function() return lvgl.Font("montserrat", size, "normal") end)
  if ok and f then return f end
  if lvgl.BUILTIN_FONT then
    return lvgl.BUILTIN_FONT["MONTSERRAT_" .. tostring(size)] or lvgl.BUILTIN_FONT.DEFAULT
  end
  return nil
end

-- ---- 工具 ----
local function joinPath(a, b)
  if a == "/" then return "/" .. b end
  return a .. "/" .. b
end

local function parentOf(p)
  if not p or p == "/" then return nil end
  local q = string.match(p, "^(.*)/[^/]*$")
  if not q or q == "" then return "/" end
  return q
end

local function humanSize(b)
  if not b or b < 0 then return "?" end
  if b < 1024 then return tostring(b) .. "B" end
  if b < 1048576 then return string.format("%.1fK", b / 1024) end
  return string.format("%.1fM", b / 1048576)
end

local function ltruncate(s, n)
  s = tostring(s or "")
  if #s <= n then return s end
  return ".." .. s:sub(#s - n + 3)
end

-- 右截断（保留开头）：用于统计/状态文案，保证“总数”永远可见
local function rtruncate(s, n)
  s = tostring(s or "")
  if #s <= n then return s end
  return s:sub(1, n - 2) .. ".."
end

-- 归一化目录项名称：去尾部斜杠、只保留最后一段，兼容某些 readdir 返回全路径/带斜杠
local function baseName(name)
  local n = tostring(name or "")
  n = n:gsub("[\\/]+$", "")
  return (n:match("([^\\/]+)$")) or n
end

local function printable(s, n)
  s = tostring(s or "")
  s = s:sub(1, n or 64)
  return (s:gsub("[^%g ]", "."))
end

local function setText(lbl, text, color)
  if not lbl then return end
  local p = { text = text }
  if color then p.text_color = color end
  pcall(function() lbl:set(p) end)
end

-- 标签：默认左对齐 + EVENT_BUBBLE（让点击冒泡到父卡片/按钮）
local function mkLabel(parent, props)
  props = props or {}
  if props.text_align == nil then props.text_align = 0 end
  local lbl = lvgl.Label(parent, props)
  pcall(function() lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  return lbl
end

-- 按钮：显式 CLICKABLE + 仅 SHORT_CLICKED（自身不冒泡，避免误触父级）
local function mkButton(parent, x, y, w, h, text, cb, opts)
  opts = opts or {}
  local btn = lvgl.Object(parent, {
    x = x, y = y, w = w, h = h,
    radius = opts.radius or 0,
    bg_color = opts.bg_color or 0,
    bg_opa = opts.bg_opa or 0,
    border_width = opts.border_width or 0,
    border_color = opts.border_color or 0,
    pad_all = 0,
  })
  pcall(function() btn:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() btn:add_flag(lvgl.FLAG.CLICKABLE) end)
  mkLabel(btn, {
    align = lvgl.ALIGN.CENTER,
    text = text,
    text_color = opts.color or C.TEXT,
    text_font = font(opts.font or 16),
  })
  if cb then pcall(function() btn:onevent(lvgl.EVENT.SHORT_CLICKED, cb) end) end
  return btn
end

-- ---- 文件系统（全部 pcall）----
local function openDir(p)
  if lvgl.fs and type(lvgl.fs.open_dir) == "function" then
    local ok, d = pcall(lvgl.fs.open_dir, p)
    if ok and d and type(d.read) == "function" then return d end
  end
  return nil
end

local function isDir(p)
  local d = openDir(p)
  if d then
    pcall(function() d:close() end)
    return true
  end
  return false
end

local function openFile(p, mode)
  if lvgl.fs and type(lvgl.fs.open_file) == "function" then
    local ok, f = pcall(lvgl.fs.open_file, p, mode)
    if ok and f then return f end
  end
  if io and type(io.open) == "function" then
    local ok, f = pcall(io.open, p, mode)
    if ok and f then return f end
  end
  return nil
end

local function fileSize(p)
  local f = openFile(p, "r")
  if not f then return nil end
  local sz = nil
  -- 固件文件接口为 seek(offset, whence)，whence ∈ {"set","cur","end"}；旧写法 seek("end") 兜底
  pcall(function() sz = f:seek(0, "end") end)
  if type(sz) ~= "number" then
    pcall(function() sz = f:seek("end") end)
  end
  pcall(function() f:close() end)
  return (type(sz) == "number") and sz or nil
end

local function readPreview(p, n)
  local f = openFile(p, "r")
  if not f then return nil end
  local data = nil
  pcall(function() data = f:read(n or 64) end)
  pcall(function() f:close() end)
  if type(data) ~= "string" then return nil end
  return printable(data, n or 64)
end

local function listDir(p)
  local d = openDir(p)
  if not d then return nil end
  -- 先收集全部名字并关闭目录，再逐个判定类型：
  -- 避免在遍历目录时嵌套 open_dir（部分固件/文件系统并发目录句柄有限，
  -- 嵌套 open_dir 会打断外层目录迭代，导致“只列出一个条目”）。
  local names, seen = {}, {}
  local count = 0
  local name = d:read()
  while name and count < LIST_CAP do
    count = count + 1
    local n = baseName(name)
    if n ~= "" and n ~= "." and n ~= ".." and not seen[n] then
      seen[n] = true
      names[#names + 1] = n
    end
    name = d:read()
  end
  pcall(function() d:close() end)
  table.sort(names)
  local out, files = {}, {}
  for _, n in ipairs(names) do
    local full = joinPath(p, n)
    if isDir(full) then
      out[#out + 1] = { name = n, full = full, isDir = true }
    else
      files[#files + 1] = { name = n, full = full, isDir = false }
    end
  end
  for _, e in ipairs(files) do out[#out + 1] = e end
  return out
end

local function removePath(p)
  if type(os.remove) == "function" then
    return pcall(os.remove, p)
  end
  return false, "no delete api"
end

-- ---- 能力探测（原生应用注入相关，按需触发，pcall 保护）----
local function apiAvailable(kind)
  local f
  if kind == "fs_list" then
    f = lvgl.fs and lvgl.fs.open_dir
  elseif kind == "fs_read" then
    f = lvgl.fs and lvgl.fs.open_file
  elseif kind == "io_open" then
    f = io and io.open
  elseif kind == "os_remove" then
    f = os and os.remove
  elseif kind == "os_execute" then
    f = os and os.execute
  elseif kind == "io_popen" then
    f = io and io.popen
  elseif kind == "loadlib" then
    f = package and package.loadlib
  end
  return type(f) == "function"
end

local CAP_ROWS = {
  { "List dirs ", "fs_list" },
  { "Read files", "fs_read" },
  { "io.open    ", "io_open" },
  { "Delete     ", "os_remove" },
  { "Run command", "os_execute" },
  { "Pipe cmd   ", "io_popen" },
  { "Load native", "loadlib" },
}

-- ---- 状态 ----
local path = HOME
local entries = {}
local pageIdx = 0

-- 前向声明
local navigate, goUp, render, showFileInfo, confirmDelete, doDelete, hideDialog, showInfo, hideInfo

-- ---- 原生应用注入（ELF 注入闭环，已实机验证的调用链；pcall 保护，仅手动触发）----
-- 验证过的完整链：写 .ko → insmod → lsmod 解析模块基址 → exec <base+1>。
-- 关键机制（实机验证结论）：
--   * insmod 只加载不执行；exec 以函数调用方式跳转，模块 pop{r7,pc} 干净返回
--   * lsmod 列：NAME INIT UNINIT ARG NEXPORTS TEXT SIZE DATA SIZE，第 5 列 = 模块文本基址(textalloc)
--   * exec 需 Thumb 位：跳 <base+1>
--   * 固件 Lua 5.4 tonumber 不认 0x 前缀：需 tonumber(s:sub(3), 16)
local INJECT = {
  ko_path = "/data/deepscan_module.ko",  -- 写 .ko 的位置（/data 可写）
  mod_name = "deepscan",                  -- insmod 的模块名（lsmod 按此名解析基址）
  entry_offset = 1,                       -- exec <base+1>（Thumb 位）
  marker_addr = 0x20001000,               -- 模块写入标记的地址，用 mw 验证（可选，nil 跳过）
}

-- os.execute 返回 (true, "exit", 0) / (nil, "exit", code)；统一成 success, detail
local function shellExec(cmd)
  if type(os.execute) ~= "function" then
    return false, "no os.execute"
  end
  local r = { pcall(os.execute, cmd) }
  local pcallOk = table.remove(r, 1)
  if not pcallOk then
    return false, tostring(r[1])
  end
  local flag, kind, code = r[1], r[2], r[3]
  local success = (flag == true) and (code == 0 or code == nil)
  return success, string.format("%s %s", tostring(kind or ""), tostring(code or ""))
end

-- 捕获命令输出：优先 io.popen，否则重定向到临时文件再读回（pcall 保护）
local function shellCapture(cmd)
  if io and type(io.popen) == "function" then
    local ok, res = pcall(function()
      local p = io.popen(cmd, "r")
      if not p then error("popen failed") end
      local out = p:read("*a")
      p:close()
      return out
    end)
    if ok and type(res) == "string" then return true, res end
  end
  local tmp = INJECT.ko_path .. ".out"
  shellExec(cmd .. " > " .. tmp .. " 2>&1")
  local f = openFile(tmp, "r")
  if not f then return false, "cannot capture output" end
  local out = nil
  pcall(function() out = f:read("*a") end)
  pcall(function() f:close() end)
  pcall(function() os.remove(tmp) end)
  return type(out) == "string", out or ""
end

-- 解析十六进制：固件 tonumber 不认 0x 前缀，手动剥离
local function parseHex(s)
  s = tostring(s or ""):gsub("%s+", "")
  if s:sub(1, 2) == "0x" or s:sub(1, 2) == "0X" then
    return tonumber(s:sub(3), 16)
  end
  return tonumber(s, 16)
end

-- 从 lsmod 输出解析模块基址：模块名所在行的第 5 列（textalloc）
local function lsmodBase(out, modName)
  for line in tostring(out or ""):gmatch("[^\r\n]+") do
    local toks = {}
    for t in line:gmatch("%S+") do toks[#toks + 1] = t end
    if toks[1] == modName then
      local base = parseHex(toks[5])
      if base then return base end
    end
  end
  return nil
end

local function injectWritePayload()
  if not PAYLOAD or #PAYLOAD == 0 then return false, "no embedded payload" end
  local ok, err = pcall(function()
    -- 优先用已文档化且实机验证的 lvgl.fs.open_file(path, "w")
    local f
    if lvgl.fs and type(lvgl.fs.open_file) == "function" then
      f = lvgl.fs.open_file(INJECT.ko_path, "w")
    end
    if not f and io and type(io.open) == "function" then
      f = io.open(INJECT.ko_path, "wb") or io.open(INJECT.ko_path, "w")
    end
    if not f then error("open failed") end
    f:write(PAYLOAD)
    f:close()
  end)
  return ok, err
end

local function runInject()
  local lines = {}
  local function step(tag, ok, detail)
    lines[#lines + 1] = string.format("%-8s %s", tag, ok and "OK" or "FAIL")
    if detail ~= nil and detail ~= true and detail ~= "" then
      lines[#lines + 1] = "   " .. tostring(detail)
    end
  end

  -- 1) 写 .ko 到可写分区
  local ok1, e1 = injectWritePayload()
  step("write", ok1, ok1 and nil or e1)
  if not ok1 then
    showInfo("NATIVE INJECT", table.concat(lines, "\n"), "embed payload/module.ko then rebuild")
    return
  end

  -- 2) insmod 加载（只加载，不执行入口）
  local ok2, d2 = shellExec("insmod " .. INJECT.ko_path .. " " .. INJECT.mod_name)
  step("insmod", ok2, d2)

  -- 3) lsmod 现场解析模块基址
  local ok3, out3 = shellCapture("lsmod")
  local base = ok3 and lsmodBase(out3, INJECT.mod_name) or nil
  step("lsmod", base ~= nil, base and string.format("base 0x%X", base) or "base not found")

  -- 4) exec <base+1> 执行入口
  if base then
    local entry = base + (INJECT.entry_offset or 1)
    local ok4, d4 = shellExec(string.format("exec 0x%X", entry))
    step("exec", ok4, d4)
  else
    step("exec", false, "no base")
  end

  -- 5) 可选：mw 验证模块写入的标记
  if INJECT.marker_addr then
    local ok5, out5 = shellCapture(string.format("mw 0x%X", INJECT.marker_addr))
    step("verify", ok5, ok5 and (tostring(out5):gsub("%s+$", "")) or nil)
  end

  showInfo("NATIVE INJECT", table.concat(lines, "\n"), "chain: write -> insmod -> lsmod -> exec")
end

-- ---- 运行时逆向采集（RE DUMP）----
-- 固件加密导致静态分析死路；唯一可行路径是运行时逆向。此按钮把 re/README 里
-- P1/P2/P3 需要的设备样本就地采集到 /data/deepscan_re/，之后用本表盘文件管理器
-- 逐条查看并把内容发回来即可。全部 pcall 保护，任何单条失败都不影响其余项。
local REDUMP = {
  dir = "/data/deepscan_re", -- 采集输出目录（/data 可写）
  max_file = 65536,           -- 单个文本文件拷贝上限（字节）
  tree_depth = 3,             -- 目录树最大深度
  tree_budget = 600,          -- 目录树条目上限
}

-- 文本文件直接拷贝：应用注册表 + /proc 运行时信息（路径不存在则跳过，不影响其它项）
local REDUMP_FILES = {
  { "/data/apps.json",     "apps.json" },
  { "/data/apps.db",       "apps.db" },
  { "/data/persist.db",    "persist.db" },
  { "/system/apps.json",   "system_apps.json" },
  { "/proc/modules",       "proc_modules.txt" },
  { "/proc/version",       "proc_version.txt" },
  { "/proc/kallsyms",      "proc_kallsyms.txt" },
}

-- shell 命令输出（os.execute 可用时；不存在/无权限则记失败，不影响其余项）
local REDUMP_CMDS = {
  { "mount",              "mount.txt" },
  { "uname -a",           "uname.txt" },
  { "df",                 "df.txt" },
  { "lsmod",              "lsmod.txt" },
  { "ps",                 "ps.txt" },
  { "ls -l /",            "ls_root.txt" },
  { "ls -l /data",        "ls_data.txt" },
  { "ls -l /usr/lib",     "ls_usrlib.txt" },
  { "ls -l /system",      "ls_system.txt" },
  { "cat /proc/version",  "cat_proc_version.txt" },
}

-- 递归目录树：从 root 出发按深度/条目上限列出真实文件系统结构。
-- 这是“发现真实路径”的关键——之前按猜测路径找 apps.json/usr/lib 大多不存在。
local function walkTree(root, maxDepth, budget)
  maxDepth = maxDepth or 3
  budget = budget or 600
  local out = {}
  local count = 0
  local function walk(dir, indent, d)
    if count >= budget or d > maxDepth then return end
    local list = listDir(dir)
    if not list then
      count = count + 1
      out[#out + 1] = indent .. dir .. "  <cannot list>"
      return
    end
    for _, e in ipairs(list) do
      if count >= budget then break end
      count = count + 1
      if e.isDir then
        out[#out + 1] = indent .. e.name .. "/"
        if d < maxDepth then walk(e.full, indent .. "  ", d + 1) end
      else
        out[#out + 1] = indent .. e.name .. "  " .. tostring(fileSize(e.full) or "?")
      end
    end
  end
  walk(root, "", 0)
  return table.concat(out, "\n") .. "\n"
end

local function writeFile(path, data)
  return pcall(function()
    -- 优先用已文档化且实机验证的 lvgl.fs.open_file(path, "w")，io.open("wb") 作兜底
    local f
    if lvgl.fs and type(lvgl.fs.open_file) == "function" then
      f = lvgl.fs.open_file(path, "w")
    end
    if not f and io and type(io.open) == "function" then
      f = io.open(path, "wb") or io.open(path, "w")
    end
    if not f then error("open failed: " .. tostring(path)) end
    f:write(data)
    f:close()
  end)
end

local function readFileBytes(p, maxBytes)
  local f = openFile(p, "r")
  if not f then return nil end
  local data = nil
  pcall(function() data = f:read(maxBytes or 65536) end)
  pcall(function() f:close() end)
  return data
end

local function runREDump()
  -- 先收集所有样本到内存，再统一写盘：
  --   1) 合并报告写到 /data/deepscan_dump.txt（不依赖 mkdir，/data 可写，单文件好找）
  --   2) 若 /data/deepscan_re/ 可建立，再按条目拆分成单个文件方便逐条查看
  local samples = {}
  local okCount, failCount = 0, 0
  local function collect(tag, data)
    if type(data) == "string" and #data > 0 then
      okCount = okCount + 1
      samples[#samples + 1] = { tag = tag, data = data }
    else
      failCount = failCount + 1
      samples[#samples + 1] = { tag = tag, data = nil }
    end
  end

  -- 1) 递归目录树（真实文件系统结构，最关键）
  collect("tree_root", walkTree("/", REDUMP.tree_depth, REDUMP.tree_budget))
  collect("tree_data", walkTree("/data", REDUMP.tree_depth + 1, REDUMP.tree_budget))
  collect("tree_system", walkTree("/system", REDUMP.tree_depth, REDUMP.tree_budget))

  -- 2) 文本文件拷贝
  for _, t in ipairs(REDUMP_FILES) do
    collect(t[2], readFileBytes(t[1], REDUMP.max_file))
  end

  -- 3) shell 命令输出
  if type(os.execute) == "function" then
    for _, c in ipairs(REDUMP_CMDS) do
      local ok, out = shellCapture(c[1])
      collect(c[2], (ok and type(out) == "string" and #out > 0) and out or nil)
    end
  else
    collect("shell", nil)
  end

  -- 4) 合并报告（写 /data 根目录，不依赖 mkdir）
  local lines = { "DeepScan RE dump" }
  for _, s in ipairs(samples) do
    lines[#lines + 1] = "\n===== " .. s.tag .. " ====="
    lines[#lines + 1] = s.data or "<failed/empty>"
  end
  local report = table.concat(lines, "\n") .. "\n"
  local target = "/data/deepscan_dump.txt"
  local wok = writeFile(target, report)

  -- 5) 若子目录可建立，再按条目拆分（mkdir 失败则忽略，不影响合并报告）
  shellExec("mkdir -p " .. REDUMP.dir)
  shellExec("mkdir " .. REDUMP.dir)
  if openDir(REDUMP.dir) then
    for _, s in ipairs(samples) do
      if s.data then writeFile(joinPath(REDUMP.dir, s.tag .. ".txt"), s.data) end
    end
    writeFile(joinPath(REDUMP.dir, "_report.txt"), report)
  end

  local body = wok and (target .. "\n" .. okCount .. " ok / " .. failCount .. " failed")
    or ("write failed: " .. target)
  showInfo("RE DUMP", body, "open /data/deepscan_dump.txt to review")
end

-- ---- 界面 ----
local root = lvgl.Object(nil, {
  x = 0, y = 0, w = W, h = H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
pcall(function() root:clear_flag(lvgl.FLAG.SCROLLABLE) end)

-- 顶栏（原生深色，底部细分隔线）
local header = lvgl.Object(root, { x = 0, y = 0, w = W, h = HEADER_H, bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0 })
header:clear_flag(lvgl.FLAG.SCROLLABLE)
local headerSep = lvgl.Object(root, { x = 0, y = HEADER_H, w = W, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
headerSep:clear_flag(lvgl.FLAG.SCROLLABLE)

local backBtn = mkButton(header, 0, 0, 48, HEADER_H, "<", function() goUp() end, { color = C.TEXT, font = 24 })
local infoBtn = mkButton(header, W - 48, 0, 48, HEADER_H, "i", nil, { color = C.DIM, font = 16 })
local titleLabel = mkLabel(header, { x = 52, y = 10, w = W - 104, text = "Files", text_color = C.TEXT, text_font = font(18) })
local pathLabel = mkLabel(header, { x = 52, y = 38, w = W - 104, text = HOME, text_color = C.DIM, text_font = font(14) })

-- 列表区
local listArea = lvgl.Object(root, { x = 0, y = LIST_TOP, w = W, h = FOOTER_TOP - LIST_TOP, bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0 })
listArea:clear_flag(lvgl.FLAG.SCROLLABLE)

-- 底栏（原生深色，顶部分隔线）
local footer = lvgl.Object(root, { x = 0, y = FOOTER_TOP, w = W, h = FOOTER_H, bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0 })
footer:clear_flag(lvgl.FLAG.SCROLLABLE)
local footerSep = lvgl.Object(root, { x = 0, y = FOOTER_TOP, w = W, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
footerSep:clear_flag(lvgl.FLAG.SCROLLABLE)

local statusLabel = mkLabel(footer, { x = 16, y = 16, w = W - 156, text = "", text_color = C.DIM, text_font = font(14) })
local prevBtn = mkButton(footer, W - 140, 6, 38, 32, "<", function()
  pageIdx = math.max(0, pageIdx - 1)
  render()
end, { radius = 16, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 18 })

local pageLabel = mkLabel(footer, { x = W - 98, y = 14, w = 44, text = "", align = lvgl.ALIGN.CENTER, text_color = C.DIM, text_font = font(14) })

local nextBtn = mkButton(footer, W - 54, 6, 38, 32, ">", function()
  pageIdx = pageIdx + 1
  render()
end, { radius = 16, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 18 })

-- ---- 列表渲染 ----
local rows = {}

local function clearRows()
  for _, r in ipairs(rows) do
    for _, o in ipairs(r) do pcall(function() o:delete() end) end
  end
  rows = {}
end

-- 行图标：文件夹 = 系统蓝圆角矩形+顶部凸起；文件 = 浅灰圆角矩形
local function mkRowIcon(card, isDir)
  local objs = {}
  local x = 20
  local y = (ROW_H - 18) / 2
  if isDir then
    objs[#objs + 1] = lvgl.Object(card, { x = x, y = y, w = 8, h = 4, radius = 1, bg_color = C.ACCENT, bg_opa = 255, border_width = 0 })
    objs[#objs + 1] = lvgl.Object(card, { x = x, y = y + 3, w = 20, h = 14, radius = 3, bg_color = C.ACCENT, bg_opa = 255, border_width = 0 })
  else
    objs[#objs + 1] = lvgl.Object(card, { x = x + 3, y = y, w = 14, h = 18, radius = 2, bg_color = C.FILE_ICON, bg_opa = 255, border_width = 0 })
  end
  for _, o in ipairs(objs) do
    pcall(function() o:clear_flag(lvgl.FLAG.SCROLLABLE) end)
    pcall(function() o:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  end
  return objs
end

-- 行：全宽透明 + 底部细分隔线；左图标+名称，右红色 Delete
local function addRow(e, slot)
  local y = slot * ROW_H
  local card = lvgl.Object(listArea, { x = 0, y = y, w = W, h = ROW_H, bg_color = 0, bg_opa = 0, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  card:add_flag(lvgl.FLAG.CLICKABLE)

  mkRowIcon(card, e.isDir)

  local label = e.isDir and (e.name .. "/") or e.name
  mkLabel(card, { x = NAME_X, y = (ROW_H - 20) / 2, w = W - NAME_X - DEL_W - 28, text = ltruncate(label, 24), text_color = C.TEXT, text_font = font(16) })

  card:onevent(lvgl.EVENT.SHORT_CLICKED, function()
    if e.isDir then navigate(e.full) else showFileInfo(e) end
  end)

  local delBtn = mkButton(card, W - 16 - DEL_W, (ROW_H - DEL_H) / 2, DEL_W, DEL_H, "Delete", function() confirmDelete(e) end, { radius = 16, bg_color = C.DESTRUCTIVE_BG, bg_opa = 255, color = C.DESTRUCTIVE, font = 14 })

  local sep = lvgl.Object(listArea, { x = 20, y = y + ROW_H - 1, w = W - 40, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
  sep:clear_flag(lvgl.FLAG.SCROLLABLE)

  rows[#rows + 1] = { card, sep, delBtn }
end

render = function()
  clearRows()
  setText(pathLabel, ltruncate(path, 34))

  local total = #entries
  local pageCount = math.max(1, math.ceil(total / ENTRIES_PER_PAGE))
  if pageIdx >= pageCount then pageIdx = pageCount - 1 end
  if pageIdx < 0 then pageIdx = 0 end

  local start = pageIdx * ENTRIES_PER_PAGE
  for k = 1, ENTRIES_PER_PAGE do
    local e = entries[start + k]
    if e then addRow(e, k - 1) end
  end

  setText(pageLabel, string.format("%d/%d", pageIdx + 1, pageCount))
  pcall(function() prevBtn:set({ hidden = pageIdx == 0 }) end)
  pcall(function() nextBtn:set({ hidden = pageIdx >= pageCount - 1 }) end)

  if total == 0 then
    setText(statusLabel, "(empty)")
  else
    local nd, nf = 0, 0
    for _, e in ipairs(entries) do
      if e.isDir then nd = nd + 1 else nf = nf + 1 end
    end
    -- 总数优先：如 "15 items (12 files, 3 dirs)"，避免把 "12 files" 误读成总数
    setText(statusLabel, rtruncate(string.format("%d items (%d files, %d dirs)", total, nf, nd), 28))
  end
end

navigate = function(p)
  local list = listDir(p)
  if not list then
    setText(statusLabel, ltruncate("cannot open: " .. p, 24))
    return
  end
  path = p
  entries = list
  pageIdx = 0
  render()
end

goUp = function()
  local parent = parentOf(path)
  if parent then
    navigate(parent)
  else
    setText(statusLabel, "already at /")
  end
end

showFileInfo = function(e)
  local sz = fileSize(e.full)
  local prev = readPreview(e.full, 256)
  local body = "size: " .. humanSize(sz) .. "\n\n"
  if prev and prev ~= "" then
    body = body .. "preview:\n" .. prev
  else
    body = body .. "(no text preview)"
  end
  showInfo("FILE  " .. ltruncate(e.name, 22), body, ltruncate(e.full, 40))
end

-- ---- 通用信息弹窗（文件详情 / 能力探测）----
local infoDialog, infoTitle, infoBody, infoSub

local function buildInfoDialog()
  infoDialog = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 140, border_width = 0, pad_all = 0 })
  infoDialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  infoDialog:set({ hidden = true })

  local cw = W - 40
  local card = lvgl.Object(infoDialog, { x = 20, y = 72, w = cw, h = 336, radius = 16, bg_color = C.SURFACE, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

  infoTitle = mkLabel(card, { x = 20, y = 16, w = cw - 40, text = "", text_color = C.TEXT, text_font = font(18) })
  infoBody = mkLabel(card, { x = 20, y = 50, w = cw - 40, h = 210, text = "", text_color = C.TEXT, text_font = font(16) })
  infoSub = mkLabel(card, { x = 20, y = 262, w = cw - 40, text = "", text_color = C.DIM, text_font = font(14) })
  local gap = 8
  local bw = (cw - 40 - gap * 2) / 3
  mkButton(card, 20, 288, bw, 36, "DUMP", function() runREDump() end, { radius = 12, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 13 })
  mkButton(card, 20 + bw + gap, 288, bw, 36, "INJECT", function() runInject() end, { radius = 12, bg_color = C.ACCENT, bg_opa = 255, color = 0xFFFFFF, font = 13 })
  mkButton(card, 20 + 2 * (bw + gap), 288, bw, 36, "CLOSE", function() hideInfo() end, { radius = 12, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 13 })
end

showInfo = function(title, body, sub)
  if not infoDialog then buildInfoDialog() end
  setText(infoTitle, title or "")
  setText(infoBody, body or "")
  setText(infoSub, sub or "")
  pcall(function() infoDialog:set({ hidden = false }) end)
end

hideInfo = function()
  if infoDialog then pcall(function() infoDialog:set({ hidden = true }) end) end
end

-- 能力探测：把表盘运行时实际暴露的“原生能力”列出来（原生应用注入研究落地）
local function showCapabilities()
  local lines = {}
  for _, item in ipairs(CAP_ROWS) do
    lines[#lines + 1] = item[1] .. "  " .. (apiAvailable(item[2]) and "[OK]" or "[--]")
  end
  local body = table.concat(lines, "\n")
  local note = "native injection via Lua watchface runtime"
  if PAYLOAD and #PAYLOAD > 0 then note = note .. " | .ko embedded" end
  showInfo("SYSTEM CAPABILITIES", body, note)
end

pcall(function() infoBtn:onevent(lvgl.EVENT.SHORT_CLICKED, function() showCapabilities() end) end)

-- ---- 删除确认弹窗 ----
local dialog, dName, dPath, dTarget

local function buildDialog()
  dialog = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 140, border_width = 0, pad_all = 0 })
  dialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  dialog:set({ hidden = true })

  local card = lvgl.Object(dialog, { x = 32, y = 150, w = W - 64, h = 184, radius = 16, bg_color = C.SURFACE, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

  mkLabel(card, { x = 24, y = 20, w = W - 112, text = "Delete this item?", text_color = C.TEXT, text_font = font(18) })
  dName = mkLabel(card, { x = 24, y = 52, w = W - 112, text = "", text_color = C.DESTRUCTIVE, text_font = font(16) })
  dPath = mkLabel(card, { x = 24, y = 78, w = W - 112, text = "", text_color = C.DIM, text_font = font(14) })

  local bw = (W - 64 - 48 - 12) / 2
  mkButton(card, 24, 122, bw, 42, "CANCEL", function() hideDialog() end, { radius = 12, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 14 })
  mkButton(card, 24 + bw + 12, 122, bw, 42, "DELETE", function() doDelete() end, { radius = 12, bg_color = C.DESTRUCTIVE, bg_opa = 255, color = 0xFFFFFF, font = 14 })
end

confirmDelete = function(e)
  if not dialog then buildDialog() end
  dTarget = e
  setText(dName, ltruncate(e.name, 28))
  setText(dPath, ltruncate(e.full, 40))
  pcall(function() dialog:set({ hidden = false }) end)
end

hideDialog = function()
  if dialog then pcall(function() dialog:set({ hidden = true }) end) end
  dTarget = nil
end

doDelete = function()
  local t = dTarget
  hideDialog()
  if not t then return end
  local ok, res = removePath(t.full)
  if ok and res == true then
    setText(statusLabel, ltruncate("deleted: " .. t.name, 24))
    pcall(function()
      local okv, vibrator = pcall(require, "vibrator")
      if okv and vibrator and vibrator.start then
        vibrator.start(vibrator.type.WATCH_FACE)
      end
    end)
    navigate(path)
  else
    setText(statusLabel, ltruncate("delete failed: " .. tostring(res or "unknown"), 24))
  end
end

-- ---- 初始加载 ----
navigate(path)

-- ============================================================
-- 生命周期
-- ============================================================
function ScreenStateChangedCB(pre, now, reason)
end
