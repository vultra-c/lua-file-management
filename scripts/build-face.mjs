// scripts/build-face.mjs
// 把 lua/ 目录源码打包为 Vela Lua 表盘 .face（小米手环 9 Pro / Band 8 Pro / Watch S3 等）
// 用法：bun scripts/build-face.mjs            （读 watchface.config.json，输出 bin/）
//      bun scripts/build-face.mjs --out bin/Test.face
// 产物：bin/<projectName>.face + bin/resource.bin（模拟器安装用，与 LuaDevTemplate 一致）
// 依赖：Node 18+ / Bun，无第三方包。

import { readFileSync, readdirSync, writeFileSync, mkdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { buildFace, parseFace } from "./face-lib.mjs";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

function loadConfig() {
  const cfg = JSON.parse(readFileSync(join(root, "watchface.config.json"), "utf8"));
  return cfg;
}

function listLua() {
  const dir = join(root, "lua");
  const names = readdirSync(dir)
    .filter((n) => n.endsWith(".lua"))
    .sort();
  // 入口 main.lua 放第一条
  names.sort((a, b) => (a === "main.lua" ? -1 : b === "main.lua" ? 1 : a < b ? -1 : 1));
  return names.map((n) => {
    const data = readFileSync(join(dir, n));
    return { name: `_lua/${n}`, data };
  });
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

  const { face, records, payloadEnd } = buildFace(files, {
    id: watchfaceId,
    title: projectName,
    power: cfg.power_consumption,
  });

  // 自校验：重新解析并比对
  const parsed = parseFace(face);
  if (parsed.id !== watchfaceId) throw new Error(`verify failed: id ${parsed.id} != ${watchfaceId}`);
  if (parsed.payloadEnd !== payloadEnd) throw new Error(`verify failed: payloadEnd mismatch`);
  if (parsed.files.length !== files.length) throw new Error(`verify failed: file count`);
  for (let i = 0; i < files.length; i++) {
    const a = files[i];
    const b = parsed.files[i];
    if (a.name !== b.name || !a.data.equals(b.data)) throw new Error(`verify failed: file ${a.name}`);
  }

  const outDir = join(root, "bin");
  mkdirSync(outDir, { recursive: true });
  const facePath = join(outDir, `${projectName}.face`);
  const resourcePath = join(outDir, "resource.bin");
  writeFileSync(facePath, face);
  writeFileSync(resourcePath, face);

  console.log("built:", facePath, `(${face.length} bytes)`);
  console.log("copy :", resourcePath);
  console.log(`face : ${projectName}.face  id=${watchfaceId}  payloadEnd=${payloadEnd}`);
  console.log(`files: ${records.length}`);
  for (const r of records) {
    console.log(`  - ${r.name} (${r.size - 20 - r.name.length} bytes)`);
  }
  console.log("sha256:", createHash("sha256").update(face).digest("hex"));
}

main();
