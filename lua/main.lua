-- ============================================================
-- DEEP_SCAN 文件管理器表盘（小米手环 9 Pro，336×480）
-- 简洁风格：安装后即为文件管理器（无表盘主界面、无终端主题）
--   左侧：文件/文件夹名（点击文件夹进入、点击文件查看大小）
--   右侧：DEL 删除按钮（点击弹出确认后删除）
--
-- 入口约定（与 9 Pro 运行时 / Monika 一致）：
--   * 顶层直接构建 UI
--   * 导出 ScreenStateChangedCB(pre, now, reason)
--
-- 点击可靠性说明：
--   * 每个可点元素都显式 add_flag(CLICKABLE) 并注册 SHORT_CLICKED
--   * 只注册 SHORT_CLICKED（LVGL 单次短按会同时触发 SHORT_CLICKED 与 CLICKED，
--     同时注册会导致回调执行两次 → 表现为“点击失灵/跳转两级”）
-- ============================================================

local lvgl = require("lvgl")

local W = lvgl.HOR_RES()
local H = lvgl.VER_RES()
if not W or W == 0 then W = 336 end
if not H or H == 0 then H = 480 end

-- ---- 配置 ----
local HOME = "/data"
local LIST_CAP = 300
local ROWS_PER_PAGE = 7
local ROW_H = 50
local HEADER_H = 56
local LIST_TOP = HEADER_H
local FOOTER_Y = LIST_TOP + ROWS_PER_PAGE * ROW_H -- 406

-- ---- 简洁浅色配色 ----
local C = {
  BG = 0xF6F7F9,
  HEADER = 0xFFFFFF,
  CARD = 0xFFFFFF,
  TEXT = 0x1B1F27,
  DIM = 0x8A94A6,
  DIR = 0x1F6FEB,
  DEL = 0xE5484D,
  DEL_BG = 0xFCE9EA,
  SEP = 0xE6E9EF,
}

-- ---- 字体（仅用已验证尺寸）----
local function font(size)
  if lvgl.BUILTIN_FONT then
    local f = lvgl.BUILTIN_FONT["MONTSERRAT_" .. tostring(size)]
    if f then return f end
    return lvgl.BUILTIN_FONT.DEFAULT
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
  if b < 1024 then return tostring(b) .. " B" end
  if b < 1048576 then return string.format("%.1f KB", b / 1024) end
  return string.format("%.1f MB", b / 1048576)
end

local function ltruncate(s, n)
  s = tostring(s or "")
  if #s <= n then return s end
  return ".." .. s:sub(#s - n + 3)
end

local function setText(lbl, text, color)
  if not lbl then return end
  local p = { text = text }
  if color then p.text_color = color end
  pcall(function() lbl:set(p) end)
end

local function mkLabel(parent, props)
  local lbl = lvgl.Label(parent, props)
  pcall(function() lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  return lbl
end

-- 按钮：显式 CLICKABLE + 仅 SHORT_CLICKED（避免 SHORT_CLICKED/CLICKED 双触发）
local function mkButton(parent, x, y, w, h, text, cb, opts)
  opts = opts or {}
  local btn = lvgl.Object(parent, {
    x = x, y = y, w = w, h = h,
    radius = opts.radius or 0,
    bg_color = opts.bg_color or 0,
    bg_opa = opts.bg_opa or 0,
    border_width = 0,
  })
  pcall(function() btn:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() btn:add_flag(lvgl.FLAG.CLICKABLE) end)
  local lbl = mkLabel(btn, {
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
  if lvgl.fs and lvgl.fs.open_dir then
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
  if lvgl.fs and lvgl.fs.open_file then
    local ok, f = pcall(lvgl.fs.open_file, p, mode)
    if ok and f then return f end
  end
  if io and io.open then
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
  if type(sz) == "number" then return sz end
  return nil
end

local function listDir(p)
  if not (lvgl.fs and lvgl.fs.open_dir) then return nil end
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

  local function byName(a, b) return a.name < b.name end
  table.sort(dirs, byName)
  table.sort(files, byName)
  for _, e in ipairs(files) do dirs[#dirs + 1] = e end
  return dirs
end

local function removePath(p)
  if type(os.remove) == "function" then
    return pcall(os.remove, p)
  end
  return false, "no delete api"
end

-- ---- 状态 ----
local path = HOME
local entries = {}
local pageIdx = 0

-- 前向声明（跨引用）
local navigate, goUp, render, showFileInfo, confirmDelete, doDelete, hideDialog

-- ---- 界面 ----
local root = lvgl.Object(nil, {
  w = W, h = H, bg_color = C.BG, bg_opa = 255, border_width = 0,
})
root:clear_flag(lvgl.FLAG.SCROLLABLE)

-- 头部
local header = lvgl.Object(root, {
  x = 0, y = 0, w = W, h = HEADER_H, bg_color = C.HEADER, bg_opa = 255, border_width = 0,
})
header:clear_flag(lvgl.FLAG.SCROLLABLE)

local sepTop = lvgl.Object(root, { x = 0, y = HEADER_H, w = W, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
sepTop:clear_flag(lvgl.FLAG.SCROLLABLE)

local pathLabel = mkLabel(header, { x = 56, y = 18, w = W - 112, text = HOME, text_color = C.TEXT, text_font = font(16) })

local backBtn = mkButton(header, 0, 0, 56, HEADER_H, "<", function() goUp() end, { color = C.DIR, font = 24 })
local homeBtn = mkButton(header, W - 56, 0, 56, HEADER_H, "/", function() navigate(HOME) end, { color = C.DIR, font = 24 })

-- 列表区域
local listArea = lvgl.Object(root, {
  x = 0, y = LIST_TOP, w = W, h = FOOTER_Y - LIST_TOP, bg_color = C.BG, bg_opa = 255, border_width = 0,
})
listArea:clear_flag(lvgl.FLAG.SCROLLABLE)

-- 底部分页 + 状态
local prevBtn = mkButton(root, 8, FOOTER_Y + 6, 92, 38, "< prev", function()
  pageIdx = math.max(0, pageIdx - 1)
  render()
end, { radius = 10, bg_color = C.CARD, bg_opa = 255, color = C.TEXT, font = 14 })

local nextBtn = mkButton(root, W - 100, FOOTER_Y + 6, 92, 38, "next >", function()
  pageIdx = pageIdx + 1
  render()
end, { radius = 10, bg_color = C.CARD, bg_opa = 255, color = C.TEXT, font = 14 })

local pageLabel = mkLabel(root, { x = 104, y = FOOTER_Y + 16, w = W - 208, text = "", align = lvgl.ALIGN.CENTER, text_color = C.DIM, text_font = font(14) })
local statusLabel = mkLabel(root, { x = 16, y = FOOTER_Y + 46, w = W - 32, text = "", text_color = C.DIM, text_font = font(14) })

-- ---- 列表渲染 ----
local rows = {}

local function clearRows()
  for _, r in ipairs(rows) do
    for _, o in ipairs(r) do pcall(function() o:delete() end) end
  end
  rows = {}
end

local function addRow(e, rowIdx)
  local y = LIST_TOP + rowIdx * ROW_H
  local objs = {}

  -- 名称（左侧）
  local nameBtn = lvgl.Object(listArea, { x = 0, y = y, w = W - 76, h = ROW_H, bg_color = 0, bg_opa = 0, border_width = 0 })
  nameBtn:clear_flag(lvgl.FLAG.SCROLLABLE)
  nameBtn:add_flag(lvgl.FLAG.CLICKABLE)
  local label = e.isDir and (e.name .. "/") or e.name
  local nameLbl = mkLabel(nameBtn, { x = 16, y = 15, w = W - 100, text = ltruncate(label, 24), text_color = e.isDir and C.DIR or C.TEXT, text_font = font(16) })
  nameBtn:onevent(lvgl.EVENT.SHORT_CLICKED, function()
    if e.isDir then navigate(e.full) else showFileInfo(e) end
  end)
  objs[#objs + 1] = nameBtn

  -- 删除按钮（右侧）
  local delBtn = lvgl.Object(listArea, { x = W - 72, y = y + 9, w = 60, h = ROW_H - 18, radius = 8, bg_color = C.DEL_BG, bg_opa = 255, border_width = 0 })
  delBtn:clear_flag(lvgl.FLAG.SCROLLABLE)
  delBtn:add_flag(lvgl.FLAG.CLICKABLE)
  local delLbl = mkLabel(delBtn, { align = lvgl.ALIGN.CENTER, text = "DEL", text_color = C.DEL, text_font = font(14) })
  delBtn:onevent(lvgl.EVENT.SHORT_CLICKED, function() confirmDelete(e) end)
  objs[#objs + 1] = delBtn

  -- 分隔线
  local sep = lvgl.Object(listArea, { x = 16, y = y + ROW_H - 1, w = W - 32, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
  sep:clear_flag(lvgl.FLAG.SCROLLABLE)
  objs[#objs + 1] = sep

  rows[#rows + 1] = objs
end

local function addUpRow(rowIdx)
  local y = LIST_TOP + rowIdx * ROW_H
  local btn = lvgl.Object(listArea, { x = 0, y = y, w = W, h = ROW_H, bg_color = 0, bg_opa = 0, border_width = 0 })
  btn:clear_flag(lvgl.FLAG.SCROLLABLE)
  btn:add_flag(lvgl.FLAG.CLICKABLE)
  local lbl = mkLabel(btn, { x = 16, y = 15, w = W - 32, text = "..  (up)", text_color = C.DIR, text_font = font(16) })
  btn:onevent(lvgl.EVENT.SHORT_CLICKED, function() goUp() end)
  local sep = lvgl.Object(listArea, { x = 16, y = y + ROW_H - 1, w = W - 32, h = 1, bg_color = C.SEP, bg_opa = 255, border_width = 0 })
  sep:clear_flag(lvgl.FLAG.SCROLLABLE)
  rows[#rows + 1] = { btn, sep }
end

render = function()
  clearRows()
  setText(pathLabel, ltruncate(path, 30))

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

  -- 分页
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
    setText(statusLabel, string.format("%d folders / %d files", nd, nf))
  end
end

navigate = function(p)
  local list, err = listDir(p)
  if not list then
    setText(statusLabel, "cannot open: " .. ltruncate(p, 26))
    return
  end
  path = p
  entries = list
  pageIdx = 0
  setText(statusLabel, "")
  render()
end

goUp = function()
  local parent = parentOf(path)
  if parent then navigate(parent) end
end

showFileInfo = function(e)
  local sz = fileSize(e.full)
  setText(statusLabel, e.name .. "  ·  " .. humanSize(sz))
end

-- ---- 删除确认弹窗 ----
local dialog, dName, dPath, dCancelBtn, dDeleteBtn, dTarget

local function buildDialog()
  dialog = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 120, border_width = 0 })
  dialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  dialog:set({ hidden = true })

  local card = lvgl.Object(dialog, { x = 32, y = 128, w = W - 64, h = 224, radius = 14, bg_color = C.CARD, bg_opa = 255, border_width = 0 })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)

  mkLabel(card, { x = 20, y = 22, w = W - 104, text = "Delete this item?", text_color = C.TEXT, text_font = font(18) })
  dName = mkLabel(card, { x = 20, y = 58, w = W - 104, text = "", text_color = C.DEL, text_font = font(16) })
  dPath = mkLabel(card, { x = 20, y = 86, w = W - 104, text = "", text_color = C.DIM, text_font = font(14) })

  local bw = (W - 64 - 40 - 12) / 2
  dCancelBtn = mkButton(card, 20, 160, bw, 44, "CANCEL", function() hideDialog() end, { radius = 10, bg_color = 0xF1F3F5, bg_opa = 255, color = C.TEXT, font = 14 })
  dDeleteBtn = mkButton(card, 20 + bw + 12, 160, bw, 44, "DELETE", function() doDelete() end, { radius = 10, bg_color = C.DEL, bg_opa = 255, color = 0xFFFFFF, font = 14 })
end

confirmDelete = function(e)
  if not dialog then buildDialog() end
  dTarget = e
  setText(dName, ltruncate(e.name, 28))
  setText(dPath, ltruncate(e.full, 40))
  dialog:set({ hidden = false })
end

hideDialog = function()
  if dialog then dialog:set({ hidden = true }) end
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
