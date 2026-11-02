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
