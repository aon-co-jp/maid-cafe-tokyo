#!/usr/bin/env bash
# open-english をLinuxのアプリケーションメニュー/デスクトップから起動する
# .desktopファイルをインストールする。
#
# 【2026-08-21修正】従来はopen-english自体を「サーバー不要の静的HTML/JS
# アプリ」として index.html を xdg-open で直接開くだけだったが、これは
# 2026-08-10のserver/(Rust)crate新設より前の古い前提のままだった記述
# ミス。現行のREADME.md「実行方法」節が示す通り、file:// で直接開くと
# 一部ブラウザがfetch()をブロックしauto-update.js等の機能が動かない
# ため、ビルド済みサーバーバイナリ(installer/unix/install.sh または
# `cd server && cargo build --release`で生成)が見つかればそちらを起動して
# HTTP経由のURLを開くようにし、見つからない場合のみ従来通りindex.htmlを
# 直接開く(その場合は機能が一部制限される旨を正直に表示する)。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INDEX_HTML="$REPO_ROOT/index.html"
ICON_PATH="$REPO_ROOT/icons/icon-192.png"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_FILE="$DESKTOP_DIR/open-english.desktop"

mkdir -p "$DESKTOP_DIR"

# ビルド済みサーバーバイナリの候補(開発ビルド or install.sh配置先)。
SERVER_BIN=""
for candidate in \
    "$REPO_ROOT/server/target/release/open-english-server" \
    "$REPO_ROOT/open-english-server" \
    "$HOME/.local/share/open-english/open-english-server"
do
    if [ -x "$candidate" ]; then
        SERVER_BIN="$candidate"
        break
    fi
done

if [ -n "$SERVER_BIN" ]; then
    LAUNCH_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/open-english"
    mkdir -p "$LAUNCH_DIR"
    LAUNCH_SCRIPT="$LAUNCH_DIR/open-english-launch.sh"
    SERVER_URL="http://127.0.0.1:4601/"
    cat > "$LAUNCH_SCRIPT" <<EOF
#!/usr/bin/env bash
"$SERVER_BIN" &
sleep 1
xdg-open "$SERVER_URL"
EOF
    chmod +x "$LAUNCH_SCRIPT"
    EXEC_LINE="$LAUNCH_SCRIPT"
    echo "サーバーバイナリを検出しました: $SERVER_BIN"
    echo "ランチャーは $SERVER_URL 経由でアプリを開きます(auto-update等の機能もフル動作)。"
else
    EXEC_LINE="xdg-open \"$INDEX_HTML\""
    echo "警告: ビルド済みサーバーバイナリが見つかりませんでした(server/target/release/open-english-server 等を確認)。"
    echo "index.html を file:// で直接開くフォールバックにします——一部ブラウザではfetch()がブロックされ、自動更新等の機能が動きません。"
    echo "フル機能を使うには: cd $REPO_ROOT/server && cargo build --release、または installer/unix/install.sh を実行してください。"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=open-english
Comment=Maid Cafe English Trainer (Phase 0 prototype)
Exec=$EXEC_LINE
Icon=$ICON_PATH
Terminal=false
Categories=Education;Network;
EOF

chmod +x "$DESKTOP_FILE"
echo "作成しました: $DESKTOP_FILE"
echo "デスクトップにも置きたい場合は、この .desktop ファイルを ~/Desktop へコピーしてください。"
