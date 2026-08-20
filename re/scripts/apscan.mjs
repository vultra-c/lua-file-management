// re/scripts/apscan.mjs
//
// 从 MiWear OTA 外层的 ZIP local entry 提取明文 vela_ap.bin，
// 再用字符串引用、Thumb-2 BL 交叉引用和函数序言做第一轮静态定位。
//
// 重要边界：这里输出的是“静态候选地址”，不是已经在设备上调用验证过的 ABI。
// 任何模块调用前仍需要匹配的 supervisor/执行通道和真机探针确认。
//
// 用法：
//   bun re/scripts/apscan.mjs [firmware.bin] [optional-ap-output.bin]
import { createHash } from "node:crypto";
import { inflateRawSync } from "node:zlib";
import { readFileSync, writeFileSync } from "node:fs";

const firmwarePath = process.argv[2] || "re/firmware/upd_miwear.watch.n67cn.bin";
const apOutputPath = process.argv[3] || null;
const firmware = readFileSync(firmwarePath);
const LOCAL = Buffer.from([0x50, 0x4b, 0x03, 0x04]);
const AP_RUNTIME_BASE = 0x2c080000;

function hasAt(offset, signature) {
  return offset + signature.length <= firmware.length
    && firmware.subarray(offset, offset + signature.length).equals(signature);
}

function findLocalEntries() {
  const entries = [];
  for (let offset = 0; offset + 30 <= firmware.length; offset++) {
    if (!hasAt(offset, LOCAL)) continue;
    const version = firmware.readUInt16LE(offset + 4);
    const flags = firmware.readUInt16LE(offset + 6);
    const method = firmware.readUInt16LE(offset + 8);
    const compressedSize = firmware.readUInt32LE(offset + 18);
    const uncompressedSize = firmware.readUInt32LE(offset + 22);
    const nameLength = firmware.readUInt16LE(offset + 26);
    const extraLength = firmware.readUInt16LE(offset + 28);
    if (version < 10 || version > 63 || flags !== 0 || nameLength === 0 || nameLength > 512) continue;

    const nameStart = offset + 30;
    const dataStart = nameStart + nameLength + extraLength;
    const dataEnd = dataStart + compressedSize;
    if (dataEnd > firmware.length || (method !== 0 && method !== 8)) continue;

    const name = firmware.toString("utf8", nameStart, nameStart + nameLength);
    if (!/^[\x20-\x7e\u0080-\uffff]+$/.test(name)) continue;
    entries.push({ offset, name, method, compressedSize, uncompressedSize, dataStart, dataEnd });
    offset = dataEnd - 1;
  }
  return entries;
}

function inflate(entry) {
  const compressed = firmware.subarray(entry.dataStart, entry.dataEnd);
  const data = entry.method === 0 ? Buffer.from(compressed) : inflateRawSync(compressed);
  if (data.length !== entry.uncompressedSize) {
    throw new Error(`${entry.name}: inflated size ${data.length} != ${entry.uncompressedSize}`);
  }
  return data;
}

function findAscii(data, text) {
  const result = [];
  let at = data.indexOf(text);
  while (at >= 0) {
    result.push(at);
    at = data.indexOf(text, at + 1);
  }
  return result;
}

function findCString(data, text) {
  return findAscii(data, text).find((at) => {
    const before = at === 0 ? 0 : data[at - 1];
    const after = at + text.length >= data.length ? 0 : data[at + text.length];
    const startsRun = before < 0x20 || before >= 0x7f;
    const endsRun = after === 0 || after < 0x20 || after >= 0x7f;
    return startsRun && endsRun;
  }) ?? -1;
}

function pointerRefs(data, address) {
  const needle = Buffer.alloc(4);
  needle.writeUInt32LE(address >>> 0);
  return findAll(data, needle);
}

function findAll(data, needle) {
  const result = [];
  let at = data.indexOf(needle);
  while (at >= 0) {
    result.push(at);
    at = data.indexOf(needle, at + 1);
  }
  return result;
}

function signExtend(value, bits) {
  const sign = 1 << (bits - 1);
  return (value & sign) !== 0 ? value - (1 << bits) : value;
}

// Decode a Thumb-2 BL at file offset i. The returned target is a file offset
// because the AP uses one flat image and the runtime base is added later.
function thumbBlTarget(data, i) {
  if (i + 4 > data.length) return null;
  const first = data.readUInt16LE(i);
  const second = data.readUInt16LE(i + 2);
  if ((first & 0xf800) !== 0xf000 || (second & 0xd000) !== 0xd000) return null;

  const s = (first >>> 10) & 1;
  const j1 = (second >>> 13) & 1;
  const j2 = (second >>> 11) & 1;
  const i1 = (~(j1 ^ s)) & 1;
  const i2 = (~(j2 ^ s)) & 1;
  const immediate = (s << 24)
    | (i1 << 23)
    | (i2 << 22)
    | ((first & 0x03ff) << 12)
    | ((second & 0x07ff) << 1);
  return i + 4 + signExtend(immediate, 25);
}

function callRefs(data, target) {
  const result = [];
  for (let i = 0; i + 4 <= data.length; i += 2) {
    if (thumbBlTarget(data, i) === target) result.push(i);
  }
  return result;
}

function isPrologue(data, offset) {
  if (offset < 0 || offset + 2 > data.length) return false;
  const half = data.readUInt16LE(offset);
  // push {..,lr} / push.w {..,lr}; enough for a report, not a full CFG.
  return (half & 0xfe00) === 0xb400 || (half === 0xe92d);
}

function formatAddress(value) {
  return `0x${value.toString(16).padStart(8, "0")}`;
}

const entries = findLocalEntries();
const apEntry = entries.find((entry) => entry.name === "vela_ap.bin");
if (!apEntry) throw new Error("vela_ap.bin ZIP local entry not found");
const ap = inflate(apEntry);

const sha256 = createHash("sha256").update(ap).digest("hex");
console.log(`firmware: ${firmwarePath} (${firmware.length} bytes)`);
console.log(`AP local entry: offset=0x${apEntry.offset.toString(16)} compressed=${apEntry.compressedSize} raw=${ap.length}`);
console.log(`AP sha256: ${sha256}`);
console.log(`runtime base: ${formatAddress(AP_RUNTIME_BASE)} (FLASH_BASE + OTA_CODE_OFFSET)`);

if (apOutputPath) {
  writeFileSync(apOutputPath, ap);
  console.log(`wrote: ${apOutputPath}`);
}

// The first four are the useful static anchors for the Canopus native-app path.
// Offsets are intentionally kept in this script so a future firmware revision can
// be compared by rerunning the same report rather than copying addresses by hand.
const anchors = [
  {
    name: "lvx_page_title_create",
    string: "lvx_page_title_create",
    candidateOffset: 0x1f83c8,
    confidence: "high",
    reason: "the candidate owns the string reference and is reached by two Thumb BL call sites",
  },
  {
    name: "app_launcher_add",
    string: "app_launcher_add",
    candidateOffset: 0x227cb8,
    confidence: "high",
    reason: "the candidate owns the log string; callers pass an app-id-shaped u16 before the call",
  },
  {
    name: "app_lookup",
    string: null,
    candidateOffset: 0x3c9334,
    confidence: "high",
    reason: "the candidate walks the app registry, compares the u16 app id at object offset +0x10, and returns the matching object",
  },
  {
    name: "app_install",
    string: "app_install",
    candidateOffset: 0x3cb5d0,
    confidence: "high",
    reason: "the candidate validates the descriptor, reads app_id at +0x10, allocates/registers pages, and owns the app_install diagnostic string; call ABI still needs a probe",
  },
  {
    name: "lvx_list_set_parent candidate",
    string: "lvx_list_set_parent",
    candidateOffset: 0x3b8148,
    confidence: "medium",
    reason: "the candidate's literal pool is used by the lvx_list.c diagnostic path and its control flow checks/links a list parent; it is not yet a proof of the exported row API",
  },
];

const lifecycleAnchors = [
  {
    name: "page_on_resume wrapper candidate",
    string: "on_resume_wrapped",
    candidateOffset: 0x3cbb10,
    confidence: "medium",
    reason: "function prologue at the literal-reference neighborhood; checks page state and dispatches through a page callback field before returning",
  },
  {
    name: "page_on_destroy wrapper candidate",
    string: "on_destroy_wrapped",
    candidateOffset: 0x3cbba4,
    confidence: "medium",
    reason: "function prologue at the literal-reference neighborhood; logs the wrapper name, dispatches cleanup callbacks and updates the page state",
  },
  {
    name: "page_on_create wrapper candidate",
    string: "on_create_wrapped",
    candidateOffset: 0x3cfc58,
    confidence: "medium",
    reason: "function prologue at the literal-reference neighborhood; creates/attaches the page session and dispatches the create callback through a page field",
  },
  {
    name: "screen_session_destroy candidate",
    string: "screen_session_destroy",
    candidateOffset: 0x3ce8f0,
    confidence: "medium",
    reason: "function prologue owns the screen-session destroy diagnostic string and unlinks/frees the session object",
  },
  {
    name: "lvx_eventbus_unsubscribe candidate",
    string: "lvx_eventbus_unsubscribe",
    candidateOffset: 0x3b91ec,
    confidence: "medium-high",
    reason: "function prologue owns the eventbus unsubscribe literal, validates the object, clears its handler field and returns the eventbus cleanup result",
  },
];

const listCandidates = [
  {
    name: "lvx_list_child_create_or_attach candidate",
    string: null,
    candidateOffset: 0x3b8268,
    confidence: "medium",
    reason: "function allocates/copies a child descriptor and calls the 0x3b8148 parent-management candidate; exported row name is not recovered",
  },
  {
    name: "lvx_list_child_lookup candidate",
    string: null,
    candidateOffset: 0x3b82b8,
    confidence: "low-medium",
    reason: "function traverses a list-like child array at object offset +0x78 and returns a matching child; exact LVX type is unconfirmed",
  },
];

const descriptorEvidence = [
  {
    offset: 0x00,
    width: "u32",
    meaning: "list link / firmware-owned after install",
    confidence: "medium",
    evidence: "app_install copies 0x3c bytes, then writes the installed object's +0x00/+0x04 links",
  },
  {
    offset: 0x04,
    width: "u32",
    meaning: "list link / firmware-owned after install",
    confidence: "medium",
    evidence: "app_install copies 0x3c bytes, then writes the installed object's +0x00/+0x04 links",
  },
  {
    offset: 0x08,
    width: "ptr",
    meaning: "required non-null pointer; likely package/name string",
    confidence: "high",
    evidence: "validated at entry and duplicated into the installed object",
  },
  {
    offset: 0x0c,
    width: "ptr",
    meaning: "pointer field; exact role unconfirmed",
    confidence: "high",
    evidence: "conditionally duplicated into the installed object",
  },
  {
    offset: 0x10,
    width: "u16",
    meaning: "application id",
    confidence: "high",
    evidence: "loaded with LDRH and passed to app_lookup before allocation",
  },
  {
    offset: 0x14,
    width: "ptr",
    meaning: "pointer/callback field; exact role unconfirmed",
    confidence: "high",
    evidence: "conditionally duplicated into the installed object",
  },
  {
    offset: 0x18,
    width: "ptr",
    meaning: "pointer/callback field; exact role unconfirmed",
    confidence: "high",
    evidence: "conditionally duplicated into the installed object",
  },
  {
    offset: 0x1c,
    width: "ptr",
    meaning: "callback-like field",
    confidence: "medium",
    evidence: "installed object +0x1c is invoked through BLX during teardown",
  },
];

function printDescriptorEvidence() {
  const installOffset = 0x3cb5d0;
  const copySize = 0x3c;
  const appIdRead = thumbBlTarget(ap, 0x3cb5ea);
  console.log("\n=== app_install descriptor evidence ===");
  console.log(`app_install candidate: ${formatAddress(AP_RUNTIME_BASE + installOffset)} (Thumb entry ${formatAddress(AP_RUNTIME_BASE + installOffset + 1)})`);
  console.log(`descriptor copy size: 0x${copySize.toString(16)} (${copySize} bytes)`);
  console.log(`argument shape: r0=descriptor, r1=page-pointer array, r2=page_count (r2 is loop bound)`);
  console.log(`app_id read: descriptor+0x10 -> app_lookup BL target ${appIdRead == null ? "not decoded" : formatAddress(AP_RUNTIME_BASE + appIdRead)}`);
  for (const field of descriptorEvidence) {
    console.log(`  +0x${field.offset.toString(16).padStart(2, "0")} ${field.width.padEnd(4)} ${field.meaning} [${field.confidence}]`);
    console.log(`      ${field.evidence}`);
  }
  console.log("descriptor ABI warning: the public Canopus struct layout is not validated for this 9 Pro image; do not reuse the old +0x08 app_id layout");
}

function printListEvidence() {
  console.log("\n=== LVX list static evidence ===");
  console.log(`lvx_list_set_parent source string: file+0x${findCString(ap, "lvx_list_set_parent").toString(16)}`);
  console.log(`list-management candidate: ${formatAddress(AP_RUNTIME_BASE + 0x3b8148)} (Thumb entry ${formatAddress(AP_RUNTIME_BASE + 0x3b8149)})`);
  console.log("status: medium-confidence list-parent/error path only; row-create/update/event ABI remains unresolved");
  for (const candidate of listCandidates) {
    const address = AP_RUNTIME_BASE + candidate.candidateOffset;
    const calls = callRefs(ap, candidate.candidateOffset);
    console.log(`${candidate.name}`);
    console.log(`  candidate: ${formatAddress(address)} (Thumb entry ${formatAddress(address + 1)})`);
    console.log(`  confidence: ${candidate.confidence}`);
    console.log(`  prologue: ${isPrologue(ap, candidate.candidateOffset) ? "yes" : "no"}`);
    console.log(`  direct BL refs: ${calls.length} ${calls.slice(0, 8).map(formatAddress).join(", ")}`);
    console.log(`  reason: ${candidate.reason}`);
  }
}

function printLifecycleEvidence() {
  console.log("\n=== page/lifecycle static evidence ===");
  for (const candidate of lifecycleAnchors) {
    const address = AP_RUNTIME_BASE + candidate.candidateOffset;
    const stringOffset = findCString(ap, candidate.string);
    const refs = stringOffset < 0 ? [] : pointerRefs(ap, AP_RUNTIME_BASE + stringOffset);
    const calls = callRefs(ap, candidate.candidateOffset);
    console.log(`${candidate.name}`);
    console.log(`  candidate: ${formatAddress(address)} (Thumb entry ${formatAddress(address + 1)})`);
    console.log(`  confidence: ${candidate.confidence}`);
    console.log(`  prologue: ${isPrologue(ap, candidate.candidateOffset) ? "yes" : "no"}`);
    console.log(`  string: file+0x${stringOffset.toString(16)} refs=${refs.length} ${refs.slice(0, 8).map(formatAddress).join(", ")}`);
    console.log(`  direct BL refs: ${calls.length} ${calls.slice(0, 8).map(formatAddress).join(", ")}`);
    console.log(`  reason: ${candidate.reason}`);
  }
  console.log("lifecycle ABI warning: these are firmware-internal wrappers; callback argument order and page descriptor offsets remain unresolved");
}

console.log("\n=== native-app / LVX static anchors ===");
for (const anchor of anchors) {
  const candidateAddress = AP_RUNTIME_BASE + anchor.candidateOffset;
  const calls = callRefs(ap, anchor.candidateOffset);
  const stringOffset = anchor.string == null ? null : findCString(ap, anchor.string);
  const refs = stringOffset == null || stringOffset < 0
    ? []
    : pointerRefs(ap, AP_RUNTIME_BASE + stringOffset);
  const prologue = isPrologue(ap, anchor.candidateOffset);
  console.log(`${anchor.name}`);
  console.log(`  candidate: ${formatAddress(candidateAddress)} (Thumb entry ${formatAddress(candidateAddress + 1)})`);
  console.log(`  confidence: ${anchor.confidence}`);
  console.log(`  prologue: ${prologue ? "yes" : "no"}`);
  console.log(`  direct BL refs: ${calls.length} ${calls.slice(0, 8).map(formatAddress).join(", ")}`);
  if (stringOffset != null) {
    console.log(`  string: file+0x${stringOffset.toString(16)} -> ${formatAddress(AP_RUNTIME_BASE + stringOffset)}`);
    console.log(`  string pointer refs: ${refs.length} ${refs.slice(0, 8).map(formatAddress).join(", ")}`);
  }
  console.log(`  reason: ${anchor.reason}`);
}

printDescriptorEvidence();
printListEvidence();
printLifecycleEvidence();

console.log("\n=== architecture/runtime strings ===");
for (const text of [
  "NuttX",
  "NuttShell (NSH) NuttX-10.3.0",
  "lvgl/src/core/lv_obj.c",
  "lvx_widgets/lvx_list.c",
  "CHIP=best1503",
  "FLASH_BASE=0x2C000000",
  "OTA_CODE_OFFSET=0x80000",
]) {
  const offset = ap.indexOf(text);
  console.log(`${text}: ${offset < 0 ? "not found" : `file+0x${offset.toString(16)} (${formatAddress(AP_RUNTIME_BASE + offset)})`}`);
}

console.log("\nstatic-only: do not call these addresses without a matching runtime/supervisor and a read-only probe");
