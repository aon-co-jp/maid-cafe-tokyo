#!/bin/sh
# open-english インストールスクリプト(Linux/macOS共通、2026-08-11新設)。
#
# ユーザー指示「インストーラーは必要なものはまとめてインストール可能
# にして、WindowsやLinuxやMAC版も」への対応——Windows版(Inno Setup、
# `installer/windows/`)の「まとめてインストール」設計を、root権限
# 不要のユーザー空間インストールとしてLinux/macOSへ移植したもの。
#
# 使い方(リリースtarballを展開したディレクトリで実行、リリースの
# 実際のURLはCI〈`.github/workflows/release.yml`〉が生成する):
#   curl -fsSL https://github.com/aon-co-jp/open-english/releases/latest/download/open-english-<os>-<arch>.tar.gz | tar xz
#   cd open-english-<os>-<arch>
#   ./install.sh                 # デスクトップ配信サーバーのみ
#   ./install.sh --with-aruaru-llm  # aruaru-llm(AI応答エンジン)も同時取得
#
# 正直な開示: aruaru-db・PostgreSQL・実モデル重み(GPT-2系・
# multilingual-e5-small)はここでは一切セットアップしない
# (aruaru-dbはマシン/サーバーごとに一度だけの共有インフラ、アプリ内の
# 「Setup aruaru-db」ボタンから既存の`aruaru-db/install.sh`/
# `install.ps1`を案内する設計、詳細はアプリ内モーダル参照)。

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${OPEN_ENGLISH_INSTALL_DIR:-$HOME/.local/share/open-english}"
BIN_DIR="${OPEN_ENGLISH_BIN_DIR:-$HOME/.local/bin}"
WITH_ARUARU_LLM=0

for arg in "$@"; do
    case "$arg" in
        --with-aruaru-llm) WITH_ARUARU_LLM=1 ;;
        *) echo "unknown option: $arg" >&2; exit 1 ;;
    esac
done

if [ ! -f "$SCRIPT_DIR/open-english-server" ]; then
    echo "open-english-server バイナリが見つかりません($SCRIPT_DIR)。同梱のtar.gzを展開したディレクトリで実行してください。" >&2
    exit 1
fi

echo "==> ${INSTALL_DIR} へファイルを配置"
mkdir -p "$INSTALL_DIR/icons"
install -m 755 "$SCRIPT_DIR/open-english-server" "$INSTALL_DIR/open-english-server"
for f in index.html style.css app.js auto-update.js version.json manifest.json exam-prep-questions.json; do
    cp "$SCRIPT_DIR/$f" "$INSTALL_DIR/$f"
done
cp "$SCRIPT_DIR"/icons/* "$INSTALL_DIR/icons/" 2>/dev/null || true

echo "==> 起動ランチャーを作成(${BIN_DIR}/open-english)"
mkdir -p "$BIN_DIR"
cat > "$BIN_DIR/open-english" << EOF
#!/bin/sh
cd "$INSTALL_DIR"
exec ./open-english-server "\$@"
EOF
chmod 755 "$BIN_DIR/open-english"

# Linuxのみ: デスクトップランチャー(.desktop)を追加(macOSにはこの
# 仕組みが無いため対象外、アイコンダブルクリック運用はmacOSでは
# `open-english`コマンドまたはターミナル起動に留める)。
OS_NAME="$(uname -s)"
if [ "$OS_NAME" = "Linux" ]; then
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    cat > "$DESKTOP_DIR/open-english.desktop" << EOF
[Desktop Entry]
Type=Application
Name=open-english
Comment=Maid Cafe English Trainer
Exec=$BIN_DIR/open-english
Icon=$INSTALL_DIR/icons/icon-192.png
Terminal=false
Categories=Education;
EOF
    echo "==> デスクトップランチャーを作成(${DESKTOP_DIR}/open-english.desktop)"
fi

if [ "$WITH_ARUARU_LLM" -eq 1 ]; then
    echo "==> aruaru-llm(AI応答エンジン)を取得します..."
    "$SCRIPT_DIR/fetch-aruaru-llm.sh" "$INSTALL_DIR/aruaru-llm" || true
fi

echo ""
echo "==> 完了。次のコマンドで起動してください:"
echo "    $BIN_DIR/open-english"
echo "    ブラウザで http://127.0.0.1:4601/ を開いてください。"
if [ "$WITH_ARUARU_LLM" -ne 1 ]; then
    echo ""
    echo "AI応答(チャット機能)を使うには、aruaru-llmも別途セットアップしてください:"
    echo "    ./install.sh --with-aruaru-llm"
    echo "    または https://github.com/aon-co-jp/aruaru-llm/releases から手動で取得"
fi
