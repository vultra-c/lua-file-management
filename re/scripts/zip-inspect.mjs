// re/scripts/zip-inspect.mjs
// 检查并解析 MiWear OTA 外层 ZIP 条目。
// 重要：外层 `ZZZ~` 表记录的是压缩/封装后的更新载荷；真正的 AP 镜像还位于
// 前面的 ZIP local-entry 中，inflateRaw 后可得到可反汇编的 M33 固件镜像。
// 用法：
//   bun re/scripts/zip-inspect.mjs [firmware.bin] [optional-output-dir]
// 第二个参数只会写出 vela_ap.bin，避免默认生成大量二进制副本。
import { createHash } from "node:crypto";
import { inflateRawSync } from "node:zlib";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const firmwarePath = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const outputDir = process.argv[3] || null;
const buf = readFileSync(firmwarePath);
const LOCAL = Buffer.from([0x50, 0x4b, 0x03, 0x04]);
const MAX_NAME = 512;

function hasAt(offset, signature) {
  return offset + signature.length <= buf.length && buf.subarray(offset, offset + signature.length).equals(signature);
}

function sha256(data) {
  return createHash("sha256").update(data).digest("hex");
}

function findLocalEntries() {
  const entries = [];
  for (let offset = 0; offset + 30 <= buf.length; offset++) {
    if (!hasAt(offset, LOCAL)) continue;
    const version = buf.readUInt16LE(offset + 4);
    const flags = buf.readUInt16LE(offset + 6);
    const method = buf.readUInt16LE(offset + 8);
    const compressedSize = buf.readUInt32LE(offset + 18);
    const uncompressedSize = buf.readUInt32LE(offset + 22);
    const nameLength = buf.readUInt16LE(offset + 26);
    const extraLength = buf.readUInt16LE(offset + 28);
    if (version < 10 || version > 63 || flags !== 0 || nameLength === 0 || nameLength > MAX_NAME) continue;
    const nameStart = offset + 30;
    const dataStart = nameStart + nameLength + extraLength;
    const dataEnd = dataStart + compressedSize;
    if (dataEnd > buf.length) continue;
    const name = buf.toString("utf8", nameStart, nameStart + nameLength);
    if (!/^[\x20-\x7e\u0080-\uffff]+$/.test(name)) continue;
    if (method !== 0 && method !== 8) continue;
    entries.push({
      offset,
      name,
      version,
      method,
      compressedSize,
      uncompressedSize,
      dataStart,
      dataEnd,
    });
    offset = dataEnd - 1;
  }
  return entries;
}

function inflate(entry) {
  const payload = buf.subarray(entry.dataStart, entry.dataEnd);
  const data = entry.method === 0 ? Buffer.from(payload) : inflateRawSync(payload);
  if (data.length !== entry.uncompressedSize) {
    throw new Error(`${entry.name}: size mismatch ${data.length} != ${entry.uncompressedSize}`);
  }
  return data;
}

function asciiRuns(data, minLength = 6) {
  const result = [];
  let start = -1;
  for (let i = 0; i <= data.length; i++) {
    const value = i < data.length ? data[i] : 0;
    const printable = value >= 0x20 && value < 0x7f;
    if (printable && start < 0) start = i;
    if (!printable && start >= 0) {
      if (i - start >= minLength) result.push({ offset: start, text: data.toString("latin1", start, i) });
      start = -1;
    }
  }
  return result;
}

const entries = findLocalEntries();
console.log(`firmware: ${firmwarePath} (${buf.length} bytes)`);
console.log(`valid ZIP local entries: ${entries.length}`);
for (const entry of entries) {
  console.log(`  0x${entry.offset.toString(16).padStart(8, "0")} ${entry.name} compressed=${entry.compressedSize} raw=${entry.uncompressedSize}`);
}

const apEntry = entries.find((entry) => entry.name === "vela_ap.bin");
if (!apEntry) {
  console.error("vela_ap.bin local entry not found");
  process.exit(1);
}

const ap = inflate(apEntry);
console.log(`\nvela_ap.bin inflated: ${ap.length} bytes`);
console.log(`sha256: ${sha256(ap)}`);
console.log(`head: ${Array.from(ap.subarray(0, 32), (v) => v.toString(16).padStart(2, "0")).join(" ")}`);

const keys = [
  "NuttX", "openvela", "app_install", "launcher_add", "lvx_", "lvgl", "apps.json",
  "identity", "canopus", "supervisor", "watchface", "/system/", "/data/",
];
const runs = asciiRuns(ap);
for (const key of keys) {
  const hits = runs.filter(({ text }) => text.includes(key)).slice(0, 20);
  if (hits.length) {
    console.log(`\n${key}:`);
    for (const hit of hits) console.log(`  0x${hit.offset.toString(16)} ${JSON.stringify(hit.text)}`);
  }
}

if (outputDir) {
  mkdirSync(outputDir, { recursive: true });
  const outputPath = join(outputDir, "vela_ap.bin");
  writeFileSync(outputPath, ap);
  console.log(`\nwrote ${outputPath}`);
}
