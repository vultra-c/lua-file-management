// re/scripts/fwscan.mjs
// 小米手环固件（`ZZ~ 容器）扫描器：解析头部、探测分区/压缩签名、定位关键字符串。
// 无依赖。用法：bun re/scripts/fwscan.mjs [固件路径]
import { readFileSync } from "node:fs";

const path = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const buf = readFileSync(path);
console.log(`file: ${path} (${buf.length} bytes)`);

// ---- 头部解析（`ZZ~ = 60 5a 5a 7e）----
const magic = buf.toString("latin1", 0, 4);
console.log(`magic: ${JSON.stringify(magic)}`);
const ver = buf.toString("latin1", 4, 16).replace(/\0+$/, "");
console.log(`version: ${ver}`);

const u32 = (o) => buf.readUInt32LE(o);
console.log("\n=== header u32 fields (LE) ===");
for (let o = 0x40; o < 0x70; o += 4) {
  console.log(`0x${o.toString(16).padStart(2, "0")}: 0x${u32(o).toString(16)} (${u32(o)})`);
}

// ---- 压缩/分区签名探测 ----
const SIGS = [
  ["gzip", [0x1f, 0x8b, 0x08]],
  ["zlib 78 01", [0x78, 0x01]],
  ["zlib 78 9c", [0x78, 0x9c]],
  ["zlib 78 da", [0x78, 0xda]],
  ["lz4 frame", [0x04, 0x22, 0x4d, 0x18]],
  ["lzma", [0x5d, 0x00, 0x00]],
  ["xz", [0xfd, 0x37, 0x7a, 0x58, 0x5a, 0x00]],
  ["zstd", [0x28, 0xb5, 0x2f, 0xfd]],
  ["squashfs(hsqs)", [0x68, 0x73, 0x71, 0x73]],
  ["cramfs", [0x45, 0x3d, 0xcd, 0x28]],
  ["lzo", [0x89, 0x4c, 0x5a, 0x4f]],
  ["7z", [0x37, 0x7a, 0xbc, 0xaf, 0x27, 0x1c]],
];

function findBytes(sig) {
  const hits = [];
  outer: for (let i = 0; i + sig.length <= buf.length; i++) {
    for (let j = 0; j < sig.length; j++) if (buf[i + j] !== sig[j]) continue outer;
    hits.push(i);
    if (hits.length >= 20) break;
  }
  return hits;
}

console.log("\n=== compression/partition signatures (first 20 offsets) ===");
for (const [name, sig] of SIGS) {
  const hits = findBytes(sig);
  if (hits.length) console.log(`${name}: ${hits.map((h) => "0x" + h.toString(16)).join(", ")}`);
}

// ---- 关键字符串定位 ----
const KEYS = [
  "insmod", "lsmod", "rmmod", "exec", "sh", "mw8", "mw16", "mw32", "memread",
  "app_install", "appinstall", "launcher_add", "register_app", "install_app",
  "apps.json", "applist", "launcher", "widget", "watchface", "vela", "NuttX",
  "lv_", "lvgl", "bluetooth", "app", "deepscan",
];
console.log("\n=== key string hits (offset : preview) ===");
for (const k of KEYS) {
  const hits = [];
  let i = buf.indexOf(k);
  while (i !== -1 && hits.length < 8) {
    hits.push(i);
    i = buf.indexOf(k, i + 1);
  }
  if (hits.length) {
    const first = hits[0];
    const ctx = buf.toString("latin1", Math.max(0, first - 16), first + 32).replace(/[^\x20-\x7e]/g, ".");
    console.log(`${k} (${hits.length >= 8 ? "8+" : hits.length}): first@0x${first.toString(16)}  [${ctx}]`);
  }
}
