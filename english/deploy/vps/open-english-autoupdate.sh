#!/usr/bin/env bash
# open-english VPS auto-update (systemd friendly). Replaces the in-process self-update,
# which spawns a detached child and exits (wrong for a systemd-managed service).
# Flow: latest GitHub Release -> if newer than the applied tag -> download linux tarball ->
#       probe the new binary on a spare port -> back up -> swap binary + static web files ->
#       restart both services -> health check -> roll back automatically on failure.
# Env overrides (for tests): FORCE_TAG=vX.Y.Z (apply even if not newer), DRY=1, OE_TEST_FAIL=1 (force health failure).
set -uo pipefail

REPO="${OE_REPO:-aon-co-jp/open-english}"
ASSET="open-english-installer-linux-x86_64.tar.gz"
ROOT="${OE_ROOT:-/root/easy-web.tokyo/open-english}"
BIN="${OE_BIN:-$ROOT/server/target/release/open-english-server}"
WEB="${OE_WEB:-/root/url/easy-web.tokyo/open-english}"
STATE_DIR="${OE_STATE_DIR:-/var/lib/open-english-autoupdate}"
BAK_ROOT="${OE_BAK_ROOT:-/root/open-english-autoupdate-bak}"
SERVICES=(open-english open-english-demo)
HEALTH=("http://127.0.0.1:8104/healthz" "http://127.0.0.1:8107/healthz")
PROBE_PORT="${OE_PROBE_PORT:-8199}"

log() { echo "[open-english-autoupdate] $*"; }
mkdir -p "$STATE_DIR" "$BAK_ROOT"
exec 9>"$STATE_DIR/lock"; flock -n 9 || { log "another run is active, exiting"; exit 0; }

applied="$(cat "$STATE_DIR/applied-tag" 2>/dev/null || true)"
if [ -z "$applied" ]; then log "no applied tag recorded (seed $STATE_DIR/applied-tag first)"; exit 1; fi

latest="$(curl -fsS --max-time 20 -H 'Accept: application/vnd.github+json' "https://api.github.com/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
[ -n "$latest" ] || { log "could not read the latest release (network/rate limit); keeping $applied"; exit 0; }
tag="${FORCE_TAG:-$latest}"
newest="$(printf '%s\n%s\n' "$applied" "$tag" | sort -V | tail -1)"
if [ -z "${FORCE_TAG:-}" ] && { [ "$newest" = "$applied" ]; }; then log "up to date ($applied, latest $latest)"; exit 0; fi
log "applying $tag (applied: $applied)"
[ "${DRY:-0}" = 1 ] && { log "DRY run: stop here"; exit 0; }

work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
curl -fsSL --max-time 300 -o "$work/pkg.tgz" "https://github.com/$REPO/releases/download/$tag/$ASSET" || { log "download failed; keeping $applied"; exit 1; }
mkdir "$work/x" && tar xzf "$work/pkg.tgz" -C "$work/x" || { log "extract failed"; exit 1; }
src="$(find "$work/x" -maxdepth 2 -name open-english-server -type f | head -1)"; srcdir="$(dirname "$src")"
[ -n "$src" ] || { log "binary not found in the tarball"; exit 1; }
chmod 755 "$src"

# glibc check (VPS is 2.39)
need="$(objdump -T "$src" 2>/dev/null | grep -o 'GLIBC_[0-9.]*' | sort -uV | tail -1 | sed 's/GLIBC_//')"
have="$(ldd --version | head -1 | grep -o '[0-9]*\.[0-9]*$')"
if [ -n "$need" ] && [ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | tail -1)" != "$have" ]; then log "needs glibc $need > $have; abort"; exit 1; fi

# probe on a spare port with an isolated data path (never touches production data)
# exec so that $! is the binary itself (a plain `a && b &` would kill only the subshell); fd 9 (lock) is not inherited.
( cd "$ROOT/server" && exec env OPEN_ENGLISH_SERVER_BIND="127.0.0.1:$PROBE_PORT" OPEN_EASY_WEB_LOCAL_BIND="127.0.0.1:$((PROBE_PORT+1))" OPEN_ENGLISH_DB_PATH="$work/probe-store.json" "$src" >"$work/probe.log" 2>&1 9>&- ) &
echo $! >"$work/probe.pid"
ok=0; for _ in $(seq 1 20); do sleep 1; curl -fsS --max-time 2 "http://127.0.0.1:$PROBE_PORT/healthz" >/dev/null 2>&1 && { ok=1; break; }; done
kill "$(cat "$work/probe.pid")" 2>/dev/null || true; sleep 1; kill -9 "$(cat "$work/probe.pid")" 2>/dev/null || true
[ "$ok" = 1 ] || { log "probe failed (see below); keeping $applied"; tail -5 "$work/probe.log"; exit 1; }

# back up
bak="$BAK_ROOT/$(date +%Y%m%d-%H%M%S)-from-$applied"; mkdir -p "$bak"
cp -a "$BIN" "$bak/open-english-server"
tar czf "$bak/web.tgz" -C "$WEB" . 2>/dev/null || true
log "backup: $bak"

rollback() {
  log "ROLLBACK to $applied"
  cp -a "$bak/open-english-server" "$BIN.new" && mv -f "$BIN.new" "$BIN"
  [ -n "${prev_head:-}" ] && git -C "$ROOT" reset -q --keep "$prev_head" 2>/dev/null
  [ -f "$bak/web.tgz" ] && tar xzf "$bak/web.tgz" -C "$WEB"
  systemctl restart "${SERVICES[@]}"
}

# swap binary (cp + atomic mv; the running process keeps the old inode) and static web files
cp "$src" "$BIN.new" && chmod 755 "$BIN.new" && mv -f "$BIN.new" "$BIN" || { log "binary swap failed"; exit 1; }
( cd "$srcdir" && for f in *.js *.html *.css *.json icons; do [ -e "$f" ] && cp -a "$f" "$WEB/"; done )
# The server re-syncs $WEB from the git clone's web/ at start, so fast-forward the clone to the tag too
# (otherwise a restart would put the old web files back).
prev_head="$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || true)"
git -C "$ROOT" fetch -q origin "refs/tags/$tag:refs/tags/$tag" 2>/dev/null && git -C "$ROOT" merge -q --ff-only "$tag" 2>&1 | tail -1 || log "warning: could not fast-forward the clone to $tag"
systemctl restart "${SERVICES[@]}"

good=1
for url in "${HEALTH[@]}"; do
  up=0; for _ in $(seq 1 30); do sleep 1; curl -fsS --max-time 2 "$url" >/dev/null 2>&1 && { up=1; break; }; done
  [ "$up" = 1 ] || good=0
done
[ "${OE_TEST_FAIL:-0}" = 1 ] && good=0
if [ "$good" != 1 ]; then rollback; for url in "${HEALTH[@]}"; do sleep 3; curl -fsS --max-time 5 "$url" >/dev/null 2>&1 && log "after rollback: $url ok" || log "after rollback: $url NOT ok"; done; exit 1; fi
echo "$tag" >"$STATE_DIR/applied-tag"
log "done: $tag applied, both services healthy"
