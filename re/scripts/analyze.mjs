// re/scripts/analyze.mjs
// 无依赖 ELF 分析器：扫描 re/exec、re/system、re/firmware、re/libs 下的样本，
// 解析 ELF 头 / 节表 / 符号表，提取架构、导出符号与 UI 相关字符串，写 re/report/。
// 只读输入，不修改任何样本。用法：bun re/scripts/analyze.mjs
import { readFileSync, readdirSync, statSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const SCAN_DIRS = ["exec", "system", "firmware", "libs"].map((d) => join(root, d));
const REPORT_DIR = join(root, "report");

const MACHINE = {
  0x00: "No machine", 0x02: "SPARC", 0x03: "x86", 0x08: "MIPS", 0x14: "PowerPC",
  0x16: "S390", 0x28: "ARM", 0x2A: "SuperH", 0x32: "IA-64", 0x3E: "x86-64",
  0xB7: "AArch64", 0xF3: "RISC-V",
};
const TYPE = { 0: "NONE", 1: "REL", 2: "EXEC", 3: "DYN", 4: "CORE" };
const STT = ["NOTYPE", "OBJECT", "FUNC", "SECTION", "FILE", "COMMON", "TLS", "NUM"];
const STB = ["LOCAL", "GLOBAL", "WEAK", "NUM"];

// UI 相关关键词（用于在字符串/符号里圈定系统原生 UI 框架入口）
const UI_HINTS = [
  "window", "widget", "list", "button", "label", "text", "view", "screen",
  "render", "draw", "paint", "touch", "input", "gesture", "event",
  "app", "launcher", "vela", "ui", "lvgl", "framebuffer", "display", "gfx",
  "dialog", "menu", "scroll", "animation", "icon", "font", "theme", "style",
];

function walk(dir, out) {
  if (!existsSync(dir)) return out;
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    const st = statSync(p);
    if (st.isDirectory()) walk(p, out);
    else if (st.isFile()) out.push(p);
  }
  return out;
}

function readMaybeU16(buf, off) {
  return off + 2 <= buf.length ? buf.readUInt16LE(off) : undefined;
}
function readMaybeU32(buf, off) {
  return off + 4 <= buf.length ? buf.readUInt32LE(off) : undefined;
}

function parseElf(buf) {
  if (buf.length < 20 || buf[0] !== 0x7f || buf[1] !== 0x45 || buf[2] !== 0x4c || buf[3] !== 0x46)
    return null;
  const cls = buf[4]; // 1=32 2=64
  const is64 = cls === 2;
  if (cls !== 1 && cls !== 2) return { bad: `unknown class ${cls}` };
  const endian = buf[5];
  if (endian === 2) return { bad: "big-endian ELF (unsupported)" };

  const u16 = (o) => buf.readUInt16LE(o);
  const u32 = (o) => buf.readUInt32LE(o);
  const u64 = (o) => (o + 8 <= buf.length ? buf.readBigUInt64LE(o) : 0n);

  const e_type = u16(0x10);
  const e_machine = u16(0x12);
  const e_entry = is64 ? u64(0x18) : BigInt(u32(0x18));
  const shoff = is64 ? u64(0x28) : BigInt(u32(0x20));
  const shentsize = is64 ? u16(0x3A) : u16(0x2E);
  const shnum = is64 ? u16(0x3C) : u16(0x30);
  const shstrndx = is64 ? u16(0x3E) : u16(0x32);

  const sections = [];
  for (let i = 0; i < shnum; i++) {
    const o = Number(shoff) + i * shentsize;
    if (o + shentsize > buf.length) break;
    sections.push({
      name: u32(o),
      type: u32(o + 4),
      offset: Number(is64 ? u64(o + 24) : BigInt(u32(o + 16))),
      size: Number(is64 ? u64(o + 32) : BigInt(u32(o + 20))),
      link: is64 ? u32(o + 40) : u32(o + 24),
      info: is64 ? u32(o + 44) : u32(o + 28),
      entsize: Number(is64 ? u64(o + 56) : BigInt(u32(o + 36))),
    });
  }
  const shstr = sections[shstrndx] && sections[shstrndx].offset != null
    ? buf.subarray(sections[shstrndx].offset, sections[shstrndx].offset + sections[shstrndx].size)
    : null;
  const secName = (s) => {
    if (!shstr || s.name == null) return "";
    const end = shstr.indexOf(0, s.name);
    return shstr.subarray(s.name, end < 0 ? shstr.length : end).toString("utf8");
  };
  sections.forEach((s) => (s._name = secName(s)));

  // 符号表：.symtab（REL/.ko）与 .dynsym（.so）
  const symbols = [];
  for (const symSecName of [".symtab", ".dynsym"]) {
    const ssec = sections.find((s) => s._name === symSecName);
    if (!ssec || !ssec.entsize) continue;
    const strSec = sections[ssec.link];
    if (!strSec) continue;
    const strtab = buf.subarray(strSec.offset, strSec.offset + strSec.size);
    const ent = ssec.entsize;
    for (let off = ssec.offset; off + ent <= ssec.offset + ssec.size; off += ent) {
      const nameOff = u32(off);
      const info = buf[off + (is64 ? 4 : 12)];
      const bind = info >> 4;
      const type = info & 0xf;
      const nameEnd = strtab.indexOf(0, nameOff);
      const name = nameEnd < 0 ? "" : strtab.subarray(nameOff, nameEnd).toString("utf8");
      if (!name) continue;
      symbols.push({ name, bind, type, sec: symSecName });
    }
  }

  // 导出符号（全局/弱 + 函数/对象）
  const exported = symbols
    .filter((s) => (s.bind === 1 || s.bind === 2) && (s.type === 1 || s.type === 2))
    .map((s) => s.name);

  // UI 相关字符串（原始字节扫 ASCII 串，>=4 字符）
  const strings = [];
  let run = "";
  for (let i = 0; i < buf.length; i++) {
    const b = buf[i];
    if (b >= 0x20 && b < 0x7f) run += String.fromCharCode(b);
    else {
      if (run.length >= 4) strings.push(run);
      run = "";
    }
  }
  if (run.length >= 4) strings.push(run);

  const uiStrings = strings.filter((s) =>
    UI_HINTS.some((k) => s.toLowerCase().includes(k)));
  const uiSymbols = exported.filter((s) =>
    UI_HINTS.some((k) => s.toLowerCase().includes(k)));

  return {
    is64,
    machine: MACHINE[e_machine] || `0x${e_machine.toString(16)}`,
    type: TYPE[e_type] || `0x${e_type.toString(16)}`,
    entry: "0x" + e_entry.toString(16),
    sectionCount: sections.length,
    symbolCount: symbols.length,
    exported,
    uiSymbols: uiSymbols.slice(0, 200),
    uiStrings: Array.from(new Set(uiStrings)).slice(0, 200),
  };
}

function analyzeFile(path) {
  const buf = readFileSync(path);
  const rel = path.replace(root + "/", "");
  const isElf = buf.length >= 4 && buf[0] === 0x7f && buf[1] === 0x45;
  const report = {
    file: rel,
    size: buf.length,
    kind: isElf ? "ELF" : "data",
  };
  if (isElf) {
    const r = parseElf(buf);
    if (r.bad) {
      report.error = r.bad;
    } else {
      Object.assign(report, {
        is64: r.is64,
        machine: r.machine,
        type: r.type,
        entry: r.entry,
        sectionCount: r.sectionCount,
        symbolCount: r.symbolCount,
        exported: r.exported.length,
        uiSymbols: r.uiSymbols,
        uiStrings: r.uiStrings,
      });
    }
  } else {
    // 非 ELF：可能是 apps.json / 目录清单 / 文本，抓首行 + UI 关键词
    const text = buf.subarray(0, 2000).toString("utf8").replace(/\0/g, "");
    report.preview = text.split("\n").slice(0, 5).join("\n");
    const hit = UI_HINTS.filter((k) => text.toLowerCase().includes(k));
    if (hit.length) report.uiHints = hit;
  }
  return report;
}

function main() {
  const files = [];
  for (const d of SCAN_DIRS) walk(d, files);
  mkdirSync(REPORT_DIR, { recursive: true });

  const reports = files.map(analyzeFile);
  writeFileSync(join(REPORT_DIR, "report.json"), JSON.stringify(reports, null, 2));

  const lines = ["# re/report — ELF 分析报告", ""];
  lines.push(`扫描目录：${SCAN_DIRS.map((d) => d.replace(root + "/", "")).join("、")}`);
  lines.push(`样本总数：${reports.length}`, "");
  for (const r of reports) {
    lines.push(`## ${r.file} (${r.size} bytes, ${r.kind})`);
    if (r.error) lines.push(`- ⚠️ ${r.error}`);
    if (r.kind === "ELF" && !r.error) {
      lines.push(`- 架构: ${r.machine} / ${r.is64 ? 64 : 32}-bit / type=${r.type} / entry=${r.entry}`);
      lines.push(`- 节: ${r.sectionCount}，符号: ${r.symbolCount}，导出: ${r.exported}`);
      if (r.uiSymbols.length) lines.push(`- UI 符号:\n  - ${r.uiSymbols.join("\n  - ")}`);
      if (r.uiStrings.length) lines.push(`- UI 字符串:\n  - ${r.uiStrings.join("\n  - ")}`);
    } else if (r.preview) {
      lines.push("```\n" + r.preview + "\n```");
      if (r.uiHints) lines.push(`- UI 关键词命中: ${r.uiHints.join(", ")}`);
    }
    lines.push("");
  }
  writeFileSync(join(REPORT_DIR, "report.md"), lines.join("\n"));

  console.log(`analyzed ${reports.length} sample(s)`);
  console.log(`wrote ${join("re", "report", "report.json")} / report.md`);
}

main();
