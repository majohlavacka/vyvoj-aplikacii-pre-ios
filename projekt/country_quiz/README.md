# Hádaj krajinu

Kvízová Flutter aplikácia, v ktorej hráč háda krajiny sveta v troch režimoch:
**podľa vlajky**, **podľa hlavného mesta** a **podľa polohy na mape**.
Hráč zadá meno, vyberie režim a počet otázok (5 / 10 / 15 / 20). Každá otázka má 4 možnosti.
Po hre vidí výsledok a prehľad odpovedí. Aplikácia obsahuje aj **Atlas krajín** s vyhľadávaním
a detailom krajiny a **Históriu hier** so štatistikami.

Dáta o krajinách sa načítavajú z REST API **apicountries.com**, výsledky sa ukladajú do pamäte zariadenia.

**Použité balíčky:** `provider`, `http`, `shared_preferences`, `flutter_map`, `latlong2`

---

## Splnenie požiadaviek

| Požiadavka | Stav | Riešenie |
|---|---|---|
| Min. 3 obrazovky + `push` / `pop` | ✅ | 6 obrazoviek, `pop` vracia dáta |
| Formulár / používateľský vstup | ✅ | formulár s menom a validáciou + ďalšie vstupy |
| Provider / Riverpod | ✅ | 3 providery (Provider) |
| Vlastný dátový model | ✅ | 5 modelov |
| Odovzdávanie dát / callbacky | ✅ | konštruktory obrazoviek, 5 callbackov |
| Responzívne rozloženie | ✅ | Column, Row, Expanded, ListView, LayoutBuilder |
| Externá funkcionalita | ✅ | REST API (`http` + JSON) |
| Odporúčaná štruktúra | ✅ | models, providers, widgets, screens + services, utils |
| **Bonus:** uloženie dát | ✅ | SharedPreferences – 3 druhy dát |

### 1. Obrazovky a navigácia – 6 obrazoviek

| Obrazovka | Súbor |
|---|---|
| Domov (formulár, výber režimu) | `screens/home_screen.dart` |
| Hra | `screens/game_screen.dart` |
| Výsledok | `screens/result_screen.dart` |
| Atlas krajín (zoznam) | `screens/countries_list_screen.dart` |
| Detail krajiny | `screens/country_detail_screen.dart` |
| História hier | `screens/history_screen.dart` |

Navigácia cez `Navigator.push()` a `Navigator.pop()`, pričom `pop()` vracia dáta späť:

```
Domov ──push──▶ Hra ──push──▶ Výsledok
  ▲              │ ▲             │
  └─pop(GameResult)┘ └─pop(true/false)┘   true = hrať znova, false = domov
```

Ďalšie prechody: Domov → Atlas, Domov → História, Atlas → Detail, Výsledok → Detail,
Detail → Detail susednej krajiny.

### 2. Používateľský vstup

- **Formulár s menom hráča** (`home_screen.dart`) – `Form` + `TextFormField` s validáciou (2 – 20 znakov)
- výber počtu otázok – `SegmentedButton`
- výber herného režimu – karty `ModeCard`
- odpovede v hre – tlačidlá `AnswerButton`
- vyhľadávanie v Atlase – `TextField`, filter kontinentu – `ChoiceChip`
- potvrdzovacie dialógy (ukončenie hry, vymazanie histórie)

### 3. Správa stavu – Provider (3 providery)

Registrované cez `MultiProvider` v `main.dart`:

| Provider | Spravuje |
|---|---|
| `CountriesProvider` | zoznam krajín, načítanie z API / pamäte, vyhľadávanie, filter, detaily krajín |
| `GameProvider` | priebeh hry – generovanie otázok, odpovede, skóre |
| `HistoryProvider` | história hier, štatistiky, meno hráča |

### 4. Dátové modely – 5 modelov (`models/`)

| Model | Popis |
|---|---|
| `Country` | krajina – kód, názov, hlavné mesto, región, rozloha, vlajka, meny, súradnice |
| `CountryDetails` | údaje z detailu API – populácia, jazyky, susedia, časové pásma, predvoľba |
| `Question` | otázka – správna krajina, 4 možnosti, zvolená odpoveď |
| `GameResult` | výsledok hry – meno, režim, skóre, dátum |
| `GameMode` | enum režimov – vlajka, hlavné mesto, mapa |

Modely majú konverzie `fromJson` / `toJson` na prácu s API a pamäťou.

### 5. Odovzdávanie dát a callbacky

**Cez konštruktor:** `ResultScreen(result, questions)`, `CountryDetailScreen(country)`, `QuestionView(question, mode)`

**Callbacky (dieťa → rodič):**

| Widget | Callback |
|---|---|
| `ModeCard` | `onTap` – výber režimu |
| `AnswerButton` | `onPressed` – kliknutie na odpoveď |
| `_AnswersPanel` | `onAnswer` – posiela zvolenú krajinu (`ValueChanged<Country>`) |
| `CountryTile` | `onTap` – posiela krajinu na otvorenie detailu (`ValueChanged<Country>`) |
| `_ApiDetailsCard` | `onNeighborTap` – posiela susednú krajinu (`ValueChanged<Country>`) |

### 6. Responzívne rozloženie

- `Column`, `Row` – všetky obrazovky
- `Expanded` – mriežka odpovedí 2 × 2, tlačidlá vo výsledku, štatistiky v histórii
- `ListView` – Atlas, zoznam odpovedí vo výsledku, história, filter kontinentov
- `LayoutBuilder` – na širokej obrazovke (≥ 700 px) sa Domov, Hra a Detail zobrazia v dvoch stĺpcoch,
  na telefóne pod sebou

### 7. Externá funkcionalita – REST API (http + JSON)

`services/country_api_service.dart` volá **apicountries.com** (adresa `countries.dev`) cez balíček `http`:

| Endpoint | Kedy | Výsledok |
|---|---|---|
| `GET /countries` | pri štarte aplikácie | 250 krajín → `List<Country>` |
| `GET /alpha/{kód}` | pri otvorení detailu krajiny | `CountryDetails` |

JSON sa dekóduje cez `jsonDecode` a prevádza na modely. Chyby siete sú ošetrené – zobrazí sa hláška
s tlačidlom „Skúsiť znova“, detail používa `FutureBuilder`.

Vlajky sa načítavajú ako obrázky z `https://flagcdn.com/w320/{kód}.png`.

### Mapa – widget `CountryMap`

`widgets/country_map.dart` – mapa cez balíček `flutter_map`. Dostane súradnice krajiny (`latitude`, `longitude`
z modelu `Country`), vycentruje sa na ne a položí na ne červený špendlík (`MarkerLayer`).
Ten istý widget sa používa na dvoch miestach, podklad sa vyberá parametrom `showLabels`:

| Kde | `showLabels` | Podklad | Adresa (tile server) |
|---|---|---|---|
| Hra – režim Mapa (slepá mapa) | `false` | Esri World Imagery – satelit **bez názvov**, neprezradí odpoveď | `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}` |
| Detail krajiny | `true` | OpenStreetMap – bežná mapa s názvami | `https://tile.openstreetmap.org/{z}/{x}/{y}.png` |

- Ide o **tile servery** – vracajú obrázky PNG (štvorčeky mapy 256 × 256 px), nie JSON. `flutter_map` za
  `{z}` (priblíženie), `{x}`, `{y}` (poloha štvorčeka) sám dosadí čísla a stiahne viditeľnú časť mapy.
  Pozor: Esri má v adrese poradie `{y}/{x}`, OpenStreetMap `{x}/{y}`.
- Oba podklady sú bez API kľúča. Zdroj mapy je uvedený cez ikonku „i“ (`RichAttributionWidget`).
- V hre má mapa `key: ValueKey(country.code)`, aby sa pri ďalšej otázke vytvorila nanovo a vycentrovala na novú krajinu.

### Bonus – uloženie dát do pamäte

`services/storage_service.dart` – `SharedPreferences`:

| Dáta | Kľúč | Využitie |
|---|---|---|
| Zoznam krajín | `countries_cache_v3` | pri ďalšom spustení sa nesťahuje znova, hra funguje aj offline |
| História hier | `game_results_v1` | obrazovka História, najlepší výsledok na domovskej obrazovke |
| Meno hráča | `player_name` | predvyplní sa vo formulári |

---

## Štruktúra projektu

Obrazovky nevolajú API ani pamäť priamo, pracujú len s providermi
(prezentačná vrstva → stavová vrstva → dátová vrstva).

```
lib/
├── main.dart                   vstupný bod, MultiProvider
├── models/                     dátové modely (5)
├── providers/                  správa stavu (3)
├── services/                   API a SharedPreferences
├── screens/                    obrazovky (6)
├── widgets/                    vlastné widgety (8)
└── utils/formatters.dart       formátovanie čísel a dátumov
test/
└── widget_test.dart            testy modelov a GameProvider
```

**Vlastné widgety (8):** `AnswerButton`, `CountryMap`, `CountryTile`, `FlagImage`, `InfoRow`,
`ModeCard`, `QuestionView`, `StatCard`

---

## Popis súborov

### Koreň projektu

| Súbor | Čo robí |
|---|---|
| `pubspec.yaml` | názov projektu, verzia Dartu a zoznam balíčkov (`provider`, `http`, `shared_preferences`, `flutter_map`, `latlong2`) |
| `test/widget_test.dart` | testy: parsovanie JSON do `Country`, uloženie `GameResult`, skóre v `GameProvider` |

### `lib/`

| Súbor | Čo robí |
|---|---|
| `main.dart` | vstupný bod, vytvorí služby, zaregistruje 3 providery cez `MultiProvider`, nastaví tému a úvodnú obrazovku |

### `lib/models/` – dátové modely

| Súbor | Čo robí |
|---|---|
| `country.dart` | model krajiny; `fromApiJson` (z API), `fromJson` / `toJson` (pamäť) |
| `country_details.dart` | doplňujúce údaje z `GET /alpha/{kód}` (populácia, jazyky, susedia…) |
| `question.dart` | jedna otázka – správna krajina, 4 možnosti, zvolená odpoveď |
| `game_result.dart` | výsledok hry; `fromJson` / `toJson` na uloženie do histórie |
| `game_mode.dart` | enum režimov (vlajka, hlavné mesto, mapa) s názvom, popisom a otázkou |

### `lib/providers/` – správa stavu

| Súbor | Čo robí |
|---|---|
| `countries_provider.dart` | načíta krajiny (pamäť → API), stav načítania, vyhľadávanie, filter kontinentu, detaily krajín |
| `game_provider.dart` | vytvorí otázky (nesprávne možnosti z rovnakého regiónu), spracuje odpovede, počíta skóre, vytvorí `GameResult` |
| `history_provider.dart` | história hier, štatistiky (priemer, najlepší výsledok), meno hráča |

### `lib/services/` – dátová vrstva

| Súbor | Čo robí |
|---|---|
| `country_api_service.dart` | HTTP volania `GET /countries` a `GET /alpha/{kód}`, dekódovanie JSON, ošetrenie chýb |
| `storage_service.dart` | ukladanie a načítanie krajín, histórie a mena cez `SharedPreferences` |

### `lib/screens/` – obrazovky

| Súbor | Čo robí |
|---|---|
| `home_screen.dart` | formulár s menom (validácia), výber režimu a počtu otázok, štart hry; `push` na Hru / Atlas / Históriu, prijme `GameResult` z `pop` |
| `game_screen.dart` | priebeh hry, mriežka odpovedí 2 × 2, potvrdenie odchodu; `push` na Výsledok, `pop(result)` späť na Domov |
| `result_screen.dart` | skóre a zoznam odpovedí (dáta cez konštruktor); `pop(true / false)`, `push` na Detail |
| `countries_list_screen.dart` | Atlas – zoznam krajín, vyhľadávanie, filter kontinentu, obnovenie z API |
| `country_detail_screen.dart` | detail krajiny, údaje z API cez `FutureBuilder`, klikateľní susedia, mapa |
| `history_screen.dart` | uložené výsledky, štatistiky, vymazanie histórie |

### `lib/widgets/` – vlastné widgety

| Súbor | Čo robí |
|---|---|
| `answer_button.dart` | tlačidlo odpovede, farba podľa stavu (zelená / červená); callback `onPressed` |
| `country_map.dart` | mapa so špendlíkom; slepá satelitná mapa v hre, OpenStreetMap v detaile |
| `country_tile.dart` | riadok zoznamu krajín s vlajkou; callback `onTap(Country)` |
| `flag_image.dart` | vlajka zo siete s indikátorom načítania a náhradnou ikonou pri chybe |
| `info_row.dart` | riadok „ikona – popis – hodnota“ v detaile krajiny |
| `mode_card.dart` | karta herného režimu; callback `onTap` |
| `question_view.dart` | zadanie otázky podľa režimu (vlajka / hlavné mesto / mapa) |
| `stat_card.dart` | štatistická karta v histórii |

### `lib/utils/`

| Súbor | Čo robí |
|---|---|
| `formatters.dart` | formátovanie čísel („5 458 827“) a dátumov, preklad kontinentov do slovenčiny, vyhľadávanie bez diakritiky |