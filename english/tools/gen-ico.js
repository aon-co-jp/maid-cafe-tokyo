// icon-32.png / icon-192.png から Windows用 .ico を生成する(外部ツール
// 非依存)。モダンWindows(Vista以降)のICOフォーマットは、各エントリの
// 画像データとしてPNGバイト列をそのまま埋め込むことをサポートしている
// ため、独自のBMPラスタライズは不要——既存のPNGを再利用するだけでよい。
"use strict";
const fs = require("fs");
const path = require("path");

const iconsDir = path.join(__dirname, "..", "icons");
const entries = [
  { size: 32, file: "icon-32.png" },
  { size: 192, file: "icon-192.png" },
];

const images = entries.map((e) => fs.readFileSync(path.join(iconsDir, e.file)));

const headerSize = 6;
const dirEntrySize = 16;
let offset = headerSize + dirEntrySize * entries.length;

const header = Buffer.alloc(headerSize);
header.writeUInt16LE(0, 0); // reserved
header.writeUInt16LE(1, 2); // type: icon
header.writeUInt16LE(entries.length, 4);

const dirEntries = [];
for (let i = 0; i < entries.length; i++) {
  const e = entries[i];
  const img = images[i];
  const entry = Buffer.alloc(dirEntrySize);
  entry.writeUInt8(e.size >= 256 ? 0 : e.size, 0); // width (0 = 256)
  entry.writeUInt8(e.size >= 256 ? 0 : e.size, 1); // height
  entry.writeUInt8(0, 2); // color palette
  entry.writeUInt8(0, 3); // reserved
  entry.writeUInt16LE(1, 4); // color planes
  entry.writeUInt16LE(32, 6); // bits per pixel
  entry.writeUInt32LE(img.length, 8); // image data size
  entry.writeUInt32LE(offset, 12); // offset
  dirEntries.push(entry);
  offset += img.length;
}

const out = Buffer.concat([header, ...dirEntries, ...images]);
const outFile = path.join(iconsDir, "open-english.ico");
fs.writeFileSync(outFile, out);
console.log(`wrote ${outFile} (${out.length} bytes)`);
