# docs/i18n — per-language documentation folders / 言語別ドキュメントフォルダ

**Honest disclosure / 正直な開示**

This folder contains one subfolder per language listed in open-english's language
registry (130 languages), each with `README.md`, `CLAUDE.md` and `PORTING.md`.
**Almost all of them are placeholders**: the documents have not been translated yet,
and no machine translation has been pasted in to make the coverage look larger than it
is. The canonical documents are the Japanese ones at the repository root, with an
English `README-English.md` and human-written translations for eight languages
(German, Italian, French, Russian, Ukrainian, Hebrew, Persian, Arabic) as flat files.

このフォルダには、open-englishの対応言語一覧に載っている**130言語**ぶんのサブフォルダが
あり、それぞれに `README.md` / `CLAUDE.md` / `PORTING.md` を置いています。
**そのほとんどはプレースホルダー**です——本文はまだ翻訳しておらず、対応言語数を多く
見せるために機械翻訳を貼り付けることもしていません。正本はリポジトリ直下の日本語版で、
英語版 `README-English.md` と、人手で用意した8言語(ドイツ語・イタリア語・フランス語・
ロシア語・ウクライナ語・ヘブライ語・ペルシャ語・アラビア語)のフラットなファイルがあります。

## Language list / 言語一覧

| Language | Code | Name | Practice questions / 模擬問題 | Docs |
| --- | --- | --- | --- | --- |
| 🇬🇧🇺🇸 English | `en` | English / 英語 | 既定 / default | [README](en/README.md) · [CLAUDE](en/CLAUDE.md) · [PORTING](en/PORTING.md) |
| 🇯🇵 日本語 | `ja` | Japanese / 日本語 | 既定 / default | [README](ja/README.md) · [CLAUDE](ja/CLAUDE.md) · [PORTING](ja/PORTING.md) |
| 🇪🇸🇲🇽 Español | `es` | Spanish / スペイン語 | ✅ 6問 / 6 items | [README](es/README.md) · [CLAUDE](es/CLAUDE.md) · [PORTING](es/PORTING.md) |
| 🇫🇷 Français | `fr` | French / フランス語 | ✅ 6問 / 6 items | [README](fr/README.md) · [CLAUDE](fr/CLAUDE.md) · [PORTING](fr/PORTING.md) |
| 🇩🇪🇦🇹 Deutsch | `de` | German / ドイツ語 | ✅ 6問 / 6 items | [README](de/README.md) · [CLAUDE](de/CLAUDE.md) · [PORTING](de/PORTING.md) |
| 🇮🇹 Italiano | `it` | Italian / イタリア語 | ✅ 6問 / 6 items | [README](it/README.md) · [CLAUDE](it/CLAUDE.md) · [PORTING](it/PORTING.md) |
| 🇵🇹🇧🇷 Português | `pt` | Portuguese / ポルトガル語 | ✅ 6問 / 6 items | [README](pt/README.md) · [CLAUDE](pt/CLAUDE.md) · [PORTING](pt/PORTING.md) |
| 🇳🇱 Nederlands | `nl` | Dutch / オランダ語 | ✅ 6問 / 6 items | [README](nl/README.md) · [CLAUDE](nl/CLAUDE.md) · [PORTING](nl/PORTING.md) |
| 🇸🇪 Svenska | `sv` | Swedish / スウェーデン語 | ✅ 5問 / 5 items | [README](sv/README.md) · [CLAUDE](sv/CLAUDE.md) · [PORTING](sv/PORTING.md) |
| 🇳🇴 Norsk | `no` | Norwegian / ノルウェー語 | ✅ 4問 / 4 items | [README](no/README.md) · [CLAUDE](no/CLAUDE.md) · [PORTING](no/PORTING.md) |
| 🇩🇰 Dansk | `da` | Danish / デンマーク語 | ✅ 4問 / 4 items | [README](da/README.md) · [CLAUDE](da/CLAUDE.md) · [PORTING](da/PORTING.md) |
| 🇫🇮 Suomi | `fi` | Finnish / フィンランド語 | ✅ 4問 / 4 items | [README](fi/README.md) · [CLAUDE](fi/CLAUDE.md) · [PORTING](fi/PORTING.md) |
| 🇵🇱 Polski | `pl` | Polish / ポーランド語 | ✅ 4問 / 4 items | [README](pl/README.md) · [CLAUDE](pl/CLAUDE.md) · [PORTING](pl/PORTING.md) |
| 🇨🇿 Čeština | `cs` | Czech / チェコ語 | ✅ 4問 / 4 items | [README](cs/README.md) · [CLAUDE](cs/CLAUDE.md) · [PORTING](cs/PORTING.md) |
| 🇭🇺 Magyar | `hu` | Hungarian / ハンガリー語 | ✅ 4問 / 4 items | [README](hu/README.md) · [CLAUDE](hu/CLAUDE.md) · [PORTING](hu/PORTING.md) |
| 🇨🇭 Rumantsch | `rm` | Romansh (Switzerland) / ロマンシュ語(スイス) | ✅ 3問 / 3 items | [README](rm/README.md) · [CLAUDE](rm/CLAUDE.md) · [PORTING](rm/PORTING.md) |
| 🇷🇴 Română | `ro` | Romanian / ルーマニア語 | ✅ 4問 / 4 items | [README](ro/README.md) · [CLAUDE](ro/CLAUDE.md) · [PORTING](ro/PORTING.md) |
| 🇷🇺 Русский | `ru` | Russian / ロシア語 | ✅ 5問 / 5 items | [README](ru/README.md) · [CLAUDE](ru/CLAUDE.md) · [PORTING](ru/PORTING.md) |
| 🇺🇦 Українська | `uk` | Ukrainian / ウクライナ語 | ✅ 4問 / 4 items | [README](uk/README.md) · [CLAUDE](uk/CLAUDE.md) · [PORTING](uk/PORTING.md) |
| 🇬🇷 Ελληνικά | `el` | Greek / ギリシャ語 | ✅ 4問 / 4 items | [README](el/README.md) · [CLAUDE](el/CLAUDE.md) · [PORTING](el/PORTING.md) |
| 🇹🇷 Türkçe | `tr` | Turkish / トルコ語 | ✅ 4問 / 4 items | [README](tr/README.md) · [CLAUDE](tr/CLAUDE.md) · [PORTING](tr/PORTING.md) |
| 🇸🇦🇦🇪 العربية | `ar` | Arabic / アラビア語 | ✅ 4問 / 4 items | [README](ar/README.md) · [CLAUDE](ar/CLAUDE.md) · [PORTING](ar/PORTING.md) |
| 🇮🇱 עברית | `he` | Hebrew / ヘブライ語 | ✅ 4問 / 4 items | [README](he/README.md) · [CLAUDE](he/CLAUDE.md) · [PORTING](he/PORTING.md) |
| 🇮🇷 فارسی | `fa` | Persian / ペルシャ語 | ✅ 4問 / 4 items | [README](fa/README.md) · [CLAUDE](fa/CLAUDE.md) · [PORTING](fa/PORTING.md) |
| 🇮🇳 हिन्दी | `hi` | Hindi / ヒンディー語 | ✅ 4問 / 4 items | [README](hi/README.md) · [CLAUDE](hi/CLAUDE.md) · [PORTING](hi/PORTING.md) |
| 🇧🇩 বাংলা | `bn` | Bengali / ベンガル語 | ✅ 3問 / 3 items | [README](bn/README.md) · [CLAUDE](bn/CLAUDE.md) · [PORTING](bn/PORTING.md) |
| 🇮🇩 Bahasa Indonesia | `id` | Indonesian / インドネシア語 | ✅ 4問 / 4 items | [README](id/README.md) · [CLAUDE](id/CLAUDE.md) · [PORTING](id/PORTING.md) |
| 🇲🇾 Bahasa Melayu | `ms` | Malay / マレー語 | ✅ 3問 / 3 items | [README](ms/README.md) · [CLAUDE](ms/CLAUDE.md) · [PORTING](ms/PORTING.md) |
| 🇻🇳 Tiếng Việt | `vi` | Vietnamese / ベトナム語 | ✅ 4問 / 4 items | [README](vi/README.md) · [CLAUDE](vi/CLAUDE.md) · [PORTING](vi/PORTING.md) |
| 🇹🇭 ไทย | `th` | Thai / タイ語 | ✅ 3問 / 3 items | [README](th/README.md) · [CLAUDE](th/CLAUDE.md) · [PORTING](th/PORTING.md) |
| 🇵🇭 Filipino | `tl` | Filipino (Tagalog) / フィリピン語(タガログ語) | ✅ 3問 / 3 items | [README](tl/README.md) · [CLAUDE](tl/CLAUDE.md) · [PORTING](tl/PORTING.md) |
| 🇨🇳 中文(简体) | `zh` | Chinese (Simplified) / 中国語(簡体字) | ✅ 5問 / 5 items | [README](zh/README.md) · [CLAUDE](zh/CLAUDE.md) · [PORTING](zh/PORTING.md) |
| 🇹🇼🇭🇰 中文(繁體) | `zh-Hant` | Chinese (Traditional) / 中国語(繁体字) | ✅ 4問 / 4 items | [README](zh-Hant/README.md) · [CLAUDE](zh-Hant/CLAUDE.md) · [PORTING](zh-Hant/PORTING.md) |
| 🇮🇳🇱🇰 தமிழ் | `ta` | Tamil / タミル語 | ✅ 3問 / 3 items | [README](ta/README.md) · [CLAUDE](ta/CLAUDE.md) · [PORTING](ta/PORTING.md) |
| 🇮🇳 తెలుగు | `te` | Telugu / テルグ語 | ✅ 3問 / 3 items | [README](te/README.md) · [CLAUDE](te/CLAUDE.md) · [PORTING](te/PORTING.md) |
| 🇵🇰 اردو | `ur` | Urdu / ウルドゥー語 | ✅ 3問 / 3 items | [README](ur/README.md) · [CLAUDE](ur/CLAUDE.md) · [PORTING](ur/PORTING.md) |
| 🇮🇳 मराठी | `mr` | Marathi / マラーティー語 | ✅ 3問 / 3 items | [README](mr/README.md) · [CLAUDE](mr/CLAUDE.md) · [PORTING](mr/PORTING.md) |
| 🇮🇳🇵🇰 ਪੰਜਾਬੀ | `pa` | Punjabi / パンジャブ語 | ✅ 3問 / 3 items | [README](pa/README.md) · [CLAUDE](pa/CLAUDE.md) · [PORTING](pa/PORTING.md) |
| 🇰🇷 한국어 | `ko` | Korean / 韓国語 | ✅ 5問 / 5 items | [README](ko/README.md) · [CLAUDE](ko/CLAUDE.md) · [PORTING](ko/PORTING.md) |
| 🇰🇪🇹🇿 Kiswahili | `sw` | Swahili / スワヒリ語 | ✅ 3問 / 3 items | [README](sw/README.md) · [CLAUDE](sw/CLAUDE.md) · [PORTING](sw/PORTING.md) |
| 🇿🇦 Afrikaans | `af` | Afrikaans / アフリカーンス語 | — 未作成 / not written yet | [README](af/README.md) · [CLAUDE](af/CLAUDE.md) · [PORTING](af/PORTING.md) |
| 🇦🇱 Shqip | `sq` | Albanian / アルバニア語 | — 未作成 / not written yet | [README](sq/README.md) · [CLAUDE](sq/CLAUDE.md) · [PORTING](sq/PORTING.md) |
| 🇪🇹 አማርኛ | `am` | Amharic / アムハラ語 | — 未作成 / not written yet | [README](am/README.md) · [CLAUDE](am/CLAUDE.md) · [PORTING](am/PORTING.md) |
| 🇦🇲 Հայերեն | `hy` | Armenian / アルメニア語 | — 未作成 / not written yet | [README](hy/README.md) · [CLAUDE](hy/CLAUDE.md) · [PORTING](hy/PORTING.md) |
| 🇮🇳 অসমীয়া | `as` | Assamese / アッサム語 | — 未作成 / not written yet | [README](as/README.md) · [CLAUDE](as/CLAUDE.md) · [PORTING](as/PORTING.md) |
| 🇦🇿 Azərbaycanca | `az` | Azerbaijani / アゼルバイジャン語 | — 未作成 / not written yet | [README](az/README.md) · [CLAUDE](az/CLAUDE.md) · [PORTING](az/PORTING.md) |
| 🇪🇸 Euskara | `eu` | Basque / バスク語 | — 未作成 / not written yet | [README](eu/README.md) · [CLAUDE](eu/CLAUDE.md) · [PORTING](eu/PORTING.md) |
| 🇧🇾 Беларуская | `be` | Belarusian / ベラルーシ語 | — 未作成 / not written yet | [README](be/README.md) · [CLAUDE](be/CLAUDE.md) · [PORTING](be/PORTING.md) |
| 🇧🇦 Bosanski | `bs` | Bosnian / ボスニア語 | — 未作成 / not written yet | [README](bs/README.md) · [CLAUDE](bs/CLAUDE.md) · [PORTING](bs/PORTING.md) |
| 🇫🇷 Brezhoneg | `br` | Breton / ブルトン語 | — 未作成 / not written yet | [README](br/README.md) · [CLAUDE](br/CLAUDE.md) · [PORTING](br/PORTING.md) |
| 🇧🇬 Български | `bg` | Bulgarian / ブルガリア語 | — 未作成 / not written yet | [README](bg/README.md) · [CLAUDE](bg/CLAUDE.md) · [PORTING](bg/PORTING.md) |
| 🇲🇲 မြန်မာဘာသာ | `my` | Burmese / ビルマ語 | — 未作成 / not written yet | [README](my/README.md) · [CLAUDE](my/CLAUDE.md) · [PORTING](my/PORTING.md) |
| 🇭🇰 粵語 | `yue` | Cantonese / 広東語 | — 未作成 / not written yet | [README](yue/README.md) · [CLAUDE](yue/CLAUDE.md) · [PORTING](yue/PORTING.md) |
| 🇪🇸 Català | `ca` | Catalan / カタルーニャ語 | — 未作成 / not written yet | [README](ca/README.md) · [CLAUDE](ca/CLAUDE.md) · [PORTING](ca/PORTING.md) |
| 🇵🇭 Cebuano | `ceb` | Cebuano / セブアノ語 | — 未作成 / not written yet | [README](ceb/README.md) · [CLAUDE](ceb/CLAUDE.md) · [PORTING](ceb/PORTING.md) |
| 🇲🇼 Chichewa | `ny` | Chichewa / チェワ語 | — 未作成 / not written yet | [README](ny/README.md) · [CLAUDE](ny/CLAUDE.md) · [PORTING](ny/PORTING.md) |
| 🇫🇷 Corsu | `co` | Corsican / コルシカ語 | — 未作成 / not written yet | [README](co/README.md) · [CLAUDE](co/CLAUDE.md) · [PORTING](co/PORTING.md) |
| 🇭🇷 Hrvatski | `hr` | Croatian / クロアチア語 | — 未作成 / not written yet | [README](hr/README.md) · [CLAUDE](hr/CLAUDE.md) · [PORTING](hr/PORTING.md) |
| 🇲🇻 ދިވެހި | `dv` | Dhivehi / ディベヒ語 | — 未作成 / not written yet | [README](dv/README.md) · [CLAUDE](dv/CLAUDE.md) · [PORTING](dv/PORTING.md) |
| 🌐 Esperanto | `eo` | Esperanto / エスペラント | — 未作成 / not written yet | [README](eo/README.md) · [CLAUDE](eo/CLAUDE.md) · [PORTING](eo/PORTING.md) |
| 🇪🇪 Eesti | `et` | Estonian / エストニア語 | — 未作成 / not written yet | [README](et/README.md) · [CLAUDE](et/CLAUDE.md) · [PORTING](et/PORTING.md) |
| 🇬🇭 Eʋegbe | `ee` | Ewe / エウェ語 | — 未作成 / not written yet | [README](ee/README.md) · [CLAUDE](ee/CLAUDE.md) · [PORTING](ee/PORTING.md) |
| 🇫🇴 Føroyskt | `fo` | Faroese / フェロー語 | — 未作成 / not written yet | [README](fo/README.md) · [CLAUDE](fo/CLAUDE.md) · [PORTING](fo/PORTING.md) |
| 🇫🇯 Na Vosa Vakaviti | `fj` | Fijian / フィジー語 | — 未作成 / not written yet | [README](fj/README.md) · [CLAUDE](fj/CLAUDE.md) · [PORTING](fj/PORTING.md) |
| 🇪🇸 Galego | `gl` | Galician / ガリシア語 | — 未作成 / not written yet | [README](gl/README.md) · [CLAUDE](gl/CLAUDE.md) · [PORTING](gl/PORTING.md) |
| 🇬🇪 ქართული | `ka` | Georgian / グルジア語(ジョージア語) | — 未作成 / not written yet | [README](ka/README.md) · [CLAUDE](ka/CLAUDE.md) · [PORTING](ka/PORTING.md) |
| 🇵🇾 Avañe'ẽ | `gn` | Guarani / グアラニー語 | — 未作成 / not written yet | [README](gn/README.md) · [CLAUDE](gn/CLAUDE.md) · [PORTING](gn/PORTING.md) |
| 🇮🇳 ગુજરાતી | `gu` | Gujarati / グジャラート語 | — 未作成 / not written yet | [README](gu/README.md) · [CLAUDE](gu/CLAUDE.md) · [PORTING](gu/PORTING.md) |
| 🇭🇹 Kreyòl ayisyen | `ht` | Haitian Creole / ハイチ・クレオール語 | — 未作成 / not written yet | [README](ht/README.md) · [CLAUDE](ht/CLAUDE.md) · [PORTING](ht/PORTING.md) |
| 🇳🇬 Hausa | `ha` | Hausa / ハウサ語 | — 未作成 / not written yet | [README](ha/README.md) · [CLAUDE](ha/CLAUDE.md) · [PORTING](ha/PORTING.md) |
| 🇺🇸 ʻŌlelo Hawaiʻi | `haw` | Hawaiian / ハワイ語 | — 未作成 / not written yet | [README](haw/README.md) · [CLAUDE](haw/CLAUDE.md) · [PORTING](haw/PORTING.md) |
| 🇱🇦 Hmoob | `hmn` | Hmong / モン語 | — 未作成 / not written yet | [README](hmn/README.md) · [CLAUDE](hmn/CLAUDE.md) · [PORTING](hmn/PORTING.md) |
| 🇮🇸 Íslenska | `is` | Icelandic / アイスランド語 | — 未作成 / not written yet | [README](is/README.md) · [CLAUDE](is/CLAUDE.md) · [PORTING](is/PORTING.md) |
| 🇳🇬 Asụsụ Igbo | `ig` | Igbo / イボ語 | — 未作成 / not written yet | [README](ig/README.md) · [CLAUDE](ig/CLAUDE.md) · [PORTING](ig/PORTING.md) |
| 🇵🇭 Ilokano | `ilo` | Ilocano / イロカノ語 | — 未作成 / not written yet | [README](ilo/README.md) · [CLAUDE](ilo/CLAUDE.md) · [PORTING](ilo/PORTING.md) |
| 🇮🇪 Gaeilge | `ga` | Irish / アイルランド語 | — 未作成 / not written yet | [README](ga/README.md) · [CLAUDE](ga/CLAUDE.md) · [PORTING](ga/PORTING.md) |
| 🇮🇩 Basa Jawa | `jv` | Javanese / ジャワ語 | — 未作成 / not written yet | [README](jv/README.md) · [CLAUDE](jv/CLAUDE.md) · [PORTING](jv/PORTING.md) |
| 🇮🇳 ಕನ್ನಡ | `kn` | Kannada / カンナダ語 | — 未作成 / not written yet | [README](kn/README.md) · [CLAUDE](kn/CLAUDE.md) · [PORTING](kn/PORTING.md) |
| 🇰🇿 Қазақша | `kk` | Kazakh / カザフ語 | — 未作成 / not written yet | [README](kk/README.md) · [CLAUDE](kk/CLAUDE.md) · [PORTING](kk/PORTING.md) |
| 🇰🇭 ភាសាខ្មែរ | `km` | Khmer / クメール語 | — 未作成 / not written yet | [README](km/README.md) · [CLAUDE](km/CLAUDE.md) · [PORTING](km/PORTING.md) |
| 🇷🇼 Ikinyarwanda | `rw` | Kinyarwanda / キニアルワンダ語 | — 未作成 / not written yet | [README](rw/README.md) · [CLAUDE](rw/CLAUDE.md) · [PORTING](rw/PORTING.md) |
| 🇰🇬 Кыргызча | `ky` | Kyrgyz / キルギス語 | — 未作成 / not written yet | [README](ky/README.md) · [CLAUDE](ky/CLAUDE.md) · [PORTING](ky/PORTING.md) |
| 🇹🇷 Kurdî | `ku` | Kurdish (Kurmanji) / クルド語 | — 未作成 / not written yet | [README](ku/README.md) · [CLAUDE](ku/CLAUDE.md) · [PORTING](ku/PORTING.md) |
| 🇱🇦 ພາສາລາວ | `lo` | Lao / ラオ語 | — 未作成 / not written yet | [README](lo/README.md) · [CLAUDE](lo/CLAUDE.md) · [PORTING](lo/PORTING.md) |
| 🇻🇦 Latina | `la` | Latin / ラテン語 | — 未作成 / not written yet | [README](la/README.md) · [CLAUDE](la/CLAUDE.md) · [PORTING](la/PORTING.md) |
| 🇱🇻 Latviešu | `lv` | Latvian / ラトビア語 | — 未作成 / not written yet | [README](lv/README.md) · [CLAUDE](lv/CLAUDE.md) · [PORTING](lv/PORTING.md) |
| 🇱🇹 Lietuvių | `lt` | Lithuanian / リトアニア語 | — 未作成 / not written yet | [README](lt/README.md) · [CLAUDE](lt/CLAUDE.md) · [PORTING](lt/PORTING.md) |
| 🇱🇺 Lëtzebuergesch | `lb` | Luxembourgish / ルクセンブルク語 | — 未作成 / not written yet | [README](lb/README.md) · [CLAUDE](lb/CLAUDE.md) · [PORTING](lb/PORTING.md) |
| 🇲🇰 Македонски | `mk` | Macedonian / マケドニア語 | — 未作成 / not written yet | [README](mk/README.md) · [CLAUDE](mk/CLAUDE.md) · [PORTING](mk/PORTING.md) |
| 🇲🇬 Malagasy | `mg` | Malagasy / マダガスカル語 | — 未作成 / not written yet | [README](mg/README.md) · [CLAUDE](mg/CLAUDE.md) · [PORTING](mg/PORTING.md) |
| 🇮🇳 മലയാളം | `ml` | Malayalam / マラヤーラム語 | — 未作成 / not written yet | [README](ml/README.md) · [CLAUDE](ml/CLAUDE.md) · [PORTING](ml/PORTING.md) |
| 🇲🇹 Malti | `mt` | Maltese / マルタ語 | — 未作成 / not written yet | [README](mt/README.md) · [CLAUDE](mt/CLAUDE.md) · [PORTING](mt/PORTING.md) |
| 🇳🇿 Te Reo Māori | `mi` | Maori / マオリ語 | — 未作成 / not written yet | [README](mi/README.md) · [CLAUDE](mi/CLAUDE.md) · [PORTING](mi/PORTING.md) |
| 🇲🇳 Монгол | `mn` | Mongolian / モンゴル語 | — 未作成 / not written yet | [README](mn/README.md) · [CLAUDE](mn/CLAUDE.md) · [PORTING](mn/PORTING.md) |
| 🇳🇵 नेपाली | `ne` | Nepali / ネパール語 | — 未作成 / not written yet | [README](ne/README.md) · [CLAUDE](ne/CLAUDE.md) · [PORTING](ne/PORTING.md) |
| 🇿🇦 Sesotho sa Leboa | `nso` | Northern Sotho / 北ソト語 | — 未作成 / not written yet | [README](nso/README.md) · [CLAUDE](nso/CLAUDE.md) · [PORTING](nso/PORTING.md) |
| 🇫🇷 Occitan | `oc` | Occitan / オック語 | — 未作成 / not written yet | [README](oc/README.md) · [CLAUDE](oc/CLAUDE.md) · [PORTING](oc/PORTING.md) |
| 🇮🇳 ଓଡ଼ିଆ | `or` | Odia / オリヤー語 | — 未作成 / not written yet | [README](or/README.md) · [CLAUDE](or/CLAUDE.md) · [PORTING](or/PORTING.md) |
| 🇪🇹 Afaan Oromoo | `om` | Oromo / オロモ語 | — 未作成 / not written yet | [README](om/README.md) · [CLAUDE](om/CLAUDE.md) · [PORTING](om/PORTING.md) |
| 🇦🇫 پښتو | `ps` | Pashto / パシュトー語 | — 未作成 / not written yet | [README](ps/README.md) · [CLAUDE](ps/CLAUDE.md) · [PORTING](ps/PORTING.md) |
| 🇵🇪 Runa Simi | `qu` | Quechua / ケチュア語 | — 未作成 / not written yet | [README](qu/README.md) · [CLAUDE](qu/CLAUDE.md) · [PORTING](qu/PORTING.md) |
| 🇼🇸 Gagana Samoa | `sm` | Samoan / サモア語 | — 未作成 / not written yet | [README](sm/README.md) · [CLAUDE](sm/CLAUDE.md) · [PORTING](sm/PORTING.md) |
| 🇮🇳 संस्कृतम् | `sa` | Sanskrit / サンスクリット語 | — 未作成 / not written yet | [README](sa/README.md) · [CLAUDE](sa/CLAUDE.md) · [PORTING](sa/PORTING.md) |
| 🏴󠁧󠁢󠁳󠁣󠁴󠁿 Gàidhlig | `gd` | Scottish Gaelic / スコットランド・ゲール語 | — 未作成 / not written yet | [README](gd/README.md) · [CLAUDE](gd/CLAUDE.md) · [PORTING](gd/PORTING.md) |
| 🇷🇸 Српски | `sr` | Serbian / セルビア語 | — 未作成 / not written yet | [README](sr/README.md) · [CLAUDE](sr/CLAUDE.md) · [PORTING](sr/PORTING.md) |
| 🇱🇸 Sesotho | `st` | Sesotho / ソト語 | — 未作成 / not written yet | [README](st/README.md) · [CLAUDE](st/CLAUDE.md) · [PORTING](st/PORTING.md) |
| 🇿🇼 ChiShona | `sn` | Shona / ショナ語 | — 未作成 / not written yet | [README](sn/README.md) · [CLAUDE](sn/CLAUDE.md) · [PORTING](sn/PORTING.md) |
| 🇵🇰 سنڌي | `sd` | Sindhi / シンド語 | — 未作成 / not written yet | [README](sd/README.md) · [CLAUDE](sd/CLAUDE.md) · [PORTING](sd/PORTING.md) |
| 🇱🇰 සිංහල | `si` | Sinhala / シンハラ語 | — 未作成 / not written yet | [README](si/README.md) · [CLAUDE](si/CLAUDE.md) · [PORTING](si/PORTING.md) |
| 🇸🇰 Slovenčina | `sk` | Slovak / スロバキア語 | — 未作成 / not written yet | [README](sk/README.md) · [CLAUDE](sk/CLAUDE.md) · [PORTING](sk/PORTING.md) |
| 🇸🇮 Slovenščina | `sl` | Slovenian / スロベニア語 | — 未作成 / not written yet | [README](sl/README.md) · [CLAUDE](sl/CLAUDE.md) · [PORTING](sl/PORTING.md) |
| 🇸🇴 Soomaali | `so` | Somali / ソマリ語 | — 未作成 / not written yet | [README](so/README.md) · [CLAUDE](so/CLAUDE.md) · [PORTING](so/PORTING.md) |
| 🇮🇩 Basa Sunda | `su` | Sundanese / スンダ語 | — 未作成 / not written yet | [README](su/README.md) · [CLAUDE](su/CLAUDE.md) · [PORTING](su/PORTING.md) |
| 🇹🇯 Тоҷикӣ | `tg` | Tajik / タジク語 | — 未作成 / not written yet | [README](tg/README.md) · [CLAUDE](tg/CLAUDE.md) · [PORTING](tg/PORTING.md) |
| 🇷🇺 Татарча | `tt` | Tatar / タタール語 | — 未作成 / not written yet | [README](tt/README.md) · [CLAUDE](tt/CLAUDE.md) · [PORTING](tt/PORTING.md) |
| 🇨🇳 བོད་སྐད | `bo` | Tibetan / チベット語 | — 未作成 / not written yet | [README](bo/README.md) · [CLAUDE](bo/CLAUDE.md) · [PORTING](bo/PORTING.md) |
| 🇪🇷 ትግርኛ | `ti` | Tigrinya / ティグリニャ語 | — 未作成 / not written yet | [README](ti/README.md) · [CLAUDE](ti/CLAUDE.md) · [PORTING](ti/PORTING.md) |
| 🇹🇴 Lea Faka-Tonga | `to` | Tongan / トンガ語 | — 未作成 / not written yet | [README](to/README.md) · [CLAUDE](to/CLAUDE.md) · [PORTING](to/PORTING.md) |
| 🇿🇦 Xitsonga | `ts` | Tsonga / ツォンガ語 | — 未作成 / not written yet | [README](ts/README.md) · [CLAUDE](ts/CLAUDE.md) · [PORTING](ts/PORTING.md) |
| 🇹🇲 Türkmençe | `tk` | Turkmen / トルクメン語 | — 未作成 / not written yet | [README](tk/README.md) · [CLAUDE](tk/CLAUDE.md) · [PORTING](tk/PORTING.md) |
| 🇨🇳 ئۇيغۇرچە | `ug` | Uyghur / ウイグル語 | — 未作成 / not written yet | [README](ug/README.md) · [CLAUDE](ug/CLAUDE.md) · [PORTING](ug/PORTING.md) |
| 🇺🇿 Oʻzbekcha | `uz` | Uzbek / ウズベク語 | — 未作成 / not written yet | [README](uz/README.md) · [CLAUDE](uz/CLAUDE.md) · [PORTING](uz/PORTING.md) |
| 🏴󠁧󠁢󠁷󠁬󠁳󠁿 Cymraeg | `cy` | Welsh / ウェールズ語 | — 未作成 / not written yet | [README](cy/README.md) · [CLAUDE](cy/CLAUDE.md) · [PORTING](cy/PORTING.md) |
| 🇳🇱 Frysk | `fy` | Western Frisian / 西フリジア語 | — 未作成 / not written yet | [README](fy/README.md) · [CLAUDE](fy/CLAUDE.md) · [PORTING](fy/PORTING.md) |
| 🇿🇦 isiXhosa | `xh` | Xhosa / コサ語 | — 未作成 / not written yet | [README](xh/README.md) · [CLAUDE](xh/CLAUDE.md) · [PORTING](xh/PORTING.md) |
| 🇮🇱 ייִדיש | `yi` | Yiddish / イディッシュ語 | — 未作成 / not written yet | [README](yi/README.md) · [CLAUDE](yi/CLAUDE.md) · [PORTING](yi/PORTING.md) |
| 🇳🇬 Yorùbá | `yo` | Yoruba / ヨルバ語 | — 未作成 / not written yet | [README](yo/README.md) · [CLAUDE](yo/CLAUDE.md) · [PORTING](yo/PORTING.md) |
| 🇿🇦 isiZulu | `zu` | Zulu / ズールー語 | — 未作成 / not written yet | [README](zu/README.md) · [CLAUDE](zu/CLAUDE.md) · [PORTING](zu/PORTING.md) |
| 🇬🇭 Ákán | `ak` | Akan (Twi) / アカン語(トウィ語) | — 未作成 / not written yet | [README](ak/README.md) · [CLAUDE](ak/CLAUDE.md) · [PORTING](ak/PORTING.md) |
| 🇸🇳 Wolof | `wo` | Wolof / ウォロフ語 | — 未作成 / not written yet | [README](wo/README.md) · [CLAUDE](wo/CLAUDE.md) · [PORTING](wo/PORTING.md) |
