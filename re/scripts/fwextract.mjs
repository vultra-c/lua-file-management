// re/scripts/fwextract.mjs
// 小米手环 9 Pro 固件（`ZZ~ 容器）解析 + 子镜像提取器。
// 已实机固件 upd_miwear.watch.n67cn.bin 逐字节验证：
//   - 外层 `ZZ~（60 5a 5a 7e）容器，0x50=构建信息偏移、0x54=嵌套 ZZZ~ 容器偏移；
//   - 嵌套 ZZZ~（5a 5a 5a 7e）容器头部后跟 0x80 字节/条的文件表：
//       0x00 路径（NUL 填充）| +0x74 type u16 | +0x76 常量 0x74 | +0x78 数据偏移 u32 | +0x7C 数据长度 u32；
//   - 文件表以「路径非 /data/ota/ 前缀」或「偏移越过数据区」为结束。
// 用法：bun re/scripts/fwextract.mjs [固件路径] [输出目录]
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const fwPath = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const outDir = process.argv[3] || "re/firmware/extracted";

const buf = readFileSync(fwPath);
if (buf.length < 0x100 || buf.toString("latin1", 0, 4) !== "`ZZ~") {
  console.error("not a `ZZ~ firmware container");
  process.exit(1);
}

const u32 = (o) => buf.readUInt32LE(o);

// 嵌套 ZZZ~ 容器偏移（外层头 0x54）
const nested = u32(0x54);
const magic = buf.toString("latin1", nested, nested + 4);
console.log(`outer header: buildInfo@0x${u32(0x50).toString(16)} nestedContainer@0x${nested.toString(16)} (${magic})`);
if (magic !== "ZZZ~") {
  console.error(`unexpected nested magic: ${JSON.stringify(magic)}`);
  process.exit(1);
}

// 嵌套容器头部（相对 nested 的 u32 字段，供参考）
console.log(`nested hdr: rel0x44=0x${u32(nested + 0x44).toString(16)} rel0x48=0x${u32(nested + 0x48).toString(16)} rel0x4C=0x${u32(nested + 0x4C).toString(16)}`);
console.log(`nested hdr: rel0x50=0x${u32(nested + 0x50).toString(16)} rel0x54=0x${u32(nested + 0x54).toString(16)} rel0x58=0x${u32(nested + 0x58).toString(16)}`);

// 文件表：紧跟在嵌套头后的首个 /data/ota/ 路径处开始（实测固定 nested+0x5C）
const tableStart = nested + 0x5c;
const entries = [];
let off = tableStart;
while (off + 0x80 <= buf.length) {
  const end = buf.indexOf(0, off);
  if (end < 0 || end > off + 0x74) break;
  const path = buf.toString("utf8", off, end);
  if (!path.startsWith("/data/ota/")) break;
  entries.push({
    path,
    type: buf.readUInt16LE(off + 0x74),
    flag: buf.readUInt16LE(off + 0x76),
    offset: buf.readUInt32LE(off + 0x78),
    size: buf.readUInt32LE(off + 0x7c),
  });
  off += 0x80;
}

console.log(`file table: ${entries.length} entries`);
mkdirSync(outDir, { recursive: true });

const manifest = [];
for (const e of entries) {
  const name = e.path.split("/").pop();
  const data = buf.subarray(e.offset, e.offset + e.size);
  writeFileSync(join(outDir, name), data);
  const head = Array.from(data.subarray(0, 8)).map((b) => b.toString(16).padStart(2, "0")).join(" ");
  console.log(`  ${name.padEnd(28)} type=${e.type} off=0x${e.offset.toString(16)} size=${e.size}  head=${head}`);
  manifest.push({ name, path: e.path, type: e.type, offset: e.offset, size: e.size, head });
}
writeFileSync(join(outDir, "manifest.json"), JSON.stringify(manifest, null, 2));
console.log(`wrote ${entries.length} file(s) + manifest.json -> ${outDir}`);

// 附加：RSA 公钥（签名验证用，位于 MCU 侧明文区）
const keyArea = buf.toString("latin1", 0x81000, 0x810b0);
console.log(`\nRSA public key (from 0x81000):\n${keyArea.trim()}`);
