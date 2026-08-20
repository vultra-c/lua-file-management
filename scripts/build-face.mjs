// scripts/build-face.mjs
// 把 lua/backend.lua + lua/main.lua 打包为 Vela Lua 表盘 .face。
// 入口脚本会把 backend.lua 前置嵌入，避免设备端依赖 package.path。
// 用法：bun scripts/build-face.mjs
// 产物：bin/<projectName>.face + bin/resource.bin
// 依赖：Node 18+ / Bun，无第三方包。

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import {
  buildFace,
  parseFace,
  decodeRLEv10,
  PREVIEW_W,
  PREVIEW_H,
} from "./face-lib.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

function loadConfig() {
  return JSON.parse(readFileSync(join(root, "watchface.config.json"), "utf8"));
}

function listLuaFiles(projectName) {
  const slug = String(projectName || "watchface").toLowerCase();
  const backend = readFileSync(join(root, "lua", "backend.lua"));
  const main = readFileSync(join(root, "lua", "main.lua"));
  const entry = Buffer.concat([
    Buffer.from("-- embedded Lua filesystem backend\n", "utf8"),
    backend,
    Buffer.from("\n-- watchface UI entry\n", "utf8"),
    main,
  ]);
  return [
    { name: `_lua/${slug}/${slug}.lua`, data: entry },
    { name: `_lua/${slug}/backend.lua`, data: backend },
  ];
}

// ---- 336x480 preview image ----
const BG = [0, 0, 0];
const TEXT = [255, 255, 255];
const DIM = [142, 142, 147];
const ACCENT = [10, 132, 255];
const DESTRUCTIVE = [255, 69, 58];
const DESTRUCTIVE_BG = [42, 17, 20];
const SEP = [28, 28, 30];
const BTN = [28, 28, 30];
const FILE_ICON = [58, 58, 60];

function renderPreviewRgba(width, height) {
  const pixels = Buffer.alloc(width * height * 4, 0);
  const fill = (x0, y0, fw, fh, [r, g, b], alpha = 255) => {
    const x1 = Math.max(0, Math.round(x0));
    const y1 = Math.max(0, Math.round(y0));
    const x2 = Math.min(width, Math.round(x0 + fw));
    const y2 = Math.min(height, Math.round(y0 + fh));
    for (let y = y1; y < y2; y++) {
      for (let x = x1; x < x2; x++) {
        const offset = (y * width + x) * 4;
        pixels[offset] = b;
        pixels[offset + 1] = g;
        pixels[offset + 2] = r;
        pixels[offset + 3] = alpha;
      }
    }
  };

  const sx = width / 336;
  const sy = height / 480;
  fill(0, 0, width, height, BG);
  fill(0, 0, width, 64 * sy, BG);
  fill(0, 64 * sy, width, 1, SEP);
  fill(18 * sx, 26 * sy, 12 * sx, 10 * sy, TEXT);
  fill(52 * sx, 14 * sy, 40 * sx, 12 * sy, TEXT);
  fill(52 * sx, 36 * sy, 190 * sx, 8 * sy, DIM);
  fill(278 * sx, 28 * sy, 12 * sx, 8 * sy, ACCENT);
  fill(300 * sx, 28 * sy, 8 * sx, 8 * sy, DIM);

  const rowKinds = [true, false, false, true, false, false];
  const rowHeight = 56 * sy;
  const listTop = 68 * sy;
  for (let index = 0; index < rowKinds.length; index++) {
    const y = listTop + index * rowHeight;
    fill(20 * sx, y + rowHeight - 1, width - 40 * sx, 1, SEP);
    if (rowKinds[index]) {
      fill(20 * sx, y + 21 * sy, 8 * sx, 4 * sy, ACCENT);
      fill(20 * sx, y + 24 * sy, 20 * sx, 14 * sy, ACCENT);
    } else {
      fill(23 * sx, y + 19 * sy, 14 * sx, 18 * sy, FILE_ICON);
    }
    fill(48 * sx, y + 20 * sy, 150 * sx, 14 * sy, TEXT);
    fill(width - 88 * sx, y + 12 * sy, 72 * sx, 32 * sy, DESTRUCTIVE_BG);
    fill(width - 71 * sx, y + 21 * sy, 38 * sx, 12 * sy, DESTRUCTIVE);
  }

  fill(0, 436 * sy, width, 1, SEP);
  fill(16 * sx, 452 * sy, 150 * sx, 6 * sy, DIM);
  fill(width - 140 * sx, 442 * sy, 38 * sx, 32 * sy, BTN);
  fill(width - 98 * sx, 450 * sy, 44 * sx, 8 * sy, DIM);
  fill(width - 54 * sx, 442 * sy, 38 * sx, 32 * sy, BTN);
  return pixels;
}

function main() {
  const config = loadConfig();
  const projectName = String(config.projectName || "watchface");
  const watchfaceId = String(config.watchfaceId || "");
  const files = listLuaFiles(projectName);
  const previewRgba = renderPreviewRgba(PREVIEW_W, PREVIEW_H);
  const luaEntryIndex = 0;

  const { face, records, previewOffset } = buildFace(files, {
    id: watchfaceId,
    title: projectName,
    previewRgba,
    luaEntryIndex,
  });

  const parsed = parseFace(face);
  if (parsed.id !== watchfaceId) throw new Error(`verify failed: id ${parsed.id} != ${watchfaceId}`);
  if (parsed.luaEntryIndex !== luaEntryIndex) throw new Error("verify failed: lua entry index");
  if (parsed.previewOffset !== previewOffset || !parsed.preview) throw new Error("verify failed: preview");
  if (parsed.preview.width !== PREVIEW_W || parsed.preview.height !== PREVIEW_H)
    throw new Error(`verify failed: preview dims ${parsed.preview.width}x${parsed.preview.height}`);
  if (parsed.files.length !== files.length) throw new Error("verify failed: file count");
  for (let index = 0; index < files.length; index++) {
    if (files[index].name !== parsed.files[index].name || !files[index].data.equals(parsed.files[index].data)) {
      throw new Error(`verify failed: file ${files[index].name}`);
    }
  }

  const preview = face.subarray(previewOffset, previewOffset + parsed.preview.blockLen);
  const dataLength = preview.readUInt32LE(8);
  const stream = preview.subarray(20, 20 + dataLength - 8);
  const decoded = decodeRLEv10(stream, PREVIEW_W * PREVIEW_H, 4);
  if (!decoded.some((value) => value !== 0)) throw new Error("verify failed: empty preview");

  const outputDir = join(root, "bin");
  mkdirSync(outputDir, { recursive: true });
  const facePath = join(outputDir, `${projectName}.face`);
  const resourcePath = join(outputDir, "resource.bin");
  writeFileSync(facePath, face);
  writeFileSync(resourcePath, face);

  console.log("built:", facePath, `(${face.length} bytes)`);
  console.log("copy :", resourcePath);
  console.log(`face : ${projectName}.face id=${watchfaceId} files=${records.length} luaEntryIndex=${luaEntryIndex}`);
  console.log(`preview: ${PREVIEW_W}x${PREVIEW_H} @ ${previewOffset} (${parsed.preview.blockLen} bytes, RLE ok)`);
  for (const record of records) {
    console.log(`  - ${record.name} (${record.size - 20 - record.name.length} bytes)`);
  }
  console.log("sha256:", createHash("sha256").update(face).digest("hex"));
}

main();
