-- ============================================================
-- DEEP_SCAN — 小米手环 9 Pro Lua 表盘（单文件自包含）
-- 表盘主界面 + 系统文件管理器（深度浏览 / 深度搜索 / 删除文件）
--
-- 入口约定（与 9 Pro 运行时 / Monika 一致）：
--   * main.lua 顶层直接构建 UI（不使用 ui.init）
--   * 导出 ScreenStateChangedCB(pre, now, reason)
--
-- 仅使用已验证可用的 API：
--   * lvgl.Object / lvgl.Label / lvgl.BUILTIN_FONT
--   * dataman.subscribe(key, obj, cb)，value 为 Q24.8（value // 256）
--   * lvgl.fs.open_dir / open_file（seek("end") 取大小）
--   * os.remove 删除（pcall 兜底，可能被设备裁剪）
-- ============================================================

local lvgl = require("lvgl")
local okDm, dataman = pcall(require, "dataman")
if not okDm then dataman = nil end

local W = lvgl.HOR_RES()
local H = lvgl.VER_RES()
if not W or W == 0 then W = 336 end
if not H or H == 0 then H = 480 end

-- ---- 配置 ----
local FS_ROOT = "/data"
local LIST_CAP = 300
local SEARCH_LIMIT = 60
local SEARCH_DEPTH = 8
local SEARCH_SCAN_CAP = 20000
local ROWS_PER_PAGE = 8
local ROW_H = 36
local LIST_TOP = 100
local LIST_BOTTOM = LIST_TOP + ROWS_PER_PAGE * ROW_H -- 388
local DANGER_PREFIXES = {
  "/resource", "/misc", "/mode", "/etc", "/dev",
  "/data/app/system", "/data/system", "/data/app/quickapp",
  "/data/quickapp", "/data/app/watchface",
}

-- ---- 配色（终端风格）----
local C = {
  BG = 0x07090D, SURFACE = 0x0F141B, SURFACE2 = 0x161D27,
  BORDER = 0x223042, TEXT = 0xE6EDF5, DIM = 0x8A97A8,
  ACCENT = 0x37E0A4, ACCENT_D = 0x1E8A66, CYAN = 0x4CC9F0,
  AMBER = 0xFFC857, RED = 0xFF5C5C,
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
local function q24(v)
  if v == nil or v >= 0x7FFFFFFF then return nil end
  return v // 256
end

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
  if b < 1048576 then return string.format("%.1fK", b / 1024) end
  return string.format("%.1fM", b / 1048576)
end

local function ltruncate(s, n)
  s = tostring(s or "")
  if #s <= n then return s end
  return ".." .. s:sub(#s - n + 3)
end

local function tapPoint()
  local ok, x, y = pcall(function()
    local indev = lvgl.indev and lvgl.indev.get_act()
    if not indev then return nil, nil end
    return indev:get_point()
  end)
  if ok then return x, y end
  return nil, nil
end

local function mkLabel(parent, props)
  local lbl = lvgl.Label(parent, props)
  pcall(function() lbl:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  return lbl
end

local function setText(lbl, text, color)
  if not lbl then return end
  local p = { text = text }
  if color then p.text_color = color end
  pcall(function() lbl:set(p) end)
end

local function onClick(obj, cb)
  pcall(function() obj:onevent(lvgl.EVENT.SHORT_CLICKED, cb) end)
  pcall(function() obj:onevent(lvgl.EVENT.CLICKED, cb) end)
end

-- ============================================================
-- 根对象
-- ============================================================
local rootbase = lvgl.Object(nil, {
  w = W, h = H, bg_color = 0, bg_opa = 255, border_width = 0,
})
rootbase:clear_flag(lvgl.FLAG.SCROLLABLE)
rootbase:add_flag(lvgl.FLAG.EVENT_BUBBLE)

local root = lvgl.Object(rootbase, {
  x = 0, y = 0, w = W, h = H,
  outline_width = 0, border_width = 0, pad_all = 0, bg_opa = 0, bg_color = 0,
})
root:clear_flag(lvgl.FLAG.SCROLLABLE)
root:add_flag(lvgl.FLAG.EVENT_BUBBLE)

-- ============================================================
-- 表盘主界面
-- ============================================================
local hour, minute, second, month, day, week, battery, steps, hr

local watchPage = lvgl.Object(root, {
  x = 0, y = 0, w = W, h = H, bg_color = C.BG, bg_opa = 255, border_width = 0,
})
watchPage:clear_flag(lvgl.FLAG.SCROLLABLE)
watchPage:add_flag(lvgl.FLAG.EVENT_BUBBLE)

local batLabel = mkLabel(watchPage, { x = 16, y = 14, text = "--%", text_color = C.DIM, text_font = font(14) })
mkLabel(watchPage, { align = { type = lvgl.ALIGN.TOP_RIGHT, x_ofs = -16, y_ofs = 14 }, text = "DEEP_SCAN", text_color = C.ACCENT_D, text_font = font(14) })
local dateLabel = mkLabel(watchPage, { align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 48 }, text = "--  --  --", text_color = C.DIM, text_font = font(16) })
local timeLabel = mkLabel(watchPage, { align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 128 }, text = "--:--", text_color = C.TEXT, text_font = font(32) })
local secLabel = mkLabel(watchPage, { align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 210 }, text = "--", text_color = C.CYAN, text_font = font(18) })

-- 分隔线
local divider = lvgl.Object(watchPage, { x = 20, y = 252, w = W - 40, h = 1, bg_color = C.BORDER, bg_opa = 255, border_width = 0 })
divider:clear_flag(lvgl.FLAG.SCROLLABLE)

-- 终端卡片
local card = lvgl.Object(watchPage, {
  x = 12, y = 272, w = W - 24, h = 188, radius = 12,
  bg_color = C.SURFACE, bg_opa = 255, border_width = 1, border_color = C.ACCENT_D,
})
card:clear_flag(lvgl.FLAG.SCROLLABLE)
card:add_flag(lvgl.FLAG.EVENT_BUBBLE)

mkLabel(card, { x = 14, y = 10, text = "deep_scan@band9pro:~$", text_color = C.ACCENT, text_font = font(14) })
local stepLabel = mkLabel(card, { x = 22, y = 44, text = "steps    --", text_color = C.TEXT, text_font = font(16) })
local hrLabel = mkLabel(card, { x = 22, y = 76, text = "hr       -- bpm", text_color = C.TEXT, text_font = font(16) })
mkLabel(card, { x = 22, y = 108, text = "fs       /data mounted", text_color = C.DIM, text_font = font(14) })
mkLabel(card, { x = 14, y = 144, text = "tap to open file manager >", text_color = C.ACCENT, text_font = font(16) })

-- ---- 渲染 ----
local function renderTime()
  if hour == nil or minute == nil then return end
  setText(timeLabel, string.format("%02d:%02d", hour, minute))
end

local function renderSec()
  if second == nil then return end
  setText(secLabel, string.format("%02d", second))
end

local function renderDate()
  local wd = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local ws = (week and wd[week + 1]) or "--"
  setText(dateLabel, string.format("%s  %02d-%02d", ws, month or 0, day or 0))
end

local function renderBattery()
  if battery == nil then return end
  setText(batLabel, string.format("%d%%", math.min(battery, 100)))
end

local function renderSteps()
  if steps == nil then return end
  setText(stepLabel, "steps    " .. tostring(steps))
end

local function renderHr()
  if hr == nil then return end
  local color = C.CYAN
  if hr > 140 then color = C.RED elseif hr > 100 then color = C.AMBER end
  setText(hrLabel, "hr       " .. tostring(hr) .. " bpm", color)
end

-- ---- 数据订阅 ----
local function subscribe(key, obj, cb)
  if not dataman then return nil end
  local ok, t = pcall(dataman.subscribe, key, obj, cb)
  if ok and t ~= nil then return t end
  local ok2, t2 = pcall(dataman.subscribe, key, cb)
  if ok2 and t2 ~= nil then return t2 end
  return nil
end

local subs = {}
local function sub(key, obj, fn)
  local t = subscribe(key, obj, function(o, v)
    local val = q24(v)
    if val == nil then return end
    pcall(fn, val)
  end)
  if t ~= nil then subs[#subs + 1] = t end
end

sub("timeHour", timeLabel, function(v) hour = v; renderTime() end)
sub("timeMinute", timeLabel, function(v) minute = v; renderTime() end)
sub("timeSecond", secLabel, function(v) second = v; renderSec() end)
sub("dateMonth", dateLabel, function(v) month = v; renderDate() end)
sub("dateDay", dateLabel, function(v) day = v; renderDate() end)
sub("dateWeek", dateLabel, function(v) week = v; renderDate() end)
sub("systemStatusBattery", batLabel, function(v) battery = v; renderBattery() end)
sub("healthStepCount", stepLabel, function(v) steps = v; renderSteps() end)
sub("healthHeartRate", hrLabel, function(v) hr = v; renderHr() end)

-- ============================================================
-- 文件管理器（懒构建，首次点击卡片时才创建）
-- ============================================================
local fm = {
  page = nil,
  built = false,
  path = FS_ROOT,
  mode = "browse",        -- browse | search
  entries = {},           -- 当前浏览目录条目 {name, full, isDir, size}
  results = {},           -- 搜索结果
  keyword = "",
  pageIdx = 0,            -- 分页偏移
  selected = nil,         -- 待删除条目
  regions = {},           -- 点击区域（屏幕坐标）
  rowLabels = {},
  kbdRegions = {},
  kbdLabels = {},
}

local fmPathLabel, fmStatusLabel, fmSearchLabel
local fmPage, kbdOverlay, detailOverlay
local detName, detPath, detSize, detWarn

-- 前向声明：以下函数存在跨引用（定义在后、调用在前）
local closeKeyboard, closeFM, isHidden

-- ---- 文件系统操作（全部 pcall）----
local function openDir(path)
  if lvgl.fs and lvgl.fs.open_dir then
    local ok, d = pcall(lvgl.fs.open_dir, path)
    if ok and d and type(d.read) == "function" then return d end
  end
  return nil
end

local function openFile(path, mode)
  if lvgl.fs and lvgl.fs.open_file then
    local ok, f = pcall(lvgl.fs.open_file, path, mode)
    if ok and f then return f end
  end
  if io and io.open then
    local ok, f = pcall(io.open, path, mode)
    if ok and f then return f end
  end
  return nil
end

-- 以目录方式打开判断是否目录
local function isDir(path)
  local d = openDir(path)
  if d then
    pcall(function() d:close() end)
    return true
  end
  return false
end

local function fileSize(path)
  local f = openFile(path, "r")
  if not f then return nil end
  local sz = nil
  pcall(function() sz = f:seek("end") end) -- seek("end") 返回当前位置 = 大小
  pcall(function() f:close() end)
  if type(sz) == "number" then return sz end
  return nil
end

local function listDir(path)
  if not (lvgl.fs and lvgl.fs.open_dir) then return nil, "no fs api" end
  local d = openDir(path)
  if not d then return nil, "cannot open dir" end
  local dirs, files = {}, {}
  local count = 0
  local name = d:read()
  while name and count < LIST_CAP do
    count = count + 1
    local n = tostring(name)
    if n ~= "" and n ~= "." and n ~= ".." then
      local full = joinPath(path, n)
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

-- 深度搜索：递归扫描 path 下文件名包含 keyword 的条目
local function deepSearch(path, keyword, limit)
  local kw = string.lower(tostring(keyword or ""))
  local results = {}
  local count, scanned = 0, 0

  local function walk(p, depth)
    if count >= limit or scanned >= SEARCH_SCAN_CAP or depth > SEARCH_DEPTH then return end
    local entries, err = listDir(p)
    if not entries then return end
    for _, e in ipairs(entries) do
      scanned = scanned + 1
      if scanned >= SEARCH_SCAN_CAP then return end
      if count < limit and string.find(string.lower(e.name), kw, 1, true) then
        count = count + 1
        results[#results + 1] = e
      end
      if e.isDir and depth < SEARCH_DEPTH and e.name:sub(1, 1) ~= "." then
        walk(e.full, depth + 1)
        if count >= limit or scanned >= SEARCH_SCAN_CAP then return end
      end
    end
  end

  walk(path, 0)
  return results
end

local function isDanger(path)
  for _, p in ipairs(DANGER_PREFIXES) do
    if path == p or path:sub(1, #p + 1) == p .. "/" then return true end
  end
  return false
end

local function removePath(path)
  if type(os.remove) == "function" then
    return pcall(os.remove, path)
  end
  return false, "no delete api"
end

-- ---- 点击区域命中 ----
local function hitRegion(list, x, y)
  for _, r in ipairs(list) do
    if x >= r.x and x < r.x + r.w and y >= r.y and y < r.y + r.h then return r end
  end
  return nil
end

-- ---- 列表渲染（分页，非滚动）----
local function clearRows()
  for _, lbl in ipairs(fm.rowLabels) do
    pcall(function() lbl:delete() end)
  end
  fm.rowLabels = {}
end

local function fmRender()
  clearRows()
  fm.regions = {}
  setText(fmPathLabel, ltruncate(fm.path, 34))

  local list = (fm.mode == "search") and fm.results or fm.entries
  local total = #list
  local pageCount = math.max(1, math.ceil(total / ROWS_PER_PAGE))
  if fm.pageIdx >= pageCount then fm.pageIdx = pageCount - 1 end
  if fm.pageIdx < 0 then fm.pageIdx = 0 end

  -- 浏览模式首页：第 0 行固定为 ".."（返回上级）
  local slot = 0
  if fm.mode == "browse" and fm.pageIdx == 0 then
    fm.regions[#fm.regions + 1] = { x = 0, y = LIST_TOP, w = W, h = ROW_H, entry = { name = "..", isDir = true, up = true } }
    local lbl = mkLabel(fmPage, { x = 14, y = LIST_TOP + 9, w = W - 28, text = "> ..", text_color = C.ACCENT, text_font = font(14) })
    fm.rowLabels[#fm.rowLabels + 1] = lbl
    slot = 1
  end

  local start = fm.pageIdx * ROWS_PER_PAGE
  local shown = 0
  for k = 1, ROWS_PER_PAGE - slot do
    local e = list[start + k]
    local y = LIST_TOP + (slot + k - 1) * ROW_H
    if e then
      shown = shown + 1
      fm.regions[#fm.regions + 1] = { x = 0, y = y, w = W, h = ROW_H, entry = e }
      local label = e.isDir and ("> " .. e.name) or e.name
      if fm.mode == "search" then label = (e.isDir and "> " or "") .. ltruncate(e.full, 30) end
      local lbl = mkLabel(fmPage, {
        x = 14, y = y + 9, w = W - 28,
        text = label,
        text_color = e.isDir and C.ACCENT or C.TEXT,
        text_font = font(14),
      })
      fm.rowLabels[#fm.rowLabels + 1] = lbl
    end
  end

  if shown == 0 and total == 0 then
    setText(fmStatusLabel, (fm.mode == "search") and "(no match)" or "(empty directory)", C.DIM)
  end

  -- 底部状态
  if fm.mode == "search" then
    setText(fmStatusLabel, string.format("%d match(es)  [%d/%d]", total, fm.pageIdx + 1, pageCount), C.DIM)
    setText(fmSearchLabel, "search: " .. (fm.keyword ~= "" and fm.keyword or "deep scan"))
  else
    local nd, nf = 0, 0
    for _, e in ipairs(fm.entries) do
      if e.isDir then nd = nd + 1 else nf = nf + 1 end
    end
    setText(fmStatusLabel, string.format("%d dirs / %d files  [%d/%d]", nd, nf, fm.pageIdx + 1, pageCount), C.DIM)
    setText(fmSearchLabel, "search: deep scan (tap)")
  end

  -- 分页点击区域
  if pageCount > 1 then
    fm.regions[#fm.regions + 1] = { x = 0, y = LIST_BOTTOM, w = W / 2, h = 40, action = "prev" }
    fm.regions[#fm.regions + 1] = { x = W / 2, y = LIST_BOTTOM, w = W / 2, h = 40, action = "next" }
    setText(fmStatusLabel, string.format("[%d/%d]  < prev | next >", fm.pageIdx + 1, pageCount), C.AMBER)
  end
end

local function navigate(path)
  local entries, err = listDir(path)
  if not entries then
    setText(fmStatusLabel, "cannot open: " .. ltruncate(path, 24), C.RED)
    return
  end
  fm.path = path
  fm.mode = "browse"
  fm.entries = entries
  fm.results = {}
  fm.pageIdx = 0
  fmRender()
end

local function goUp()
  if fm.mode == "search" then
    fm.mode = "browse"
    fm.results = {}
    fm.pageIdx = 0
    fmRender()
    return
  end
  local parent = parentOf(fm.path)
  if parent then
    navigate(parent)
  else
    closeFM()
  end
end

-- ---- 键盘 ----
local function appendKey(ch)
  if #fm.keyword >= 24 then return end
  fm.keyword = fm.keyword .. ch
  setText(fmSearchLabel, "search: " .. fm.keyword)
end

local function backspaceKey()
  fm.keyword = string.sub(fm.keyword, 1, -2)
  setText(fmSearchLabel, "search: " .. (fm.keyword ~= "" and fm.keyword or "deep scan"))
end

local function clearKeyword()
  fm.keyword = ""
  setText(fmSearchLabel, "search: deep scan")
end

local function runSearch()
  closeKeyboard()
  local kw = fm.keyword or ""
  if kw == "" then
    fm.mode = "browse"
    fmRender()
    return
  end
  setText(fmStatusLabel, "scanning ...", C.AMBER)
  local ok, results = pcall(deepSearch, fm.path, kw, SEARCH_LIMIT)
  if not ok then
    setText(fmStatusLabel, "search failed", C.RED)
    return
  end
  fm.results = results
  fm.mode = "search"
  fm.pageIdx = 0
  fmRender()
end

local function buildKeyboard()
  kbdOverlay = lvgl.Object(fmPage, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 220, border_width = 0 })
  kbdOverlay:clear_flag(lvgl.FLAG.SCROLLABLE)
  kbdOverlay:set({ hidden = true })

  local panel = lvgl.Object(kbdOverlay, {
    x = 8, y = 16, w = W - 16, h = 340, radius = 14,
    bg_color = C.SURFACE, bg_opa = 255, border_width = 1, border_color = C.BORDER,
  })
  panel:clear_flag(lvgl.FLAG.SCROLLABLE)

  mkLabel(panel, { align = { type = lvgl.ALIGN.TOP_MID, y_ofs = 10 }, text = "DEEP SCAN · KEYWORD", text_color = C.ACCENT, text_font = font(14) })
  mkLabel(panel, { x = 12, y = 40, w = W - 40, text = "> ", text_color = C.TEXT, text_font = font(16) })

  -- 键位（面板内坐标）
  local rows = {
    { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" },
    { "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T" },
    { "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3" },
    { "4", "5", "6", "7", "8", "9", "_", ".", "-" },
  }
  local keyW, keyH, gap = 30, 32, 2
  local rowStartY = 76
  fm.kbdRegions = {}
  for ri, row in ipairs(rows) do
    local y = rowStartY + (ri - 1) * (keyH + 4)
    local totalW = #row * keyW + (#row - 1) * gap
    local x0 = math.floor((W - 16 - totalW) / 2)
    for ci, ch in ipairs(row) do
      local kx = x0 + (ci - 1) * (keyW + gap)
      local lbl = mkLabel(panel, {
        x = kx, y = y, w = keyW, h = keyH,
        text = ch, align = lvgl.ALIGN.CENTER, text_color = C.TEXT, text_font = font(14),
      })
      fm.kbdLabels[#fm.kbdLabels + 1] = lbl
      -- 屏幕坐标区域（panel 在 8,16）
      fm.kbdRegions[#fm.kbdRegions + 1] = {
        x = 8 + kx, y = 16 + y, w = keyW, h = keyH, ch = ch,
      }
    end
  end

  -- 操作行
  local btnY = rowStartY + 4 * (keyH + 4) + 8
  local btnH = 36
  local btnW = math.floor((W - 16 - 12 - 3 * 6) / 4)
  local actions = {
    { "DEL", backspaceKey, C.AMBER },
    { "CLR", clearKeyword, C.DIM },
    { "RUN", runSearch, C.BG },
    { "OK", closeKeyboard, C.CYAN },
  }
  for i, a in ipairs(actions) do
    local kx = 6 + (i - 1) * (btnW + 6)
    mkLabel(panel, {
      x = kx, y = btnY, w = btnW, h = btnH,
      text = a[1], align = lvgl.ALIGN.CENTER, text_color = a[3], text_font = font(14),
    })
    fm.kbdRegions[#fm.kbdRegions + 1] = {
      x = 8 + kx, y = 16 + btnY, w = btnW, h = btnH, action = a[2],
    }
  end
end

local function openKeyboard()
  if kbdOverlay then kbdOverlay:set({ hidden = false }) end
end

closeKeyboard = function()
  if kbdOverlay then kbdOverlay:set({ hidden = true }) end
end

-- ---- 删除确认弹窗 ----
local function buildDetail()
  detailOverlay = lvgl.Object(fmPage, { x = 0, y = 0, w = W, h = H, bg_color = 0x000000, bg_opa = 200, border_width = 0 })
  detailOverlay:clear_flag(lvgl.FLAG.SCROLLABLE)
  detailOverlay:set({ hidden = true })

  local dcard = lvgl.Object(detailOverlay, {
    x = 24, y = 96, w = W - 48, h = 264, radius = 14,
    bg_color = C.SURFACE, bg_opa = 255, border_width = 1, border_color = C.BORDER,
  })
  dcard:clear_flag(lvgl.FLAG.SCROLLABLE)

  mkLabel(dcard, { x = 16, y = 14, text = "DELETE?", text_color = C.RED, text_font = font(18) })
  detName = mkLabel(dcard, { x = 16, y = 48, w = W - 80, text = "", text_color = C.TEXT, text_font = font(16) })
  detPath = mkLabel(dcard, { x = 16, y = 78, w = W - 80, text = "", text_color = C.DIM, text_font = font(14) })
  detSize = mkLabel(dcard, { x = 16, y = 104, w = W - 80, text = "", text_color = C.DIM, text_font = font(14) })
  detWarn = mkLabel(dcard, { x = 16, y = 132, w = W - 80, text = "", text_color = C.RED, text_font = font(14) })

  mkLabel(dcard, { x = 16, y = 200, w = (W - 48 - 32 - 12) / 2, h = 44, text = "CANCEL", align = lvgl.ALIGN.CENTER, text_color = C.TEXT, text_font = font(14) })
  mkLabel(dcard, { x = 16 + (W - 48 - 32 - 12) / 2 + 12, y = 200, w = (W - 48 - 32 - 12) / 2, h = 44, text = "DELETE", align = lvgl.ALIGN.CENTER, text_color = C.BG, text_font = font(14) })
end

local function hideDetail()
  if detailOverlay then detailOverlay:set({ hidden = true }) end
  fm.selected = nil
end

local function openDetail(e)
  fm.selected = e
  setText(detName, e.name)
  setText(detPath, ltruncate(e.full, 40), C.DIM)
  if e.isDir then
    setText(detSize, "[directory]", C.DIM)
  else
    local sz = e.size or fileSize(e.full)
    e.size = sz
    setText(detSize, "size: " .. humanSize(sz), C.DIM)
  end
  if isDanger(e.full) then
    setText(detWarn, "! SYSTEM PATH", C.RED)
  else
    setText(detWarn, "delete " .. ltruncate(e.name, 24) .. " ?", C.TEXT)
  end
  if detailOverlay then detailOverlay:set({ hidden = false }) end
end

local function doDelete()
  if not fm.selected then return end
  local target = fm.selected
  local ok, res = removePath(target.full)
  hideDetail()
  if ok and res == true then
    setText(fmStatusLabel, "deleted: " .. ltruncate(target.name, 24), C.ACCENT)
    pcall(function()
      local okv, vibrator = pcall(require, "vibrator")
      if okv and vibrator and vibrator.start then
        vibrator.start(vibrator.type.WATCH_FACE)
      end
    end)
    fm.mode = "browse"
    navigate(fm.path)
  else
    setText(fmStatusLabel, "delete failed: " .. tostring(res or "unknown"), C.RED)
  end
end

-- ---- 文件管理器页面事件 ----
local function fmOnTap()
  local x, y = tapPoint()
  if not x or not y then return end

  -- 弹窗优先级：键盘 > 删除确认 > 列表
  if kbdOverlay and not isHidden(kbdOverlay) then
    local r = hitRegion(fm.kbdRegions, x, y)
    if r then
      if r.ch then appendKey(r.ch) end
      if r.action then r.action() end
    end
    return
  end
  if detailOverlay and not isHidden(detailOverlay) then
    -- CANCEL 左上，DELETE 右下（按 x 区分）
    if x < W / 2 then hideDetail() else doDelete() end
    return
  end

  -- 顶栏
  if y < 56 then
    if x < 56 then goUp() end
    if x > W - 56 then navigate(FS_ROOT) end
    return
  end
  -- 搜索栏
  if y >= 56 and y < 96 then
    openKeyboard()
    return
  end
  -- 列表 / 分页
  local r = hitRegion(fm.regions, x, y)
  if r then
    if r.action == "prev" then
      fm.pageIdx = math.max(0, fm.pageIdx - 1)
      fmRender()
    elseif r.action == "next" then
      fm.pageIdx = fm.pageIdx + 1
      fmRender()
    elseif r.entry then
      if r.entry.up then
        if fm.mode == "search" then
          fm.mode = "browse"; fm.results = {}; fm.pageIdx = 0; fmRender()
        else
          local parent = parentOf(fm.path)
          if parent then navigate(parent) else closeFM() end
        end
      elseif r.entry.isDir then
        navigate(r.entry.full)
      else
        openDetail(r.entry)
      end
    end
  end
end

isHidden = function(obj)
  local ok, hidden = pcall(function() return obj:is_visible() end)
  if ok then return not hidden end
  return true
end

-- ---- 构建文件管理器页面 ----
local function buildFM()
  fmPage = lvgl.Object(root, { x = 0, y = 0, w = W, h = H, bg_color = C.BG, bg_opa = 255, border_width = 0 })
  fmPage:clear_flag(lvgl.FLAG.SCROLLABLE)
  fmPage:add_flag(lvgl.FLAG.EVENT_BUBBLE)
  fmPage:set({ hidden = true })

  -- 顶栏
  mkLabel(fmPage, { x = 8, y = 8, w = 44, h = 44, text = "<", align = lvgl.ALIGN.CENTER, text_color = C.ACCENT, text_font = font(18) })
  fmPathLabel = mkLabel(fmPage, { x = 56, y = 22, w = W - 112, text = FS_ROOT, text_color = C.DIM, text_font = font(14) })
  mkLabel(fmPage, { x = W - 52, y = 8, w = 44, h = 44, text = "/", align = lvgl.ALIGN.CENTER, text_color = C.CYAN, text_font = font(18) })

  -- 搜索栏
  local searchBox = lvgl.Object(fmPage, { x = 8, y = 56, w = W - 16, h = 36, radius = 10, bg_color = C.SURFACE, bg_opa = 255, border_width = 1, border_color = C.BORDER })
  searchBox:clear_flag(lvgl.FLAG.SCROLLABLE)
  searchBox:add_flag(lvgl.FLAG.EVENT_BUBBLE)
  fmSearchLabel = mkLabel(searchBox, { x = 12, y = 9, w = W - 40, text = "search: deep scan (tap)", text_color = C.DIM, text_font = font(14) })

  -- 状态栏
  fmStatusLabel = mkLabel(fmPage, { x = 12, y = LIST_BOTTOM + 8, w = W - 24, text = "", text_color = C.DIM, text_font = font(14) })

  buildKeyboard()
  buildDetail()

  onClick(fmPage, fmOnTap)
  fm.built = true
end

local function openFM()
  if not fm.built then buildFM() end
  if fmPage then fmPage:set({ hidden = false }) end
  fm.mode = "browse"
  navigate(fm.path)
end

closeFM = function()
  if fmPage then fmPage:set({ hidden = true }) end
  closeKeyboard()
  hideDetail()
end

-- 表盘点击 → 打开文件管理器（下半屏区域）
onClick(watchPage, function()
  local x, y = tapPoint()
  if y and y >= 250 then openFM() end
end)

-- ============================================================
-- 生命周期
-- ============================================================
function ScreenStateChangedCB(pre, now, reason)
  -- 熄屏/亮屏回调（9 Pro 运行时约定）。数据订阅由运行时托管，无需手动 pause/resume。
end

-- 兼容新文档约定：若运行时调用 ui.init，复用已构建的根对象
local ui = {}
function ui.init(style)
  return rootbase
end

return ui
