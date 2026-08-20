-- DEEP_SCAN File Manager backend
--
-- The backend is intentionally plain Lua/LVGL:
--   * list/stat/read/delete real filesystem entries
--   * process an explicit request/response bridge owned by the companion QuickApp
--
-- The bridge is a filesystem hand-off, not an undocumented IPC call. The
-- QuickApp writes only to its own internal://files/ sandbox. On firmware where
-- that sandbox is mapped to /data/quickapp/file/{package}, the Lua watchface
-- can read the request, operate on system /data, and write the response there.
-- The mapping and Lua permissions must be checked on the real Band 9 Pro.
--
-- Request format (one key=value per line):
--   version=1
--   ready=1
--   id=123
--   op=LIST|READ|DELETE|PING
--   path=%2Fdata
--
-- Response format is also line based. Paths, names and text use percent
-- encoding, so this protocol does not require a JSON module on the watch.

local lvgl = require("lvgl")
local Backend = {}

Backend.BRIDGE_PROTOCOL = 1
Backend.BRIDGE_PACKAGE = "com.deepscan.velafiles"
Backend.BRIDGE_ROOT = "/data/quickapp/file/" .. Backend.BRIDGE_PACKAGE .. "/.velafiles-bridge"
Backend.BRIDGE_REQUEST = Backend.BRIDGE_ROOT .. "/request.txt"
Backend.BRIDGE_RESPONSE = Backend.BRIDGE_ROOT .. "/response.txt"
Backend.MAX_ENTRIES = 300
Backend.MAX_PREVIEW = 256

local lastRequest = nil

local function openDir(path)
  if lvgl.fs and type(lvgl.fs.open_dir) == "function" then
    local ok, dir = pcall(lvgl.fs.open_dir, path)
    if ok and dir and type(dir.read) == "function" then return dir end
  end
  return nil
end

local function openFile(path, mode)
  if lvgl.fs and type(lvgl.fs.open_file) == "function" then
    local ok, file = pcall(lvgl.fs.open_file, path, mode)
    if ok and file then return file end
  end
  if io and type(io.open) == "function" then
    local ok, file = pcall(io.open, path, mode)
    if ok and file then return file end
  end
  return nil
end

local function baseName(value)
  local name = tostring(value or ""):gsub("[\\/]+$", "")
  return name:match("([^\\/]+)$") or name
end

local function joinPath(parent, child)
  if parent == "/" then return "/" .. child end
  return parent .. "/" .. child
end

local function isDirectory(path)
  local dir = openDir(path)
  if not dir then return false end
  pcall(function() dir:close() end)
  return true
end

local function fileSize(path)
  local file = openFile(path, "r")
  if not file then return nil end
  local size = nil
  pcall(function() size = file:seek(0, "end") end)
  if type(size) ~= "number" then
    pcall(function() size = file:seek("end") end)
  end
  pcall(function() file:close() end)
  return type(size) == "number" and size or nil
end

local function printable(value, maxBytes)
  local text = tostring(value or ""):sub(1, maxBytes or Backend.MAX_PREVIEW)
  return (text:gsub("[^%g ]", "."))
end

local function normalizeProtectedPath(path)
  return tostring(path or ""):gsub("/+$", "")
end

local function isSafeSystemPath(path)
  local value = tostring(path or "")
  if value == "" or value:sub(1, 5) ~= "/data" then return false end
  if value ~= "/data" and value:sub(1, 6) ~= "/data/" then return false end
  if value:find("%z", 1, true) then return false end
  for segment in value:gmatch("[^/]+") do
    if segment == "." or segment == ".." then return false end
  end
  return true
end

function Backend.list(path, cap)
  local dir = openDir(path)
  if not dir then return nil, "cannot open directory" end

  local names, seen = {}, {}
  local limit = cap or Backend.MAX_ENTRIES
  local name = dir:read()
  while name and #names < limit do
    local clean = baseName(name)
    if clean ~= "" and clean ~= "." and clean ~= ".." and not seen[clean] then
      seen[clean] = true
      names[#names + 1] = clean
    end
    name = dir:read()
  end
  pcall(function() dir:close() end)
  table.sort(names)

  local directories, files = {}, {}
  for _, clean in ipairs(names) do
    local full = joinPath(path, clean)
    local item = {
      name = clean,
      path = full,
      isDir = isDirectory(full),
    }
    item.size = item.isDir and nil or fileSize(full)
    if item.isDir then
      directories[#directories + 1] = item
    else
      files[#files + 1] = item
    end
  end

  local result = {}
  for _, item in ipairs(directories) do result[#result + 1] = item end
  for _, item in ipairs(files) do result[#result + 1] = item end
  return result
end

function Backend.read(path, maxBytes)
  local file = openFile(path, "r")
  if not file then return nil, "cannot open file" end
  local data = nil
  pcall(function() data = file:read(maxBytes or Backend.MAX_PREVIEW) end)
  pcall(function() file:close() end)
  if type(data) ~= "string" then return nil, "cannot read file" end
  return printable(data, maxBytes or Backend.MAX_PREVIEW)
end

function Backend.delete(path)
  local protected = normalizeProtectedPath(path)
  if not path or path == "" or protected == "/" or protected == "/data" then
    return false, "refusing to delete protected path"
  end
  if type(os.remove) ~= "function" then return false, "delete API unavailable" end
  local ok, result = pcall(os.remove, path)
  if ok and result == true then return true end
  return false, tostring(result or "delete failed; directory may be non-empty")
end

-- Percent encode only bytes which are unsafe in a line protocol.
function Backend.encode(value)
  local text = tostring(value or "")
  return (text:gsub("([^%w%._%-/])", function(char)
    return string.format("%%%02X", string.byte(char))
  end))
end

function Backend.decode(value)
  local text = tostring(value or "")
  return (text:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function readAll(path)
  local file = openFile(path, "r")
  if not file then return nil end
  local data = nil
  pcall(function() data = file:read("*a") end)
  if type(data) ~= "string" then
    pcall(function() data = file:read(8192) end)
  end
  pcall(function() file:close() end)
  return data
end

local function writeAll(path, data)
  local file = openFile(path, "w")
  if not file then return false, "cannot open bridge file" end
  local ok, err = pcall(function()
    file:write(data)
    file:close()
  end)
  return ok, ok and nil or tostring(err)
end

local function parseRequest(raw)
  local request = {}
  for line in tostring(raw or ""):gmatch("[^\r\n]+") do
    local key, value = line:match("^([%w_]+)=(.*)$")
    if key then request[key] = value end
  end
  request.version = request.version or "0"
  request.ready = request.ready or ""
  request.op = tostring(request.op or ""):upper()
  request.path = Backend.decode(request.path or "/data")
  request.id = Backend.decode(request.id or "0")
  return request
end

local function responseHeader(request, status)
  return {
    "version=" .. tostring(Backend.BRIDGE_PROTOCOL),
    "id=" .. Backend.encode(request.id),
    "status=" .. Backend.encode(status),
    "op=" .. Backend.encode(request.op),
    "path=" .. Backend.encode(request.path),
  }
end

local function markConsumed(request)
  return writeAll(Backend.BRIDGE_REQUEST, table.concat({
    "version=" .. tostring(Backend.BRIDGE_PROTOCOL),
    "consumed=" .. Backend.encode(request.id),
    "\n",
  }, "\n"))
end

function Backend.processBridge()
  local raw = readAll(Backend.BRIDGE_REQUEST)
  if type(raw) ~= "string" or raw == "" then
    return false, "no request"
  end

  local request = parseRequest(raw)
  if request.version ~= tostring(Backend.BRIDGE_PROTOCOL) or request.ready ~= "1" then
    return false, "request not ready"
  end
  if raw == lastRequest then return false, "request already processed" end
  lastRequest = raw

  local lines = responseHeader(request, "error")
  local validPath = isSafeSystemPath(request.path)

  if request.op == "PING" then
    lines[3] = "status=ok"
    lines[#lines + 1] = "backend=lua"
    lines[#lines + 1] = "protocol=" .. tostring(Backend.BRIDGE_PROTOCOL)
    lines[#lines + 1] = "mapping=" .. Backend.encode(Backend.BRIDGE_ROOT)
  elseif not validPath then
    lines[#lines + 1] = "error=" .. Backend.encode("unsafe path")
  elseif request.op == "LIST" then
    local entries, err = Backend.list(request.path)
    if entries then
      lines[3] = "status=ok"
      lines[#lines + 1] = "count=" .. tostring(#entries)
      for _, item in ipairs(entries) do
        lines[#lines + 1] = table.concat({
          "item=" .. (item.isDir and "D" or "F"),
          Backend.encode(item.name),
          tostring(item.size or ""),
        }, "|")
      end
    else
      lines[#lines + 1] = "error=" .. Backend.encode(err or "list failed")
    end
  elseif request.op == "READ" then
    local text, err = Backend.read(request.path, Backend.MAX_PREVIEW)
    if text then
      lines[3] = "status=ok"
      lines[#lines + 1] = "text=" .. Backend.encode(text)
      lines[#lines + 1] = "size=" .. tostring(fileSize(request.path) or "")
    else
      lines[#lines + 1] = "error=" .. Backend.encode(err or "read failed")
    end
  elseif request.op == "DELETE" then
    local ok, err = Backend.delete(request.path)
    lines[3] = ok and "status=ok" or "status=error"
    if not ok then lines[#lines + 1] = "error=" .. Backend.encode(err) end
  else
    lines[#lines + 1] = "error=unknown operation"
  end

  local ok, err = writeAll(Backend.BRIDGE_RESPONSE, table.concat(lines, "\n") .. "\n")
  if not ok then return false, err or "response write failed" end

  -- A consumed marker prevents replay after a Lua state restart. The next
  -- QuickApp request overwrites this file with a fresh ready=1 payload.
  local consumed, consumeErr = markConsumed(request)
  if not consumed then return false, consumeErr or "request acknowledge failed" end
  return true, request.op
end

FileManagerBackend = Backend
