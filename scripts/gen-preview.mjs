// scripts/gen-preview.mjs
// 生成表盘预览图 watchface/fprj/images/preview.png（336x480）
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

const BG = [7, 9, 13];
const SURFACE = [15, 20, 27];
const BORDER = [34, 48, 66];
const GREEN = [55, 224, 164];
const GREEN_DIM = [30, 138, 102];
const CYAN = [76, 201, 240];
const TEXT = [230, 237, 245];
const DIM = [138, 151, 168];
const FAINT = [85, 98, 122];
const RED = [255, 92, 92];

function fill(x0, y0, w, h, [r, g, b], a = 255) {
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      if (x < 0 || y < 0 || x >= W || y >= H) continue;
      const i = (y * W + x) * 4;
      px[i] = r; px[i + 1] = g; px[i + 2] = b; px[i + 3] = a;
    }
  }
}

// 圆角矩形（简易：只画内部区域，四角像素保持背景）
function fillRound(x0, y0, w, h, color, radius = 12) {
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      const dx = x < x0 + radius ? x0 + radius - x : x >= x0 + w - radius ? x - (x0 + w - radius) : 0;
      const dy = y < y0 + radius ? y0 + radius - y : y >= y0 + h - radius ? y - (y0 + h - radius) : 0;
      if (dx * dx + dy * dy > radius * radius) continue;
      const i = (y * W + x) * 4;
      px[i] = color[0]; px[i + 1] = color[1]; px[i + 2] = color[2]; px[i + 3] = 255;
    }
  }
}

// ---- 背景 ----
fill(0, 0, W, H, BG);

// ---- 顶部状态栏 ----
fill(16, 14, 46, 5, DIM);            // 电量
fill(272, 14, 52, 5, GREEN_DIM);     // DEEP_SCAN

// ---- 日期带 ----
fill(140, 48, 56, 4, DIM);

// ---- 时间带（大号） ----
fillRound(104, 138, 128, 52, SURFACE, 8);
fill(120, 150, 40, 18, TEXT);
fill(166, 150, 22, 18, TEXT);
fill(196, 150, 6, 18, GREEN_DIM);    // 冒号
fill(206, 150, 28, 18, TEXT);

// ---- 秒 ----
fill(152, 214, 32, 4, CYAN);

// ---- 分隔线 ----
fill(20, 252, W - 40, 1, BORDER);

// ---- 终端卡片 ----
fillRound(12, 272, W - 24, 188, SURFACE, 12);
fill(12, 272, W - 24, 1, GREEN_DIM);       // 顶部描边
fill(12, 459, W - 24, 1, GREEN_DIM);       // 底部描边
fill(14, 282, 130, 4, GREEN);              // 标题行
fill(24, 308, 120, 5, TEXT);               // steps
fill(24, 336, 120, 5, TEXT);               // hr
fill(24, 364, 96, 4, DIM);                 // fs
fill(26, 420, 160, 5, GREEN);              // CTA
fill(296, 420, 6, 6, GREEN);               // 光标

// ---- 文件管理器小示意（底部提示区背景留空即可） ----

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
