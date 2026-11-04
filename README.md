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
