// scripts/gen-appicon.mjs
// 生成文件管理器的 launcher 图标（117×117 ARGB8888，与 Canopus 蓝牙示例
// appicon_headphones.bin 同格式：12 字节头 + w*h*4 字节像素，共 54768 字节）。
// 无依赖，纯 Node。用法：bun scripts/gen-appicon.mjs [输出路径]
//
// 头部：magic 0x19 0x10 | w u16 | h u16 | stride u16(=w*4) | reserved u16(=0)
// 像素：每个 u32 LE = A R G B（各 8bit），stride = w*4。

import { writeFileSync } from "node:fs";

const W = 117;
const H = 117;
const OUT = process.argv[2] || "watchfaces/filemanager/appicon_filemanager.bin";

const px = new Uint32Array(W * H);

const argb = (a, r, g, b) => ((a << 24) | (r << 16) | (g << 8) | b) >>> 0;

// 调色板（ARGB8888）
const BG = argb(255, 18, 42, 72); // 深蓝底
const BG_EDGE = argb(255, 12, 30, 56);
const FOLDER = argb(255, 242, 196, 66); // 米黄文件夹
const FOLDER_TAB = argb(255, 250, 214, 110);
const FOLDER_EDGE = argb(255, 168, 132, 38);
const SHEET = argb(255, 255, 255, 255); // 白色文档
const SHEET_LINE = argb(255, 128, 156, 216);

const inRoundRect = (x, y, x0, y0, w, h, r) => {
  if (x < x0 || x >= x0 + w || y < y0 || y >= y0 + h) return false;
  const cx = Math.min(Math.max(x, x0 + r), x0 + w - r - 1);
  const cy = Math.min(Math.max(y, y0 + r), y0 + h - r - 1);
  const dx = x - cx, dy = y - cy;
  return dx * dx + dy * dy <= r * r;
};

const inRect = (x, y, x0, y0, w, h) =>
  x >= x0 && x < x0 + w && y >= y0 && y < y0 + h;

for (let y = 0; y < H; y++) {
  for (let x = 0; x < W; x++) {
    let c = 0;
    // 背景圆角方块
    if (inRoundRect(x, y, 4, 4, W - 8, H - 8, 26)) {
      c = BG;
      // 边缘暗化
      if (x < 10 || y < 10 || x >= W - 10 || y >= H - 10) c = BG_EDGE;
    }
    // 文件夹：标签 + 主体
    if (inRect(x, y, 30, 30, 57, 14)) c = FOLDER_TAB;
    if (inRect(x, y, 22, 42, 73, 40)) c = FOLDER;
    // 文件夹边缘线
    if (inRect(x, y, 22, 42, 73, 40) &&
        (x === 22 || x === 94 || y === 42 || y === 81)) c = FOLDER_EDGE;
    if (inRect(x, y, 30, 30, 57, 14) &&
        (x === 30 || x === 86 || y === 30 || y === 43)) c = FOLDER_EDGE;
    // 白色文档（带折角）
    if (inRect(x, y, 40, 48, 37, 28)) c = SHEET;
    if (inRect(x, y, 40, 48, 37, 28) &&
        (x === 40 || x === 76 || y === 48 || y === 75)) c = SHEET_LINE;
    // 文档文字行
    if (inRect(x, y, 45, 55, 27, 2)) c = SHEET_LINE;
    if (inRect(x, y, 45, 61, 27, 2)) c = SHEET_LINE;
    if (inRect(x, y, 45, 67, 18, 2)) c = SHEET_LINE;
    px[y * W + x] = c;
  }
}

const header = Buffer.alloc(12);
header[0] = 0x19; header[1] = 0x10;
header.writeUInt16LE(W, 4);
header.writeUInt16LE(H, 6);
header.writeUInt16LE(W * 4, 8); // stride
header.writeUInt16LE(0, 10); // reserved

const body = Buffer.alloc(W * H * 4);
for (let i = 0; i < px.length; i++) body.writeUInt32LE(px[i], i * 4);

writeFileSync(OUT, Buffer.concat([header, body]));
console.log(`wrote ${OUT} (${12 + body.length} bytes, ${W}x${H} ARGB8888)`);
