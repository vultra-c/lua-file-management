// scripts/gen-preview.mjs
// 生成表盘预览图 watchface/fprj/images/preview.png（336x480）
// 与 lua/main.lua 的简洁浅色文件管理器界面一致。
// 纯 Node 实现（zlib 内置），无需第三方依赖：
//   bun scripts/gen-preview.mjs
// 或 node scripts/gen-preview.mjs

import { deflateSync } from "node:zlib";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const W = 336;
const H = 480;
const px = Buffer.alloc(W * H * 4, 0);

// 与 lua/main.lua 的原生深色配色一致（RGBA 字节序）
const BG = [0, 0, 0];
const SURFACE = [17, 17, 19];
const TEXT = [255, 255, 255];
const DIM = [142, 142, 147];
const ACCENT = [10, 132, 255];
const DESTRUCTIVE = [255, 69, 58];
const DESTRUCTIVE_BG = [42, 17, 20];
const SEP = [28, 28, 30];
const BTN = [28, 28, 30];
const FILE_ICON = [58, 58, 60];

function fill(x0, y0, w, h, [r, g, b], a = 255) {
  for (let y = Math.max(0, y0); y < Math.min(H, y0 + h); y++) {
    for (let x = Math.max(0, x0); x < Math.min(W, x0 + w); x++) {
      const i = (y * W + x) * 4;
      px[i] = r; px[i + 1] = g; px[i + 2] = b; px[i + 3] = a;
    }
  }
}

// 圆角矩形（四角像素不绘制）
function fillRound(x0, y0, w, h, color, radius = 12) {
  for (let y = Math.max(0, y0); y < Math.min(H, y0 + h); y++) {
    for (let x = Math.max(0, x0); x < Math.min(W, x0 + w); x++) {
      const dx = x < x0 + radius ? x0 + radius - x : x >= x0 + w - radius ? x - (x0 + w - radius) : 0;
      const dy = y < y0 + radius ? y0 + radius - y : y >= y0 + h - radius ? y - (y0 + h - radius) : 0;
      if (dx * dx + dy * dy > radius * radius) continue;
      const i = (y * W + x) * 4;
      px[i] = color[0]; px[i + 1] = color[1]; px[i + 2] = color[2]; px[i + 3] = 255;
    }
  }
}

// 简易像素字形（5x7 点阵，用于 < > i / 等小图标）
function glyph(px0, py0, rows, color) {
  for (let r = 0; r < rows.length; r++) {
    const line = rows[r];
    for (let c = 0; c < line.length; c++) {
      if (line[c] === "1") fill(px0 + c, py0 + r, 1, 1, color);
    }
  }
}

const G_LT = ["00100", "01100", "11000", "01100", "00100"];
const G_GT = ["00100", "00011", "00001", "00011", "00100"];
const G_I = ["111", "010", "010", "010", "111"];

// ---- 背景 ----
fill(0, 0, W, H, BG);

// ---- 顶部标题栏（原生深色）----
fill(0, 0, W, 64, BG);
fill(0, 64, W, 1, SEP);
glyph(14, 26, G_LT, TEXT);            // < 返回
fill(52, 14, 40, 12, TEXT);           // Files 标题
fill(52, 36, 190, 8, DIM);            // 路径面包屑
glyph(296, 26, G_I, DIM);             // i 信息

// ---- 列表行：图标 + 名称 + Delete ----
const rows = [true, false, false, true, false, false];
const listTop = 68;
const rowH = 56;
for (let i = 0; i < rows.length; i++) {
  const y = listTop + i * rowH;
  fill(20, y + rowH - 1, W - 40, 1, SEP);          // 分隔线
  if (rows[i]) {
    fill(20, y + 21, 8, 4, ACCENT);                // 文件夹凸起
    fillRound(20, y + 24, 20, 14, ACCENT, 3);      // 文件夹主体
  } else {
    fillRound(23, y + 19, 14, 18, FILE_ICON, 2);   // 文件
  }
  fill(48, y + 20, 150, 14, TEXT);                 // 名称
  fillRound(W - 88, y + 12, 72, 32, DESTRUCTIVE_BG, 16); // Delete 底
  fill(W - 71, y + 21, 38, 12, DESTRUCTIVE);       // Delete 文字
}

// ---- 底栏：条目统计 + 分页 ----
fill(0, 436, W, 1, SEP);
fill(16, 452, 150, 6, DIM);                        // 统计
fillRound(W - 140, 442, 38, 32, BTN, 16);          // prev
glyph(W - 124, 456, G_LT, DIM);
fill(W - 98, 450, 44, 8, DIM);                     // 页码
fillRound(W - 54, 442, 38, 32, BTN, 16);           // next
glyph(W - 38, 456, G_GT, DIM);

// ---- PNG 编码 ----
function crc32(buf) {
  let table = crc32.table;
  if (!table) {
    table = crc32.table = new Int32Array(256);
    for (let n = 0; n < 256; n++) {
      let c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      table[n] = c;
    }
  }
  let c = -1;
  for (let i = 0; i < buf.length; i++) c = table[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ -1) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type, "ascii"), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(td));
  return Buffer.concat([len, td, crc]);
}

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(W, 0);
ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8;  // bit depth
ihdr[9] = 6;  // color type RGBA
ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

const raw = Buffer.alloc(H * (1 + W * 4));
for (let y = 0; y < H; y++) {
  raw[y * (1 + W * 4)] = 0; // filter none
  px.copy(raw, y * (1 + W * 4) + 1, y * W * 4, (y + 1) * W * 4);
}

const png = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk("IHDR", ihdr),
  chunk("IDAT", deflateSync(raw, { level: 9 })),
  chunk("IEND", Buffer.alloc(0)),
]);

const out = join(dirname(fileURLToPath(import.meta.url)), "..", "watchface", "fprj", "images", "preview.png");
mkdirSync(dirname(out), { recursive: true });
writeFileSync(out, png);
console.log("written:", out, `(${png.length} bytes)`);
