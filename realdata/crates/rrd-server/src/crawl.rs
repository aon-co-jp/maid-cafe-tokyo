//! 毎朝の自動収集(日本全国の体験・見学・学び・育成の情報)。
//!
//! 毎日 7:00(日本時間)以降の最初の機会に、下の `TOPICS` を「日本全体」と、日替わりの都道府県で検索し、
//! 記事の見出し・要約・URL だけをデータセット `daily_jp_YYYYMMDD` に保存する(AI の分析はしない)。
//! 「場所(日本全体+47都道府県)×知りたい情報」の組を検索する。無料の自前メタ検索(aruaru-search)が使える
//! あいだは共有キーの枠を使わず(検索は `free_only`)、1日 `MAX_SEARCHES_PER_DAY`(2,500)組まで検索する
//! (日中の世界リサーチのために500件を残す: 合わせた1日の上限は `research::MAX_SEARCHES_PER_DAY` の3,000件)。使えないときは、
//! 共有の検索が1日100回までのため、毎日 `DEFAULT_SEARCHES_PER_DAY`(20)組ずつ順番に回る。
//! 環境変数 `RRD_CRAWL_SEARCHES_PER_DAY` で件数を固定できる。
//! 結果は GitHub の非公開リポジトリ(`RRD_ARCHIVE_REPO`)に保存し、VPS には残さない。保存できなかったものだけ
//! `RRD_DATA_DIR/daily/` に置き、あとで送り直す(`archive_old`)。

use std::path::PathBuf;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::Arc;

use crate::places::Place;
use crate::research;
use crate::schema::AppState;

/// 毎朝集める「知りたい情報」
pub const TOPICS: &[&str] = &[
    "stream_fishing",
    "shellfish_tour",
    "mushroom_picking",
    "mushroom_factory",
    "pc_class",
    "claude_class",
    "factory_tour",
    "company_tour",
    "aquaculture_tour",
    "strawberry_farm",
    "farm_experience",
    "forestry_experience",
    "industry_tour",
    "sake_tour",
    "whisky_tour",
    "wine_tour",
    "beer_tour",
    "producer_tour",
    "similar_tour",
    "construction_training",
    "construction_site_tour",
    "carpenter",
    "carpenter_site_tour",
    "facility_mgmt_training",
    "facility_mgmt_fire",
    "job_construction",
    "job_facility",
];
const DEFAULT_SEARCHES_PER_DAY: usize = 20;
/// 毎朝の自動収集が1日に使う検索の上限(日中の世界リサーチのために、合計の上限3,000件のうち500件を残す)
const MAX_SEARCHES_PER_DAY: usize = 2_500;
/// 無料検索のときの、1日の既定の検索の組の数。検索元に負担をかけすぎないよう、上限より少なくする
/// (2026-09-25 実測: 1日に約1,300件を1時間で行うと Brave・Yahoo! JAPAN に拒否され、Bing も検索語の一部しか反映しなくなった)
const DEFAULT_FREE_SEARCHES_PER_DAY: usize = 600;
/// 無料検索のときの、検索と検索の間隔(ミリ秒)
const CRAWL_PACE_MS: u64 = 12_000;
/// 保管庫を使わないときに、手元へ残す日数
const KEEP_DAYS: usize = 7;

/// 検索が使えないエラーがこの回数「続けて」起きたら、その日の収集を打ち切る
const MAX_UNAVAILABLE_STREAK: usize = 4;

/// 直近の自動収集の結果(画面に出す)
#[derive(Clone, Default)]
pub struct LastRun {
    pub finished_unix: u64,
    pub name: String,
    pub ok: usize,
    pub failed: usize,
    pub saved_to: String,
    pub error: String,
}

static LAST_RUN: std::sync::Mutex<Option<LastRun>> = std::sync::Mutex::new(None);

pub fn last_run() -> Option<LastRun> {
    LAST_RUN.lock().ok().and_then(|g| g.clone())
}

/// 再起動直後など、メモリに直近の結果が無いとき、読み込み済みの保存分(daily_jp_YYYYMMDD)から復元する。
/// 成功・失敗の数は保存されていないため 0 とし、保存先の表示でそのことを示す。
pub fn last_run_or_restored(st: &AppState) -> Option<LastRun> {
    if let Some(l) = last_run() {
        return Some(l);
    }
    let m = st.datasets.read().ok()?;
    let name = m.keys().filter(|k| is_daily_name(k)).max()?.clone();
    let s = name.strip_prefix("daily_jp_")?;
    let (y, mo, d): (i64, i64, i64) = (
        s[0..4].parse().ok()?,
        s[4..6].parse().ok()?,
        s[6..8].parse().ok()?,
    );
    Some(LastRun {
        finished_unix: jst_noon_unix(y, mo, d),
        name,
        ok: 0,
        failed: 0,
        saved_to: "GitHub(再起動前の記録。成功・失敗の数は不明)".into(),
        error: String::new(),
    })
}

/// 日本時間のその日の正午(おおよその目安)のUNIX時間
fn jst_noon_unix(y: i64, mo: i64, d: i64) -> u64 {
    let (yy, mm) = if mo <= 2 { (y - 1, mo + 9) } else { (y, mo - 3) };
    let era = yy.div_euclid(400);
    let yoe = yy - era * 400;
    let doy = (153 * mm + 2) / 5 + d - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    let days = era * 146_097 + doe - 719_468;
    (days * 86_400 + 12 * 3600 - 9 * 3600).max(0) as u64
}

pub fn is_running() -> bool {
    RUNNING.load(Ordering::SeqCst)
}

static RUNNING: AtomicBool = AtomicBool::new(false);
/// 最後に保管庫への移動を試みた日(通算日)
static LAST_ARCHIVE_DAY: AtomicU64 = AtomicU64::new(0);
/// 最後に収集を試みた日(通算日)。失敗しても同じ日に何度も検索し直さない(検索の無料枠を守る)
static LAST_TRY_DAY: AtomicU64 = AtomicU64::new(0);

/// 無料の自前メタ検索(aruaru-search)が使えるか。
async fn free_search_available(st: &AppState) -> bool {
    let base = std::env::var("RRD_SEARCH_URL").unwrap_or_else(|_| "http://127.0.0.1:4610".into());
    if base.trim().is_empty() {
        return false;
    }
    st.http
        .get(format!("{}/healthz", base.trim_end_matches('/')))
        .timeout(std::time::Duration::from_secs(3))
        .send()
        .await
        .is_ok_and(|r| r.status().is_success())
}

/// 1日に検索する組の数。aruaru-search が使えるあいだは、上限まで(共有キーの検索枠は使わない)。
/// 使えないときは、共有キーの枠(1日100回)を守るため既定20。環境変数で明示すれば、それを優先する。
fn searches_per_day(free_available: bool) -> usize {
    if let Some(n) = std::env::var("RRD_CRAWL_SEARCHES_PER_DAY")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
    {
        return n.clamp(1, MAX_SEARCHES_PER_DAY);
    }
    if free_available {
        DEFAULT_FREE_SEARCHES_PER_DAY
    } else {
        DEFAULT_SEARCHES_PER_DAY
    }
}

fn day_index(unix: u64) -> u64 {
    (unix + 9 * 3600) / 86_400
}

fn dir(st: &AppState) -> PathBuf {
    st.data_dir.join("daily")
}

fn today(unix: u64) -> String {
    let (y, m, d, _) = crate::market::jst(unix);
    format!("daily_jp_{y:04}{m:02}{d:02}")
}

/// 今日のぶんがまだなら true
pub fn is_due(st: &AppState) -> bool {
    if RUNNING.load(Ordering::SeqCst) {
        return false;
    }
    let now = crate::market::now_unix();
    if LAST_TRY_DAY.load(Ordering::SeqCst) == day_index(now) {
        return false;
    }
    let name = today(now);
    // 今日のぶんが、手元(保存に失敗して残っているもの)にも、読み込み済みのデータにも無ければ実行する。
    // `RRD_CRAWL_FORCE=1` なら、今日のぶんがあっても、起動後に1回だけ実行する(動作確認・やり直し用)。
    let done = dir(st).join(format!("{name}.csv")).exists()
        || st.datasets.read().is_ok_and(|m| m.contains_key(&name));
    !done || std::env::var("RRD_CRAWL_FORCE").is_ok_and(|v| v == "1")
}

/// 保存済みの最新の収集結果を、起動時に読み込む(再起動しても分析に使えるようにする)。
pub fn load_latest(st: &Arc<AppState>) {
    let Ok(rd) = std::fs::read_dir(dir(st)) else {
        return;
    };
    let mut files: Vec<PathBuf> = rd
        .flatten()
        .map(|e| e.path())
        .filter(|p| p.extension().is_some_and(|x| x == "csv"))
        .collect();
    files.sort();
    for p in files.iter().rev().take(KEEP_DAYS) {
        let (Some(name), Ok(df)) = (
            p.file_stem().and_then(|s| s.to_str()).map(String::from),
            rrd_core::csv::read_csv(p),
        ) else {
            continue;
        };
        if let Ok(mut m) = st.datasets.write() {
            m.insert(name, df);
        }
    }
}

/// 今日検索する(場所, 知りたい情報)の組。場所は 0=日本全体、1〜=都道府県(`prefs` の順)。
/// 「場所 × 知りたい情報」を場所順に並べ、毎日 `budget` 組ずつ続きから取る(終わったら最初に戻る)。
fn plan(day_index: u64, budget: usize, n_places: usize) -> Vec<(usize, Vec<&'static str>)> {
    let total = n_places * TOPICS.len();
    if total == 0 {
        return Vec::new();
    }
    let start = if budget >= total {
        0
    } else {
        (day_index as usize * budget) % total
    };
    let mut out: Vec<(usize, Vec<&'static str>)> = Vec::new();
    for k in 0..budget.min(total) {
        let idx = (start + k) % total;
        let (place, topic) = (idx / TOPICS.len(), TOPICS[idx % TOPICS.len()]);
        match out.last_mut() {
            Some((p, v)) if *p == place => v.push(topic),
            _ => out.push((place, vec![topic])),
        }
    }
    out
}

pub async fn run_daily(st: Arc<AppState>) {
    if RUNNING.swap(true, Ordering::SeqCst) {
        return;
    }
    LAST_TRY_DAY.store(day_index(crate::market::now_unix()), Ordering::SeqCst);
    if let Err(e) = collect(&st).await {
        eprintln!("realdata.pro: 毎朝の自動収集に失敗: {e:#}");
        if let Ok(mut g) = LAST_RUN.lock() {
            *g = Some(LastRun {
                finished_unix: crate::market::now_unix(),
                error: format!("{e:#}").chars().take(200).collect(),
                ..Default::default()
            });
        }
    }
    RUNNING.store(false, Ordering::SeqCst);
}

async fn collect(st: &Arc<AppState>) -> anyhow::Result<()> {
    let Some(regions) = st.regions.read().ok().and_then(|g| g.clone()) else {
        return Ok(()); // 地名データが未読み込み。次の巡回(5分後)にやり直す
    };
    let now = crate::market::now_unix();
    let prefs: Vec<String> = regions
        .top_level("JP")
        .items
        .into_iter()
        .map(|i| i.code)
        .collect();
    let free = free_search_available(st).await;
    let mut places: Vec<(Place, Vec<String>)> = Vec::new();
    for (idx, topics) in plan(day_index(now), searches_per_day(free), prefs.len() + 1) {
        let region = if idx == 0 {
            None
        } else {
            prefs.get(idx - 1).cloned()
        };
        places.push((
            Place {
                country: "JP".into(),
                region,
                city: None,
            },
            topics.iter().map(|s| s.to_string()).collect(),
        ));
    }
    let mut merged: Option<String> = None;
    let (mut ok, mut failed, mut empty) = (0usize, 0usize, 0usize);
    let mut unavailable_streak = 0usize;
    eprintln!(
        "realdata.pro: 毎朝の自動収集を開始します(場所 {} か所、検索の組 {} 件、無料検索 {})",
        places.len(),
        places.iter().map(|(_, t)| t.len()).sum::<usize>(),
        if free { "使える" } else { "使えない" }
    );
    for (place, topics) in places {
        let n_topics = topics.len();
        let label = format!(
            "{}/{}",
            place.country,
            place.region.clone().unwrap_or_else(|| "全国".into())
        );
        let opt = research::Options {
            theme: String::new(),
            places: vec![place],
            topics,
            search_languages: Vec::new(),
            translate_items: false,
            per_country: 3,
            include_news: false,
            include_github: false,
            include_youtube: false,
            languages: Vec::new(),
            analyze: false,
            // aruaru-search が使えるあいだは、共有キーの検索枠へは移らない(日中の世界リサーチの枠を守る)
            free_only: free,
            use_osm: false,
            // 検索元に機械利用を疑われないよう、無料検索のときは1件ずつ間を空け、検索語も短くする
            pace_ms: if free { CRAWL_PACE_MS } else { 0 },
            short_queries: free,
        };
        match research::run(&st.http, &st.llm_base, &regions, opt).await {
            Ok(out) => {
                ok += 1;
                unavailable_streak = 0;
                eprintln!(
                    "realdata.pro: 自動収集 {label}: {n_topics}件の検索で {} 件を収集",
                    out.items.len()
                );
                let csv = rrd_core::csv::to_csv_string(&out.df);
                match &mut merged {
                    None => merged = Some(csv),
                    Some(m) => {
                        // 見出し行を除いて連結する
                        for line in csv.lines().skip(1) {
                            m.push_str(line);
                            m.push('\n');
                        }
                    }
                }
            }
            Err(e) if format!("{e:#}").contains("1件も集められませんでした") => {
                // 検索元の障害ではなく、その場所・分野に該当する情報が無かった(検索語を含まない結果が除外された)
                empty += 1;
                unavailable_streak = 0;
                eprintln!("realdata.pro: 自動収集 {label}: 該当する情報なし(失敗ではありません)");
            }
            Err(e) => {
                failed += 1;
                let msg = format!("{e:#}");
                eprintln!(
                    "realdata.pro: 毎朝の自動収集(1か所)に失敗 {label}({n_topics}件の検索): {}",
                    msg.chars().take(600).collect::<String>()
                );
                // 検索が使えない(枠切れ・検索元に拒否)ことを示すエラーが「続けて」起きたときだけ打ち切る。
                // 1か所だけ(検索元が一時的に休止中など)で打ち切ると、9/29 のように23か所中2か所で止まる
                if msg.contains("quota") || msg.contains("free search") {
                    unavailable_streak += 1;
                    if unavailable_streak >= MAX_UNAVAILABLE_STREAK {
                        eprintln!("realdata.pro: 検索が{MAX_UNAVAILABLE_STREAK}か所続けて使えなかったため、残りは翌日にします");
                        break;
                    }
                } else {
                    unavailable_streak = 0;
                }
            }
        }
    }
    let Some(csv) = merged else {
        anyhow::bail!("どの場所も収集できませんでした");
    };
    let df = rrd_core::csv::read_csv_str(&csv)?;
    let name = today(now);
    if let Ok(mut m) = st.datasets.write() {
        m.insert(name.clone(), df);
    }
    // 保存先(GitHub の非公開リポジトリ)へ保存する。VPS のディスクには残さない。
    // 保存できなかったときだけ手元に置き、後で送り直す(`archive_old`)。
    let saved_remote = match &st.store {
        Some(store) => match store.save_daily(&name, &csv).await {
            Ok(()) => true,
            Err(e) => {
                eprintln!("realdata.pro: 自動収集を GitHub へ保存できませんでした(手元に残して送り直します): {e:#}");
                false
            }
        },
        None => false,
    };
    if !saved_remote {
        let d = dir(st);
        std::fs::create_dir_all(&d)?;
        std::fs::write(d.join(format!("{name}.csv")), &csv)?;
    }
    if let Ok(mut g) = LAST_RUN.lock() {
        *g = Some(LastRun {
            finished_unix: crate::market::now_unix(),
            name: name.clone(),
            ok,
            failed,
            saved_to: if saved_remote {
                "GitHub".into()
            } else {
                "手元(後で送り直し)".into()
            },
            error: String::new(),
        });
    }
    eprintln!("realdata.pro: 毎朝の自動収集を保存しました({name}、{ok}か所成功・{empty}か所該当なし・{failed}か所失敗、保存先 {})", if saved_remote { "GitHub" } else { "手元(後で送り直し)" });
    Ok(())
}

/// 手元に残った収集結果があり、今日まだ送り直していなければ true(保存先が設定されているときだけ)
pub fn archive_due(st: &AppState) -> bool {
    st.store.is_some()
        && LAST_ARCHIVE_DAY.load(Ordering::SeqCst) != day_index(crate::market::now_unix())
        && std::fs::read_dir(dir(st)).is_ok_and(|mut rd| rd.any(|e| e.is_ok()))
}

/// 「daily_jp_YYYYMMDD」の形の名前か
fn is_daily_name(name: &str) -> bool {
    name.strip_prefix("daily_jp_")
        .is_some_and(|s| s.len() == 8 && s.bytes().all(|b| b.is_ascii_digit()))
}

/// 手元に残っている収集結果(GitHub へ保存できなかったもの)を、保存先へ送って手元から消す。
/// 保存先が設定されていなければ、従来どおり古い収集ファイルを7日ぶんだけ残して消す。
/// 3日などの保持期限は無い: 保存できたものは、すべて GitHub にある。
pub async fn archive_old(st: Arc<AppState>) {
    let now = crate::market::now_unix();
    let Some(store) = &st.store else {
        prune(&st);
        return;
    };
    LAST_ARCHIVE_DAY.store(day_index(now), Ordering::SeqCst);
    let Ok(rd) = std::fs::read_dir(dir(&st)) else {
        return;
    };
    let mut sent = 0;
    for p in rd.flatten().map(|e| e.path()) {
        let Some(name) = p.file_stem().and_then(|s| s.to_str()).map(String::from) else {
            continue;
        };
        if !is_daily_name(&name) || !p.extension().is_some_and(|x| x == "csv") {
            continue;
        }
        let Ok(csv) = std::fs::read_to_string(&p) else {
            continue;
        };
        match store.save_daily(&name, &csv).await {
            Ok(()) => {
                let _ = std::fs::remove_file(&p);
                sent += 1;
            }
            Err(e) => eprintln!(
                "realdata.pro: {name} を GitHub へ送れませんでした(手元に残します): {e:#}"
            ),
        }
    }
    if sent > 0 {
        eprintln!("realdata.pro: 手元に残っていた収集結果 {sent} 日ぶんを GitHub へ送りました");
    }
}

/// 保管庫を使わないとき: 古い日のデータ(ファイルとメモリ上)を消す
fn prune(st: &Arc<AppState>) {
    let Ok(rd) = std::fs::read_dir(dir(st)) else {
        return;
    };
    let mut files: Vec<PathBuf> = rd.flatten().map(|e| e.path()).collect();
    files.sort();
    let extra = files.len().saturating_sub(KEEP_DAYS);
    for p in files.into_iter().take(extra) {
        let stem = p.file_stem().and_then(|s| s.to_str()).map(String::from);
        let _ = std::fs::remove_file(&p);
        if let (Some(s), Ok(mut m)) = (stem, st.datasets.write()) {
            m.remove(&s);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn jst_noon_matches_known_dates() {
        // 2026-11-16 12:00 JST = 2026-11-16 03:00 UTC = 1_794_798_000
        assert_eq!(jst_noon_unix(1970, 1, 2), 86_400 + 3 * 3600);
        let u = jst_noon_unix(2026, 10, 16);
        assert_eq!(today(u), "daily_jp_20261016");
        let u = jst_noon_unix(2024, 2, 29);
        assert_eq!(today(u), "daily_jp_20240229");
    }

    #[test]
    fn plan_uses_the_budget_and_covers_everything_eventually() {
        let n_places = 48;
        let total = n_places * TOPICS.len();
        let mut seen = std::collections::HashSet::new();
        let days = total.div_ceil(20) as u64;
        for day in 0..days {
            let p = plan(day, 20, n_places);
            assert_eq!(p.iter().map(|(_, v)| v.len()).sum::<usize>(), 20);
            for (place, topics) in p {
                for t in topics {
                    seen.insert((place, t));
                }
            }
        }
        assert_eq!(seen.len(), total, "毎日20組ずつで、全ての組を一巡する");
        assert!(plan(0, 20, 0).is_empty());
    }

    #[test]
    fn daily_names() {
        assert!(is_daily_name("daily_jp_20260925"));
        assert!(!is_daily_name("daily_jp_2026"));
        assert!(!is_daily_name("other_20260925"));
    }

    #[test]
    fn all_crawl_topics_exist() {
        for id in TOPICS {
            assert!(crate::places::topic(id).is_some(), "{id}");
        }
    }
}
