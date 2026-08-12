-- databind.lua
-- dataman 数据订阅封装：Q24.8 解码、字符串源、统一 pause/resume
-- 兼容性：部分固件 dataman.subscribe 为 (key, obj, cb)，部分为 (key, cb)，
--         统一先尝试三参，失败退回两参；全部 pcall，订阅失败静默降级。

local okM, dataman = pcall(require, "dataman")
if not okM then dataman = nil end

local M = {}
local subs = {}

local function doSubscribe(key, obj, cb)
  if not dataman then return nil end
  local ok3, t3 = pcall(dataman.subscribe, key, obj, cb)
  if ok3 and t3 ~= nil then return t3 end
  local ok2, t2 = pcall(dataman.subscribe, key, cb)
  if ok2 and t2 ~= nil then return t2 end
  return nil
end

-- 数值型订阅（默认 Q24.8 定点，除以 256）
-- render(obj, value)：value 已解码为真实值
function M.subscribeQ(key, label, render)
  local token = doSubscribe(key, label, function(obj, raw)
    if raw == nil or raw >= 0x7FFFFFFF then return end
    local ok = pcall(function() render(obj, math.floor(raw / 256)) end)
    if not ok then
      pcall(function() render(obj, raw) end) -- 部分源直接给真实值
    end
  end)
  if token ~= nil then subs[#subs + 1] = token end
  return token
end

-- 字符串型订阅（如英文星期）
function M.subscribeString(key, label, render)
  local token = doSubscribe(key, label, function(obj, value)
    if type(value) == "string" and #value > 0 then
      pcall(function() render(obj, value) end)
    end
  end)
  if token ~= nil then subs[#subs + 1] = token end
  return token
end

-- 原始订阅
function M.subscribe(key, label, cb)
  local token = doSubscribe(key, label, cb)
  if token ~= nil then subs[#subs + 1] = token end
  return token
end

function M.pauseAll()
  for _, t in ipairs(subs) do
    pcall(function() dataman.pause(t) end)
  end
end

function M.resumeAll()
  for _, t in ipairs(subs) do
    pcall(function() dataman.resume(t) end)
  end
end

return M
