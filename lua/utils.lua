-- utils.lua
-- 通用工具：常量读取、安全调用、路径、格式化

local utils = {}

-- HOR_RES / VER_RES 在部分脚本中是函数、部分是数值
function utils.constValue(v)
  if type(v) == "function" then return v() end
  return v
end

-- 安全调用：返回 ok, a, b（pcall 包装）
function utils.call(fn, ...)
  local ok, a, b = pcall(fn, ...)
  if ok then return true, a, b end
  return false, a
end

-- 路径拼接
function utils.join(base, name)
  if base == "/" then return "/" .. name end
  return base .. "/" .. name
end

-- 父目录；根目录返回 nil
function utils.parent(path)
  if not path or path == "/" then return nil end
  local p = path:match("^(.*)/[^/]+$")
  if not p or p == "" then return "/" end
  return p
end

-- Q24.8 定点解码；无效值（整数最大值）返回 nil
function utils.q24(raw)
  if raw == nil then return nil end
  if raw >= 0x7FFFFFFF then return nil end
  return math.floor(raw / 256)
end

-- 数字位解码：兼容"纯数字(0-9)"与"Q24.8(0-2304)"两种形态
function utils.digit(raw)
  if raw == nil then return nil end
  if raw >= 0x7FFFFFFF then return nil end
  if raw < 100 then return math.floor(raw) end
  return math.floor(raw / 256)
end

-- 千分位格式化
function utils.thousands(v)
  v = math.floor(v)
  local s = tostring(v)
  local out = {}
  local len = #s
  for i = 1, len do
    out[#out + 1] = s:sub(i, i)
    if (len - i) % 3 == 0 and i < len then
      out[#out + 1] = ","
    end
  end
  return table.concat(out)
end

-- 人类可读文件大小
function utils.humanSize(bytes)
  if not bytes or bytes < 0 then return "" end
  if bytes < 1024 then return tostring(bytes) .. " B" end
  if bytes < 1024 * 1024 then
    return string.format("%.1f KB", bytes / 1024)
  end
  if bytes < 1024 * 1024 * 1024 then
    return string.format("%.1f MB", bytes / (1024 * 1024))
  end
  return string.format("%.1f GB", bytes / (1024 * 1024 * 1024))
end

-- 左侧截断：保留尾部 max 个字符（用于长路径显示）
function utils.ltruncate(s, max)
  s = tostring(s or "")
  if #s <= max then return s end
  return "..." .. s:sub(#s - max + 4)
end

return utils
