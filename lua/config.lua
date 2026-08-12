-- config.lua
-- 设备与显示配置：小米手环 9 Pro（Vela / MiWear Lua 5.4）
-- 说明：优先读取 lvgl.HOR_RES()/VER_RES() 运行时值，此处仅作兜底。

local config = {}

config.WIDTH = 336
config.HEIGHT = 480

-- 文件管理器起始目录
config.FS_ROOT = "/"

-- 列表单页最大行数（防止对象过多导致卡顿）
config.MAX_LIST_ROWS = 200

-- 单目录最多枚举条目数（限制目录扫描 I/O 上限）
config.LIST_CAP = 300

-- 深度搜索限制
config.SEARCH_LIMIT = 60     -- 最多返回结果数
config.SEARCH_DEPTH = 8      -- 最大递归深度
config.SEARCH_SCAN_CAP = 20000 -- 最多扫描的条目数

-- 删除高危目录前缀（确认弹窗中显示强警告，仅提示不阻止）
config.DANGER_PREFIXES = {
  "/resource",
  "/misc",
  "/mode",
  "/etc",
  "/dev",
  "/data/app/system",
  "/data/system",
  "/data/app/quickapp",
  "/data/quickapp",
  "/data/app/watchface",
}

return config
