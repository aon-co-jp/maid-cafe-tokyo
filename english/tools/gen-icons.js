// アイコン生成スクリプト(外部画像ツール非依存、Node.js標準のzlibのみ使用)。
// SVGレンダラ・PIL・ImageMagick等がこの開発環境に一切無いため、
// 手書きのラスタライズ+手書きPNGエンコーダで生成する(正直な開示:
// 実際のキャラクターSVGを忠実に再現したものではなく、同じ配色・
// シルエット〈紺の背景+ピンクのパネル+黒髪+メイド服〉を単純な図形で
// 再現した簡易版アイコン)。
"use strict";
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");

function crc32(buf) {
  let c;
  const table = crc32.table || (crc32.table = (() => {
    const t = new Uint32Array(256);
    for (let n = 0; n < 256; n++) {
      c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      t[n] = c;
    }
    return t;
  })());
  let crc = 0xffffffff;
  for (let i = 0; i < buf.length; i++) crc = table[(crc ^ buf[i]) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const typeBuf = Buffer.from(type, "ascii");
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}

function encodePng(width, height, rgba) {
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // color type RGBA
  ihdr[10] = 0;
  ihdr[11] = 0;
  ihdr[12] = 0;
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    const rowStart = y * (width * 4 + 1);
    raw[rowStart] = 0; // no filter
    rgba.copy(raw, rowStart + 1, y * width * 4, (y + 1) * width * 4);
  }
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    sig,
    chunk("IHDR", ihdr),
    chunk("IDAT", idat),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

function setPixel(rgba, w, x, y, r, g, b, a) {
  if (x < 0 || y < 0 || x >= w) return;
  const i = (y * w + x) * 4;
  if (i < 0 || i + 3 >= rgba.length) return;
  rgba[i] = r;
  rgba[i + 1] = g;
  rgba[i + 2] = b;
  rgba[i + 3] = a;
}

function fillCircle(rgba, w, h, cx, cy, r, color) {
  const [cr, cg, cb, ca] = color;
  for (let y = Math.max(0, cy - r); y <= Math.min(h - 1, cy + r); y++) {
    for (let x = Math.max(0, cx - r); x <= Math.min(w - 1, cx + r); x++) {
      const dx = x - cx, dy = y - cy;
      if (dx * dx + dy * dy <= r * r) setPixel(rgba, w, x, y, cr, cg, cb, ca);
    }
  }
}

function fillRoundedRect(rgba, w, h, x0, y0, x1, y1, radius, color) {
  const [cr, cg, cb, ca] = color;
  for (let y = Math.max(0, y0); y <= Math.min(h - 1, y1); y++) {
    for (let x = Math.max(0, x0); x <= Math.min(w - 1, x1); x++) {
      let inside = true;
      if (x < x0 + radius && y < y0 + radius) {
        const dx = x0 + radius - x, dy = y0 + radius - y;
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x > x1 - radius && y < y0 + radius) {
        const dx = x - (x1 - radius), dy = y0 + radius - y;
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x < x0 + radius && y > y1 - radius) {
        const dx = x0 + radius - x, dy = y - (y1 - radius);
        inside = dx * dx + dy * dy <= radius * radius;
      } else if (x > x1 - radius && y > y1 - radius) {
        const dx = x - (x1 - radius), dy = y - (y1 - radius);
        inside = dx * dx + dy * dy <= radius * radius;
      }
      if (inside) setPixel(rgba, w, x, y, cr, cg, cb, ca);
    }
  }
}

function drawIcon(size) {
  const w = size, h = size;
  const rgba = Buffer.alloc(w * h * 4);
  // 背景: 紺(open-englishのページ背景色 #1a1220 に近い色)、角丸。
  fillRoundedRect(rgba, w, h, 0, 0, w - 1, h - 1, Math.round(w * 0.16), [26, 18, 32, 255]);
  // キャラクター周りの薄いピンクパネル。
  const panelPad = Math.round(w * 0.1);
  fillRoundedRect(rgba, w, h, panelPad, Math.round(h * 0.18), w - panelPad, h - Math.round(h * 0.06), Math.round(w * 0.14), [251, 228, 236, 255]);
  // 顔(肌色)。
  const cx = Math.round(w * 0.5), cy = Math.round(h * 0.46), rFace = Math.round(w * 0.22);
  fillCircle(rgba, w, h, cx, cy, rFace, [240, 207, 160, 255]);
  // 黒髪(頭頂のドーム)。
  fillRoundedRect(rgba, w, h, cx - rFace - 2, cy - rFace - Math.round(rFace * 0.9), cx + rFace + 2, cy - Math.round(rFace * 0.15), Math.round(rFace * 0.9), [26, 20, 24, 255]);
  fillCircle(rgba, w, h, cx, cy - Math.round(rFace * 0.15), rFace, [240, 207, 160, 255]); // 顔を再度上書きして黒髪を額の高さで切る
  fillRoundedRect(rgba, w, h, cx - rFace - 2, cy - rFace - Math.round(rFace * 0.55), cx + rFace + 2, cy - Math.round(rFace * 0.5), Math.round(rFace * 0.5), [26, 20, 24, 255]);
  // 目(2つの小さい黒丸)。
  const eyeDx = Math.round(rFace * 0.42), eyeDy = Math.round(rFace * 0.05), eyeR = Math.max(1, Math.round(rFace * 0.11));
  fillCircle(rgba, w, h, cx - eyeDx, cy + eyeDy, eyeR, [30, 20, 30, 255]);
  fillCircle(rgba, w, h, cx + eyeDx, cy + eyeDy, eyeR, [30, 20, 30, 255]);
  // 頬のピンク。
  fillCircle(rgba, w, h, cx - Math.round(rFace * 0.55), cy + Math.round(rFace * 0.35), Math.max(1, Math.round(rFace * 0.13)), [245, 170, 190, 140]);
  fillCircle(rgba, w, h, cx + Math.round(rFace * 0.55), cy + Math.round(rFace * 0.35), Math.max(1, Math.round(rFace * 0.13)), [245, 170, 190, 140]);
  // メイド服の襟(白いパネル、顔の下)。
  fillRoundedRect(rgba, w, h, cx - Math.round(rFace * 1.3), cy + rFace + Math.round(rFace * 0.1), cx + Math.round(rFace * 1.3), h - Math.round(h * 0.08), Math.round(rFace * 0.3), [30, 24, 34, 255]);
  fillRoundedRect(rgba, w, h, cx - Math.round(rFace * 0.9), cy + rFace + Math.round(rFace * 0.25), cx + Math.round(rFace * 0.9), h - Math.round(h * 0.1), Math.round(rFace * 0.25), [250, 245, 247, 255]);
  return encodePng(w, h, rgba);
}

const outDir = path.join(__dirname, "..", "icons");
fs.mkdirSync(outDir, { recursive: true });
const sizes = [32, 180, 192, 512];
for (const s of sizes) {
  const buf = drawIcon(s);
  const file = path.join(outDir, `icon-${s}.png`);
  fs.writeFileSync(file, buf);
  console.log(`wrote ${file} (${buf.length} bytes)`);
}
