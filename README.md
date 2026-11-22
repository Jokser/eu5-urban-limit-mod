# Urban Limit Reworked

A rework of the Steam Workshop mod **Urban limit** (workshop id 3688963094). The original caps the number of towns and
cities per province; this version keeps the caps and adds geography: where a town or city may grow depends on the
location's climate, water access and local resources.

## Files
| File | What |
|---|---|
| `in_game/common/scripted_triggers/urban_caps_gate1_triggers_FIXED_SCOPE.txt` | from the original: the per-province caps (gate 1) |
| `in_game/common/script_values/urban_caps_script_values_v2.txt` | from the original: cap values |
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

Wetlands have no separate rule (about 89% already have water; canals are not on the map).
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
