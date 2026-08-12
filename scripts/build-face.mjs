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

function listLua() {
  const dir = join(root, "lua");
  const names = readdirSync(dir)
    .filter((n) => n.endsWith(".lua"))
    .sort((a, b) => (a === "main.lua" ? -1 : b === "main.lua" ? 1 : a < b ? -1 : 1));
  return names.map((n) => {
    const data = readFileSync(join(dir, n));
    return { name: `_lua/${n}`, data };
  });
}

// ---- 预览图像素绘制（终端风格，等比缩放）----
const BG = [7, 9, 13];
const SURFACE = [15, 20, 27];
const BORDER = [34, 48, 66];
const GREEN = [55, 224, 164];
const GREEN_DIM = [30, 138, 102];
const CYAN = [76, 201, 240];
const TEXT = [230, 237, 245];
const DIM = [138, 151, 168];

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
  fill(16 * sx, 14 * sy, 46 * sx, 5 * sy, DIM); // 电量
  fill(272 * sx, 14 * sy, 52 * sx, 5 * sy, GREEN_DIM); // 品牌
  fill(140 * sx, 48 * sy, 56 * sx, 4 * sy, DIM); // 日期
  fill(104 * sx, 138 * sy, 128 * sx, 52 * sy, SURFACE); // 时间块
  fill(120 * sx, 150 * sy, 40 * sx, 18 * sy, TEXT);
  fill(166 * sx, 150 * sy, 22 * sx, 18 * sy, TEXT);
  fill(196 * sx, 150 * sy, 6 * sx, 18 * sy, GREEN_DIM);
  fill(206 * sx, 150 * sy, 28 * sx, 18 * sy, TEXT);
  fill(152 * sx, 214 * sy, 32 * sx, 4 * sy, CYAN); // 秒
  fill(20 * sx, 252 * sy, (w - 40) * sx, 1, BORDER); // 分隔线
  fill(12 * sx, 272 * sy, (w - 24) * sx, 188 * sy, SURFACE); // 终端卡片
  fill(12 * sx, 272 * sy, (w - 24) * sx, 2, GREEN_DIM); // 顶部描边
  fill(12 * sx, 458 * sy, (w - 24) * sx, 2, GREEN_DIM); // 底部描边
  fill(14 * sx, 282 * sy, 130 * sx, 4 * sy, GREEN); // 标题行
  fill(24 * sx, 308 * sy, 120 * sx, 5 * sy, TEXT); // steps
  fill(24 * sx, 336 * sy, 120 * sx, 5 * sy, TEXT); // hr
  fill(24 * sx, 364 * sy, 96 * sx, 4 * sy, DIM); // fs
  fill(26 * sx, 420 * sy, 160 * sx, 5 * sy, GREEN); // CTA
  fill((296) * sx, 420 * sy, 6 * sx, 6 * sy, GREEN); // 光标
  return px;
}

function main() {
  const cfg = loadConfig();
  const projectName = String(cfg.projectName || "watchface");
  const watchfaceId = String(cfg.watchfaceId || "");
  const files = listLua();
  if (files.length === 0) {
    console.error("error: no lua files found in lua/");
    process.exit(1);
  }

  const previewRgba = renderPreviewRgba(PREVIEW_W, PREVIEW_H);

  const { face, records, payloadEnd, previewOffset } = buildFace(files, {
    id: watchfaceId,
    title: projectName,
    previewRgba,
  });

  // 自校验：重新解析并比对
  const parsed = parseFace(face);
  if (parsed.id !== watchfaceId) throw new Error(`verify failed: id ${parsed.id} != ${watchfaceId}`);
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
  console.log(`face : ${projectName}.face  id=${watchfaceId}  files=${records.length}`);
  console.log(`preview: ${PREVIEW_W}x${PREVIEW_H} @ ${previewOffset} (${parsed.preview.blockLen} bytes, RLE ok)`);
  for (const r of records) {
    console.log(`  - ${r.name} (${r.size - 20 - r.name.length} bytes)`);
  }
  console.log("sha256:", createHash("sha256").update(face).digest("hex"));
}

main();
