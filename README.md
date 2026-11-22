# maid-cafe.tokyo

メイドカフェ先生の英会話・学習(maid-cafe-english)と、データ分析(realdata.pro)のハイブリッド。設計の正本は `maid-cafe-se` リポジトリの `docs/maid-cafe-tokyo-design.md`。
Hybrid of the maid-cafe English teacher (maid-cafe-english) and data analysis (realdata.pro). Design doc: `docs/maid-cafe-tokyo-design.md` in `maid-cafe-se`.

## 構成 / Layout(2026-11-02に実機で確認)
```
利用者 → open-web-server(HTTPS 443、自前の証明書) ─┬─ /data/*   → rrd-server          127.0.0.1:4701 (realdata.pro)
                                                     ├─ /school/* → プログラミング教室   127.0.0.1:8109
                                                     └─ それ以外  → open-english-server  127.0.0.1:8104 (maid-cafe-english)
```
- 前面は **Caddy ではなく `open-web-server`** で、ドメインの振り分けは VPS の `domains.toml` に書いてある。
- `open-english-server`(`open-english.service`)と `rrd-server`(`realdata-pro.service`)は、それぞれ別のリポジトリのビルド成果物で、各リポジトリの手順で更新する。
- 旧URL(`easy-web.tokyo/open-english/`・`realdata.pro/english/`)には「引っ越しました」の案内を出している。`open-english` リポジトリは廃止し、履歴のために残している。
- `deps.lock`: 依存リポジトリのコミット固定(2026-10-28時点の各master最新)。
- 秘密情報はVPS上にだけ置き、リポジトリに入れない。

Front end is **`open-web-server`, not Caddy** (domain routing lives in the VPS `domains.toml`): `/data/*` → `rrd-server` (4701), `/school/*` → the programming school (8109), everything else → `open-english-server` (8104). The two backends are built and updated from their own repositories. The old URLs show a "moved" notice, and the `open-english` repository is retired and kept for its history.

## 状態 / Status(正直に)
- **配備済み・稼働中**(確認日 2026-11-02): `https://maid-cafe.tokyo/` は200、`/data/` は200、`/school/` は200。`/english/` は404(使っていない)。
- **このリポジトリの `deploy/` は使われていない**: `Caddyfile`・`maid-*.service`・`bin/update.sh`(毎朝05:00の自動更新)は、**Caddy を前提にした別案の設計**で、VPS には入れていない(`caddy` も `maid` ユーザーも `/etc/maid-cafe` も無い)。実機では一度も実行しておらず、自動更新とロールバックは未検証。実際の更新は、各リポジトリを VPS 上でビルドして、サービスを再起動する手順。
- **公開前の確認(2026-11-02)**: `open-english-server` の VPS/ローカル操作のエージェント機能は、認証なしだと403で拒否される(`/v1/agent/*` を実測)。管理用の `/v1/admin/aruaru-llm/*`(モデルの選択・インストール・ダウンロード)は、認証なしで通る不具合があったため、管理者ゲートを追加した(`open-english` の 0b5cd2b)。**この修正は、VPS のバイナリを入れ替えるまで本番に反映されない。**
- RPoem最新コミットのCIは failure(保守中)。固定したコミットでのビルド成功は未確認。
- **Deployed and running** (checked 2026-11-02): `/`, `/data/` and `/school/` return 200. **The `deploy/` directory here is not used**: the Caddy-based design (Caddyfile, `maid-*.service`, the 05:00 `update.sh` auto-update) was never installed on the VPS and its auto-update/rollback is unverified. Admin routes `/v1/admin/aruaru-llm/*` were callable without authentication; a gate was added (open-english 0b5cd2b) and takes effect once the VPS binary is replaced. RPoem master CI is failing (under maintenance).

## 次の手順 / Next
1. VPS の `open-english-server` を最新(0b5cd2b 以降)にビルドして入れ替え、`/v1/admin/aruaru-llm/runtime` が認証なしで403になることを確認する。
2. `deploy/` を、実際の構成(`open-web-server` 前提)に合わせて作り直すか、使わないなら削除する。
3. CIで両サーバーをビルドして成果物 `maid-cafe-tokyo-linux-x86_64.tar.gz` と `SHA256SUMS` をリリースに添付する(自動更新を使う場合)。

## API 方針: REST 全廃・gRPC / Connect へ (2026-11-04)

### 日本語
- **REST は全廃する。新しい API は REST で作らない。** ブラウザや `curl` から呼ぶ API は **Connect の単純呼び出し**(`POST /<パッケージ>.<Service>/<Method>`、`content-type: application/json`、本文は JSON)、サービス間は **gRPC / gRPC-web**(RPoem の管理API `open_runo.admin.v1.Admin` と同じ流儀)。ストリーミングは、必要になってから。
- **既存の REST は、触るときに順に移す。** 移したら旧 REST の経路は消す。移行が終わるまで残るが、**新規には追加しない**。
- **JSON は RS-JSON に統一**する(読み込みは `from_str_secure` / `parse_secure` でサイズ・深さ・重複キーの上限つき、書き出しは `rust_json::fast`)。ブラウザの WASM に `prost` は入れない(サイズが増えるため)。
- **例外(自分たちの API ではなく、相手の規格が決めているもの)**: ACME、OAuth/OIDC のコールバック、第三者(GitHub など)からの Webhook、ヘルスチェック、静的ファイル配信、OTLP など。これらは規格どおりの HTTP を受ける。
- 参考実装: `RPoem`(`open_runo.admin.v1.Admin`)、`open-easy-web`(`server/src/connect.rs`、`proto/open_easy_web/admin/v1/admin.proto`)。
- ※ このリポジトリのコードが既に方針どおりかどうかは、各リポジトリの現状による。この節は方針の記録であり、コードの変更を意味しない。

### English
- **REST is being abolished. New APIs are not built as REST.** APIs called from browsers or `curl` use **Connect unary calls** (`POST /<package>.<Service>/<Method>`, `content-type: application/json`, JSON body); service-to-service calls use **gRPC / gRPC-web** (the same style as RPoem's admin API `open_runo.admin.v1.Admin`). Streaming only when it is actually needed.
- **Existing REST endpoints are migrated one by one, when they are touched.** The old REST route is removed once migrated. Until migration is finished they remain, but **no new ones are added**.
- **JSON is unified on RS-JSON**: reading with `from_str_secure` / `parse_secure` (size, depth and duplicate-key limits), writing with `rust_json::fast`. `prost` is not put into browser WASM (it would grow the binary).
- **Exceptions (shapes dictated by someone else's standard, not our own API)**: ACME, OAuth/OIDC callbacks, webhooks from third parties (e.g. GitHub), health checks, static file serving, OTLP, and so on. These accept plain HTTP as the standard requires.
- Reference implementations: `RPoem` (`open_runo.admin.v1.Admin`) and `open-easy-web` (`server/src/connect.rs`, `proto/open_easy_web/admin/v1/admin.proto`).
- Note: whether the code in a given repository already follows this policy depends on that repository. This section records the policy; it does not mean the code has been changed.

### Deutsch (KI-Übersetzung, redaktionell überarbeitet; noch nicht von Muttersprachlern geprüft)
- **REST wird vollständig abgeschafft; neue APIs entstehen nicht mehr als REST.** APIs, die aus dem Browser oder per `curl` aufgerufen werden, verwenden **unäre Connect-Aufrufe** (`POST /<Paket>.<Service>/<Methode>`, `content-type: application/json`, JSON-Body). Zwischen Diensten kommen **gRPC bzw. gRPC-web** zum Einsatz, im selben Stil wie die Admin-API von RPoem (`open_runo.admin.v1.Admin`). Streaming wird erst ergänzt, wenn es tatsächlich gebraucht wird.
- **Bestehende REST-Endpunkte werden schrittweise umgestellt, und zwar immer dann, wenn man ohnehin an ihnen arbeitet.** Sobald ein Endpunkt umgestellt ist, wird die alte REST-Route entfernt. Bis zum Abschluss der Migration bleiben die übrigen bestehen, es werden aber **keine neuen mehr hinzugefügt**.
- **JSON wird einheitlich über RS-JSON verarbeitet**: Gelesen wird mit `from_str_secure` bzw. `parse_secure` (mit Obergrenzen für Größe, Verschachtelungstiefe und doppelte Schlüssel), geschrieben mit `rust_json::fast`. `prost` wird nicht in das Browser-WASM aufgenommen, da es die Datei vergrößern würde.
- **Ausnahmen (Schnittstellen, deren Form ein fremder Standard vorgibt und die nicht zu unserer eigenen API gehören)**: ACME, OAuth/OIDC-Callbacks, Webhooks von Drittanbietern (z. B. GitHub), Health-Checks, die Auslieferung statischer Dateien, OTLP und Ähnliches. Diese nehmen, wie vom jeweiligen Standard verlangt, gewöhnliches HTTP entgegen.
- Referenzimplementierungen: `RPoem` (`open_runo.admin.v1.Admin`) und `open-easy-web` (`server/src/connect.rs`, `proto/open_easy_web/admin/v1/admin.proto`).
- Hinweis: Ob der Code eines einzelnen Repositorys diese Richtlinie bereits erfüllt, hängt vom jeweiligen Repository ab. Dieser Abschnitt dokumentiert lediglich die Richtlinie; er besagt nicht, dass der Code schon angepasst wurde.

### Русский (перевод выполнен с помощью ИИ и отредактирован; носителями языка пока не проверен)
- **От REST мы полностью отказываемся; новые API больше не создаются в стиле REST.** API, к которым обращаются из браузера или через `curl`, используют **унарные вызовы Connect** (`POST /<пакет>.<Service>/<Method>`, `content-type: application/json`, тело запроса — JSON). Для взаимодействия между сервисами применяются **gRPC и gRPC-web** — в том же стиле, что и административный API RPoem (`open_runo.admin.v1.Admin`). Потоковая передача данных добавляется лишь тогда, когда в ней действительно возникает необходимость.
- **Существующие REST-эндпоинты переводятся поэтапно — по мере того, как с ними приходится работать.** После перевода старый REST-маршрут удаляется. Пока миграция не завершена, оставшиеся эндпоинты сохраняются, но **новые не добавляются**.
- **Работа с JSON унифицирована на основе RS-JSON**: чтение — через `from_str_secure` или `parse_secure` (с ограничениями на размер, глубину вложенности и повторяющиеся ключи), запись — через `rust_json::fast`. `prost` в браузерный WASM не включается, поскольку это увеличило бы размер файла.
- **Исключения (интерфейсы, форму которых определяет чужой стандарт, а не наш собственный API)**: ACME, обратные вызовы OAuth/OIDC, вебхуки сторонних сервисов (например, GitHub), проверки работоспособности, раздача статических файлов, OTLP и тому подобное. Такие интерфейсы принимают обычный HTTP, как того требует соответствующий стандарт.
- Эталонные реализации: `RPoem` (`open_runo.admin.v1.Admin`) и `open-easy-web` (`server/src/connect.rs`, `proto/open_easy_web/admin/v1/admin.proto`).
- Примечание: соответствует ли код конкретного репозитория этой политике, зависит от самого репозитория. Данный раздел лишь фиксирует политику и не означает, что код уже изменён.

## API 方針の補足: 用語の整理と使い分け (2026-11-04)

### 日本語
**1つに統一するものではなく、別の層の話です。** 「REST の代わり」になるのは Connect・gRPC・GraphQL だけで、WASM は画面を作る技術です。

| 用語 | 何か | REST の代わりか |
|---|---|---|
| REST | URL と HTTP メソッドで操作を表す API の作り方 | 全廃する側 |
| **Connect** | `POST /サービス名/メソッド名` に JSON を送る形式。`curl` でもブラウザの `fetch` でも呼べる | はい(**採用**) |
| **gRPC** | 同じ「サービス/メソッド」の考え方を、バイナリ(protobuf)と HTTP/2 で行う形式。速く、ストリーミングも得意 | はい(**サービス同士に採用**) |
| gRPC-web | gRPC のブラウザ向けの変形版 | はい(必要なら) |
| GraphQL | 欲しい項目を問い合わせる形式 | 一部だけ(**問い合わせ(読み取り)専用**) |
| WASM | Rust をブラウザの中で動かす仕組み | いいえ(画面を作る技術) |

- **ブラウザの画面や `curl` から呼ぶ API は Connect**(POST、JSON を RS-JSON で読み書き)。ブラウザの WASM は素の gRPC を話せず、Connect なら `fetch` のままで、`prost` を足さずに済む(画面のサイズも増えない)。
- **サービス同士の通信(サーバー間、重い処理、ストリーミング)は gRPC。** 多くは Connect で足りるので、ストリーミングが必要になった所だけ gRPC に上げる。
- **GraphQL は、まとめて問い合わせたいときの読み取り専用。** 書き込み(操作)には使わない。
- **WASM は画面を作る技術として、そのまま使う。** 画面から呼ぶ API が Connect になっただけ。
- 外部の規格が形を決めるもの(ACME、OAuth のコールバック、第三者の Webhook、ヘルスチェック、静的ファイル、OTLP)は、規格どおりの HTTP のまま。
- **迷ったら Connect。**

### English
**These are not alternatives to unify; they sit at different layers.** Only Connect, gRPC and GraphQL can replace REST; WASM is a way to build the UI.

| Term | What it is | Replaces REST? |
|---|---|---|
| REST | API style that expresses operations through URLs and HTTP methods | The thing being abolished |
| **Connect** | `POST /Service/Method` with a JSON body; callable from `curl` and from a browser `fetch` | Yes (**adopted**) |
| **gRPC** | The same service/method idea over binary (protobuf) and HTTP/2; fast, good at streaming | Yes (**for service-to-service**) |
| gRPC-web | A browser-friendly variant of gRPC | Yes (if needed) |
| GraphQL | A query language: ask for exactly the fields you want | Partly (**read-only queries**) |
| WASM | Runs Rust inside the browser | No (a UI technology) |

- **APIs called from browser screens or `curl` use Connect** (POST, JSON read and written with RS-JSON). Browser WASM cannot speak plain gRPC; with Connect it stays a `fetch`, and `prost` is not needed (the binary does not grow).
- **Service-to-service calls (server to server, heavy work, streaming) use gRPC.** Connect is enough in most places; move a call to gRPC only where streaming is actually needed.
- **GraphQL is read-only**, for queries that gather several pieces of data. It is not used for writes (operations).
- **WASM stays as the way to build the UI.** The API it calls simply became Connect.
- Interfaces whose shape an outside standard dictates (ACME, OAuth callbacks, third-party webhooks, health checks, static files, OTLP) stay plain HTTP.
- **When in doubt, use Connect.**

### Deutsch (KI-Übersetzung, sprachlich überarbeitet; noch nicht von Muttersprachlern geprüft)
**Es geht nicht darum, eine einzige Technik auszuwählen – die Begriffe liegen auf unterschiedlichen Ebenen.** Als Ersatz für REST kommen nur Connect, gRPC und GraphQL in Frage; WASM dagegen ist eine Technik, mit der die Benutzeroberfläche gebaut wird.

| Begriff | Was ist das? | Ersatz für REST? |
|---|---|---|
| REST | Ein API-Stil, bei dem Operationen über URLs und HTTP-Methoden ausgedrückt werden | wird abgeschafft |
| **Connect** | `POST /Dienst/Methode` mit JSON im Body; aufrufbar mit `curl` ebenso wie mit `fetch` im Browser | ja (**gewählt**) |
| **gRPC** | Dasselbe Prinzip aus Dienst und Methode, aber über binäres protobuf und HTTP/2; schnell und gut für Streaming geeignet | ja (**zwischen Diensten**) |
| gRPC-web | Eine für den Browser angepasste Variante von gRPC | ja (bei Bedarf) |
| GraphQL | Abfragesprache, mit der man genau die benötigten Felder anfordert | teilweise (**nur für lesende Abfragen**) |
| WASM | Führt Rust-Code direkt im Browser aus | nein (Technik für die Oberfläche) |

- **APIs, die von Browseroberflächen oder per `curl` aufgerufen werden, verwenden Connect** (POST; JSON wird mit RS-JSON gelesen und geschrieben). WASM im Browser kann kein reines gRPC sprechen. Mit Connect bleibt es bei einem gewöhnlichen `fetch`, und `prost` ist nicht nötig – die WASM-Datei wird dadurch nicht größer.
- **Für die Kommunikation zwischen Diensten (Server zu Server, rechenintensive Aufgaben, Streaming) wird gRPC eingesetzt.** In den meisten Fällen reicht Connect aus; auf gRPC wird nur dort umgestellt, wo Streaming tatsächlich gebraucht wird.
- **GraphQL dient ausschließlich lesenden Abfragen**, wenn mehrere Informationen gebündelt abgefragt werden sollen. Für Schreibzugriffe (Operationen) wird es nicht verwendet.
- **WASM bleibt die Technik für die Oberfläche.** Geändert hat sich lediglich, dass die aufgerufene API nun auf Connect beruht.
- Schnittstellen, deren Form durch einen externen Standard festgelegt ist (ACME, OAuth-Callbacks, Webhooks von Drittanbietern, Health-Checks, statische Dateien, OTLP), bleiben gewöhnliches HTTP.
- **Im Zweifel: Connect.**

### Русский (перевод выполнен с помощью ИИ и литературно отредактирован; носителями языка пока не проверен)
**Это не варианты, из которых нужно выбрать один, а технологии разных уровней.** Заменить REST могут только Connect, gRPC и GraphQL; WASM же — это способ создания пользовательского интерфейса.

| Термин | Что это | Заменяет REST? |
|---|---|---|
| REST | Стиль построения API, при котором операции выражаются через URL и HTTP-методы | отменяется |
| **Connect** | `POST /Сервис/Метод` с телом в формате JSON; вызывается как из `curl`, так и из браузерного `fetch` | да (**выбран**) |
| **gRPC** | Тот же принцип «сервис — метод», но поверх двоичного формата protobuf и HTTP/2; работает быстро и хорошо подходит для потоковой передачи | да (**для связи между сервисами**) |
| gRPC-web | Адаптированный для браузера вариант gRPC | да (при необходимости) |
| GraphQL | Язык запросов: клиент запрашивает ровно те поля, которые ему нужны | частично (**только запросы на чтение**) |
| WASM | Позволяет выполнять код на Rust прямо в браузере | нет (технология для интерфейса) |

- **API, которые вызываются из браузерных интерфейсов или через `curl`, строятся на Connect** (POST; JSON читается и записывается через RS-JSON). Браузерный WASM не умеет работать с «чистым» gRPC. С Connect достаточно обычного `fetch`, а `prost` не требуется — размер WASM-файла не увеличивается.
- **Для обмена между сервисами (сервер — сервер, ресурсоёмкие задачи, потоковая передача) применяется gRPC.** В большинстве случаев достаточно Connect; на gRPC переходят только там, где потоковая передача действительно необходима.
- **GraphQL используется только для чтения**, когда нужно получить сразу несколько связанных данных. Для записи (операций) он не применяется.
- **WASM по-прежнему остаётся технологией для интерфейса.** Изменилось лишь то, что вызываемый им API теперь построен на Connect.
- Интерфейсы, форма которых задана внешним стандартом (ACME, обратные вызовы OAuth, вебхуки сторонних сервисов, проверки работоспособности, статические файлы, OTLP), остаются обычным HTTP.
- **Если есть сомнения — выбирайте Connect.**

## 2026-11-20 融合の記録: maid-cafe.tokyo / Fusion record
**日本語**: このリポジトリが、英会話・学習(maid-cafe-english、旧open-english)と データ分析(realdata.pro)を融合した **maid-cafe.tokyo** の入口・配備の正本です。英会話の部品(open-english-server)は、融合後も英会話・学習の部品(open-english-server)として使われ続けます。リリースやミラーの手順は変えていません(コード自体の統合は、配備を壊さないよう別途、試験してから行います)。
**English**: This repository is the entrance and deployment source of truth of **maid-cafe.tokyo**, the fusion of English learning (maid-cafe-english, formerly open-english) and data analysis (realdata.pro). The English-learning code (open-english-server) keeps serving as the English-learning part (open-english-server). Release and mirror steps are unchanged; merging the code itself will be done separately, after tests, so as not to break deployment.

## 2026-11-20 コード統合 / Code merged into this repository
**日本語**: 旧 `maid-cafe-english`(旧 open-english)のコードを `english/`、旧 `realdata.pro` のコードを `realdata/` に取り込みました(履歴は元のリポジトリに残っています)。2つのサーバー(`open-english-server`・`rrd-server`)が、このリポジトリ1つでビルドできます。兄弟の依存(RPoem・open-cuda など)は `deps.lock` で固定し、このリポジトリの隣のフォルダーに置きます(Cargo の `path` はそのための相対パスに直してあります)。`cargo check` は両方とも成功を確認しました(Windows)。**未了**: VPS の配備元をこのリポジトリへ切り替える通し確認、リリース用 CI(`english/` の既存 release.yml はまだ旧リポジトリ用)、旧リポジトリの扱い(当面は変更せず残す。リリースのタグ push 元・ミラーは従来どおり)。
**English**: The code of the former `maid-cafe-english` (formerly open-english) now lives in `english/` and the former `realdata.pro` in `realdata/` (their history stays in the original repositories). Both servers (`open-english-server` and `rrd-server`) build from this one repository. Sibling dependencies (RPoem, open-cuda, ...) are pinned in `deps.lock` and sit in the folder next to this repository (Cargo `path`s were rewritten accordingly). `cargo check` passes for both (Windows). **Open**: switching the VPS deployment source to this repository and verifying it end to end, release CI (the existing `release.yml` in `english/` still targets the old repository), and what to do with the old repositories (for now they are left unchanged; release tags and mirrors work as before).

## 2026-11-20 統合後の配備(VPS)/ Deployed from the merged repo
**日本語**: 統合後の CI(`release.yml`、ubuntu-24.04=glibc 2.39、Kokoro なし)の成果物を VPS に入れ替えました。`open-english-server`(46.7MB)と `rrd-server` を、バックアップ(`*.before-merge-20261120-1522`)付きで差し替え、`maid-cafe.tokyo` の `/`・`/data/`・`/school/` が200、2サービス active、直近ログのエラー0を確認。別ポートでの試験起動も先に行いました。**注意**: (1) ubuntu-latest(glibc 2.43)でビルドすると VPS で動かない。(2) `english/server` の `main.rs`・`news_qa.rs` は、VPS で動いていた版(類義語検索・学習=maid-cafe-english 側、`x-tenant`=open-english 側)の両方を含む統合版。(3) Kokoro 付きビルド(278MB)は、メモリ3.6GBの VPS では未検証のため入れていない。(4) VPS のソースクローン(`/root/easy-web.tokyo/open-english`・`/root/repository/realdata.pro`)はまだ旧リポジトリのままで、今後はこのリポジトリの成果物を使う。ロールバック=バックアップを戻して `systemctl restart open-english realdata-pro`。**未了**: 旧3リポジトリとの二重管理の整理、ブラウザでの画面確認、Kokoro の扱い。
**English**: The merged repo's CI artifact (`release.yml`, ubuntu-24.04 = glibc 2.39, no Kokoro) was swapped onto the VPS with backups (`*.before-merge-20261120-1522`): `/`, `/data/`, `/school/` return 200, both services active, 0 errors in recent logs; a trial start on another port came first. **Notes**: ubuntu-latest (glibc 2.43) builds do not run on the VPS; `english/server` merges both lines of work that were running (synonym search/learning from maid-cafe-english, `x-tenant` from open-english); the 278 MB Kokoro build was not deployed (untested on a 3.6 GB VPS). **Open**: untangling the three old repositories, a browser check, the Kokoro decision.

## 2026-11-22 追記: 翻訳の高速化の知見を関連リポジトリで共有 / Sharing the translation-speed findings (日本語・English)

### 日本語
**共有する相手(同時に開発する)**: `open-tv-chat`(音声翻訳の本体)、`maid-cafe-english`(`maid-cafe.tokyo` の英語学習。翻訳・音声)、`maid-cafe-tokyo`(`https://maid-cafe.tokyo` の運用先)、`aruaru-llm`・`open-cuda`・`open-cpu`・`open-directx`(推論の土台)。なお、`open-maid-cafe` という名前のリポジトリは `aon-co-jp` に**存在しません**(あるのは `maid-cafe-tokyo`・`maid-cafe-english`・`maid-cafe-se`・`maid-cafe-programming-school`)。
**実測(CPU のみ、Ryzen 9 3950X・WSL・GPU は GT 730 2GB で実質使えない)**: 翻訳モデル MADLAD-400 3B(q4k、約1.65GB)を candle の quantized-t5 例で実行。
- 読み込みに約30秒かかるため、**常駐させて1回だけ読み込む**(標準入力から1行ずつ訳す形に改造、環境変数 `MT_TOKIENIZER` でトークナイザーを指定)。
- **短い文ごとに訳す**と、1文あたり約3〜8秒(2.7語/秒)。長い文をまとめるより、前半が落ちにくい。
- `RUSTFLAGS="-C target-cpu=native"` で語速が約2.3→2.7語/秒(約15%向上)。
- 音声認識(`rs-whisper` tiny、11秒の音声で約10.5秒)と合わせても、**そのままではリアルタイムに届かない**。次の候補は、小さい翻訳モデル、`open-cuda-llm` への T5 追加と比較、`open-cuda-whisper` との音声認識の比較、音声合成(Piper/Kokoro)。
**取り込み方針**: maid-cafe-english の翻訳・音声(AI回答や聞き取り)は、常駐+文ごと+native ビルドをまず適用する。新しい REST は作らず Connect/gRPC で呼ぶ。VPS は4コアで遅いので、**測定・開発は手元PC**、VPS は配備と確認だけ。
**未了**: (1)`open-cuda-llm` への T5 実装と candle との比較、(2)`open-cuda-whisper` と `rs-whisper` の比較、(3)GPU(Vulkan/DirectX)の実測(この PC の GT 730 は古く効果は期待薄)、(4)各リポジトリのコードへの実際の反映(今回は文書のみ)。

### English
**Who shares this (developed together)**: `open-tv-chat` (the voice-translation app), `maid-cafe-english` (English learning for `maid-cafe.tokyo`: translation and voice), `maid-cafe-tokyo` (the site running at `https://maid-cafe.tokyo`), and `aruaru-llm`, `open-cuda`, `open-cpu`, `open-directx` (the inference base). Note: there is **no** repository named `open-maid-cafe` in `aon-co-jp` (the existing ones are `maid-cafe-tokyo`, `maid-cafe-english`, `maid-cafe-se` and `maid-cafe-programming-school`).
**Measured (CPU only; Ryzen 9 3950X, WSL; the GT 730 2 GB GPU is effectively unusable)**: the MADLAD-400 3B translation model (q4k, about 1.65 GB) run with candle's quantized-t5 example.
- Loading takes about 30 s, so **keep it resident and load once** (patched to translate one line at a time from stdin; the tokenizer path comes from env `MT_TOKENIZER`).
- **Translating short sentences one by one** takes about 3 to 8 s each (2.7 tokens/s) and drops the first half less often than long input.
- `RUSTFLAGS="-C target-cpu=native"` raised speed from about 2.3 to 2.7 tokens/s (about 15%).
- Even with speech recognition (`rs-whisper` tiny, about 10.5 s for 11 s of audio) it is **still not real time**. Next candidates: a smaller translation model, adding T5 to `open-cuda-llm` and comparing, comparing `open-cuda-whisper` for recognition, and speech synthesis (Piper/Kokoro).
**Adoption policy**: apply resident + sentence-by-sentence + native build first to maid-cafe-english's translation and voice (AI answers and listening). No new REST; call over Connect/gRPC. The VPS has 4 slow cores, so **measure and develop on the local PC**; use the VPS only to deploy and verify.
**Open**: (1) T5 in `open-cuda-llm` and a comparison with candle; (2) `open-cuda-whisper` vs `rs-whisper`; (3) GPU (Vulkan/DirectX) measurements (this PC's GT 730 is old, little gain expected); (4) real code changes in each repository (this round is documentation only).

### 再開用メッセージ(2026-11-22、翻訳高速化・関連リポジトリ共有) / Resume message
**日本語**: 前の続きです。`F:\runo\PORTING.md` 末尾の「翻訳の高速化の知見を関連リポジトリで共有」を読んでから、`open-tv-chat`・`maid-cafe-english`・`maid-cafe-tokyo`(`open-maid-cafe` という名前のリポジトリは存在しません)・`aruaru-llm`・`open-cuda`・`open-cpu`・`open-directx` の未了を、確認なしで自動で進めてください。順番: (1)常駐+文ごと翻訳を maid-cafe-english のコードへ反映、(2)`open-cuda-llm` に T5 を追加して candle と比較、(3)`open-cuda-whisper` と `rs-whisper` の比較、(4)GPU 実測。作業は手元PC(WSL)、VPS は配備と確認のみ。決まり: 本物で確認してから完了、秘密は書かない、新しいRESTは作らない、返答は日本語のみ。
**English**: Continuing from before. Read "Sharing the translation-speed findings" at the end of `F:\runo\PORTING.md`, then keep working through the open items of `open-tv-chat`, `maid-cafe-english`, `maid-cafe-tokyo` (there is no repository named `open-maid-cafe`), `aruaru-llm`, `open-cuda`, `open-cpu` and `open-directx` without asking. Order: (1) apply resident + sentence-by-sentence translation to maid-cafe-english's code; (2) add T5 to `open-cuda-llm` and compare with candle; (3) compare `open-cuda-whisper` with `rs-whisper`; (4) GPU measurements. Work on the local PC (WSL); use the VPS only to deploy and verify. Rules: verify on real systems before saying done, never write secrets, no new REST.
