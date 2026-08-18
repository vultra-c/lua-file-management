-- scripts/smoke-watchface.lua
-- 冒烟测试：打桩 lvgl / io / os / SCRIPT_PATH，驱动安装表盘的完整 happy path
-- （固件检测 → stage 图标/收据/模块 → CPC2 INSTALL → 成功），以及不支持的固件路径。
-- 用法：lua5.4 scripts/smoke-watchface.lua
-- 说明：收据/模块是构造的“格式合法”假数据；真实签名在构建链里由 AstroBox 私钥完成。

local here = arg and arg[0]:match("^(.*)/[^/]+$") or "."
local MAIN = here .. "/../watchfaces/filemanager/main.lua"
local SCRIPT_DIR = os.getenv("SMOKE_DIR") or "/tmp/fm-smoke"

-- ---------------- 假文件系统 ----------------
local fs = {}
local function normalize(p) return p end

local function u16_le(s, o) return s:byte(o + 1) + s:byte(o + 2) * 0x100 end
local function u32_le(s, o)
  return s:byte(o + 1) + s:byte(o + 2) * 0x100 + s:byte(o + 3) * 0x10000 + s:byte(o + 4) * 0x1000000
end
local function word(v)
  return string.char(v % 0x100, math.floor(v / 0x100) % 0x100,
    math.floor(v / 0x10000) % 0x100, math.floor(v / 0x1000000) % 0x100)
end
local function half(v)
  return string.char(v % 0x100, math.floor(v / 0x100) % 0x100)
end

-- 构造 117x117 ARGB8888 图标（12 字节头 + 每像素 u32，共 54768 字节）
local W, H = 117, 117
local icon = string.char(0x19, 0x10, 0, 0) .. half(W) .. half(H) .. half(W * 4) .. half(0)
  .. string.rep(word(0xFFFFFFFF), W * H)

-- 构造假模块（>=512 字节，标准 ELF 头：e_ident@0..15，e_type@16，e_machine@18）
local module = "\127ELF" .. string.char(1, 1, 1, 0) .. string.rep("\0", 8)
  .. half(1) .. half(40) .. string.rep("\0", 512 - 24)
module = module .. string.rep("\0", 2048 - #module)

-- 构造 256 字节收据（CMI1 头部字段合法；签名区全 0）
local receipt = word(0x31494D43) .. word(1) .. word(256) .. word(0)
  .. word(0) .. word(1) .. word(#module) .. word(0)
receipt = receipt .. "file_manager" .. string.rep("\0", 32 - 12)
receipt = receipt .. "xiaomi-band-9-pro-3.1.175" .. string.rep("\0", 48 - 27)
receipt = receipt .. string.rep("\0", 256 - #receipt)
assert(#receipt == 256, "receipt must be 256 bytes")

-- 假 /dev/canopus 响应（CPC2 成功：result@28 = 5）
local cpc2_ok = word(0x43504332) .. half(36) .. half(2) .. half(1) .. half(0)
  .. word(36) .. word(2) .. word(1) .. word(0) .. word(5) .. word(0)
assert(#cpc2_ok == 36, "cpc2 response must be 36 bytes")

fs[SCRIPT_DIR .. "/appicon_filemanager.bin"] = icon
fs[SCRIPT_DIR .. "/filemanager-xiaomi-band-9-pro-3.1.175.cmi.bin"] = receipt
fs[SCRIPT_DIR .. "/filemanager-xiaomi-band-9-pro-3.1.175.bin"] = module

-- CPC2 请求写入 /dev/canopus 后，读回时给成功响应
local DEVICE = "/dev/canopus"
local fake_version = "3.1.175"
local last_status = nil

local function fake_io_open(path, mode)
  if mode == "wb" then
    return {
      write = function(_, content) fs[normalize(path)] = content return #content end,
      close = function() return true end,
    }
  end
  -- rb / r
  return {
    read = function(_, fmt)
      if path == DEVICE then
        return cpc2_ok
      end
      local content = fs[normalize(path)]
      if not content then return nil end
      if fmt == "*a" then return content end
      if type(fmt) == "number" then return content:sub(1, fmt) end
      return nil
    end,
    close = function() return true end,
  }
end

local function fake_os_execute(command)
  -- 固件检测：getprop 输出写进固定临时文件（与 main.lua 的常量一致）
  if command:match("^getprop ") then
    fs["/data/filemanager-installer-version.tmp"] = fake_version .. "\n"
  end
  return true
end

-- ---------------- 打桩 lvgl ----------------
local lvgl_stub = {
  HOR_RES = function() return 336 end,
  VER_RES = function() return 480 end,
  OPA = function(v) return v end,
  ALIGN = { CENTER = "center", TOP_MID = "top_mid" },
  Object = function() return {} end,
  Label = function(_, props)
    local self = {}
    self.set = function(_, p)
      if p.text then last_status = p.text end
    end
    return self
  end,
}
package.preload["lvgl"] = function() return lvgl_stub end

local original_io_open, original_os_execute = io.open, os.execute
io.open = fake_io_open
os.execute = fake_os_execute
os.remove = function() return true end
SCRIPT_PATH = SCRIPT_DIR .. "/"

local passed = 0
local function check(name, cond)
  if cond then
    passed = passed + 1
    print("PASS  " .. name)
  else
    print("FAIL  " .. name)
    os.exit(1)
  end
end

-- ---------------- 场景 1：happy path ----------------
last_status = nil
local ok, err = pcall(dofile, MAIN)
check("main.lua loads without error", ok and not err)
check("staged receipt written", fs["/data/canopus/inbox/file_manager.cmi"] ~= nil)
check("staged module written", fs["/data/canopus/inbox/file_manager.ko"] ~= nil)
check("icon staged to /data/canopus", fs["/data/canopus/appicon_filemanager.bin"] ~= nil)
check("status shows installed", last_status and last_status:find("Installed", 1, true) ~= nil)
print("  status: " .. tostring(last_status))

-- ---------------- 场景 2：不支持的固件 ----------------
fake_version = "9.9.9"
last_status = nil
pcall(dofile, MAIN)
check("unsupported firmware shows error", last_status and last_status:find("not supported", 1, true) ~= nil)

io.open, os.execute = original_io_open, original_os_execute
print(string.format("\n%d checks passed", passed))
