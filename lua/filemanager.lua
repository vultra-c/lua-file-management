-- filemanager.lua
-- 系统文件管理器（DEEP_SCAN FS）
-- 能力：
--   1. 深度浏览：从 / 开始逐层进入任意目录，显示目录与文件大小
--   2. 深度搜索：在当前目录下递归扫描，按关键字过滤文件名
--   3. 文件管理：查看文件信息、删除文件（二次确认，高危路径强警告）
-- 文件操作基于 lvgl.fs（open_dir / open_file）+ Lua 标准库 os.remove。

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

local M = {}

local W, H = utils.constValue(lvgl.HOR_RES), utils.constValue(lvgl.VER_RES)
local ROW_H = 34
local MAX_ROWS = config.MAX_LIST_ROWS

local fonts = {}
local function font(size)
  if not fonts[size] then
    fonts[size] = lvgl.Font("montserrat", size, "normal")
  end
  return fonts[size]
end

-- ---- 状态 ----
local state = {
  path = config.FS_ROOT,
  mode = "browse",       -- browse | search
  entries = {},          -- 当前浏览目录条目 {name, full, isDir, size}
  results = {},          -- 搜索结果
  keyword = "",
  rows = {},             -- 已创建的行（清理用）
  selected = nil,        -- 待删除条目
}

-- ---- 控件句柄 ----
local page, pathLabel, listBox, statusLabel
local searchBox, searchInput, kbdOverlay, kbdClose, kb
local detail, detName, detPath, detSize, detWarn
local searchTimer

-- ---- 前向声明（函数间互相调用） ----
local status, navigate, refresh, goUp, clearSearchInput
local runSearch, scheduleSearch, openKeyboard, closeKeyboard
local openDetail, hideDetail, doDelete, addRow
local buildKeyboard, buildDetail

-- ---- 文件系统操作 ----

-- 以"目录方式打开"判断目录（句柄可能为 userdata 或 table，统一按方法判断）
local function isDir(path)
  if lvgl.fs and lvgl.fs.open_dir then
    local ok, d = utils.call(lvgl.fs.open_dir, path)
    if ok and d and type(d.read) == "function" then
      pcall(function() d:close() end)
      return true
    end
  end
  -- 退回 shell 探测（utils.call 的首返回值恒为 true，真实结果在第二返回值）
  if type(os.execute) == "function" then
    local _, res = utils.call(os.execute, string.format("ls -d \"%s\" > /dev/null 2>&1", path))
    if res == true or res == 0 then
      -- ls -d 对文件也返回成功；用 ls -d 加 / 区分目录
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

-- 文件大小（字节）
local function fileSize(path)
  if not path or path == "" then return nil end
  local ok, f = openFile(path, "r")
  if not ok or not f then return nil end
  local sz
  local ok2 = pcall(function() sz = f:seek(0, "end") end)
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

-- 用 lvgl.fs 列出目录（目录在前，文件在后，各按名称排序）
local function listDirFs(path)
  if not (lvgl.fs and lvgl.fs.open_dir) then return nil, "no fs api" end
  local dirs, files = {}, {}
  local ok, d = utils.call(lvgl.fs.open_dir, path)
  if not ok or not d or type(d.read) ~= "function" then
    return nil, "cannot open dir"
  end
  local name = d:read()
  while name do
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
-- （NuttX 上 os.execute/io.open 可用，捕获输出需重定向到文件再读）
local function listDirShell(path)
  if type(os.execute) ~= "function" or not (io and io.open) then
    return nil, "no list api"
  end
  local out = "/tmp/deepscan_ls.txt"
  local esc = string.gsub(path, '["%`$\\]', function(c) return "\\" .. c end)
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
  end
  if #entries == 0 then return entries end
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

-- 深度搜索：递归扫描 path 下所有文件名包含 keyword 的条目
local function deepSearch(path, keyword, limit)
  local kw = string.lower(keyword)
  local results = {}
  local count = 0
  local scanned = 0

  local function walk(p, depth)
    if count >= limit or scanned >= config.SEARCH_SCAN_CAP or depth > config.SEARCH_DEPTH then
      return
    end
    local entries, err = listDir(p)
    if not entries then return end
    for _, e in ipairs(entries) do
      scanned = scanned + 1
      if scanned >= config.SEARCH_SCAN_CAP then return end
      if count < limit and string.find(string.lower(e.name), kw, 1, true) then
        count = count + 1
        table.insert(results, e)
      end
      if e.isDir and depth < config.SEARCH_DEPTH and e.name:sub(1, 1) ~= "." then
        walk(e.full, depth + 1)
        if count >= limit or scanned >= config.SEARCH_SCAN_CAP then return end
      end
    end
  end

  walk(path, 0)
  return results
end

-- 危险路径判断
local function isDanger(path)
  for _, p in ipairs(config.DANGER_PREFIXES) do
    if path == p or path:sub(1, #p + 1) == p .. "/" then
      return true
    end
  end
  return false
end

-- ---- 状态栏 ----
status = function(text, color)
  statusLabel:set { text = text, text_color = color or theme.TEXT_DIM }
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
  btn:clear_flag(lvgl.FLAG.SCROLLABLE)
  btn:add_flag(lvgl.FLAG.CLICKABLE)
  local lbl = lvgl.Label(btn, {
    align = lvgl.ALIGN.CENTER,
    text = text,
    text_color = opts.text_color or theme.TEXT,
    text_font = font(opts.font_size or 14),
  })
  -- 标签文本上的点击需要冒泡到按钮
  lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE)
  if cb then btn:onevent(lvgl.EVENT.CLICKED, cb) end
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
  row:clear_flag(lvgl.FLAG.SCROLLABLE)
  row:add_flag(lvgl.FLAG.CLICKABLE)

  local name = entry.isDir and ("> " .. entry.name) or entry.name
  local nameLbl = lvgl.Label(row, {
    x = 14, y = 9, w = W - 96,
    text = name,
    text_color = entry.isDir and theme.ACCENT or theme.TEXT,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  nameLbl:add_flag(lvgl.FLAG.EVENT_BUBBLE)

  if not entry.isDir then
    local sz = entry.size or fileSize(entry.full)
    entry.size = sz
    local sizeLbl = lvgl.Label(row, {
      align = { type = lvgl.ALIGN.TOP_RIGHT, x_ofs = -14, y_ofs = 9 },
      text = utils.humanSize(sz),
      text_color = theme.TEXT_DIM,
      text_font = font(14),
    })
    sizeLbl:add_flag(lvgl.FLAG.EVENT_BUBBLE)
  end

  row:onevent(lvgl.EVENT.CLICKED, function()
    if entry.noop then return end
    if entry.backRow then
      state.mode = "browse"
      clearSearchInput()
      refresh()
      return
    end
    if entry.isDir then
      state.mode = "browse"
      clearSearchInput()
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
    clearSearchInput()
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
  pathLabel:set { text = utils.ltruncate(path, 30) }
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

-- ---- 搜索 ----
clearSearchInput = function()
  if searchInput then
    pcall(function() searchInput:set { text = "" } end)
  end
end

runSearch = function(keyword)
  local kw = keyword or ""
  state.keyword = kw
  if kw == "" then
    state.mode = "browse"
    refresh()
    return
  end
  status("scanning ...", theme.AMBER)
  local results = deepSearch(state.path, kw, config.SEARCH_LIMIT)
  state.results = results
  state.mode = "search"
  renderSearch()
  status(string.format("%d match(es) in %s", #results, utils.ltruncate(state.path, 22)), theme.TEXT_DIM)
end

scheduleSearch = function(text)
  state.pendingKeyword = text
  if searchTimer then
    -- 无限周期定时器 + 待执行标记：避免 repeat_count 耗尽后被 LVGL 删除
    pcall(function() searchTimer:set { period = 450, repeat_count = -1 } end)
    pcall(function() searchTimer:ready() end)
  else
    runSearch(text)
  end
end

local function initSearchTimer()
  local ok, t = pcall(lvgl.Timer, {
    period = 450,
    repeat_count = -1,
    cb = function()
      if state.pendingKeyword then
        local kw = state.pendingKeyword
        state.pendingKeyword = nil
        runSearch(kw)
      end
    end,
  })
  if ok and t then searchTimer = t end
end

-- ---- 键盘（可选能力，缺失时仅保留搜索框显示） ----
openKeyboard = function()
  if not kb then return end
  kb:set { hidden = false }
  kbdOverlay:set { hidden = false }
  pcall(function() kb:set { textarea = searchInput } end)
  pcall(function() searchInput:add_state(lvgl.STATE.FOCUSED) end)
end

closeKeyboard = function()
  if kb then kb:set { hidden = true } end
  if kbdOverlay then kbdOverlay:set { hidden = true } end
  pcall(function() searchInput:clear_state(lvgl.STATE.FOCUSED) end)
end

-- ---- 删除确认弹窗 ----
openDetail = function(entry)
  closeKeyboard()
  state.selected = entry
  detName:set { text = entry.name }
  detPath:set { text = utils.ltruncate(entry.full, 40) }
  if entry.isDir then
    detSize:set { text = "[directory]  (long-press dirs to delete)" }
  else
    local sz = entry.size or fileSize(entry.full)
    entry.size = sz
    detSize:set { text = "size: " .. (sz and utils.humanSize(sz) or "?") }
  end
  if isDanger(entry.full) then
    detWarn:set { hidden = false, text = "! SYSTEM PATH - be careful" }
  else
    detWarn:set { hidden = true }
  end
  detail:set { hidden = false }
end

hideDetail = function()
  if detail then detail:set { hidden = true } end
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
      local vibrator = require("vibrator")
      if vibrator and vibrator.start then
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
  page:clear_flag(lvgl.FLAG.SCROLLABLE)

  -- 头部：返回 / 路径 / 根目录
  mkButton(page, 8, 8, 40, 40, "<", goUp, { radius = 20, text_color = theme.ACCENT, font_size = 18 })
  pathLabel = lvgl.Label(page, {
    x = 56, y = 20, w = W - 120,
    text = config.FS_ROOT,
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  mkButton(page, W - 48, 8, 40, 40, "/", function()
    state.mode = "browse"
    clearSearchInput()
    navigate(config.FS_ROOT)
  end, { radius = 20, text_color = theme.CYAN, font_size = 18 })

  -- 搜索框
  searchBox = lvgl.Object(page, {
    x = 8, y = 54, w = W - 16, h = 36,
    radius = 10,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.BORDER,
  })
  searchBox:clear_flag(lvgl.FLAG.SCROLLABLE)
  searchBox:add_flag(lvgl.FLAG.CLICKABLE)
  local searchLbl = lvgl.Label(searchBox, {
    x = 12, y = 9, w = W - 40,
    text = "search: (deep scan, tap to type)",
    text_color = theme.TEXT_DIM,
    text_font = font(14),
    long_mode = lvgl.LABEL_LONG.DOT,
  })
  searchLbl:add_flag(lvgl.FLAG.EVENT_BUBBLE)
  searchBox:onevent(lvgl.EVENT.CLICKED, openKeyboard)

  -- 列表区（固定可视高度，子控件超出部分滚动）
  listBox = lvgl.Object(page, {
    x = 0, y = 96, w = W, h = H - 96 - 34,
    bg_color = theme.BG,
    bg_opa = 0,
    border_width = 0,
  })
  listBox:add_flag(lvgl.FLAG.SCROLLABLE)
  listBox:add_flag(lvgl.FLAG.SCROLL_ELASTIC)
  listBox:add_flag(lvgl.FLAG.SCROLL_MOMENTUM)
  local okS, sm = pcall(function() return lvgl.SCROLLBAR_MODE.AUTO end)
  if okS and sm then
    pcall(function() listBox:set { scrollbar_mode = sm } end)
  end

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

-- 键盘：部分固件可用，构造失败时仅保留搜索框显示
buildKeyboard = function()
  -- 遮罩层（先创建，键盘随后创建以覆盖在其上）
  kbdOverlay = lvgl.Object(page, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000,
    bg_opa = 140,
    border_width = 0,
  })
  kbdOverlay:clear_flag(lvgl.FLAG.SCROLLABLE)
  kbdOverlay:set { hidden = true }
  kbdOverlay:onevent(lvgl.EVENT.CLICKED, closeKeyboard)

  searchInput = lvgl.Textarea(kbdOverlay, {
    x = 8, y = 8, w = W - 60, h = 36,
    one_line = true,
    max_length = 32,
    placeholder = "keyword...",
    text_color = theme.TEXT,
    bg_color = theme.SURFACE_2,
    bg_opa = 255,
    radius = 8,
    border_width = 1,
    border_color = theme.BORDER,
  })
  searchInput:clear_flag(lvgl.FLAG.SCROLLABLE)

  kbdClose = mkButton(kbdOverlay, W - 46, 8, 38, 36, "OK", closeKeyboard, {
    radius = 10, text_color = theme.BG, bg_color = theme.ACCENT, border_color = theme.ACCENT,
  })

  -- 键盘放在遮罩层之后创建，保证显示在遮罩之上
  local ok, k = pcall(lvgl.Keyboard, page, {
    x = 0, y = H - 150, w = W, h = 150,
    hidden = true,
  })
  if ok and k then kb = k end

  searchInput:onevent(lvgl.EVENT.VALUE_CHANGED, function()
    local ok, t = pcall(function() return searchInput:get_text() end)
    if ok then
      scheduleSearch(tostring(t or ""))
    end
  end)

  if kb then
    pcall(function() kb:onevent(lvgl.EVENT.READY, closeKeyboard) end)
    pcall(function() kb:onevent(lvgl.EVENT.CANCEL, closeKeyboard) end)
  end

  initSearchTimer()
end

buildDetail = function()
  detail = lvgl.Object(page, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000,
    bg_opa = 200,
    border_width = 0,
  })
  detail:clear_flag(lvgl.FLAG.SCROLLABLE)
  detail:set { hidden = true }

  local card = lvgl.Object(detail, {
    x = 24, y = 96, w = W - 48, h = 264,
    radius = 14,
    bg_color = theme.SURFACE,
    bg_opa = 255,
    border_width = 1,
    border_color = theme.BORDER,
  })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

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
  build(root)
  navigate(config.FS_ROOT)
  return M
end

function M.show()
  if page then page:set { hidden = false } end
  refresh()
end

function M.hide()
  if page then page:set { hidden = true } end
  closeKeyboard()
  hideDetail()
end

function M.pageOnPause()
  if searchTimer then pcall(function() searchTimer:pause() end) end
end

function M.pageOnResume()
  if searchTimer then pcall(function() searchTimer:resume() end) end
end

return M
