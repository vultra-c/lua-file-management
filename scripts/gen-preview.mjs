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

// 与 lua/main.lua 的浅色配色一致（RGBA 字节序）
const BG = [244, 245, 247];
const CARD = [255, 255, 255];
const TEXT = [27, 32, 41];
const DIM = [138, 148, 166];
const DIR = [47, 111, 237];
const FILE = [58, 69, 84];
const DEL = [229, 72, 77];
const DEL_BG = [253, 235, 236];
const SEP = [233, 237, 242];
const BTN = [238, 241, 245];

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

// ---- 顶部标题栏 ----
fill(0, 0, W, 56, CARD);
fill(0, 56, W, 1, SEP);
glyph(16, 24, G_LT, DIR);            // < 返回
fill(52, 25, 190, 8, TEXT);          // 路径文字条
glyph(296, 24, G_I, DIR);            // i 信息

// ---- 列表行：圆点 + 名称 + DEL 按钮 ----
const rows = [
  { dir: true },
  { dir: false },
  { dir: false },
  { dir: true },
  { dir: false },
  { dir: false },
];
const listTop = 62;
const rowH = 56;
for (let i = 0; i < rows.length; i++) {
  const y = listTop + i * rowH + 5;
  fillRound(12, y, W - 24, 46, CARD, 12);
  // 左侧圆点
  fillRound(28, y + 19, 8, 8, rows[i].dir ? DIR : FILE, 4);
  // 名称条
  fill(44, y + 15, 150, 16, rows[i].dir ? DIR : FILE);
  // 右侧 DEL 按钮
  fillRound(W - 74, y + 8, 52, 30, DEL_BG, 10);
  fill(W - 62, y + 17, 28, 12, DEL);
}

// ---- 底栏：上一页 / 页码 / 下一页 ----
fill(0, 416, W, 1, SEP);
fill(0, 417, W, 63, CARD);
fillRound(12, 426, 44, 30, BTN, 15);
glyph(28, 437, G_LT, DIM);
fillRound(W - 56, 426, 44, 30, BTN, 15);
glyph(W - 40, 437, G_GT, DIM);
fill(146, 436, 44, 8, DIM);          // 页码 "1 / 2"
fill(16, 460, W - 32, 6, DIM);       // 状态行

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
