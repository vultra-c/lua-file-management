// scripts/face-lib.mjs
// Vela/MiWear Lua 表盘 .face 容器格式（Face V2，小米手环 8 Pro / 9 / 9 Pro / Watch S3）
//
// 格式依据：m0tral/UnpackMiColorFace 的 FaceV2Decompiler 源码 + 真实 9 Pro 样本逆向。
//
// 布局：
//   header 0x00..0x10F
//     - 0x00 magic 5A A5 34 12
//     - 0x10 = 2048；0x1C = 1（face slot 数）
//     - 0x20 = 预览块偏移；0x28 = 10 字节 ASCII 表盘 ID；0x68 = UTF-8 标题
//     - 0xA8 backImageId(=0)；0xAC previewImageOffset(=预览块偏移)
//     - 0xB0..0xFF 10 个 8 字节描述符 [count][offset]：
//         i=0 elements / i=2 单图 / i=3 图列表 / i=5 应用(lua) / i=7 widgets / i=9 动作
//     - 0x100 element 记录（16 字节）
//   TOC 0x110：16 字节条目 [id=(5<<24)|i][0][offset][size]，以 (5<<24)|0x14 终止
//   文件记录：[u16 size&0xFFFF][u8 size>>16][u8 nameLen][16B 0] + name + data，4 字节对齐
//   预览块（末尾）：RLEv11 压缩的 RGBA 图像，magic 0x5AA521E0

export const MAGIC = Buffer.from([0x5a, 0xa5, 0x34, 0x12]);
export const HEADER_SIZE = 0x110;
export const RECORD_HEADER_SIZE = 20;
export const ID_OFFSET = 0x28;
export const ID_SIZE = 10;
export const TITLE_OFFSET = 0x68;
export const TITLE_MAX = 0xa8 - 0x68;

export const PREVIEW_MAGIC = 0x5aa521e0;
export const PREVIEW_W = 230; // 与官方 9 Pro 样本一致（336x480 的等比缩略）
export const PREVIEW_H = 328;

function u32(v) {
  const b = Buffer.alloc(4);
  b.writeUInt32LE(v >>> 0);
  return b;
}

// 构建单条文件记录
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

// RLEv11 压缩（recordSize 字节/像素）。控制字节：高位置 1 表示重复，低 7 位 = 记录数-1。
function sameRecord(rgba, a, b, recordSize) {
  const off = a * recordSize;
  for (let i = 0; i < recordSize; i++) {
    if (rgba[off + i] !== rgba[b * recordSize + i]) return false;
  }
  return true;
}

export function encodeRLEv11(rgba, recordSize = 4) {
  const n = Math.floor(rgba.length / recordSize);
  const out = [];
  let i = 0;
  while (i < n) {
    let j = i + 1;
    while (j < n && j - i < 128 && sameRecord(rgba, i, j, recordSize)) j++;
    const runLen = j - i;
    if (runLen >= 2) {
      out.push(0x80 | (runLen - 1));
      for (let k = 0; k < recordSize; k++) out.push(rgba[i * recordSize + k]);
      i = j;
    } else {
      let k = i;
      while (k < n && k - i < 128) {
        if (k + 1 < n && sameRecord(rgba, k, k + 1, recordSize)) break;
        k++;
      }
      const uniqLen = k - i;
      out.push(uniqLen - 1);
      for (let x = i; x < k; x++) for (let c = 0; c < recordSize; c++) out.push(rgba[x * recordSize + c]);
      i = k;
    }
  }
  return Buffer.from(out);
}

// 解码 RLEv11（用于自校验）
export function decodeRLEv11(data, destRecords, recordSize = 4) {
  const out = Buffer.alloc(destRecords * recordSize);
  let offset = 0, len = 0;
  while (offset < data.length && len < destRecords) {
    const control = data[offset++];
    const size = control & 0x7f;
    if ((control & 0x80) === 0x80) {
      if (offset + recordSize > data.length) break;
      const rec = data.subarray(offset, offset + recordSize);
      for (let i = 0; i <= size && len < destRecords; i++, len++) rec.copy(out, len * recordSize);
      offset += recordSize;
    } else {
      for (let i = 0; i <= size && len < destRecords; i++, len++) {
        if (offset + recordSize > data.length) break;
        data.copy(out, len * recordSize, offset, offset + recordSize);
        offset += recordSize;
      }
    }
  }
  return out;
}

// 构建预览块（RGBA 像素，RLEv11 压缩）
export function buildPreviewBlock(rgba, width = PREVIEW_W, height = PREVIEW_H) {
  if (rgba.length !== width * height * 4) throw new Error("preview rgba size mismatch");
  const stream = encodeRLEv11(rgba, 4);
  const count = 1; // 单帧预览
  const cpr = Buffer.concat([u32(count), Buffer.from([0]), stream, u32(count), u32(0)]);
  const dataLen = 8 + cpr.length; // magic(4) + compressType(4) + cpr
  const bin = Buffer.alloc(20 + cpr.length);
  bin[0] = 0; // rle 标志（9 Pro 样本为 0）
  bin[1] = 4; // type
  bin.writeUInt16LE(width, 4);
  bin.writeUInt16LE(height, 6);
  bin.writeUInt32LE(dataLen, 8);
  bin.writeUInt32LE(PREVIEW_MAGIC, 12);
  bin.writeUInt32LE(((width * height * 4) << 4) | 4, 16); // compressType = 未压缩大小<<4 | type
  cpr.copy(bin, 20);
  return bin;
}

// 构建完整 .face
export function buildFace(files, { id, title, previewRgba } = {}) {
  if (!/^[0-9]{1,10}$/.test(id || "")) throw new Error(`bad watchface id: ${id}`);
  const idBuf = Buffer.alloc(ID_SIZE, 0);
  idBuf.write(id, 0, "ascii");
  const titleBuf = Buffer.from(String(title || "watchface"), "utf8");
  const titleSlice = titleBuf.subarray(0, TITLE_MAX - 1);

  const records = files.map((f) => buildRecord(f.name, f.data));
  const fileCount = records.length;

  const tocStart = HEADER_SIZE; // 0x110
  const terminatorOffset = tocStart + fileCount * 16;
  const recordsStart = tocStart + (fileCount + 1) * 16;

  // TOC + 记录区（每记录 4 字节对齐）
  let cursor = recordsStart;
  const toc = [];
  records.forEach((rec, i) => {
    const e = Buffer.alloc(16, 0);
    e.writeUInt32LE((5 << 24) | i, 0);
    e.writeUInt32LE(cursor, 8);
    e.writeUInt32LE(rec.size, 12);
    toc.push(e);
    cursor += rec.size + ((4 - (rec.size % 4)) % 4);
  });
  const term = Buffer.alloc(16, 0);
  term.writeUInt32LE((5 << 24) | RECORD_HEADER_SIZE, 0); // 终止哨兵（与官方一致）
  toc.push(term);

  const previewOffset = cursor;
  const rgba = previewRgba || null;
  const previewBlock = buildPreviewBlock(rgba || Buffer.alloc(PREVIEW_W * PREVIEW_H * 4), PREVIEW_W, PREVIEW_H);
  const payloadEnd = previewOffset + previewBlock.length;

  // 头部
  const head = Buffer.alloc(HEADER_SIZE, 0);
  MAGIC.copy(head, 0);
  head.writeUInt32LE(2048, 0x10);
  head.writeUInt32LE(1, 0x1c); // face slot 数
  head.writeUInt32LE(previewOffset, 0x20); // 预览块偏移
  idBuf.copy(head, ID_OFFSET);
  titleSlice.copy(head, TITLE_OFFSET);
  head.writeUInt32LE(0, 0xa8); // backImageId
  head.writeUInt32LE(previewOffset, 0xac); // previewImageOffset

  const desc = (o, count, off) => {
    head.writeUInt32LE(count, o);
    head.writeUInt32LE(off, o + 4);
  };
  desc(0xb0, 1, 0x100); // i=0 elements
  desc(0xb8, 0, tocStart); // i=1
  desc(0xc0, 0, tocStart); // i=2 image single
  desc(0xc8, 0, tocStart); // i=3 image list
  desc(0xd0, 0, tocStart); // i=4
  desc(0xd8, fileCount, tocStart); // i=5 apps（lua 文件）
  desc(0xe0, 0, terminatorOffset); // i=6
  desc(0xe8, 0, terminatorOffset); // i=7 widgets
  desc(0xf0, 0, terminatorOffset); // i=8
  desc(0xf8, 0, terminatorOffset); // i=9 action

  // element 记录 @0x100：指向 TOC 终止条目（与官方样本一致）
  head.writeUInt16LE(0, 0x100);
  head.writeUInt32LE(terminatorOffset, 0x108);
  head.writeUInt32LE(0x10, 0x10c);

  // 拼装
  const out = Buffer.alloc(payloadEnd);
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
  if (o !== previewOffset) throw new Error(`internal: layout mismatch ${o} != ${previewOffset}`);
  previewBlock.copy(out, previewOffset);
  return { face: out, records, payloadEnd, previewOffset };
}

// 解析 .face（校验/解包）
export function parseFace(buf) {
  if (!buf.subarray(0, 4).equals(MAGIC)) throw new Error("bad magic");
  const id = buf.subarray(ID_OFFSET, ID_OFFSET + ID_SIZE).toString("ascii").replace(/\0+$/, "");
  const title = buf.subarray(TITLE_OFFSET, 0xa8).toString("utf8").replace(/\0+$/, "");
  const previewOffset = buf.readUInt32LE(0x20);
  const previewImageOffset = buf.readUInt32LE(0xac);
  const fileCount = buf.readUInt32LE(0xd8); // apps 描述符的 count

  let preview = null;
  if (previewOffset > 0 && previewOffset + 20 <= buf.length && buf.readUInt32LE(previewOffset + 12) === PREVIEW_MAGIC) {
    const w = buf.readUInt16LE(previewOffset + 4);
    const h = buf.readUInt16LE(previewOffset + 6);
    const dataLen = buf.readUInt32LE(previewOffset + 8);
    preview = { offset: previewOffset, width: w, height: h, dataLen, blockLen: dataLen + 12 };
  }

  const files = [];
  let o = HEADER_SIZE;
  for (let i = 0; i < fileCount; i++) {
    if (o + 16 > buf.length) break;
    const off = buf.readUInt32LE(o + 8);
    const size = buf.readUInt32LE(o + 12);
    if (off === 0 && size === 0) break;
    const nlen = buf[off + 3];
    const dlen = buf.readUInt16LE(off) | (buf[off + 2] << 16);
    const name = buf.subarray(off + RECORD_HEADER_SIZE, off + RECORD_HEADER_SIZE + nlen).toString("utf8");
    files.push({
      index: i,
      name,
      data: buf.subarray(off + RECORD_HEADER_SIZE + nlen, off + RECORD_HEADER_SIZE + nlen + dlen),
      offset: off,
      size,
    });
    o += 16;
  }
  return { id, title, previewOffset, previewImageOffset, fileCount, preview, files };
}
