-- ============================================================
-- DeepScan — 小米手环 9 Pro 文件管理器表盘（336×480）
-- 简洁浅色主题：安装后直接进入文件管理器。
--   每行：左 = 彩色圆点 + 名称（文件夹蓝色带 / 后缀，文件深色），右 = 红色 DEL 删除按钮
--
-- 入口约定（与 9 Pro 运行时 / Monika 一致）：
--   * 顶层直接构建 UI
--   * 导出 ScreenStateChangedCB(pre, now, reason)
--
-- 点击可靠性：
--   * 可点元素显式 add_flag(CLICKABLE) 并只注册 SHORT_CLICKED
--   * 子标签加 EVENT_BUBBLE，点击冒泡到父卡片/按钮
--   * 文件系统 / 删除 / 能力探测全部 pcall 包裹
-- ============================================================

local lvgl = require("lvgl")

local W = lvgl.HOR_RES()
local H = lvgl.VER_RES()
if not W or W == 0 then W = 336 end
if not H or H == 0 then H = 480 end

-- ---- 配置 ----
local HOME = "/data"
local ROOT = "/"
local LIST_CAP = 300
local ROWS_PER_PAGE = 6
local ROW_H = 56
local HEADER_H = 56
local LIST_TOP = HEADER_H
local FOOTER_H = 64
local FOOTER_TOP = H - FOOTER_H
local PAD_X = 12
local CARD_W = W - PAD_X * 2
local CARD_H = ROW_H - 10

-- ---- 浅色简洁配色 ----
local C = {
  BG = 0xF4F5F7,
  CARD = 0xFFFFFF,
  TEXT = 0x1B2029,
  DIM = 0x8A94A6,
  DIR = 0x2F6FED,
  FILE = 0x3A4554,
  DEL = 0xE5484D,
  DEL_BG = 0xFDEBEC,
  SEP = 0xE9EDF2,
  OK = 0x1F9D6B,
  BTN = 0xEEF1F5,
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
  pcall(function() sz = f:seek("end") end)
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
  if not (lvgl.fs and type(lvgl.fs.open_dir) == "function") then return nil end
  local d = openDir(p)
  if not d then return nil end
  local dirs, files = {}, {}
  local count = 0
  local name = d:read()
  while name and count < LIST_CAP do
    count = count + 1
    local n = tostring(name)
    if n ~= "" and n ~= "." and n ~= ".." then
      local full = joinPath(p, n)
      if isDir(full) then
        dirs[#dirs + 1] = { name = n, full = full, isDir = true }
      else
        files[#files + 1] = { name = n, full = full, isDir = false }
      end
    end
    name = d:read()
  end
  pcall(function() d:close() end)
  table.sort(dirs, function(a, b) return a.name < b.name end)
  table.sort(files, function(a, b) return a.name < b.name end)
  for _, e in ipairs(files) do dirs[#dirs + 1] = e end
  return dirs
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

-- ---- 界面 ----
local root = lvgl.Object(nil, {
  x = 0, y = 0, w = W, h = H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
pcall(function() root:clear_flag(lvgl.FLAG.SCROLLABLE) end)

-- 顶栏（白色卡片）
local header = lvgl.Object(root, { x = 0, y = 0, w = W, h = HEADER_H, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
header:clear_flag(lvgl.FLAG.SCROLLABLE)
local headerSep = lvgl.Object(root, { x = 0, y = HEADER_H, w = W, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
headerSep:clear_flag(lvgl.FLAG.SCROLLABLE)

local backBtn = mkButton(header, 0, 0, 46, HEADER_H, "<", function() goUp() end, { color = C.DIR, font = 24 })
local infoBtn = mkButton(header, W - 46, 0, 46, HEADER_H, "i", nil, { color = C.DIR, font = 18 })
local pathLabel = mkLabel(header, { x = 52, y = 18, w = W - 104, text = HOME, text_color = C.TEXT, text_font = font(16) })

-- 列表区
local listArea = lvgl.Object(root, { x = 0, y = LIST_TOP, w = W, h = FOOTER_TOP - LIST_TOP, bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0 })
listArea:clear_flag(lvgl.FLAG.SCROLLABLE)

-- 底栏（白色卡片）
local footer = lvgl.Object(root, { x = 0, y = FOOTER_TOP, w = W, h = FOOTER_H, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
footer:clear_flag(lvgl.FLAG.SCROLLABLE)
local footerSep = lvgl.Object(root, { x = 0, y = FOOTER_TOP, w = W, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
footerSep:clear_flag(lvgl.FLAG.SCROLLABLE)

local prevBtn = mkButton(footer, 12, 10, 44, 30, "<", function()
  pageIdx = math.max(0, pageIdx - 1)
  render()
end, { radius = 15, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 18 })

local nextBtn = mkButton(footer, W - 56, 10, 44, 30, ">", function()
  pageIdx = pageIdx + 1
  render()
end, { radius = 15, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 18 })

local pageLabel = mkLabel(footer, { x = 64, y = 16, w = W - 128, text = "", align = lvgl.ALIGN.CENTER, text_color = C.DIM, text_font = font(14) })
local statusLabel = mkLabel(footer, { x = 16, y = 44, w = W - 32, text = "tap path to jump to /", text_color = C.DIM, text_font = font(14) })

-- ---- 列表渲染 ----
local rows = {}

local function clearRows()
  for _, r in ipairs(rows) do
    for _, o in ipairs(r) do pcall(function() o:delete() end) end
  end
  rows = {}
end

-- 卡片：白色圆角，左圆点 + 名称，右 DEL
local function addRow(e, slot)
  local y = slot * ROW_H + 5
  local card = lvgl.Object(listArea, { x = PAD_X, y = y, w = CARD_W, h = CARD_H, radius = 12, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  card:add_flag(lvgl.FLAG.CLICKABLE)

  -- 左侧彩色圆点（目录蓝 / 文件深灰）
  local dot = lvgl.Object(card, { x = 16, y = (CARD_H - 8) / 2, w = 8, h = 8, radius = 4, bg_color = e.isDir and C.DIR or C.FILE, bg_opa = 255, border_width = 0 })
  dot:clear_flag(lvgl.FLAG.SCROLLABLE)
  pcall(function() dot:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)

  local label = e.isDir and (e.name .. "/") or e.name
  local nameW = CARD_W - 32 - 66
  mkLabel(card, { x = 32, y = (CARD_H - 20) / 2, w = nameW, text = ltruncate(label, 26), text_color = e.isDir and C.DIR or C.TEXT, text_font = font(16) })

  card:onevent(lvgl.EVENT.SHORT_CLICKED, function()
    if e.isDir then navigate(e.full) else showFileInfo(e) end
  end)

  local delBtn = mkButton(card, CARD_W - 62, 8, 52, CARD_H - 16, "DEL", function() confirmDelete(e) end, { radius = 10, bg_color = C.DEL_BG, bg_opa = 255, color = C.DEL, font = 14 })

  rows[#rows + 1] = { card, dot, delBtn }
end

-- 返回上一级卡片
local function addUpRow(slot)
  local y = slot * ROW_H + 5
  local card = lvgl.Object(listArea, { x = PAD_X, y = y, w = CARD_W, h = CARD_H, radius = 12, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  card:add_flag(lvgl.FLAG.CLICKABLE)
  local dot = lvgl.Object(card, { x = 16, y = (CARD_H - 8) / 2, w = 8, h = 8, radius = 4, bg_color = C.DIR, bg_opa = 255, border_width = 0 })
  dot:clear_flag(lvgl.FLAG.SCROLLABLE)
  pcall(function() dot:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  mkLabel(card, { x = 32, y = (CARD_H - 20) / 2, w = CARD_W - 44, text = "..  (up)", text_color = C.DIR, text_font = font(16) })
  card:onevent(lvgl.EVENT.SHORT_CLICKED, function() goUp() end)
  rows[#rows + 1] = { card, dot }
end

render = function()
  clearRows()
  setText(pathLabel, ltruncate(path, 34))

  local total = #entries
  local pageCount = math.max(1, math.ceil(total / ROWS_PER_PAGE))
  if pageIdx >= pageCount then pageIdx = pageCount - 1 end
  if pageIdx < 0 then pageIdx = 0 end

  local slot = 0
  if pageIdx == 0 then
    addUpRow(0)
    slot = 1
  end
  local start = pageIdx * ROWS_PER_PAGE
  for k = 1, ROWS_PER_PAGE - slot do
    local e = entries[start + k]
    if e then addRow(e, slot + k - 1) end
  end

  setText(pageLabel, string.format("%d / %d", pageIdx + 1, pageCount))
  pcall(function() prevBtn:set({ hidden = pageIdx == 0 }) end)
  pcall(function() nextBtn:set({ hidden = pageIdx >= pageCount - 1 }) end)

  if total == 0 then
    setText(statusLabel, "(empty directory)")
  else
    local nd, nf = 0, 0
    for _, e in ipairs(entries) do
      if e.isDir then nd = nd + 1 else nf = nf + 1 end
    end
    setText(statusLabel, string.format("%d folders  /  %d files", nd, nf))
  end
end

navigate = function(p)
  local list = listDir(p)
  if not list then
    setText(statusLabel, "cannot open: " .. ltruncate(p, 26))
    return
  end
  path = p
  entries = list
  pageIdx = 0
  render()
end

goUp = function()
  local parent = parentOf(path)
  if parent then navigate(parent) end
end

showFileInfo = function(e)
  local sz = fileSize(e.full)
  local prev = readPreview(e.full, 64)
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
  infoDialog = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 120, border_width = 0, pad_all = 0 })
  infoDialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  infoDialog:set({ hidden = true })

  local cw = W - 40
  local card = lvgl.Object(infoDialog, { x = 20, y = 72, w = cw, h = 336, radius = 16, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

  infoTitle = mkLabel(card, { x = 20, y = 16, w = cw - 40, text = "", text_color = C.TEXT, text_font = font(18) })
  infoBody = mkLabel(card, { x = 20, y = 50, w = cw - 40, h = 210, text = "", text_color = C.TEXT, text_font = font(16) })
  infoSub = mkLabel(card, { x = 20, y = 262, w = cw - 40, text = "", text_color = C.DIM, text_font = font(14) })
  mkButton(card, 20, 288, cw - 40, 36, "CLOSE", function() hideInfo() end, { radius = 12, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 14 })
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
  showInfo("SYSTEM CAPABILITIES", body, note)
end

-- 顶栏 i 按钮：先探测能力，再打开弹窗
local infoBtnHandler = function() showCapabilities() end
pcall(function() infoBtn:onevent(lvgl.EVENT.SHORT_CLICKED, infoBtnHandler) end)

-- ---- 删除确认弹窗 ----
local dialog, dName, dPath, dTarget

local function buildDialog()
  dialog = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 120, border_width = 0, pad_all = 0 })
  dialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  dialog:set({ hidden = true })

  local card = lvgl.Object(dialog, { x = 32, y = 150, w = W - 64, h = 184, radius = 16, bg_color = C.CARD, bg_opa = 255, border_width = 0, pad_all = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

  mkLabel(card, { x = 24, y = 20, w = W - 112, text = "Delete this item?", text_color = C.TEXT, text_font = font(18) })
  dName = mkLabel(card, { x = 24, y = 52, w = W - 112, text = "", text_color = C.DEL, text_font = font(16) })
  dPath = mkLabel(card, { x = 24, y = 78, w = W - 112, text = "", text_color = C.DIM, text_font = font(14) })

  local bw = (W - 64 - 48 - 12) / 2
  mkButton(card, 24, 122, bw, 42, "CANCEL", function() hideDialog() end, { radius = 12, bg_color = C.BTN, bg_opa = 255, color = C.TEXT, font = 14 })
  mkButton(card, 24 + bw + 12, 122, bw, 42, "DELETE", function() doDelete() end, { radius = 12, bg_color = C.DEL, bg_opa = 255, color = 0xFFFFFF, font = 14 })
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
    setText(statusLabel, "deleted: " .. ltruncate(t.name, 24))
    pcall(function()
      local okv, vibrator = pcall(require, "vibrator")
      if okv and vibrator and vibrator.start then
        vibrator.start(vibrator.type.WATCH_FACE)
      end
    end)
    navigate(path)
  else
    setText(statusLabel, "delete failed: " .. tostring(res or "unknown"))
  end
end

-- ---- 初始加载 ----
navigate(path)

-- ============================================================
-- 生命周期
-- ============================================================
function ScreenStateChangedCB(pre, now, reason)
end
