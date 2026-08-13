// re/scripts/fwdecomp.mjs
// 解压固件内的 gzip/zlib 流并扫描关键字符串；解析 squashfs 超级块。
// 用法：bun re/scripts/fwdecomp.mjs [固件路径]
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import zlib from "node:zlib";

const path = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const buf = readFileSync(path);
const KEYS = ["insmod", "lsmod", "rmmod", "exec", "mw8", "app_install", "appinstall",
  "launcher_add", "register_app", "install_app", "apps.json", "applist", "launcher",
  "vela", "NuttX", "watchface", "lvgl", "lv_", "nsh"];

function scanKeys(data, label) {
  const hits = {};
  for (const k of KEYS) {
    const n = (data.toString("latin1").match(new RegExp(k.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g")) || []).length;
    if (n > 0) hits[k] = n;
  }
  if (Object.keys(hits).length) {
    console.log(`  ${label}: ${data.length} bytes, keys: ${JSON.stringify(hits)}`);
  } else {
    console.log(`  ${label}: ${data.length} bytes, no key strings`);
  }
}

// 1) 扫描所有 gzip 流（1f 8b 08）
console.log("=== gzip streams ===");
let idx = 0;
const gzOffsets = [];
for (let i = 0; i + 3 <= buf.length; i++) {
  if (buf[i] === 0x1f && buf[i + 1] === 0x8b && buf[i + 2] === 0x08) {
    gzOffsets.push(i);
    i += 3;
  }
}
console.log(`gzip magic count: ${gzOffsets.length}`);
let done = 0;
for (const off of gzOffsets) {
  try {
    // 尝试从该偏移解压（gunzip 会解析一个 gzip member）
    const out = zlib.gunzipSync(buf.subarray(off), { maxOutputLength: 256 * 1024 * 1024 });
    console.log(`\ngzip @0x${off.toString(16)} -> ${out.length} bytes`);
    scanKeys(out, "decompressed");
    if (done++ >= 4) break;
  } catch (e) {
    // 不是有效 gzip 起始（假阳性）
  }
}

// 2) squashfs 超级块（hsqs）
console.log("\n=== squashfs superblock ===");
const sqOff = buf.indexOf(Buffer.from("hsqs"));
if (sqOff !== -1) {
  const s = buf.subarray(sqOff);
  const sb = {
    magic: s.toString("latin1", 0, 4),
    inodes: s.readUInt32LE(4),
    mkfs_time: s.readUInt32LE(8),
    block_size: s.readUInt32LE(12),
    fragments: s.readUInt32LE(16),
    compression: s.readUInt16LE(20),
    block_log: s.readUInt16LE(22),
    flags: s.readUInt16LE(24),
    no_ids: s.readUInt16LE(26),
    major: s.readUInt16LE(28),
    minor: s.readUInt16LE(30),
  };
  const COMP = { 1: "gzip", 2: "lzma", 3: "lzo", 4: "xz", 5: "lz4", 6: "zstd" };
  console.log(`offset: 0x${sqOff.toString(16)}`);
  console.log(`inodes: ${sb.inodes}, block_size: ${sb.block_size}, compression: ${COMP[sb.compression] || sb.compression}`);
  console.log(`blocks: ${sb.fragments}, version: ${sb.major}.${sb.minor}`);
} else {
  console.log("no squashfs found");
}
