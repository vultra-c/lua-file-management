// scripts/unpack-face.mjs
// 解析并解包 Vela Lua 表盘 .face 文件（验证/分析用）
// 用法：bun scripts/unpack-face.mjs <file.face> [--extract dir]
//      --extract dir 把记录按 _lua/ 路径写入 dir（平铺文件名）

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, basename } from "node:path";
import { parseFace } from "./face-lib.mjs";

function main() {
  const args = process.argv.slice(2);
  const path = args.find((a) => !a.startsWith("--"));
  if (!path) {
    console.error("usage: bun scripts/unpack-face.mjs <file.face> [--extract dir]");
    process.exit(1);
  }
  const extractIdx = args.indexOf("--extract");
  const extractDir = extractIdx >= 0 ? args[extractIdx + 1] : null;

  const buf = readFileSync(path);
  const info = parseFace(buf);
  console.log("file  :", path, `(${buf.length} bytes)`);
  console.log("magic : OK");
  console.log("id    :", info.id);
  console.log("title :", info.title);
  console.log("payloadEnd:", info.payloadEnd);
  console.log(`files : ${info.files.length}`);
  for (const f of info.files) {
    console.log(`  #${f.index} ${f.name} (${f.data.length} bytes @ ${f.offset})`);
    if (extractDir) {
      const outName = basename(f.name);
      mkdirSync(extractDir, { recursive: true });
      writeFileSync(join(extractDir, outName), f.data);
    }
  }
  if (extractDir) console.log("extracted to:", extractDir);
}

main();
