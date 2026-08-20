// tools/verify-companion.mjs
import { inflateRawSync, inflateSync } from 'node:zlib'
import { readFileSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const rpk = process.argv[2] || join(root, 'dist', 'com.deepscan.velafiles.debug.0.4.0.rpk')
const data = readFileSync(rpk)

function readEntries(buffer) {
  const end = buffer.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]))
  if (end < 0) throw new Error('missing ZIP end record')
  const count = buffer.readUInt16LE(end + 10)
  const centralSize = buffer.readUInt32LE(end + 12)
  const centralOffset = buffer.readUInt32LE(end + 16)
  if (centralOffset + centralSize > buffer.length) throw new Error('central directory outside file')
  const entries = []
  let cursor = centralOffset
  for (let index = 0; index < count; index++) {
    if (buffer.readUInt32LE(cursor) !== 0x02014b50) throw new Error(`bad central entry ${index}`)
    const compressedSize = buffer.readUInt32LE(cursor + 20)
    const uncompressedSize = buffer.readUInt32LE(cursor + 24)
    const nameLength = buffer.readUInt16LE(cursor + 28)
    const extraLength = buffer.readUInt16LE(cursor + 30)
    const commentLength = buffer.readUInt16LE(cursor + 32)
    const localOffset = buffer.readUInt32LE(cursor + 42)
    const name = buffer.toString('utf8', cursor + 46, cursor + 46 + nameLength)
    if (buffer.readUInt32LE(localOffset) !== 0x04034b50) throw new Error(`bad local entry ${name}`)
    const localNameLength = buffer.readUInt16LE(localOffset + 26)
    const localExtraLength = buffer.readUInt16LE(localOffset + 28)
    const start = localOffset + 30 + localNameLength + localExtraLength
    const compressed = buffer.subarray(start, start + compressedSize)
    const content = buffer.readUInt16LE(localOffset + 8) === 0 ? compressed : inflateRawSync(compressed)
    if (content.length !== uncompressedSize) throw new Error(`size mismatch ${name}`)
    entries.push({ name, content })
    cursor += 46 + nameLength + extraLength + commentLength
  }
  return entries
}

const entries = readEntries(data)
const names = new Set(entries.map((entry) => entry.name))
for (const required of ['manifest.json', 'app.ux', 'pages/files/files.ux', 'common/icon.png']) {
  if (!names.has(required)) throw new Error(`missing ${required}`)
}
const manifest = JSON.parse(entries.find((entry) => entry.name === 'manifest.json').content.toString('utf8'))
if (manifest.deviceTypeList?.includes('watch') !== true) throw new Error('manifest is not watch-only')
if (manifest.versionName !== '0.4.0' || manifest.versionCode !== 4) throw new Error('manifest version must be 0.4.0/4')
if (manifest.minAPILevel !== 1) throw new Error('manifest minAPILevel must be 1')
for (const requiredFeature of ['system.app', 'system.file', 'system.prompt', 'system.vibrator']) {
  if (manifest.features?.some((feature) => feature.name === requiredFeature) !== true) throw new Error(`${requiredFeature} feature missing`)
}
const page = entries.find((entry) => entry.name === 'pages/files/files.ux').content.toString('utf8')
for (const marker of ['@system.file', 'file.list', 'file.get', 'file.writeText', 'file.readText', 'internal://files/.velafiles-bridge/', 'Lua backend via Files watchface']) {
  if (!page.includes(marker)) throw new Error(`page marker missing: ${marker}`)
}
if (page.includes('/data/vela_filemanager.request')) throw new Error('page contains obsolete bridge path')
if (!page.includes("'ready=1'") || !page.includes("requestSystem('LIST'") || !page.includes("requestSystem('DELETE'")) throw new Error('bridge request protocol missing')
const icon = entries.find((entry) => entry.name === 'common/icon.png').content
const pngSignature = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
if (icon.length < 64 || !icon.subarray(0, 8).equals(pngSignature)) throw new Error('icon is not a PNG')
let pngCursor = 8
let idatParts = []
let sawIhdr = false
let sawIend = false
while (pngCursor + 12 <= icon.length) {
  const length = icon.readUInt32BE(pngCursor)
  const type = icon.toString('ascii', pngCursor + 4, pngCursor + 8)
  const dataStart = pngCursor + 8
  const dataEnd = dataStart + length
  if (dataEnd + 4 > icon.length) throw new Error('truncated PNG chunk')
  if (type === 'IHDR') {
    if (length !== 13 || icon.readUInt32BE(dataStart) !== 192 || icon.readUInt32BE(dataStart + 4) !== 192) throw new Error('icon must be 192x192')
    sawIhdr = true
  } else if (type === 'IDAT') {
    idatParts.push(icon.subarray(dataStart, dataEnd))
  } else if (type === 'IEND') {
    sawIend = true
    break
  }
  pngCursor = dataEnd + 4
}
if (!sawIhdr || !sawIend || idatParts.length === 0) throw new Error('incomplete PNG')
const pixels = inflateSync(Buffer.concat(idatParts))
if (pixels.length !== 192 * (192 * 4 + 1)) throw new Error('PNG pixel stream size mismatch')
console.log(`companion verification: PASS (${data.length} bytes, ${entries.length} entries)`)
