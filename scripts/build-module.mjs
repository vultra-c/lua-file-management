// scripts/build-module.mjs
// 手工编码「最小原生模块」：ARM Thumb-2 / ET_REL / NuttX modlib 格式的 .ko。
// 本环境没有 ARM 交叉编译器（arm-none-eabi-gcc/rust 均不可用），因此直接在
// Node 里逐字节拼出 ELF：纯 .text、零重定位、零外部符号，仅写两个验证标记，
// 与朋友实机验证过的闭环（insmod → lsmod 解析基址 → exec <base+1>）完全兼容：
//
//   push {r7, lr}
//   r1 = 0x20001000  → 写 0x5EED0001   （标记1，同朋友探针地址）
//   r3 = 0x20001004  → 写 1             （标记2 = 版本号）
//   movs r0, #0                          （返回 0）
//   pop {r7, pc}                         （干净返回，LR 由 exec 设置）
//
// 用法：bun scripts/build-module.mjs   → 写 payload/module.ko
// 产物用 readelf/objdump 做结构自校验（脚本内已做字节级回读校验）。
import { writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");

// ---- Thumb-2 指令编码（小端）----
const u16 = (v) => Buffer.from([v & 0xff, (v >> 8) & 0xff]);
const u32 = (v) => Buffer.from([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >>> 24) & 0xff]);

// movw/movt: 11110 i 0x/1x 0100 imm4 | 0 imm3 rd imm8
function movw(rd, imm16) {
  const imm4 = (imm16 >> 12) & 0xf;
  const i = (imm16 >> 11) & 1;
  const imm3 = (imm16 >> 8) & 0x7;
  const imm8 = imm16 & 0xff;
  const h1 = 0xf240 | (i << 10) | imm4;
  const h2 = (imm3 << 12) | (rd << 8) | imm8;
  return Buffer.concat([u16(h1), u16(h2)]);
}
function movt(rd, imm16) {
  const imm4 = (imm16 >> 12) & 0xf;
  const i = (imm16 >> 11) & 1;
  const imm3 = (imm16 >> 8) & 0x7;
  const imm8 = imm16 & 0xff;
  const h1 = 0xf2c0 | (i << 10) | imm4;
  const h2 = (imm3 << 12) | (rd << 8) | imm8;
  return Buffer.concat([u16(h1), u16(h2)]);
}

let text = Buffer.alloc(0);
const ins = (b) => { text = Buffer.concat([text, b]); };

ins(u16(0xb580)); // push {r7, lr}
ins(movw(1, 0x1000)); // r1 = 0x20001000
ins(movt(1, 0x2000));
ins(movw(2, 0x0001)); // r2 = 0x5EED0001
ins(movt(2, 0x5eed));
ins(u16(0x600a)); // str r2, [r1]   → *(0x20001000) = 0x5EED0001
ins(movw(3, 0x1004)); // r3 = 0x20001004
ins(movt(3, 0x2000));
ins(u16(0x2001)); // movs r0, #1
ins(u16(0x6018)); // str r0, [r3]   → *(0x20001004) = 1
ins(u16(0x2000)); // movs r0, #0
ins(u16(0xbd80)); // pop {r7, pc}

// ---- ELF 布局 ----
const ehsize = 52;
const shentsize = 40;
const shnum = 5;
const shstrndx = 4;

const textOff = ehsize; // 0x34
const textSize = text.length;
const symtabOff = textOff + textSize;
const symtabSize = 2 * 16;
const strtabOff = symtabOff + symtabSize;
const strtab = Buffer.concat([Buffer.from([0]), Buffer.from("module_main\0")]);
const shstrtab = Buffer.concat([
  Buffer.from([0]),
  Buffer.from(".text\0"),
  Buffer.from(".symtab\0"),
  Buffer.from(".strtab\0"),
  Buffer.from(".shstrtab\0"),
]);
const shstrtabOff = strtabOff + strtab.length;
const shoff = shstrtabOff + shstrtab.length;

// sh_name 索引：1=.text 7=.symtab 15=.strtab 23=.shstrtab
function shdr(name, type, flags, offset, size, link, info, align, entsize) {
  return Buffer.concat([u32(name), u32(type), u32(flags), u32(0), u32(offset), u32(size), u32(link), u32(info), u32(align), u32(entsize)]);
}

const sections = [
  Buffer.alloc(40), // [0] NULL
  shdr(1, 1, 0x6, textOff, textSize, 0, 0, 4, 0), // [1] .text (PROGBITS, ALLOC|EXECINSTR)
  shdr(7, 2, 0, symtabOff, symtabSize, 3, 1, 4, 16), // [2] .symtab (link=.strtab, info=first global=1)
  shdr(15, 3, 0, strtabOff, strtab.length, 0, 0, 1, 0), // [3] .strtab
  shdr(23, 3, 0, shstrtabOff, shstrtab.length, 0, 0, 1, 0), // [4] .shstrtab
];

// symtab[0] NULL, symtab[1] module_main (GLOBAL FUNC, shndx=1 .text, value=0, size=textSize)
// Elf32_Sym 标准布局：st_name(4) st_value(4) st_size(4) st_info(1) st_other(1) st_shndx(2)
const symtab = Buffer.concat([
  Buffer.alloc(16),
  Buffer.concat([u32(1), u32(0), u32(textSize), Buffer.from([0x12, 0]), u16(1)]),
]);

// ELF 头
const ident = Buffer.from([0x7f, 0x45, 0x4c, 0x46, 0x01, 0x01, 0x01, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
const elf = Buffer.concat([
  ident, u16(1), u16(40), u32(1), u32(0), u32(0), u32(shoff),
  u32(0x05000000), u16(ehsize), u16(0), u16(0), u16(shentsize), u16(shnum), u16(shstrndx),
  text, symtab, strtab, shstrtab, ...sections,
]);

// ---- 自校验：字节级回读 ----
const chk = (cond, msg) => { if (!cond) { console.error("self-check FAIL: " + msg); process.exit(1); } };
chk(elf.readUInt32LE(0) === 0x464c457f, "ELF magic");
chk(elf[4] === 1 && elf[5] === 1, "class/data (32LE)");
chk(elf.readUInt16LE(0x12) === 40, "e_machine EM_ARM");
chk(elf.readUInt16LE(0x10) === 1, "e_type ET_REL");
chk(elf.readUInt16LE(0x30) === shnum && elf.readUInt16LE(0x32) === shstrndx, "section count/strndx");
chk(textSize === 36, "text size 36 bytes, got " + textSize);
chk(elf.subarray(textOff, textOff + 2).equals(u16(0xb580)), "first insn push {r7,lr}");
chk(elf.subarray(textOff + textSize - 2, textOff + textSize).equals(u16(0xbd80)), "last insn pop {r7,pc}");
// module_main 符号（Elf32_Sym: name@0, value@4, size@8, info/other@12, shndx@14）
const symOff = symtabOff + 16;
chk(elf.readUInt32LE(symOff) === 1, "module_main st_name");
chk(elf.readUInt32LE(symOff + 4) === 0, "module_main value 0");
chk(elf.readUInt32LE(symOff + 8) === textSize, "module_main size = text size");
chk(elf[symOff + 12] === 0x12 && elf[symOff + 13] === 0, "module_main GLOBAL FUNC, other=0");
chk(elf.readUInt16LE(symOff + 14) === 1, "module_main in .text");
// 文件总大小
chk(elf.length === shoff + shnum * shentsize, "file size consistent");

const outDir = join(root, "payload");
mkdirSync(outDir, { recursive: true });
const out = join(outDir, "module.ko");
writeFileSync(out, elf);

console.log("built:", out, `(${elf.length} bytes)`);
console.log(`text: ${textSize} bytes @0x${textOff.toString(16)}  symtab @0x${symtabOff.toString(16)}  shoff=0x${shoff.toString(16)}`);
console.log("instructions:");
console.log("  push {r7,lr}         ; 0xB580");
console.log("  movw/movt r1,#0x20001000");
console.log("  movw/movt r2,#0x5EED0001");
console.log("  str r2,[r1]          ; marker1 -> 0x20001000");
console.log("  movw/movt r3,#0x20001004");
console.log("  movs r0,#1 / str r0,[r3]  ; marker2 -> 0x20001004");
console.log("  movs r0,#0 / pop {r7,pc}  ; clean return");
console.log("self-check: OK");
