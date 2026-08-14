// scripts/verify-payload.mjs
// 验证 bin/<project>.face 内嵌的 PAYLOAD Lua 字面量字节与 payload/module.ko 完全一致，
// 并对比固件 Lua 解析器会遇到的关键转义是否原样保留（\xNN 在 Lua 5.4 合法）。
// 用法：bun scripts/verify-payload.mjs [face 路径]
import { readFileSync } from "node:fs";
import { parseFace } from "./face-lib.mjs";

const facePath = process.argv[2] || "bin/DeepScan.face";
const koPath = process.argv[3] || "payload/module.ko";

const face = readFileSync(facePath);
const info = parseFace(face);
const lua = info.files[0].data.toString("utf8");

const m = lua.match(/PAYLOAD\s*=\s*"([^"]*)"/);
if (!m) {
  console.error("FAIL: no PAYLOAD literal found in face Lua");
  process.exit(1);
}

const esc = m[1];
const bytes = [];
for (let i = 0; i < esc.length; i++) {
  if (esc[i] === "\\" && esc[i + 1] === "x") {
    const hex = esc.slice(i + 2, i + 4);
    if (!/^[0-9a-fA-F]{2}$/.test(hex)) {
      console.error(`FAIL: bad \\x escape at index ${i}: ${JSON.stringify(esc.slice(i, i + 4))}`);
      process.exit(1);
    }
    bytes.push(parseInt(hex, 16));
    i += 3;
  } else if (esc[i] === "\\") {
    // 其它 Lua 转义不应出现在纯字节串里
    console.error(`FAIL: unexpected escape at index ${i}: ${JSON.stringify(esc.slice(i, i + 2))}`);
    process.exit(1);
  } else {
    bytes.push(esc.charCodeAt(i));
  }
}

const ko = readFileSync(koPath);
const buf = Buffer.from(bytes);

console.log(`face        : ${facePath}`);
console.log(`embedded    : ${buf.length} bytes`);
console.log(`module.ko   : ${ko.length} bytes`);
console.log(`byte-equal  : ${buf.equals(ko)}`);

if (!buf.equals(ko)) {
  for (let i = 0; i < Math.min(buf.length, ko.length); i++) {
    if (buf[i] !== ko[i]) {
      console.error(`FAIL: first diff @ ${i}: embedded=0x${buf[i].toString(16)} ko=0x${ko[i].toString(16)}`);
      process.exit(1);
    }
  }
  console.error(`FAIL: length mismatch (embedded ${buf.length} vs ko ${ko.length})`);
  process.exit(1);
}

// 顺便输出 ELF 头关键字节，便于对设备回读结果做人工比对
const sig = Array.from(buf.subarray(0, 20)).map((b) => b.toString(16).padStart(2, "0")).join(" ");
console.log(`head 20     : ${sig}`);
console.log("OK: payload embedded in face is byte-identical to module.ko");
