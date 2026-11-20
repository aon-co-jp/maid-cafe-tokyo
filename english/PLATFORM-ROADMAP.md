# コンソール対応ロードマップ(PlayStation / Nintendo Switch / Wii / Wii U) / Console Platform Roadmap

**ステータス: 構想段階、Sony/Nintendo公式デベロッパー許可待ち。実機で動くビルドは現時点で一切存在しない。**
**Status: Concept stage only — pending official developer approval from Sony/Nintendo. No working build for any of these platforms exists today.**

このドキュメントはユーザー指示(2026-08-19「open-englishのSONYの
PSシリーズ版とNINTENDO SW1とSW2とWiiとWii U用も開発しておいて、
SONYとNintendoの許可待ちにしておいて」)に基づき作成した。既存の
Windows/Linux/macOS/Android対応(`README.md`/`CLAUDE.md`参照)とは異なり、
これらのゲーム機は個人・法人が任意に開発を進められる対象ではないため、
その事実関係を正直に記録することが本ドキュメントの目的である。

This document was created per the user's instruction (2026-08-19: "also
prepare PlayStation and Nintendo Switch 1/2/Wii/Wii U versions of
open-english, and keep them pending Sony/Nintendo approval"). Unlike the
existing Windows/Linux/macOS/Android support, these consoles are not
platforms an individual or company can simply start developing for — this
document exists to record that reality honestly.

## 1. なぜ「開発しておく」ことが技術的に不可能か / Why we cannot simply "start developing" this

### PlayStation (PS4/PS5等)

- Sony Interactive Entertainmentの **PS Partner Program**(公式デベロッパー
  登録制度、審査あり)に参加し、NDA(秘密保持契約)を締結した上で、
  非公開の公式SDK(devkit、市販PS4/PS5とは別の専用開発機材)を入手
  しない限り、実機で動作するビルドはそもそも作成できない。
- 個人開発者向けの「Indie」枠も存在するが、いずれも審査・法人/実績確認
  を経る必要があり、無審査で即座に着手できるものではない。
- Sony側の許可・SDK入手が完了するまで、このプロジェクトとして着手可能
  な作業は存在しない(公開情報の調査を除く)。

To build anything that runs on real PS4/PS5 hardware requires joining
Sony's official PS Partner Program (a vetted registration process), signing
an NDA, and obtaining the non-public official SDK/devkit (dedicated
development hardware, distinct from a retail console). An indie-developer
track exists but still requires vetting. Until that approval and SDK access
exist, there is no development work this project can actually perform
beyond public research.

### Nintendo Switch (SW1/SW2)

- 同様にNintendo Developer Portalでの公式デベロッパー登録・審査・NDA
  締結・専用devkit(市販Switch実機とは別の開発専用ハードウェア)が必須。
- 市販Switch上で動作させる非公式手法(Homebrew Launcher等の改造)は
  Nintendoの利用規約違反であり、本プロジェクトの正規リリースとしては
  採用しない方針(「絶対にしないこと」として明記)。
- Switch 2についても同様の公式デベロッパープログラムが前提となる
  (詳細は要調査)。

Likewise requires registering with the Nintendo Developer Portal, passing
vetting, signing an NDA, and obtaining dedicated devkit hardware (distinct
from a retail Switch). Unofficial homebrew methods on a retail Switch
violate Nintendo's terms of service and will not be used for this project's
official releases. Switch 2 presumably requires an equivalent official
program (needs further research).

### Wii / Wii U

- 既に生産・サポートが終了した旧世代機。Nintendoの現行デベロッパー
  プログラムの対象外である可能性が高い(**要調査** — 現行プログラムで
  旧機種向け開発が新規受付されているかは未確認)。
- 仮に対象外である場合、公式な新規開発ルートが実質存在しないことになる。

Both are discontinued legacy platforms. They are likely outside Nintendo's
current developer program (**needs further research** — it is not
confirmed whether the current program accepts new development for these
older consoles). If they are indeed out of scope, there may be no official
route to develop for them at all today.

## 2. 各コンソールの内蔵ブラウザについて(判明分) / Built-in browsers on each console (what is known)

- **PS4/PS5**: 過去に簡易的なWebブラウザ機能が搭載されていた時期がある
  (PS4初期のシステムソフトウェアにはブラウザアプリが存在した)。ただし
  現行システムソフトウェアでの提供状況・機能範囲の詳細は**要調査**。
- **Nintendo Switch**: 一般利用者向けの内蔵Webブラウザは搭載されていない
  (通信エラー時などに表示される限定的な内部ブラウザはあるが、汎用の
  Webブラウジング用途ではない)。
- **Wii**: 「インターネットチャンネル」という公式Webブラウザ(Opera
  ベース)が配信されていた実績がある。ただし現在もダウンロード・利用
  可能かは**要調査**(オンラインサービスの終了状況に依存)。
- **Wii U**: 本体標準でWebブラウザ機能(Operaベース)が搭載されていた。

- **PS4/PS5**: There was a period where a basic built-in web browser
  existed on early PS4 system software. The current availability/feature
  scope on today's system software is **unconfirmed — needs research**.
- **Nintendo Switch**: No general-purpose built-in web browser for end
  users (a restricted internal browser appears only in specific contexts
  like captive-portal login, not for general browsing).
- **Wii**: An official web browser ("Internet Channel", Opera-based) was
  distributed historically. Whether it remains downloadable/usable today
  is **unconfirmed — needs research** (depends on online service
  discontinuation status).
- **Wii U**: Shipped with a built-in Opera-based web browser.

## 3. 前向きな技術的見立て(可能性の話、確約ではない) / A forward-looking technical note (a possibility, not a promise)

open-englishは既に静的Web技術(HTML/CSS/JS)+Rustサーバーという構成
(`README.md`/`CLAUDE.md`参照)であるため、**もし将来、各社の公式SDK上で
WebView/ブラウザ埋め込みが許可されれば**、既存のフロントエンド資産
(`index.html`/`app.js`/`style.css`等)をほぼそのまま転用できる可能性が
ある。ただしこれはあくまで技術的な見立てであり、実際に許可が下りるか、
各社SDKがWebView埋め込みを許容するかは全く未確定である。確約はしない。

Because open-english is already built on static web technology (HTML/CSS/
JS) plus a Rust server, *if* the respective official SDKs ever permit
WebView/browser embedding, the existing frontend assets could potentially
be reused largely as-is. This is a technical possibility only — whether
approval is ever granted, or whether the SDKs even allow WebView embedding,
remains entirely unconfirmed. No promise is made here.

## 4. 現在のステータス / Current status

- 実装: **なし**(作成不可能なため)。`console-ports/`ディレクトリに
  プレースホルダーのみ配置。
- 次にすべきこと: Sony PS Partner Program / Nintendo Developer Portalへの
  公式デベロッパー登録を検討・申請する(このリポジトリの担当者が
  勝手に開発を進めることはできない)。承認・devkit入手後に、あらためて
  技術検証・スコープ策定を行う。

- Implementation: **none** (not technically possible today). Only a
  placeholder exists under `console-ports/`.
- Next step: consider/apply for official developer registration via Sony's
  PS Partner Program and the Nintendo Developer Portal (this project's
  maintainers cannot unilaterally start development). Technical
  investigation and scoping can resume only after approval and devkit
  access are obtained.
