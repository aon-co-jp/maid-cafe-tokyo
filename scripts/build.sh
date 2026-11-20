#!/usr/bin/env bash
# 統合後(2026-11-20): english/(旧maid-cafe-english)と realdata/(旧realdata.pro)はこのリポジトリ内にある。
# deps.lock の兄弟リポジトリ(RPoem 等)だけを、このリポジトリの隣(W、既定は親フォルダー)へコミット固定で取得してビルドする。
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"; W="${W:-$(dirname "$here")}"
grep -vE '^\s*(#|$)' "$here/deps.lock" | while read -r name url rev; do
  d="$W/$name"
  if [ ! -d "$d/.git" ]; then mkdir -p "$d"; git -C "$d" init -q; git -C "$d" remote add origin "$url"; fi
  git -C "$d" fetch --quiet origin "$rev" 2>/dev/null || git -C "$d" fetch --quiet origin
  git -C "$d" -c advice.detachedHead=false checkout --quiet "$rev"
done
cargo build --release --manifest-path "$here/english/server/Cargo.toml" ${KOKORO:+--features kokoro}   # KOKORO=1 でKokoro(日本語音声)入り(VPS本番と同じ)
cargo build --release --manifest-path "$here/realdata/Cargo.toml" -p rrd-server
out="$here/dist/pkg"; rm -rf "$here/dist"; mkdir -p "$out/bin" "$out/open-english"
cp "$here/english/server/target/release/open-english-server" "$out/bin/"
cp "$here/realdata/target/release/rrd-server" "$out/bin/"
cp -r "$here/english/web" "$out/open-english/web"
git -C "$here" rev-parse HEAD > "$out/REVISION"; cp "$here/deps.lock" "$out/deps.lock"
tar -C "$out" -czf "$here/dist/maid-cafe-tokyo-linux-x86_64.tar.gz" .
(cd "$here/dist" && sha256sum maid-cafe-tokyo-linux-x86_64.tar.gz > SHA256SUMS)
echo built; ls -l "$here/dist"
