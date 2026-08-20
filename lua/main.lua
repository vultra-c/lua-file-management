-- ============================================================
-- DEEP_SCAN Files — 小米手环 9 Pro Lua 文件管理表盘
--
-- This version deliberately does not contain native injection code.
-- The watchface is the trusted local backend: it lists, previews and
-- deletes files through the Lua/LVGL filesystem APIs available to it.
-- backend.lua also contains a versioned line protocol over the companion
-- QuickApp's private-file mapping; this is a user-mediated hand-off, not IPC.
-- ============================================================

local lvgl = require("lvgl")

-- Load the backend when running from source. The face builder also embeds
-- backend.lua before this file, so the fallback is harmless on-device.
local backendPath = (SCRIPT_PATH or "./lua/") .. "backend.lua"
pcall(dofile, backendPath)
local Backend = rawget(_G, "FileManagerBackend")
if not Backend then error("FileManagerBackend unavailable") end

local function constValue(value)
  return type(value) == "function" and value() or value
end

local W = constValue(lvgl.HOR_RES) or 336
local H = constValue(lvgl.VER_RES) or 480
if W == 0 then W = 336 end
if H == 0 then H = 480 end

local HOME = "/data"
local ROWS_PER_PAGE = 6
local ROW_H = 56
local HEADER_H = 64
local FOOTER_H = 44
local FOOTER_TOP = H - FOOTER_H
local NAME_X = 48
local DEL_W = 72
local DEL_H = 32

local C = {
  BG = 0x000000,
  SURFACE = 0x111113,
  TEXT = 0xFFFFFF,
  DIM = 0x8E8E93,
  ACCENT = 0x0A84FF,
  DESTRUCTIVE = 0xFF453A,
  DESTRUCTIVE_BG = 0x2A1114,
  SEP = 0x1C1C1E,
  BTN = 0x1C1C1E,
  FILE_ICON = 0x3A3A3C,
}

local function font(size)
  local ok, value = pcall(function() return lvgl.Font("montserrat", size, "normal") end)
  if ok and value then return value end
  if lvgl.BUILTIN_FONT then
    return lvgl.BUILTIN_FONT["MONTSERRAT_" .. tostring(size)] or lvgl.BUILTIN_FONT.DEFAULT
  end
  return nil
end

local function truncate(value, max)
  local text = tostring(value or "")
  if #text <= max then return text end
  return ".." .. text:sub(#text - max + 3)
end

local function rightTruncate(value, max)
  local text = tostring(value or "")
  if #text <= max then return text end
  return text:sub(1, max - 2) .. ".."
end

local function humanSize(size)
  if not size then return "?" end
  if size < 1024 then return tostring(size) .. "B" end
  if size < 1048576 then return string.format("%.1fK", size / 1024) end
  return string.format("%.1fM", size / 1048576)
end

local function parentOf(path)
  if not path or path == "/" then return nil end
  local parent = path:match("^(.*)/[^/]*$")
  return (not parent or parent == "") and "/" or parent
end

local function setText(label, text, color)
  if not label then return end
  local props = { text = text }
  if color then props.text_color = color end
  pcall(function() label:set(props) end)
end

local function makeLabel(parent, props)
  props = props or {}
  if props.text_align == nil then props.text_align = 0 end
  local label = lvgl.Label(parent, props)
  pcall(function() label:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  return label
end

local function makeButton(parent, x, y, width, height, text, callback, opts)
  opts = opts or {}
  local button = lvgl.Object(parent, {
    x = x, y = y, w = width, h = height,
    radius = opts.radius or 0,
    bg_color = opts.bg_color or 0,
    bg_opa = opts.bg_opa or 0,
    border_width = 0,
    pad_all = 0,
  })
  pcall(function() button:clear_flag(lvgl.FLAG.SCROLLABLE) end)
  pcall(function() button:add_flag(lvgl.FLAG.CLICKABLE) end)
  makeLabel(button, {
    align = lvgl.ALIGN.CENTER,
    text = text,
    text_color = opts.color or C.TEXT,
    text_font = font(opts.font or 16),
  })
  if callback then pcall(function() button:onevent(lvgl.EVENT.SHORT_CLICKED, callback) end) end
  return button
end

-- ---------------- application state ----------------
local path = HOME
local entries = {}
local pageIndex = 0
local rows = {}
local statusLabel
local pathLabel
local pageLabel
local previousButton
local nextButton
local infoDialog
local infoTitle
local infoBody
local infoSub
local deleteDialog
local deleteName
local deletePath
local deleteTarget
local processBridge

local navigate
local render
local showInfo
local hideInfo
local confirmDelete
local hideDelete
local performDelete

-- ---------------- root UI ----------------
local root = lvgl.Object(nil, {
  x = 0, y = 0, w = W, h = H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
pcall(function() root:clear_flag(lvgl.FLAG.SCROLLABLE) end)

local header = lvgl.Object(root, {
  x = 0, y = 0, w = W, h = HEADER_H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
header:clear_flag(lvgl.FLAG.SCROLLABLE)
local headerSeparator = lvgl.Object(root, {
  x = 0, y = HEADER_H, w = W, h = 1,
  bg_color = C.SEP, bg_opa = 255, border_width = 0,
})
headerSeparator:clear_flag(lvgl.FLAG.SCROLLABLE)

local backButton = makeButton(header, 0, 0, 44, HEADER_H, "<", function()
  local parent = parentOf(path)
  if parent then navigate(parent) else setText(statusLabel, "already at /") end
end, { color = C.TEXT, font = 24 })

local bridgeButton = makeButton(header, W - 144, 0, 44, HEADER_H, "Q", function()
  if processBridge then
    local ok, detail = processBridge(true)
    if ok then setText(statusLabel, "bridge: " .. tostring(detail))
    elseif detail == "bridge dir not found" then setText(statusLabel, "bridge dir not found")
    else setText(statusLabel, "bridge idle") end
  end
end, { color = C.ACCENT, font = 16 })

local refreshButton = makeButton(header, W - 96, 0, 44, HEADER_H, "R", function()
  navigate(path)
  setText(statusLabel, "refreshed")
end, { color = C.ACCENT, font = 18 })

local infoButton = makeButton(header, W - 48, 0, 48, HEADER_H, "i", function()
  local function available(value)
    return type(value) == "function" and "OK" or "--"
  end
  local body = table.concat({
    "Lua backend       [OK]",
    "List dirs         [" .. available(lvgl.fs and lvgl.fs.open_dir) .. "]",
    "Read files        [" .. available(lvgl.fs and lvgl.fs.open_file) .. "]",
    "Delete            [" .. available(os and os.remove) .. "]",
    "QuickApp bridge   " .. Backend.BRIDGE_PACKAGE,
    "Bridge root       " .. (Backend.bridgeStatus() or "not found yet"),
    "Root              " .. HOME,
  }, "\n")
  showInfo("FILES BACKEND", body, "Q = process a pending QuickApp request")
end, { color = C.DIM, font = 16 })

makeLabel(header, {
  x = 48, y = 9, w = W - 198,
  text = "Files",
  text_color = C.TEXT,
  text_font = font(18),
})
pathLabel = makeLabel(header, {
  x = 48, y = 36, w = W - 198,
  text = HOME,
  text_color = C.DIM,
  text_font = font(14),
})

local listArea = lvgl.Object(root, {
  x = 0, y = HEADER_H, w = W, h = FOOTER_TOP - HEADER_H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
listArea:clear_flag(lvgl.FLAG.SCROLLABLE)

local footer = lvgl.Object(root, {
  x = 0, y = FOOTER_TOP, w = W, h = FOOTER_H,
  bg_color = C.BG, bg_opa = 255, border_width = 0, pad_all = 0,
})
footer:clear_flag(lvgl.FLAG.SCROLLABLE)
local footerSeparator = lvgl.Object(root, {
  x = 0, y = FOOTER_TOP, w = W, h = 1,
  bg_color = C.SEP, bg_opa = 255, border_width = 0,
})
footerSeparator:clear_flag(lvgl.FLAG.SCROLLABLE)

statusLabel = makeLabel(footer, {
  x = 16, y = 16, w = W - 156,
  text = "loading...",
  text_color = C.DIM,
  text_font = font(14),
})
previousButton = makeButton(footer, W - 140, 6, 38, 32, "<", function()
  pageIndex = math.max(0, pageIndex - 1)
  render()
end, { radius = 16, bg_color = C.BTN, bg_opa = 255, font = 18 })
pageLabel = makeLabel(footer, {
  x = W - 98, y = 14, w = 44,
  text = "1/1", align = lvgl.ALIGN.CENTER,
  text_color = C.DIM, text_font = font(14),
})
nextButton = makeButton(footer, W - 54, 6, 38, 32, ">", function()
  pageIndex = pageIndex + 1
  render()
end, { radius = 16, bg_color = C.BTN, bg_opa = 255, font = 18 })

-- ---------------- information dialog ----------------
local function buildInfoDialog()
  infoDialog = lvgl.Object(root, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000, bg_opa = 150, border_width = 0, pad_all = 0,
  })
  infoDialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  infoDialog:set({ hidden = true })
  local cardWidth = W - 40
  local card = lvgl.Object(infoDialog, {
    x = 20, y = 86, w = cardWidth, h = 300,
    radius = 16, bg_color = C.SURFACE, bg_opa = 255,
    border_width = 0, pad_all = 0,
  })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  infoTitle = makeLabel(card, {
    x = 20, y = 16, w = cardWidth - 40,
    text = "", text_color = C.TEXT, text_font = font(18),
  })
  infoBody = makeLabel(card, {
    x = 20, y = 54, w = cardWidth - 40, h = 190,
    text = "", text_color = C.TEXT, text_font = font(14),
  })
  infoSub = makeLabel(card, {
    x = 20, y = 252, w = cardWidth - 40,
    text = "", text_color = C.DIM, text_font = font(12),
  })
  makeButton(card, 20, 270, cardWidth - 40, 28, "CLOSE", hideInfo, {
    radius = 12, bg_color = C.BTN, bg_opa = 255, font = 13,
  })
end

showInfo = function(title, body, subtitle)
  if not infoDialog then buildInfoDialog() end
  setText(infoTitle, title or "")
  setText(infoBody, body or "")
  setText(infoSub, subtitle or "")
  pcall(function() infoDialog:set({ hidden = false }) end)
end

hideInfo = function()
  if infoDialog then pcall(function() infoDialog:set({ hidden = true }) end) end
end

-- ---------------- delete dialog ----------------
local function buildDeleteDialog()
  deleteDialog = lvgl.Object(root, {
    x = 0, y = 0, w = W, h = H,
    bg_color = 0x000000, bg_opa = 150, border_width = 0, pad_all = 0,
  })
  deleteDialog:clear_flag(lvgl.FLAG.SCROLLABLE)
  deleteDialog:set({ hidden = true })
  local cardWidth = W - 64
  local card = lvgl.Object(deleteDialog, {
    x = 32, y = 150, w = cardWidth, h = 184,
    radius = 16, bg_color = C.SURFACE, bg_opa = 255,
    border_width = 0, pad_all = 0,
  })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  makeLabel(card, {
    x = 24, y = 20, w = cardWidth - 48,
    text = "Delete this item?", text_color = C.TEXT, text_font = font(18),
  })
  deleteName = makeLabel(card, {
    x = 24, y = 52, w = cardWidth - 48,
    text = "", text_color = C.DESTRUCTIVE, text_font = font(16),
  })
  deletePath = makeLabel(card, {
    x = 24, y = 78, w = cardWidth - 48,
    text = "", text_color = C.DIM, text_font = font(14),
  })
  local buttonWidth = (cardWidth - 60) / 2
  makeButton(card, 24, 122, buttonWidth, 42, "CANCEL", hideDelete, {
    radius = 12, bg_color = C.BTN, bg_opa = 255, font = 14,
  })
  makeButton(card, 36 + buttonWidth, 122, buttonWidth, 42, "DELETE", performDelete, {
    radius = 12, bg_color = C.DESTRUCTIVE, bg_opa = 255,
    color = 0xFFFFFF, font = 14,
  })
end

confirmDelete = function(item)
  if not deleteDialog then buildDeleteDialog() end
  deleteTarget = item
  setText(deleteName, truncate(item.name, 28))
  setText(deletePath, truncate(item.path, 40))
  pcall(function() deleteDialog:set({ hidden = false }) end)
end

hideDelete = function()
  if deleteDialog then pcall(function() deleteDialog:set({ hidden = true }) end) end
  deleteTarget = nil
end

performDelete = function()
  local item = deleteTarget
  hideDelete()
  if not item then return end
  local ok, err = Backend.delete(item.path)
  if ok then
    setText(statusLabel, "deleted: " .. truncate(item.name, 20))
    pcall(function()
      local vibrator = require("vibrator")
      if vibrator and vibrator.start then vibrator.start(vibrator.type.WATCH_FACE) end
    end)
    navigate(path)
  else
    setText(statusLabel, "delete failed: " .. truncate(err, 20))
  end
end

-- ---------------- list rendering ----------------
local function clearRows()
  for _, row in ipairs(rows) do
    for _, object in ipairs(row) do pcall(function() object:delete() end) end
  end
  rows = {}
end

local function makeRowIcon(card, directory)
  local objects = {}
  local x = 20
  local y = (ROW_H - 18) / 2
  if directory then
    objects[#objects + 1] = lvgl.Object(card, {
      x = x, y = y, w = 8, h = 4, radius = 1,
      bg_color = C.ACCENT, bg_opa = 255, border_width = 0,
    })
    objects[#objects + 1] = lvgl.Object(card, {
      x = x, y = y + 3, w = 20, h = 14, radius = 3,
      bg_color = C.ACCENT, bg_opa = 255, border_width = 0,
    })
  else
    objects[#objects + 1] = lvgl.Object(card, {
      x = x + 3, y = y, w = 14, h = 18, radius = 2,
      bg_color = C.FILE_ICON, bg_opa = 255, border_width = 0,
    })
  end
  for _, object in ipairs(objects) do
    pcall(function() object:clear_flag(lvgl.FLAG.SCROLLABLE) end)
    pcall(function() object:add_flag(lvgl.FLAG.EVENT_BUBBLE) end)
  end
  return objects
end

local function addRow(item, slot)
  local y = slot * ROW_H
  local card = lvgl.Object(listArea, {
    x = 0, y = y, w = W, h = ROW_H,
    bg_color = 0, bg_opa = 0, border_width = 0, pad_all = 0,
  })
  card:clear_flag(lvgl.FLAG.SCROLLABLE)
  card:add_flag(lvgl.FLAG.CLICKABLE)
  makeRowIcon(card, item.isDir)
  makeLabel(card, {
    x = NAME_X, y = (ROW_H - 20) / 2,
    w = W - NAME_X - DEL_W - 28,
    text = item.isDir and (item.name .. "/") or item.name,
    text_color = C.TEXT, text_font = font(16),
  })
  card:onevent(lvgl.EVENT.SHORT_CLICKED, function()
    if item.isDir then navigate(item.path)
    else
      local preview = Backend.read(item.path, Backend.MAX_PREVIEW)
      local body = "size: " .. humanSize(item.size) .. "\n\n"
      body = body .. (preview or "(no text preview)")
      showInfo("FILE  " .. truncate(item.name, 22), body, truncate(item.path, 40))
    end
  end)
  local deleteButton = makeButton(card, W - 16 - DEL_W, (ROW_H - DEL_H) / 2,
    DEL_W, DEL_H, "Delete", function() confirmDelete(item) end, {
      radius = 16, bg_color = C.DESTRUCTIVE_BG, bg_opa = 255,
      color = C.DESTRUCTIVE, font = 14,
    })
  local separator = lvgl.Object(listArea, {
    x = 20, y = y + ROW_H - 1, w = W - 40, h = 1,
    bg_color = C.SEP, bg_opa = 255, border_width = 0,
  })
  separator:clear_flag(lvgl.FLAG.SCROLLABLE)
  rows[#rows + 1] = { card, separator, deleteButton }
end

render = function()
  clearRows()
  setText(pathLabel, truncate(path, 34))
  local total = #entries
  local pageCount = math.max(1, math.ceil(total / ROWS_PER_PAGE))
  pageIndex = math.max(0, math.min(pageIndex, pageCount - 1))
  local first = pageIndex * ROWS_PER_PAGE
  for slot = 1, ROWS_PER_PAGE do
    local item = entries[first + slot]
    if item then addRow(item, slot - 1) end
  end
  setText(pageLabel, string.format("%d/%d", pageIndex + 1, pageCount))
  pcall(function() previousButton:set({ hidden = pageIndex == 0 }) end)
  pcall(function() nextButton:set({ hidden = pageIndex >= pageCount - 1 }) end)
  if total == 0 then
    setText(statusLabel, "(empty)")
  else
    local directories, files = 0, 0
    for _, item in ipairs(entries) do
      if item.isDir then directories = directories + 1 else files = files + 1 end
    end
    setText(statusLabel, rightTruncate(string.format("%d items (%d files, %d dirs)", total, files, directories), 28))
  end
end

navigate = function(nextPath)
  local result, err = Backend.list(nextPath)
  if not result then
    setText(pathLabel, truncate(nextPath, 34))
    setText(statusLabel, "cannot open: " .. truncate(err, 20))
    entries = {}
    clearRows()
    return
  end
  path = nextPath
  entries = result
  pageIndex = 0
  render()
end

-- Initial page: the Lua backend starts at /data and never invokes a shell command.
-- If the companion QuickApp has queued a request in its private sandbox,
-- process it here and again on resume. The real mapping is target-dependent.
processBridge = function(force)
  local ok, detail = Backend.processBridge(force == true)
  navigate(path)
  return ok, detail
end
processBridge()

function ScreenStateChangedCB(pre, now, reason)
  -- Filesystem handles are closed per operation; no background timer remains here.
end

-- The current page owns no timers, animations, topics or open file handles.
-- Keep explicit lifecycle hooks so the host can pause/resume safely.
function pageOnPause()
  -- No persistent resources to pause.
end

function pageOnResume()
  -- Re-check the companion hand-off when the watchface becomes visible.
  if processBridge then processBridge() end
end
