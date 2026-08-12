-- databind.lua
-- dataman 数据订阅封装：Q24.8 解码、字符串源、统一 pause/resume

local dataman = require("dataman")

local M = {}
local subs = {}

-- 数值型订阅（默认 Q24.8 定点，除以 256）
-- render(obj, value)：value 已解码为真实值
function M.subscribeQ(key, label, render)
  local token = dataman.subscribe(key, label, function(obj, raw)
    if raw == nil or raw >= 0x7FFFFFFF then return end
    render(obj, math.floor(raw / 256))
  end)
  subs[#subs + 1] = token
end

-- 字符串型订阅（如英文星期）
function M.subscribeString(key, label, render)
  local token = dataman.subscribe(key, label, function(obj, value)
    if type(value) == "string" and #value > 0 then
      render(obj, value)
    end
  end)
  subs[#subs + 1] = token
end

-- 原始订阅
function M.subscribe(key, label, cb)
  local token = dataman.subscribe(key, label, cb)
  subs[#subs + 1] = token
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
