// scripts/build-face.mjs
// 把 lua/ 目录源码打包为 Vela Lua 表盘 .face（小米手环 9 Pro / Band 8 Pro / Watch S3 等）
// 用法：bun scripts/build-face.mjs            （读 watchface.config.json，输出 bin/）
// 产物：bin/<projectName>.face + bin/resource.bin（模拟器安装用，与 LuaDevTemplate 一致）
// 依赖：Node 18+ / Bun，无第三方包。

import { readFileSync, readdirSync, writeFileSync, mkdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import {
  buildFace,
  parseFace,
  decodeRLEv11,
  buildPreviewBlock,
  PREVIEW_W,
  PREVIEW_H,
} from "./face-lib.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

function loadConfig() {
  return JSON.parse(readFileSync(join(root, "watchface.config.json"), "utf8"));
}

// 单文件入口：lua/main.lua → _lua/<slug>/<slug>.lua（与官方 9 Pro 样本 / Monika 一致）
function listLuaFiles(projectName) {
  const slug = String(projectName || "watchface").toLowerCase();
  const data = readFileSync(join(root, "lua", "main.lua"));
  return [{ name: `_lua/${slug}/${slug}.lua`, data }];
}

// ---- 预览图像素绘制（简洁文件管理器风格，等比缩放）----
// 与 lua/main.lua 的浅色主题保持一致
const BG = [246, 247, 249]; // 0xF6F7F9
const HEADER = [255, 255, 255]; // 0xFFFFFF
const TEXT = [27, 31, 39]; // 0x1B1F27
const DIM = [138, 148, 166]; // 0x8A94A6
const DIR = [31, 111, 235]; // 0x1F6FEB
const DEL = [229, 72, 77]; // 0xE5484D
const DEL_BG = [252, 233, 234]; // 0xFCE9EA
const SEP = [230, 233, 239]; // 0xE6E9EF

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
        px[i] = r;
        px[i + 1] = g;
        px[i + 2] = b;
        px[i + 3] = a;
      }
    }
  };
  // 坐标按 336x480 设计图等比映射
  const sx = w / 336;
  const sy = h / 480;

  fill(0, 0, w, h, BG);

  // 顶部白色标题栏：返回 / 路径 / 首页
  fill(0, 0, w, 56 * sy, HEADER);
  fill(0, 56 * sy, w, 1, SEP);
  fill(24 * sx, 22 * sy, 12 * sx, 16 * sy, DIR); // <
  fill(300 * sx, 22 * sy, 12 * sx, 16 * sy, DIR); // /
  fill(56 * sx, 26 * sy, 224 * sx, 10 * sy, TEXT); // 路径

  // 文件/文件夹行：左名称 + 右 DEL 按钮 + 分隔线
  const rows = [
    { dir: true }, // app/
    { dir: false }, // notes.txt
    { dir: false }, // report.txt
    { dir: true }, // config/
    { dir: false }, // data.json
  ];
  const rowH = 50 * sy;
  const listTop = 62 * sy;
  for (let i = 0; i < rows.length; i++) {
    const y = listTop + i * rowH;
    const c = rows[i].dir ? DIR : TEXT;
    fill(20 * sx, y + 16 * sy, 150 * sx, 14 * sy, c); // 名称
    fill(260 * sx, y + 10 * sy, 56 * sx, rowH - 20 * sy, DEL_BG); // DEL 底
    fill(266 * sx, y + 17 * sy, 44 * sx, 12 * sy, DEL); // DEL 文字
    fill(16 * sx, y + rowH - 1, w - 32 * sx, 1, SEP); // 分隔线
  }

  // 底部分页：上一页 / 页码 / 下一页
  fill(8 * sx, 422 * sy, 90 * sx, 34 * sy, HEADER);
  fill(238 * sx, 422 * sy, 90 * sx, 34 * sy, HEADER);
  fill(120 * sx, 434 * sy, 96 * sx, 10 * sy, DIM);

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
  const cpr = pBuf.subarray(20, 20 + dataLen - 8);
  const stream = cpr.subarray(5);
  const dec = decodeRLEv11(stream, PREVIEW_W * PREVIEW_H, 4);
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
