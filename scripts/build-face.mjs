// scripts/build-face.mjs
// 把 lua/ 目录源码打包为 Vela Lua 表盘 .face（小米手环 9 Pro / Band 8 Pro / Watch S3 等）
// 用法：bun scripts/build-face.mjs            （读 watchface.config.json，输出 bin/）
// 产物：bin/<projectName>.face + bin/resource.bin（模拟器安装用，与 LuaDevTemplate 一致）
// 依赖：Node 18+ / Bun，无第三方包。

import { readFileSync, readdirSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { createHash } from "node:crypto";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import {
  buildFace,
  parseFace,
  decodeRLEv10,
  buildPreviewBlock,
  PREVIEW_W,
  PREVIEW_H,
} from "./face-lib.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

function loadConfig() {
  return JSON.parse(readFileSync(join(root, "watchface.config.json"), "utf8"));
}

// 原生应用注入载荷：payload/module.ko 存在时，作为字节串嵌入到入口脚本头部。
// 生成一个全局 PAYLOAD（Lua 字符串字面量，逐字节 \xNN 转义，避免引号/反斜杠问题）。
function payloadChunk() {
  const p = join(root, "payload", "module.ko");
  if (!existsSync(p)) {
    return "-- no embedded native payload (drop payload/module.ko to embed)\nPAYLOAD = nil\n";
  }
  const buf = readFileSync(p);
  let esc = "";
  for (const b of buf) esc += "\\x" + b.toString(16).padStart(2, "0");
  return `-- embedded native payload (${buf.length} bytes)\nPAYLOAD = "${esc}"\n`;
}

// 单文件入口：lua/main.lua → _lua/<slug>/<slug>.lua（与官方 9 Pro 样本 / Monika 一致）
function listLuaFiles(projectName) {
  const slug = String(projectName || "watchface").toLowerCase();
  const src = readFileSync(join(root, "lua", "main.lua"));
  const data = Buffer.concat([Buffer.from(payloadChunk(), "utf8"), src]);
  return [{ name: `_lua/${slug}/${slug}.lua`, data }];
}

// ---- 预览图像素绘制（原生深色系统 UI 风格，等比缩放）----
// 与 lua/main.lua 的深色扁平列表保持一致
const BG = [0, 0, 0]; // 0x000000
const SURFACE = [17, 17, 19]; // 0x111113
const TEXT = [255, 255, 255]; // 0xFFFFFF
const DIM = [142, 142, 147]; // 0x8E8E93
const ACCENT = [10, 132, 255]; // 0x0A84FF
const DESTRUCTIVE = [255, 69, 58]; // 0xFF453A
const DESTRUCTIVE_BG = [42, 17, 20]; // 0x2A1114
const SEP = [28, 28, 30]; // 0x1C1C1E
const BTN = [28, 28, 30]; // 0x1C1C1E
const FILE_ICON = [58, 58, 60]; // 0x3A3A3C

function renderPreviewRgba(w, h) {
  const px = Buffer.alloc(w * h * 4, 0);
  const fill = (x0, y0, fw, fh, [r, g, b], a = 255) => {
    const X1 = Math.max(0, Math.round(x0));
    const Y1 = Math.max(0, Math.round(y0));
    const X2 = Math.min(w, Math.round(x0 + fw));
    const Y2 = Math.min(h, Math.round(y0 + fh));
    for (let y = Y1; y < Y2; y++) {
      for (let x = X1; x < X2; x++) {
        const i = (y * w + x) * 4;
        px[i] = b; // BGR(A)：蓝在前（与官方 9 Pro 预览一致）
        px[i + 1] = g;
        px[i + 2] = r;
        px[i + 3] = a;
      }
    }
  };
  // 坐标按 336x480 设计图等比映射
  const sx = w / 336;
  const sy = h / 480;

  fill(0, 0, w, h, BG);

  // 顶部标题栏：返回 < + Files + 路径面包屑 + i
  fill(0, 0, w, 64 * sy, BG);
  fill(0, 64 * sy, w, 1, SEP);
  fill(18 * sx, 26 * sy, 12 * sx, 10 * sy, TEXT); // <
  fill(52 * sx, 14 * sy, 40 * sx, 12 * sy, TEXT); // Files
  fill(52 * sx, 36 * sy, 190 * sx, 8 * sy, DIM);  // 路径
  fill(300 * sx, 28 * sy, 8 * sx, 8 * sy, DIM);   // i

  // 行：图标 + 名称 + 右 Delete
  const rowKinds = [true, false, false, true, false, false];
  const rowH = 56 * sy;
  const listTop = 68 * sy;
  for (let i = 0; i < rowKinds.length; i++) {
    const y = listTop + i * rowH;
    fill(20 * sx, y + rowH - 1, w - 40 * sx, 1, SEP); // 分隔线
    if (rowKinds[i]) {
      fill(20 * sx, y + 21 * sy, 8 * sx, 4 * sy, ACCENT);       // 文件夹凸起
      fill(20 * sx, y + 24 * sy, 20 * sx, 14 * sy, ACCENT);     // 文件夹主体
    } else {
      fill(23 * sx, y + 19 * sy, 14 * sx, 18 * sy, FILE_ICON);  // 文件
    }
    fill(48 * sx, y + 20 * sy, 150 * sx, 14 * sy, TEXT);        // 名称
    fill(w - 88 * sx, y + 12 * sy, 72 * sx, 32 * sy, DESTRUCTIVE_BG); // Delete 底
    fill(w - 71 * sx, y + 21 * sy, 38 * sx, 12 * sy, DESTRUCTIVE);    // Delete 文字
  }

  // 底栏：条目统计 + 分页
  fill(0, 436 * sy, w, 1, SEP);
  fill(16 * sx, 452 * sy, 150 * sx, 6 * sy, DIM);               // 统计
  fill(w - 140 * sx, 442 * sy, 38 * sx, 32 * sy, BTN);          // prev
  fill(w - 98 * sx, 450 * sy, 44 * sx, 8 * sy, DIM);            // 页码
  fill(w - 54 * sx, 442 * sy, 38 * sx, 32 * sy, BTN);           // next

  return px;
}

function main() {
  const cfg = loadConfig();
  const projectName = String(cfg.projectName || "watchface");
  const watchfaceId = String(cfg.watchfaceId || "");
  const files = listLuaFiles(projectName);
  if (files.length === 0) {
    console.error("error: no lua files found in lua/");
    process.exit(1);
  }

  const previewRgba = renderPreviewRgba(PREVIEW_W, PREVIEW_H);

  const luaEntryIndex = 0; // 入口文件是唯一文件，位于 TOC 索引 0
  const { face, records, payloadEnd, previewOffset } = buildFace(files, {
    id: watchfaceId,
    title: projectName,
    previewRgba,
    luaEntryIndex,
  });

  // 自校验：重新解析并比对
  const parsed = parseFace(face);
  if (parsed.id !== watchfaceId) throw new Error(`verify failed: id ${parsed.id} != ${watchfaceId}`);
  if (parsed.luaEntryIndex !== luaEntryIndex) throw new Error(`verify failed: luaEntryIndex ${parsed.luaEntryIndex} != ${luaEntryIndex}`);
  if (parsed.previewOffset !== previewOffset) throw new Error(`verify failed: preview offset`);
  if (!parsed.preview) throw new Error(`verify failed: preview block missing/invalid`);
  if (parsed.preview.width !== PREVIEW_W || parsed.preview.height !== PREVIEW_H)
    throw new Error(`verify failed: preview dims ${parsed.preview.width}x${parsed.preview.height}`);
  if (parsed.files.length !== files.length) throw new Error(`verify failed: file count ${parsed.files.length}`);
  for (let i = 0; i < files.length; i++) {
    const a = files[i];
    const b = parsed.files[i];
    if (a.name !== b.name || !a.data.equals(b.data)) throw new Error(`verify failed: file ${a.name}`);
  }
  // 预览块 RLE 自校验：解压后像素数应等于 w*h
  const pBuf = face.subarray(previewOffset, previewOffset + parsed.preview.blockLen);
  const dataLen = pBuf.readUInt32LE(8);
  const stream = pBuf.subarray(20, 20 + dataLen - 8); // 单一 RLEv10 流，无帧头
  const dec = decodeRLEv10(stream, PREVIEW_W * PREVIEW_H, 4);
  const nonEmpty = dec.some((v) => v !== 0);
  if (!nonEmpty) throw new Error("verify failed: preview decoded empty");

  const outDir = join(root, "bin");
  mkdirSync(outDir, { recursive: true });
  const facePath = join(outDir, `${projectName}.face`);
  const resourcePath = join(outDir, "resource.bin");
  writeFileSync(facePath, face);
  writeFileSync(resourcePath, face);

  console.log("built:", facePath, `(${face.length} bytes)`);
  console.log("copy :", resourcePath);
  console.log(`face : ${projectName}.face  id=${watchfaceId}  files=${records.length}  luaEntryIndex=${luaEntryIndex}`);
  console.log(`preview: ${PREVIEW_W}x${PREVIEW_H} @ ${previewOffset} (${parsed.preview.blockLen} bytes, RLE ok)`);
  for (const r of records) {
    console.log(`  - ${r.name} (${r.size - 20 - r.name.length} bytes)`);
  }
  console.log("sha256:", createHash("sha256").update(face).digest("hex"));
}

main();
