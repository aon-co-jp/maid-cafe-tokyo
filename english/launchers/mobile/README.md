# スマホ・タブレットのホーム画面にアイコンを追加する(Android/iPhone/iPad)

open-english はサーバー不要の静的Webアプリ(PWA manifest対応)のため、
専用のネイティブアプリをストアからインストールする必要はなく、ブラウザの
「ホーム画面に追加」機能でホーム画面にアイコンを置ける。

## 前提

- `index.html`をどこかのWebサーバー(または`open-easy-web`のダウンロード
  サーバー)経由で開く必要がある(`file://`直開きでは、多くのブラウザが
  manifest.json・アイコンの読み込みを許可しない・「ホーム画面に追加」が
  出てこない場合がある)。ローカルで試す場合は例えば:
  ```
  cd open-english
  python3 -m http.server 8090
  ```
  としてから `http://<PCのIP>:8090/index.html` をスマホのブラウザで開く。

## Android(Chrome)

1. `index.html`をChromeで開く。
2. 右上の「⋮」メニュー → 「ホーム画面に追加」(または自動で出る
   インストールバナーの「インストール」)を選ぶ。
3. `manifest.json`の`icons`(`icons/icon-192.png`・`icons/icon-512.png`)が
   ホーム画面アイコンとして使われる。

## iPhone / iPad(Safari)

1. `index.html`をSafariで開く。
2. 共有ボタン(□から↑が出ているアイコン)をタップ。
3. 「ホーム画面に追加」を選ぶ。
4. `<link rel="apple-touch-icon" ...>`(`icons/icon-180.png`)がホーム画面
   アイコンとして使われる。

## 正直な開示

- どちらの方式も**ネイティブアプリではなく、ブラウザのショートカット**
  (PWA)である——ストア経由のインストールではない。
- オフライン動作(Service Worker)は今回未実装——ネットワーク接続が
  必要な点は変わらない(`aruaru-llm`がローカル常駐サーバーである
  Phase 0の設計上、スマホ単体で`aruaru-llm`を動かすことは想定していない)。
