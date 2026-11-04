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

### Deutsch (KI-Übersetzung, noch nicht von Muttersprachlern geprüft)
- **REST wird abgeschafft. Neue APIs werden nicht als REST gebaut.** APIs, die aus dem Browser oder mit `curl` aufgerufen werden, nutzen **Connect-Unary-Aufrufe** (`POST /<Paket>.<Service>/<Methode>`, `content-type: application/json`, JSON-Body); zwischen Diensten gilt **gRPC / gRPC-web** (wie bei der Admin-API von RPoem, `open_runo.admin.v1.Admin`). Streaming erst, wenn es wirklich nötig ist.
- **Bestehende REST-Endpunkte werden einzeln migriert, sobald man sie anfasst.** Nach der Migration wird die alte REST-Route entfernt. Bis dahin bleiben sie bestehen, es werden aber **keine neuen hinzugefügt**.
- **JSON wird auf RS-JSON vereinheitlicht**: Lesen mit `from_str_secure` / `parse_secure` (Grenzen für Größe, Tiefe und doppelte Schlüssel), Schreiben mit `rust_json::fast`. `prost` kommt nicht in Browser-WASM (die Datei würde größer).
- **Ausnahmen (Formate, die ein fremder Standard vorgibt, nicht unsere eigene API)**: ACME, OAuth/OIDC-Callbacks, Webhooks von Dritten (z. B. GitHub), Health-Checks, statische Dateien, OTLP usw. Diese nehmen schlichtes HTTP entgegen, wie es der Standard verlangt.
- Referenzimplementierungen: `RPoem` (`open_runo.admin.v1.Admin`) und `open-easy-web` (`server/src/connect.rs`, `proto/open_easy_web/admin/v1/admin.proto`).
- Hinweis: Ob der Code eines Repositorys diese Richtlinie schon befolgt, hängt vom jeweiligen Repository ab. Dieser Abschnitt hält die Richtlinie fest; er bedeutet nicht, dass der Code bereits geändert wurde.

### Русский (машинный перевод, носителями языка ещё не проверен)
- **REST полностью отменяется. Новые API не создаются как REST.** API, вызываемые из браузера или через `curl`, используют **унарные вызовы Connect** (`POST /<пакет>.<Service>/<Method>`, `content-type: application/json`, тело — JSON); между сервисами — **gRPC / gRPC-web** (так же, как административный API RPoem, `open_runo.admin.v1.Admin`). Потоковая передача — только когда она действительно нужна.
- **Существующие REST-эндпоинты переносятся по одному, когда до них доходят руки.** После переноса старый REST-маршрут удаляется. До завершения переноса они остаются, но **новые не добавляются**.
- **JSON унифицируется на RS-JSON**: чтение через `from_str_secure` / `parse_secure` (ограничения на размер, глубину и повторяющиеся ключи), запись через `rust_json::fast`. `prost` не добавляется в браузерный WASM (размер вырос бы).
- **Исключения (форматы, заданные чужим стандартом, а не наш собственный API)**: ACME, обратные вызовы OAuth/OIDC, вебхуки сторонних сервисов (например, GitHub), проверки работоспособности, раздача статических файлов, OTLP и т. п. Они принимают обычный HTTP, как требует стандарт.
- Эталонные реализации: `RPoem` (`open_runo.admin.v1.Admin`) и `open-easy-web` (`server/src/connect.rs`, `proto/open_easy_web/admin/v1/admin.proto`).
- Примечание: соответствует ли код конкретного репозитория этой политике, зависит от самого репозитория. Этот раздел фиксирует политику и не означает, что код уже изменён.
