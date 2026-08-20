// re/scripts/canopus-gap.mjs
//
// 只读比较：9 Pro AP/OTA 是否包含 Canopus supervisor 的运行时标识，
// 以及工作区抽出的 10 Pro supervisor 依赖哪些可观察标记。
//
// 用法：
//   bun re/scripts/canopus-gap.mjs re/firmware/upd_miwear.watch.n67cn.bin
//   bun re/scripts/canopus-gap.mjs /tmp/vela_ap_9p.bin payload/canopus-manager/sup-3.101.036.ko
//
// 注意：字符串缺失不能单独证明设备绝对不支持某功能；它只能说明该标记
// 不在当前静态镜像中。最终安装通道仍需设备运行时或官方 9 Pro supervisor 验证。
import { createHash } from "node:crypto";
import { inflateRawSync } from "node:zlib";
import { readFileSync } from "node:fs";

const inputPath = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const supervisorPath = process.argv[3] || "payload/canopus-manager/sup-3.101.036.ko";
const ZIP_LOCAL = Buffer.from([0x50, 0x4b, 0x03, 0x04]);
const AP_MARKERS = [
  "/dev/canopus",
  "CMR1",
  "CPC1",
  "CPC2",
  "canopus",
  "supervisor",
  "insmod",
  "lsmod",
  "rmmod",
  "modlib",
  "module_main",
  "app_install",
  "app_launcher_add",
  "lvx_page_title_create",
  "NuttShell (NSH) NuttX-10.3.0",
  "vfs/fs_open.c",
  "vfs/fs_read.c",
  "vfs/fs_close.c",
];
const SUPERVISOR_MARKERS = [
  "/dev/canopus",
  "CMR1",
  "CPC1",
  "CPC2",
  "canopus_supervisor",
  "identity_guard",
  "sup_load_module",
  "sup_verify_package_at",
  "canopus_install_receipt_validate",
  "Native UI ABI 1.4",
  "xiaomi-band-10-pro-3.101.036",
  "ed25519",
];

function sha256(data) {
  return createHash("sha256").update(data).digest("hex");
}

function countBytes(data, text) {
  const needle = Buffer.from(text);
  let count = 0;
  let at = data.indexOf(needle);
  while (at >= 0) {
    count += 1;
    at = data.indexOf(needle, at + 1);
  }
  return count;
}

function findApLocalEntry(data) {
  for (let offset = 0; offset + 30 <= data.length; offset += 1) {
    if (!data.subarray(offset, offset + 4).equals(ZIP_LOCAL)) continue;
    const flags = data.readUInt16LE(offset + 6);
    const method = data.readUInt16LE(offset + 8);
    const compressedSize = data.readUInt32LE(offset + 18);
    const rawSize = data.readUInt32LE(offset + 22);
    const nameLength = data.readUInt16LE(offset + 26);
    const extraLength = data.readUInt16LE(offset + 28);
    if (flags !== 0 || (method !== 0 && method !== 8) || nameLength === 0 || nameLength > 512) continue;
    const nameStart = offset + 30;
    const nameEnd = nameStart + nameLength;
    const payloadStart = nameEnd + extraLength;
    const payloadEnd = payloadStart + compressedSize;
    if (payloadEnd > data.length) continue;
    const name = data.toString("utf8", nameStart, nameEnd);
    if (name !== "vela_ap.bin") continue;
    return { offset, method, compressedSize, rawSize, payloadStart, payloadEnd };
  }
  return null;
}

function loadAp(path) {
  const source = readFileSync(path);
  // OTA 外层不是 ZIP 文件头起始，而是 `ZZ~` 容器；因此必须在整个输入中
  // 搜索 local entry，不能只检查 offset 0。
  const entry = findApLocalEntry(source);
  if (entry) {
    const compressed = source.subarray(entry.payloadStart, entry.payloadEnd);
    const ap = entry.method === 0 ? Buffer.from(compressed) : inflateRawSync(compressed);
    if (ap.length !== entry.rawSize) throw new Error(`${path}: AP size mismatch`);
    return { data: ap, detail: `ZIP local entry 0x${entry.offset.toString(16)} -> vela_ap.bin` };
  }
  return { data: source, detail: "direct AP input" };
}

function printMarkers(label, data, markers) {
  console.log(`\n=== ${label} markers ===`);
  for (const marker of markers) {
    const count = countBytes(data, marker);
    console.log(`${count ? "FOUND" : "absent"}  ${String(count).padStart(3, " ")}  ${marker}`);
  }
}

const apResult = loadAp(inputPath);
console.log(`input: ${inputPath}`);
console.log(`AP: ${apResult.detail}, ${apResult.data.length} bytes`);
console.log(`AP sha256: ${sha256(apResult.data)}`);
printMarkers("9 Pro AP", apResult.data, AP_MARKERS);

try {
  const supervisor = readFileSync(supervisorPath);
  console.log(`\nsupervisor sample: ${supervisorPath}, ${supervisor.length} bytes`);
  console.log(`supervisor sha256: ${sha256(supervisor)}`);
  printMarkers("supplied supervisor sample", supervisor, SUPERVISOR_MARKERS);
} catch (error) {
  console.log(`\nsupervisor sample: ${supervisorPath} (unavailable: ${error.message})`);
}

console.log("\ninterpretation:");
console.log("- AP markers such as app_install/LVX prove firmware code exists, not that Canopus is installed.");
console.log("- /dev/canopus, CMR1/CPC2 and supervisor markers are expected in the private supervisor/module path, not in the retail AP.");
console.log("- A 10 Pro supervisor sample containing xiaomi-band-10-pro-3.101.036 is not a 9 Pro target pack.");
console.log("- static-only: no module is written, linked, installed or executed by this script.");
