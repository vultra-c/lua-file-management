// tools/build-companion.mjs
// Build a dependency-free, ZIP-compatible Vela QuickApp development package.
// Official AIoT-IDE/aiot should be used for final device signing.
import { createHash } from 'node:crypto'
import { deflateRawSync, deflateSync } from 'node:zlib'
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync, unlinkSync, writeFileSync } from 'node:fs'
import { dirname, join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const sourceRoot = join(root, 'quickapp', 'file-manager', 'src')
const outputRoot = join(root, 'dist')
const manifestPath = join(sourceRoot, 'manifest.json')

function crc32(buffer) {
  let crc = 0xffffffff
  for (const byte of buffer) {
    crc ^= byte
    for (let bit = 0; bit < 8; bit++) crc = (crc >>> 1) ^ ((crc & 1) ? 0xedb88320 : 0)
  }
  return (crc ^ 0xffffffff) >>> 0
}

function pngChunk(type, data) {
  const kind = Buffer.from(type, 'ascii')
  const body = Buffer.concat([kind, data])
  const out = Buffer.alloc(12 + data.length)
  out.writeUInt32BE(data.length, 0)
  body.copy(out, 4)
  out.writeUInt32BE(crc32(body), 8 + data.length)
  return out
}

function buildIcon() {
  // Official Vela guidance recommends a 192x192 application icon.
  const width = 192
  const height = 192
  const scanlines = Buffer.alloc(height * (width * 4 + 1))
  const scale = width / 48
  for (let y = 0; y < height; y++) {
    const line = y * (width * 4 + 1)
    scanlines[line] = 0
    for (let x = 0; x < width; x++) {
      const offset = line + 1 + x * 4
      const inside = x >= 5 * scale && x < 43 * scale && y >= 5 * scale && y < 43 * scale
      const folder = x >= 10 * scale && x < 38 * scale && y >= 17 * scale && y < 34 * scale
      const tab = x >= 13 * scale && x < 24 * scale && y >= 13 * scale && y < 19 * scale
      const paper = x >= 18 * scale && x < 31 * scale && y >= 20 * scale && y < 31 * scale
      const color = !inside ? [0, 0, 0, 0] : paper ? [255, 255, 255, 255] : (folder || tab) ? [242, 196, 66, 255] : [18, 42, 72, 255]
      color.forEach((value, index) => { scanlines[offset + index] = value })
    }
  }
  const header = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
  const ihdr = Buffer.alloc(13)
  ihdr.writeUInt32BE(width, 0)
  ihdr.writeUInt32BE(height, 4)
  ihdr[8] = 8
  ihdr[9] = 6
  // PNG IDAT uses a zlib-wrapped stream; ZIP entries below use raw deflate.
  const idat = deflateSync(scanlines)
  return Buffer.concat([header, pngChunk('IHDR', ihdr), pngChunk('IDAT', idat), pngChunk('IEND', Buffer.alloc(0))])
}

function walk(dir, files = []) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name)
    const info = statSync(path)
    if (info.isDirectory()) walk(path, files)
    else files.push(path)
  }
  return files
}

function readSources() {
  const iconPath = join(sourceRoot, 'common', 'icon.png')
  if (!existsSync(iconPath)) {
    mkdirSync(dirname(iconPath), { recursive: true })
    writeFileSync(iconPath, buildIcon())
  }
  const files = walk(sourceRoot)
  return files.map((path) => ({
    name: relative(sourceRoot, path).replaceAll('\\', '/'),
    data: readFileSync(path),
  }))
}

function dosTime() {
  return { time: 0, date: 0x21 }
}

function makeZip(entries) {
  const locals = []
  const centrals = []
  let offset = 0
  const { time, date } = dosTime()
  for (const entry of entries) {
    const name = Buffer.from(entry.name, 'utf8')
    const compressed = deflateRawSync(entry.data, { level: 9 })
    const crc = crc32(entry.data)
    const local = Buffer.alloc(30 + name.length)
    local.writeUInt32LE(0x04034b50, 0)
    local.writeUInt16LE(20, 4)
    local.writeUInt16LE(0, 6)
    local.writeUInt16LE(8, 8)
    local.writeUInt16LE(time, 10)
    local.writeUInt16LE(date, 12)
    local.writeUInt32LE(crc, 14)
    local.writeUInt32LE(compressed.length, 18)
    local.writeUInt32LE(entry.data.length, 22)
    local.writeUInt16LE(name.length, 26)
    local.writeUInt16LE(0, 28)
    name.copy(local, 30)
    locals.push(local, compressed)

    const central = Buffer.alloc(46 + name.length)
    central.writeUInt32LE(0x02014b50, 0)
    central.writeUInt16LE(20, 4)
    central.writeUInt16LE(20, 6)
    central.writeUInt16LE(0, 8)
    central.writeUInt16LE(8, 10)
    central.writeUInt16LE(time, 12)
    central.writeUInt16LE(date, 14)
    central.writeUInt32LE(crc, 16)
    central.writeUInt32LE(compressed.length, 20)
    central.writeUInt32LE(entry.data.length, 24)
    central.writeUInt16LE(name.length, 28)
    central.writeUInt16LE(0, 30)
    central.writeUInt16LE(0, 32)
    central.writeUInt16LE(0, 34)
    central.writeUInt16LE(0, 36)
    central.writeUInt32LE(0, 38)
    central.writeUInt32LE(offset, 42)
    name.copy(central, 46)
    centrals.push(central)
    offset += local.length + compressed.length
  }

  const centralDirectory = Buffer.concat(centrals)
  const body = Buffer.concat([...locals, centralDirectory])
  const end = Buffer.alloc(22)
  end.writeUInt32LE(0x06054b50, 0)
  end.writeUInt16LE(0, 4)
  end.writeUInt16LE(0, 6)
  end.writeUInt16LE(entries.length, 8)
  end.writeUInt16LE(entries.length, 10)
  end.writeUInt32LE(centralDirectory.length, 12)
  end.writeUInt32LE(offset, 16)
  end.writeUInt16LE(0, 20)
  return Buffer.concat([body, end])
}

function main() {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'))
  if (!manifest.package || !manifest.router || !manifest.minAPILevel || !manifest.versionName || !manifest.versionCode || !manifest.deviceTypeList.includes('watch')) throw new Error('invalid watch manifest')
  const featureNames = new Set((manifest.features || []).map((feature) => feature.name))
  for (const requiredFeature of ['system.app', 'system.file', 'system.prompt', 'system.vibrator']) {
    if (!featureNames.has(requiredFeature)) throw new Error(`missing manifest feature: ${requiredFeature}`)
  }
  const packageName = `${manifest.package}.debug.${manifest.versionName}.rpk`
  const entries = readSources()
  const names = new Set(entries.map((entry) => entry.name))
  for (const required of ['manifest.json', 'app.ux', 'pages/files/files.ux', 'common/icon.png']) {
    if (!names.has(required)) throw new Error(`missing package entry: ${required}`)
  }
  const packageData = makeZip(entries)
  mkdirSync(outputRoot, { recursive: true })
  for (const name of readdirSync(outputRoot)) {
    if (name.startsWith(`${manifest.package}.debug.`) && name.endsWith('.rpk') && name !== packageName) {
      unlinkSync(join(outputRoot, name))
    }
  }
  const outputPath = join(outputRoot, packageName)
  writeFileSync(outputPath, packageData)
  const metadata = {
    package: manifest.package,
    file: packageName,
    bytes: packageData.length,
    sha256: createHash('sha256').update(packageData).digest('hex'),
    entries: entries.map((entry) => ({ name: entry.name, bytes: entry.data.length })),
    note: 'ZIP-compatible development RPK; rebuild/sign with official AIoT-IDE for device installation.',
  }
  writeFileSync(join(outputRoot, 'velafiles-companion.manifest.json'), JSON.stringify(metadata, null, 2) + '\n')
  console.log(`built ${outputPath} (${packageData.length} bytes)`)
  console.log(`entries: ${entries.length}`)
  console.log(`sha256: ${metadata.sha256}`)
}

main()
