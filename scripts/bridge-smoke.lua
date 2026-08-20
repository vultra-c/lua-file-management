-- scripts/bridge-smoke.lua
-- Offline test for the QuickApp internal-file -> Lua /data bridge.
-- The mock filesystem never touches the host filesystem.

local failures = 0
local files = {
  ["/data/hello.txt"] = "hello from system data",
}
local directories = {
  ["/data"] = { "quickapp", "hello.txt" },
  ["/data/quickapp"] = {},
}

local function check(condition, message)
  if condition then
    print("  PASS " .. message)
  else
    print("  FAIL " .. message)
    failures = failures + 1
  end
end

local function openDir(path)
  local names = directories[path]
  if not names then return nil end
  local index = 0
  return {
    read = function()
      index = index + 1
      return names[index]
    end,
    close = function() end,
  }
end

local function openFile(path, mode)
  if mode == "r" and files[path] == nil then return nil end
  if mode == "w" and files[path] == nil then files[path] = "" end
  if files[path] == nil then return nil end
  local cursor = 1
  return {
    read = function(_, amount)
      local value = files[path] or ""
      if amount == "*a" then return value end
      if type(amount) == "number" then
        local result = value:sub(cursor, cursor + amount - 1)
        cursor = cursor + #result
        return result
      end
      return value
    end,
    seek = function(_, offset, whence)
      local value = files[path] or ""
      if whence == "end" or offset == "end" then return #value end
      return 0
    end,
    write = function(_, value)
      files[path] = tostring(value)
      return #files[path]
    end,
    close = function() end,
  }
end

package.loaded.lvgl = {
  fs = {
    open_dir = openDir,
    open_file = openFile,
  },
}

dofile("lua/backend.lua")
local Backend = FileManagerBackend
local request = Backend.BRIDGE_REQUEST
local response = Backend.BRIDGE_RESPONSE

local function queue(id, op, path)
  files[request] = table.concat({
    "version=1",
    "id=" .. Backend.encode(id),
    "op=" .. op,
    "path=" .. Backend.encode(path),
    "ready=1",
  }, "\n") .. "\n"
  local ok, detail = Backend.processBridge()
  check(ok, op .. " request processed (" .. tostring(detail) .. ")")
  return files[response] or ""
end

print("== Bridge phase 1: PING ==")
local ping = queue("ping-1", "PING", "/data")
check(ping:find("status=ok", 1, true) ~= nil, "PING returns ok")
check(ping:find("protocol=1", 1, true) ~= nil, "protocol version is present")
check((files[request] or ""):find("consumed=ping%-1") ~= nil, "request is marked consumed")

print("== Bridge phase 2: LIST ==")
local listing = queue("list-1", "LIST", "/data")
check(listing:find("item=D|quickapp|", 1, true) ~= nil, "LIST returns directory item")
check(listing:find("item=F|hello.txt|", 1, true) ~= nil, "LIST returns file item")

print("== Bridge phase 3: READ ==")
local read = queue("read-1", "READ", "/data/hello.txt")
check(read:find("status=ok", 1, true) ~= nil, "READ returns ok")
check(read:find("text=hello%%20from%%20system%%20data") ~= nil, "READ returns encoded text")

print("== Bridge phase 4: path safety ==")
local unsafe = queue("unsafe-1", "LIST", "/data/../etc")
check(unsafe:find("unsafe%20path", 1, true) ~= nil, "path traversal is rejected")

if failures > 0 then
  print(string.format("\n%d bridge checks failed", failures))
  os.exit(1)
end
print("\nAll bridge checks passed")
