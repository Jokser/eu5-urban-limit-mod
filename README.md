# Urban Limit Reworked

A rework of the Steam Workshop mod **Urban limit** (workshop id 3688963094). The original caps the number of towns and
cities per province; this version keeps the caps and adds geography: where a town or city may grow depends on the
location's climate, water access and local resources.

## Files
| File | What |
|---|---|
| `in_game/common/scripted_triggers/urban_caps_gate1_triggers_FIXED_SCOPE.txt` | the per-province caps (gate 1); trigger names from the original, bodies rewritten in v1.1 to use the script values below |
| `in_game/common/script_values/urban_limit_caps_values.txt` | **ours** (v1.1): caps by province size and the owner's institutions, free slots, burghers in a location |
| `in_game/common/script_values/urban_caps_script_values_v2.txt` | from the original: town / city counters (unused since v1.1) |
| `in_game/common/goods_demand/special_construction_demands.txt` | from the original |
| `main_menu/localization/english/urban_caps_l_english.yml` | from the original: cap tooltips |
| `in_game/common/scripted_triggers/urban_geo_triggers.txt` | **ours**: the per-climate geography rules (`urb_town_<climate>`, `urb_city_<climate>`, `location_allows_town_final`, `location_allows_city_final`) |
| `main_menu/localization/english/urban_geo_jokser_l_english.yml` | **ours**: one tooltip line per climate rule |
| `in_game/common/location_ranks/00_default.txt` | **GENERATED** by `tools/regen_location_ranks.ps1` from the current vanilla file + our `allow` delta |
| `tools/snippets/allow_snippet_<rank>.txt` | the `allow` delta: a `trigger_if` chain on climate, one `custom_tooltip` line per climate |
| `tools/history/` | the original author's `location_ranks` and our v1 geography rules, for reference |

**After every game patch** run `powershell -ExecutionPolicy Bypass -File tools\regen_location_ranks.ps1` so
`location_ranks` follows vanilla (the original author's copy had gone stale: no `upgrade_from`, `tier`, trade-centre power,
food-production multiplier, mills efficiency...). All `.txt` / `.yml` files keep a UTF-8 BOM.

## Rules (v2, 2026-11-19): one branch per climate
- **W (water)** = a river, a harbour of at least 0.25, or a lake shore.
- **any water** = a river, any sea coast, or a lake shore.

| Climate | Town | City |
|---|---|---|
| arctic | not mountains, harbour >= 0.25 | never |
| subpolar | not mountains + W | flatland / plateau / wetlands + (river, harbour >= 0.5 or lake) |
| continental, cold / hot semi-arid | not mountains, or mountains with W | farmland / grassland or W |
| mediterranean, oceanic, subtropical | anywhere | not mountains, or mountains with W |
| arid, cold_arid | any water, or farmland outside mountains | not mountains + (any water or farmland) |
| tropical | not mountains + (any water, farmland / grassland, or plateau / hills without jungle) | not mountains + (any water or farmland / grassland) |

Exceptions on top of the table:
- a **food RGO** (wheat, rice, fruit, millet, legumes, maize, potato) allows a town outside mountains and the arctic;
- a **valuable RGO** (silk, saffron, cotton, gems, silver, gold, incense) allows a town and a city (no city in the arctic).

- a **market center** allows a city (not in the arctic), since v1.1: trade made places like Nuremberg (woods, sand,
  the Pegnitz not drawn) great cities regardless of the site.

Wetlands have no separate rule (about 89% already have water; canals are not on the map).

## Province caps and the city gate (v1.1, 2026-11-24, experiment)
Settlements = towns + cities + megalopolises; cities = cities + megalopolises. Each institution the location's OWNER
has embraced adds its own bonus, in any order:

| Province size (locations) | 1-3 | 4-5 | 6+ |
|---|---|---|---|
| base (the original's caps) | 1 (1) | 2 (1) | 3 (1) |
| + global_trade (age 4) | - | +1 | +1 |
| + manufactories (age 5) | +1 | second city | second city |
| + industrialization (age 6) | second city | - | +1 |
| all three | 2 (2) | 3 (2) | 5 (2) |

(settlements, cities in brackets)

**City gate:** at least **5,000 burghers** in the location (`urb_location_burghers >= 5`) instead of vanilla's
`population >= 30`, which counts the whole location - peasants and laborers included - so any populous rural district
qualified.

Why (observer run 6a819256, 1700 save, Europe; history from de Vries 1984, `europop` dataset):
- 282 European locations had 8,000+ burghers vs 224 historical cities of 10,000+ in 1700, so burghers are a good
  "real city" signal; total population is not: Great Britain had 40 cities and 10 towns, many of them mining or
  farming districts (Glossop, Dingwall, Oban, Islay) with 2-6 thousand burghers.
- A burgher building level holds about 0.155 thousand burghers. A town supports about 40-50 building levels
  (25 from the rank, +0.05 per thousand pops, +25/50/100% in ages 4/5/6), so 8,000 burghers (~52 levels) was out of
  reach for almost every town (32 of 687 in Europe); 5,000 (~32 levels) was already met by 160.
- Historically 1 city of 10k+ per province was the rule; 2-7 occurred only in Holland, Flanders / Brabant, Andalusia,
  Sicily / Apulia and Provence. Cities of 10k+ in Europe: 154 (1500), 220 (1600), 224 (1700), 364 (1800) - growth in
  the 16th and 18th centuries, hence the global_trade and manufactories / industrialization steps.
Validation at design time: 36 of the 1067 start towns / cities fail the rules (accepted). Rivers come from `rivers.png`
(palette indices 3-15; 12-15 are the large rivers), coast and lakes from `locations.png` adjacency.

## History
- v1 (2026-08): water / highland model (`tools/history/urban_geo_triggers.v1_2026-08.txt.bak`).
- v2 (2026-11-19): per-climate rules + food / valuable RGO exceptions.
- v2.1: detailed per-condition tooltips; `location_ranks` generated from vanilla.
- v2.2: the rank-upgrade UI cannot show nested OR / AND ("Current level cannot be automatically flattened"), so each
  climate rule is ONE `custom_tooltip` line. To confirm in game.
- 1.0 of **Urban Limit Reworked** (2026-11-22): moved from the patch kit (`Documents\EU5_UrbanLimit_patch`) into this
  standalone mod.
- 1.1 (2026-11-24, experiment, not yet tested in game): province caps grow with global_trade / manufactories /
  industrialization; a city needs 5,000 burghers instead of 30,000 total population; market centers may always
  become cities (outside the arctic). Rank-upgrade goods demand cut to x2 vanilla (town 3/5/3 -> 2/4/2, city
  8/16/8 -> 4/8/4 glass/masonry/lumber; goods only, the gold price is unchanged), since the burgher gate now filters.
  First check (1400 save, Europe): no organic upgrade below 5,000 burghers (the two new cities, Vilnius and Lviv, come
  from flavor events); 32 of 85 cities and 1 town (Nuremberg) had 5,000+ burghers.

## FIXED (1.1.1, 2026-11-24): the caps count per MAP province (province_definition), not per owner's province
Until 1.1.1 `urban_limit_caps_values.txt` counted size, settlements and cities through the location's `province`, which in EU5 is
the OWNER's administrative province: a map province split between two countries is two `province`s. So each owner gets
its own slots, and the size used for the cap is only that owner's part. Seen in the 1550 save (run a9738f36): second
cities with no institution embraced anywhere - Lodi (LDI) next to Cremona (MLO), Chioggia (FER) next to Venice (VEN),
Macerata and Ascoli (NAP) next to Ancona (FER). Treviso (VEN, same `province` as Venice) is correctly blocked.
Fix: use `province_definition` (location link, vanilla `capital.province_definition`) with
`any_location_in_province_definition` / `every_location_in_province_definition` for size, settlements and cities.
The AI's own limit is also "per province definition" (`AI_PROVINCE_DEFINITION_MAX_URBANIZATION`). Existing extra
cities stay (no downgrade). Applied in 1.1.1 (vanilla precedent for the scope: `building_types/unique_buildings.txt`).

## AI urbanization limit (1.1.2, 2026-11-24)
`loading_screen/common/defines/urban_limit_ai_defines.txt`: `NAI: AI_PROVINCE_DEFINITION_MAX_URBANIZATION` 0.2 -> 0.6.
Vanilla lets the AI urbanize at most ceil(0.2 x locations) of a map province - one settlement in every province of
1-5 locations. In the 1550 save all 308 European provinces of 4-5 locations had exactly one (Bohemia: Prague, Plzen,
Brno, Olomouc... one each), so our caps were never reached and the institution bonuses could not be used by the AI.
At 0.6 the AI may go to 3 (4-5 locations), 4 (6), 5-6 (8-10); our caps are the binding limit. Found from the AI's
own debug strings in the exe ("Too many towns in province definition"). Untested in game.

## TODO: named exceptions
Historical cities that the map flags cannot tell from empty desert:
- cities in the 1337 setup that fail the CITY rule: Sijilmasa (also fails town), Timbuktu (also fails town; the Niger
  is not drawn), Al-Ahsa (spring oasis), Turpan (karez), Urgench (the Amu Darya is not drawn);
- future growth: Mecca (town via fruit, never a city), Kerman and Qazvin (town yes, city no), Kashan (neither; RGO livestock).
- Left out on purpose: the Sahel towns (Walata, Koumbi Saleh, Njimi), Karakorum, the Chinese loess "mountain" towns,
  Leh, Kalyan / Kanchipuram / Mani.
Possible methods: a `location_key` list, or a location flag / modifier set on game start for the listed keys.

## Credits
The province caps, their tooltips and the original idea come from **Urban limit** by **Emperor VI**, part of his
Total Realism Mod (Steam Workshop id 3688963094).
