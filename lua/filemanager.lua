-- filemanager.lua
-- 系统文件管理器（DEEP_SCAN FS）
-- 能力：
--   1. 深度浏览：从 / 开始逐层进入任意目录
--   2. 深度搜索：在当前目录下递归扫描，按关键字过滤文件名
--   3. 文件管理：查看文件信息、删除文件（二次确认，高危路径强警告）
--
-- 兼容性设计（针对 9 Pro 运行时）：
--   * 模块加载/创建时不访问文件系统；首次 show() 才列出目录（懒加载）
--   * 搜索输入使用自绘的“点击键盘”（纯 lvgl.Object + Label + 事件），
--     不依赖 Textarea/Keyboard（该运行时 Keyboard 仅为装饰控件）
--   * 所有文件系统/界面调用均 pcall 包裹，失败降级为状态提示，绝不崩溃
--   * 文件大小只在详情弹窗中按需读取，列表渲染不做文件 I/O

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

if not utils then utils = { call = pcall, join = function(a, b) return a .. "/" .. b end, parent = function() return nil end, ltruncate = function(s) return s end, humanSize = function() return "" end } end
if not theme then theme = { BG = 0x07090D, TEXT = 0xE6EDF5, TEXT_DIM = 0x8A97A8, ACCENT = 0x37E0A4, CYAN = 0x4CC9F0, AMBER = 0xFFC857, RED = 0xFF5C5C, GREEN = 0x37E0A4, SURFACE = 0x0F141B, SURFACE_2 = 0x161D27, BORDER = 0x223042 } end

local M = {}

local W, H = utils.constValue(lvgl.HOR_RES), utils.constValue(lvgl.VER_RES)
if not W or W == 0 then W = 336 end
if not H or H == 0 then H = 480 end

local ROW_H = 34
local MAX_ROWS = config.MAX_LIST_ROWS or 200
local LIST_CAP = config.LIST_CAP or 300 -- 单目录最多枚举的条目数（I/O 上限）

-- 已验证可用的 montserrat 尺寸
local fonts = {}
local function font(size)
  if not fonts[size] then
    local ok, f = pcall(lvgl.Font, "montserrat", size, "normal")
    fonts[size] = (ok and f) or false
  end
  return fonts[size] or nil
end

-- 注册点击（SHORT_CLICKED 优先，兼容 CLICKED）
local function onClick(obj, cb)
  local ok1 = pcall(function() obj:onevent(lvgl.EVENT.SHORT_CLICKED, cb) end)
  local ok2 = pcall(function() obj:onevent(lvgl.EVENT.CLICKED, cb) end)
  return ok1 or ok2
end

-- ---- 状态 ----
local state = {
  path = config.FS_ROOT or "/",
  mode = "browse",       -- browse | search
  entries = {},          -- 当前浏览目录条目 {name, full, isDir, size}
  results = {},          -- 搜索结果
  keyword = "",
  rows = {},             -- 已创建的行（清理用）
  selected = nil,        -- 待删除条目
}

-- ---- 控件句柄 ----
local page, pathLabel, listBox, statusLabel
local searchBox, searchLbl, kwLabel
local kbdOverlay, detail
local detName, detPath, detSize, detWarn

-- ---- 前向声明 ----
local status, navigate, refresh, goUp
local runSearch, openKeyboard, closeKeyboard
local openDetail, hideDetail, doDelete, addRow
local buildKeyboard, buildDetail

-- 安全更新标签
local function setText(lbl, text, color)
  if not lbl then return end
  local opts = { text = text }
  if color then opts.text_color = color end
  pcall(function() lbl:set(opts) end)
end

-- ---- 文件系统操作（全部 pcall）----

-- 以"目录方式打开"判断目录
local function isDir(path)
  if lvgl.fs and lvgl.fs.open_dir then
    local ok, d = utils.call(lvgl.fs.open_dir, path)
    if ok and d and type(d.read) == "function" then
      pcall(function() d:close() end)
      return true
    end
  end
  -- 退回 shell 探测
  if type(os.execute) == "function" then
    local _, res = utils.call(os.execute, string.format("ls -d \"%s\" > /dev/null 2>&1", path))
    if res == true or res == 0 then
      local _, res2 = utils.call(os.execute, string.format("ls -d \"%s/\" > /dev/null 2>&1", path))
      return res2 == true or res2 == 0
    end
  end
  return false
end

-- 打开文件：优先 lvgl.fs，退回 io.open
local function openFile(path, mode)
  if lvgl.fs and lvgl.fs.open_file then
    local ok, f = utils.call(lvgl.fs.open_file, path, mode)
    if ok and f then return true, f end
  end
  if io and io.open then
    local ok, f = utils.call(io.open, path, mode)
    if ok and f then return true, f end
  end
  return false, nil
end

-- 文件大小（字节）——只在详情弹窗中按需调用
local function fileSize(path)
  if not path or path == "" then return nil end
  local ok, f = openFile(path, "r")
  if not ok or not f then return nil end
  local sz
  local ok2 = pcall(function() sz = f:seek("end") end) -- seek(whence) 签名，文档：seek("end") 返回当前位置
  pcall(function() f:close() end)
  if ok2 and type(sz) == "number" then return sz end
  return nil
end

-- 删除：优先 os.remove，退回 lvgl.fs.remove
local function removePath(path)
  if type(os.remove) == "function" then
    return utils.call(os.remove, path)
  end
  if lvgl.fs and lvgl.fs.remove then
    return utils.call(lvgl.fs.remove, path)
  end
  return false, nil, "no delete api"
end

-- 用 lvgl.fs 列出目录（目录在前，文件在后，各按名称排序；有 I/O 上限）
local function listDirFs(path)
  if not (lvgl.fs and lvgl.fs.open_dir) then return nil, "no fs api" end
  local dirs, files = {}, {}
  local ok, d = utils.call(lvgl.fs.open_dir, path)
  if not ok or not d or type(d.read) ~= "function" then
    return nil, "cannot open dir"
  end
  local count = 0
  local name = d:read()
  while name and count < LIST_CAP do
    count = count + 1
    local n = tostring(name)
    if n ~= "" and n ~= "." and n ~= ".." then
      local full = utils.join(path, n)
      if isDir(full) then
        table.insert(dirs, { name = n, full = full, isDir = true })
      else
        table.insert(files, { name = n, full = full, isDir = false })
      end
    end
    name = d:read()
  end
  pcall(function() d:close() end)

  local function byName(a, b) return a.name < b.name end
  table.sort(dirs, byName)
  table.sort(files, byName)

  local entries = {}
  for _, e in ipairs(dirs) do entries[#entries + 1] = e end
  for _, e in ipairs(files) do entries[#entries + 1] = e end
  return entries
end

-- 无 lvgl.fs 时的退回方案：os.execute("ls -la ...") + io.open 解析
local function listDirShell(path)
  if type(os.execute) ~= "function" or not (io and io.open) then
    return nil, "no list api"
  end
  local out = "/tmp/deepscan_ls.txt"
  local esc = string.gsub(path, '["`$\\]', function(c) return "\\" .. c end)
  local _, res = utils.call(os.execute, string.format("ls -la \"%s\" > %s 2>&1", esc, out))
  if not (res == true or res == 0) then return nil, "ls failed" end
  local f = io.open(out, "r")
  if not f then return nil, "ls no output" end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then return nil, "ls empty" end

  local entries = {}
  for line in string.gmatch(content, "[^\r\n]+") do
    local trimmed = string.match(line, "^%s*(.-)%s*$")
    if trimmed and trimmed ~= "" and not string.match(trimmed, "^total") then
      local isdir = string.sub(trimmed, 1, 1) == "d"
      if isdir or string.sub(trimmed, 1, 1) == "-" then
        local tokens = {}
        for t in string.gmatch(trimmed, "%S+") do tokens[#tokens + 1] = t end
        local name = tokens[#tokens]
        if name and name ~= "." and name ~= ".." then
          local size = tonumber(tokens[5]) or 0
          entries[#entries + 1] = {
            name = name,
            full = utils.join(path, name),
            isDir = isdir,
            size = isdir and nil or size,
          }
        end
      end
    end
    if #entries >= LIST_CAP then break end
  end
  local function byName(a, b) return a.name < b.name end
  table.sort(entries, byName)
  return entries
end

-- 列出目录：优先 lvgl.fs，退回 shell
local function listDir(path)
  local entries, err = listDirFs(path)
  if entries then return entries end
  return listDirShell(path)
end

-- 深度搜索：递归扫描 path 下所有文件名包含 keyword 的条目（有深度/条目上限）
local function deepSearch(path, keyword, limit)
  local kw = string.lower(tostring(keyword or ""))
  local results = {}
  local count = 0
  local scanned = 0

  local function walk(p, depth)
    if count >= limit or scanned >= (config.SEARCH_SCAN_CAP or 20000) or depth > (config.SEARCH_DEPTH or 8) then
      return
    end
    local entries, err = listDir(p)
    if not entries then return end
    for _, e in ipairs(entries) do
      scanned = scanned + 1
      if scanned >= (config.SEARCH_SCAN_CAP or 20000) then return end
      if count < limit and string.find(string.lower(e.name), kw, 1, true) then
        count = count + 1
        table.insert(results, e)
      end
      if e.isDir and depth < (config.SEARCH_DEPTH or 8) and e.name:sub(1, 1) ~= "." then
        walk(e.full, depth + 1)
        if count >= limit or scanned >= (config.SEARCH_SCAN_CAP or 20000) then return end
      end
    end
  end

  walk(path, 0)
  return results
end

-- 危险路径判断
local function isDanger(path)
  for _, p in ipairs(config.DANGER_PREFIXES or {}) do
    if path == p or path:sub(1, #p + 1) == p .. "/" then
      return true
    end
  end
  return false
end

-- ---- 状态栏 ----
status = function(text, color)
  setText(statusLabel, text, color or theme.TEXT_DIM)
end

-- ---- 按钮 ----
local function mkButton(parent, x, y, w, h, text, cb, opts)
  opts = opts or {}
  local btn = lvgl.Object(parent, {
    x = x, y = y, w = w, h = h,
    radius = opts.radius or 10,
    bg_color = opts.bg_color or theme.SURFACE_2,
    bg_opa = 255,
    border_width = 1,
    border_color = opts.border_color or theme.BORDER,
  })
  pcall(function() btn:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() btn:add_flag(lvgl.FLAG.CLICKABLE) end)
  local lbl = lvgl.Label(btn, {
    align = lvgl.ALIGN.CENTER,
    text = text,
    text_color = opts.text_color or theme.TEXT,
    text_font = font(opts.font_size or 14),
  })
  pcall(function() lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  if cb then onClick(btn, cb) end
  return btn
end

-- ---- 列表渲染 ----
local function clearRows()
  for _, row in ipairs(state.rows) do
    pcall(function() row:delete() end)
  end
  state.rows = {}
end

addRow = function(parent, y, entry)
  local row = lvgl.Object(parent, {
    x = 0, y = y, w = W, h = ROW_H,
    bg_color = (math.floor(y / ROW_H)) % 2 == 0 and theme.SURFACE or theme.SURFACE_2,
    bg_opa = 255,
    border_width = 0,
  })
  pcall(function() row:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() row:add_flag(lvgl.FLAG.CLICKABLE) end)

  local name = entry.isDir and ("> " .. entry.name) or entry.name
  local nameLbl = lvgl.Label(row, {
    x = 14, y = 9, w = W - 96,
    text = name,
    text_color = entry.isDir and theme.ACCENT or theme.TEXT,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  pcall(function() nameLbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)

  -- 大小不在列表渲染时读取（避免逐文件 I/O），详情弹窗中按需计算

  onClick(row, function()
    if entry.noop then return end
    if entry.backRow then
      state.mode = "browse"
      refresh()
      return
    end
    if entry.isDir then
      state.mode = "browse"
      navigate(entry.full)
    else
      openDetail(entry)
    end
  end)

  -- 长按目录 → 删除确认（部分固件不支持 LONG_PRESSED，忽略即可）
  pcall(function()
    row:onevent(lvgl.EVENT.LONG_PRESSED, function()
      if entry.noop then return end
      if entry.isDir and not entry.backRow then openDetail(entry) end
    end)
  end)

  state.rows[#state.rows + 1] = row
  return row
end

local function renderBrowse()
  clearRows()
  local n = math.min(#state.entries, MAX_ROWS)
  for i = 1, n do
    addRow(listBox, (i - 1) * ROW_H, state.entries[i])
  end
  if #state.entries > MAX_ROWS then
    addRow(listBox, n * ROW_H, {
      name = string.format("... %d more (capped)", #state.entries - MAX_ROWS),
      full = "", isDir = false, noop = true,
    })
  end
  if #state.entries == 0 then
    addRow(listBox, 0, { name = "(empty directory)", full = "", isDir = false, noop = true })
  end
  pcall(function() listBox:scroll_to(0, 0, false) end)
end

local function renderSearch()
  clearRows()
  -- 首行：退出搜索
  addRow(listBox, 0, {
    name = "< back to " .. utils.ltruncate(state.path, 22),
    full = "", isDir = true, backRow = true,
  })
  local n = math.min(#state.results, MAX_ROWS)
  for i = 1, n do
    local e = state.results[i]
    addRow(listBox, i * ROW_H, {
      name = (e.isDir and "> " or "") .. utils.ltruncate(e.full, 26),
      full = e.full, isDir = e.isDir, size = e.size,
    })
  end
  if #state.results == 0 then
    addRow(listBox, ROW_H, { name = "(no match)", full = "", isDir = false, noop = true })
  end
  pcall(function() listBox:scroll_to(0, 0, false) end)
end

-- 处理"返回"逻辑：搜索模式先退出，浏览模式向上翻
goUp = function()
  if state.mode == "search" then
    state.mode = "browse"
    refresh()
    return
  end
  local parent = utils.parent(state.path)
  if parent then
    navigate(parent)
  elseif M.onBack then
    M.onBack() -- 回到表盘
  end
end

navigate = function(path)
  local entries, err = listDir(path)
  if not entries then
    status("cannot open: " .. utils.ltruncate(path, 30), theme.RED)
    return
  end
  state.path = path
  state.mode = "browse"
  state.entries = entries
  state.results = {}
  setText(pathLabel, utils.ltruncate(path, 30))
  renderBrowse()
  local nd, nf = 0, 0
  for _, e in ipairs(entries) do
    if e.isDir then nd = nd + 1 else nf = nf + 1 end
  end
  status(string.format("%d dirs / %d files", nd, nf), theme.TEXT_DIM)
end

refresh = function()
  if state.mode == "search" then
    renderSearch()
  else
    navigate(state.path)
  end
end

-- ---- 搜索（点击键盘）----
local KEY_MAX = 24

local function syncKeywordLabel()
  local kw = state.keyword
  if kw == "" then kw = "(tap keys to type)" end
  setText(kwLabel, "> " .. kw, theme.TEXT)
  setText(searchLbl, "search: " .. (state.keyword == "" and "deep scan" or state.keyword), theme.TEXT_DIM)
end

runSearch = function()
  closeKeyboard()
  local kw = state.keyword or ""
  if kw == "" then
    state.mode = "browse"
    refresh()
    return
  end
  status("scanning ...", theme.AMBER)
  local ok, results = pcall(deepSearch, state.path, kw, config.SEARCH_LIMIT or 60)
  if not ok then
    state.mode = "browse"
    status("search failed", theme.RED)
    return
  end
  state.results = results
  state.mode = "search"
  renderSearch()
  status(string.format("%d match(es) in %s", #results, utils.ltruncate(state.path, 22)), theme.TEXT_DIM)
end

local function appendKey(ch)
  if #state.keyword >= KEY_MAX then return end
  state.keyword = state.keyword .. ch
  syncKeywordLabel()
end

local function backspaceKey()
  state.keyword = string.sub(state.keyword, 1, -2)
  syncKeywordLabel()
end

local function clearKeyword()
  state.keyword = ""
  syncKeywordLabel()
end

-- ---- 键盘（自绘点击键盘：纯 Object/Label）----
openKeyboard = function()
  if kbdOverlay then pcall(function() kbdOverlay:set { hidden = false } end) end
  syncKeywordLabel()
end

closeKeyboard = function()
  if kbdOverlay then pcall(function() kbdOverlay:set { hidden = true } end) end
end

buildKeyboard = function()
  kbdOverlay = lvgl.Object(page, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000,
    bg_opa = 220,
    border_width = 0,
  })
  pcall(function() kbdOverlay:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() kbdOverlay:set { hidden = true } end)

  -- 面板
  local panel = lvgl.Object(kbdOverlay, {
    x = 8, y = 16, w = W - 16, h = 300,
    radius = 14,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.BORDER,
  })
  pcall(function() panel:clear_flag(lvgl.FLAG.SCROLLABLE) end)

  lvgl.Label(panel, {
    align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 10 },
    text = "DEEP SCAN · KEYWORD",
    text_color = theme.ACCENT,
    text_font = font(14),
  })

  kwLabel = lvgl.Label(panel, {
    x = 12, y = 36, w = W - 40,
    text = "> ",
    text_color = theme.TEXT,
    text_font = font(16),
    long_mode = lvgl.LABEL_LONG.DOT,
  })

  -- 字符行
  local rows = {
    { "A","B","C","D","E","F","G","H","I","J" },
    { "K","L","M","N","O","P","Q","R","S","T" },
    { "U","V","W","X","Y","Z","0","1","2","3" },
    { "4","5","6","7","8","9","_",".","-" },
  }
  local keyW, keyH, gap = 30, 30, 2
  local rowStartY = 74
  local x0 = math.floor((W - 16 - (10 * keyW + 9 * gap)) / 2)
  for ri, row in ipairs(rows) do
    local y = rowStartY + (ri - 1) * (keyH + gap + 2)
    for ci, ch in ipairs(row) do
      mkButton(panel, x0 + (ci - 1) * (keyW + gap), y, keyW, keyH, ch, function() appendKey(ch) end, {
        radius = 6, font_size = 14, bg_color = theme.SURFACE_2, border_color = theme.BORDER,
      })
    end
  end

  -- 操作行
  local btnY = rowStartY + 4 * (keyH + gap + 2) + 6
  local btnH = 36
  local btnW = math.floor((W - 16 - 12 - 3 * 6) / 4)
  local bx0 = 6
  mkButton(panel, bx0, btnY, btnW, btnH, "DEL", backspaceKey, {
    radius = 8, text_color = theme.AMBER, bg_color = theme.SURFACE_2,
  })
  mkButton(panel, bx0 + (btnW + 6), btnY, btnW, btnH, "CLR", clearKeyword, {
    radius = 8, text_color = theme.TEXT_DIM, bg_color = theme.SURFACE_2,
  })
  mkButton(panel, bx0 + 2 * (btnW + 6), btnY, btnW, btnH, "RUN", runSearch, {
    radius = 8, text_color = theme.BG, bg_color = theme.ACCENT, border_color = theme.ACCENT,
  })
  mkButton(panel, bx0 + 3 * (btnW + 6), btnY, btnW, btnH, "OK", closeKeyboard, {
    radius = 8, text_color = theme.CYAN, bg_color = theme.SURFACE_2,
  })
end

-- ---- 删除确认弹窗 ----
openDetail = function(entry)
  closeKeyboard()
  state.selected = entry
  setText(detName, entry.name)
  setText(detPath, utils.ltruncate(entry.full, 40), theme.TEXT_DIM)
  if entry.isDir then
    setText(detSize, "[directory]", theme.TEXT_DIM)
  else
    local sz = entry.size or fileSize(entry.full) -- 按需读取大小（仅此处）
    entry.size = sz
    setText(detSize, "size: " .. ((sz and utils.humanSize(sz)) or "?"), theme.TEXT_DIM)
  end
  if isDanger(entry.full) then
    setText(detWarn, "! SYSTEM PATH - be careful", theme.RED)
    pcall(function() detWarn:set { hidden = false } end)
  else
    pcall(function() detWarn:set { hidden = true } end)
  end
  pcall(function() detail:set { hidden = false } end)
end

hideDetail = function()
  if detail then pcall(function() detail:set { hidden = true } end) end
  state.selected = nil
end

doDelete = function()
  if not state.selected then return end
  local target = state.selected
  local ok, res, err = removePath(target.full)
  hideDetail()
  if ok and res == true then
    status("deleted: " .. utils.ltruncate(target.name, 24), theme.GREEN)
    pcall(function()
      local okv, vibrator = pcall(require, "vibrator")
      if okv and vibrator and vibrator.start then
        vibrator.start(vibrator.type.WATCH_FACE, false)
      end
    end)
    refresh()
  else
    status("delete failed: " .. tostring(err or res or "unknown"), theme.RED)
  end
end

-- ---- 构建 ----
local function build(root)
  page = lvgl.Object(root, {
    x = 0, y = 0, w = W, h = H,
    bg_color = theme.BG,
    bg_opa = 255,
    border_width = 0,
  })
  pcall(function() page:clear_flag(lvgl.FLAG.SCROLLABLE) end)

  -- 头部：返回 / 路径 / 根目录
  mkButton(page, 8, 8, 40, 40, "<", goUp, { radius = 20, text_color = theme.ACCENT, font_size = 18 })
  pathLabel = lvgl.Label(page, {
    x = 56, y = 20, w = W - 120,
    text = state.path,
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  mkButton(page, W - 48, 8, 40, 40, "/", function()
    state.mode = "browse"
    navigate(config.FS_ROOT or "/")
  end, { radius = 20, text_color = theme.CYAN, font_size = 18 })

  -- 搜索框（点击弹出点击键盘）
  searchBox = lvgl.Object(page, {
    x = 8, y = 54, w = W - 16, h = 36,
    radius = 10,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.BORDER,
  })
  pcall(function() searchBox:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() searchBox:add_flag(lvgl.FLAG.CLICKABLE) end)
  searchLbl = lvgl.Label(searchBox, {
    x = 12, y = 9, w = W - 40,
    text = "search: deep scan",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  pcall(function() searchLbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  onClick(searchBox, openKeyboard)

  -- 列表区（固定可视高度，子控件超出部分滚动）
  listBox = lvgl.Object(page, {
    x = 0, y = 96, w = W, h = H - 96 - 34,
    bg_color = theme.BG,
    bg_opa = 0,
    border_width = 0,
  })
  pcall(function() listBox:add_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() listBox:add_flag(lvgl.FLAG.SCROLL_ELASTIC) end)
  pcall(function() listBox:add_flag(lvgl.FLAG.SCROLL_MOMENTUM) end)
  pcall(function()
    if lvgl.SCROLLBAR_MODE and lvgl.SCROLLBAR_MODE.AUTO then
      listBox:set { scrollbar_mode = lvgl.SCROLLBAR_MODE.AUTO }
    end
  end)

  -- 状态栏
  statusLabel = lvgl.Label(page, {
    x = 12, y = H - 26, w = W - 24,
    text = "",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })

  buildKeyboard()
  buildDetail()
end

buildDetail = function()
  detail = lvgl.Object(page, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000,
    bg_opa = 200,
    border_width = 0,
  })
  pcall(function() detail:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() detail:set { hidden = true } end)

  local card = lvgl.Object(detail, {
    x = 24, y = 96, w = W - 48, h = 264,
    radius = 14,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.BORDER,
  })
  pcall(function() card:clear_flag(lvgl.FLAG.SCROLLABLE) end)

  lvgl.Label(card, {
    x = 16, y = 14,
    text = "DELETE FILE?",
    text_color = theme.RED,
    text_font = font(18),
  })

  detName = lvgl.Label(card, {
    x = 16, y = 48, w = W - 80,
    text = "",
    text_color = theme.TEXT,
    text_font = font(16),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  detPath = lvgl.Label(card, {
    x = 16, y = 78, w = W - 80,
    text = "",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  detSize = lvgl.Label(card, {
    x = 16, y = 104, w = W - 80,
    text = "",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  detWarn = lvgl.Label(card, {
    x = 16, y = 132, w = W - 80,
    text = "",
    text_color = theme.RED,
    text_font = font(14),
  })

  local btnY = 200
  local btnW = (W - 48 - 32 - 12) / 2
  mkButton(card, 16, btnY, btnW, 44, "CANCEL", hideDetail, {
    radius = 12, text_color = theme.TEXT,
  })
  mkButton(card, 16 + btnW + 12, btnY, btnW, 44, "DELETE", doDelete, {
    radius = 12, text_color = theme.BG, bg_color = theme.RED, border_color = theme.RED,
  })
end

-- ---- 对外接口 ----
function M.create(root, onBack)
  M.onBack = onBack
  -- 仅构建界面，不访问文件系统（懒加载：首次 show 才列出目录）
  local ok, err = pcall(build, root)
  if not ok then
    -- 构建失败：尽力创建一个最小页面，避免崩溃
    pcall(function()
      page = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = theme.BG, bg_opa = 255, border_width = 0 })
    end)
  end
  return M
end

function M.show()
  if page then pcall(function() page:set { hidden = false } end) end
  -- 首次进入/每次显示都刷新当前目录（按需访问文件系统）
  local ok = pcall(refresh)
  if not ok then
    status("fs unavailable", theme.RED)
  end
end

function M.hide()
  if page then pcall(function() page:set { hidden = true } end) end
  closeKeyboard()
  hideDetail()
end

function M.pageOnPause()
end

function M.pageOnResume()
end

return M
