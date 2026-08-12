// scripts/face-lib.mjs
// Vela/MiWear Lua 表盘 .face 容器格式（社区/EasyFace 兼容格式）
//
// 格式说明（由真实小米手环 9 Pro 表盘样本逆向确认）：
//   header   : 0x00 magic 5A A5 34 12；0x04-0x07 全零；0x10=2048；0x1C=1；
//              0x20 与 0xAC = 载荷结束偏移；0x28 起 10 字节 ASCII 表盘 ID；
//              0x68 起 UTF-8 标题；0xB0..0x10F 为 96 字节元数据块（与屏幕
//              分辨率相关，336x480 设备的样本值直接复用）；
//   toc      : 0x110 起 16 字节条目 [u32 (5<<24)|index][u32 0][u32 offset][u32 size]，
//              以 offset==0 && size==0 结尾；offset 指向记录起点、size 为记录总长；
//   record   : [u16 LE data_size&0xFFFF][u8 data_size>>16][u8 name_len][16 字节 0]
//              + name(UTF-8 路径) + data；记录按 4 字节对齐，间隔补零。

export const MAGIC = Buffer.from([0x5a, 0xa5, 0x34, 0x12]);
export const HEADER_SIZE = 0x110; // 固定 272 字节头部（含 96 字节元数据块）
export const RECORD_HEADER_SIZE = 20;
export const ID_OFFSET = 0x28;
export const ID_SIZE = 10; // 官方样本：9 位数字 ID + 1 个补零字节
export const TITLE_OFFSET = 0x68;
export const TITLE_MAX = 0xac - 0x68;
// 336x480 设备（Band 9 / 9 Pro / 8 Pro）的 96 字节元数据块，取自真实样本
// 结构：6 条 16 字节条目 [u32 a][u32 b][u32 off][u32 size]（样式/预览相关，设备无关）
export const META_BLOCK = Buffer.from(
  "010000000001000000000000100100000000000010010000000000001001000000000000100100002b0000001001000000000000c003000000000000c003000000000000c003000000000000c00300000000000000000000c003000010000000",
  "hex",
);
if (META_BLOCK.length !== 0x60) throw new Error("internal: META_BLOCK length");

// 构建单条记录：返回 { header, name, data, size }
export function buildRecord(name, data) {
  const nameBuf = Buffer.from(name, "utf8");
  if (nameBuf.length > 255) throw new Error(`record name too long: ${name}`);
  if (data.length >= 0x1000000) throw new Error(`record data too large: ${name}`);
  const header = Buffer.alloc(RECORD_HEADER_SIZE, 0);
  header.writeUInt16LE(data.length & 0xffff, 0);
  header[2] = (data.length >>> 16) & 0xff;
  header[3] = nameBuf.length;
  return { header, name: nameBuf, data, size: RECORD_HEADER_SIZE + nameBuf.length + data.length };
}

// 构建完整 .face：files = [{ name, data }]
// options: { id: string, title: string, power: number }
export function buildFace(files, { id, title, power = 1 } = {}) {
  if (!/^[0-9]{1,10}$/.test(id || "")) throw new Error(`bad watchface id: ${id}`);
  const idBuf = Buffer.alloc(ID_SIZE, 0); // 0x28..0x31，与官方样本一致
  idBuf.write(id, 0, "ascii");
  const titleBuf = Buffer.from(String(title || "watchface"), "utf8");
  const titleSlice = titleBuf.subarray(0, TITLE_MAX - 1);

  // 1) 记录
  const records = files.map((f) => buildRecord(f.name, f.data));

  // 2) TOC 条目数：N 条文件 + 1 条终止（6 条元数据已包含在 272 字节头部内）
  const tocEntries = records.length + 1;
  const tocStart = HEADER_SIZE;
  const recordsStart = tocStart + tocEntries * 16; // 4 字节对齐（272 与 16 都是 4 的倍数）

  // 3) 拼装记录区（每条后补零对齐到 4 字节）
  const payload = Buffer.alloc(0);
  let cursor = recordsStart;
  const toc = [];
  records.forEach((rec, i) => {
    const entry = Buffer.alloc(16, 0);
    entry.writeUInt32LE((5 << 24) | i, 0); // type=5, index=i
    entry.writeUInt32LE(cursor, 8);
    entry.writeUInt32LE(rec.size, 12);
    toc.push(entry);
    cursor += rec.size;
    const pad = (4 - (rec.size % 4)) % 4;
    cursor += pad;
  });
  // 终止条目（与样本一致：index 位为记录头大小 20）
  const term = Buffer.alloc(16, 0);
  term.writeUInt32LE((5 << 24) | 20, 0);
  toc.push(term);
  if (toc.length !== tocEntries) throw new Error(`internal: toc count ${toc.length} != ${tocEntries}`);

  // 4) 头部（与官方 9 Pro 样本逐字节一致：0x04-0x07 全零）
  const head = Buffer.alloc(HEADER_SIZE, 0);
  MAGIC.copy(head, 0);
  head.writeUInt32LE(2048, 0x10);
  head.writeUInt32LE(1, 0x1c);
  const payloadEnd = cursor; // 最后一条记录（含对齐）的结束偏移
  head.writeUInt32LE(payloadEnd, 0x20);
  idBuf.copy(head, ID_OFFSET);
  titleSlice.copy(head, TITLE_OFFSET);
  head.writeUInt32LE(payloadEnd, 0xac);
  META_BLOCK.copy(head, 0xb0);

  // 5) 拼装
  const out = Buffer.alloc(HEADER_SIZE + tocEntries * 16 + payloadEnd - recordsStart);
  head.copy(out, 0);
  let o = tocStart;
  for (const e of toc) {
    e.copy(out, o);
    o += 16;
  }
  for (const rec of records) {
    rec.header.copy(out, o);
    o += RECORD_HEADER_SIZE;
    rec.name.copy(out, o);
    o += rec.name.length;
    rec.data.copy(out, o);
    o += rec.data.length;
    o += (4 - (rec.size % 4)) % 4;
  }
  if (o !== payloadEnd) throw new Error(`internal: layout mismatch ${o} != ${payloadEnd}`);
  return { face: out, records, payloadEnd };
}

// 解析 .face：返回 { id, title, payloadEnd, files: [{name, data, offset, size}] }
export function parseFace(buf) {
  if (!buf.subarray(0, 4).equals(MAGIC)) throw new Error("bad magic");
  const idLen = buf[5] || ID_SIZE;
  const id = buf.subarray(ID_OFFSET, ID_OFFSET + Math.max(idLen, ID_SIZE)).toString("ascii").replace(/\0+$/, "");
  let title = buf.subarray(TITLE_OFFSET, 0xac).toString("utf8").replace(/\0+$/, "");
  const payloadEnd = buf.readUInt32LE(0x20);

  // TOC：跳过 6 条元数据
  const files = [];
  let o = HEADER_SIZE;
  for (;;) {
    if (o + 16 > buf.length) break;
    const a = buf.readUInt32LE(o);
    const z = buf.readUInt32LE(o + 4);
    const off = buf.readUInt32LE(o + 8);
    const size = buf.readUInt32LE(o + 12);
    if (off === 0 && size === 0) break; // 终止
    if ((a >>> 24) === 5) {
      const nlen = buf[off + 3];
      const dlen = buf.readUInt16LE(off) | (buf[off + 2] << 16);
      const name = buf.subarray(off + RECORD_HEADER_SIZE, off + RECORD_HEADER_SIZE + nlen).toString("utf8");
      files.push({ index: a & 0xffffff, name, data: buf.subarray(off + RECORD_HEADER_SIZE + nlen, off + RECORD_HEADER_SIZE + nlen + dlen), offset: off, size });
    }
    o += 16;
  }
  return { id, title, payloadEnd, files };
}
