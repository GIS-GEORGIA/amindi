# ამინდი · Amindi

**🌐 [meteo.qgis.ge](https://meteo.qgis.ge)**

მრავალმოდელიანი ამინდის პროგნოზი საქართველოსთვის — **ECMWF, ICON-EU, GFS და YR** ერთ ინტერფეისში, გვერდიგვერდ.
Multi-model weather forecast for Georgia — **ECMWF, ICON-EU, GFS and YR** side by side in one interface.

**პლატფორმა · Platform:** Flutter (Web · Android · iOS) · **ენები · Languages:** ქართული / English · **თემა · Theme:** Light / Dark

---

## 🇬🇪 ქართულად

### რას აკეთებს

ამინდის პროგნოზი მოდელის გამოთვლაა და არა ფაქტი. საქართველოს რთულ რელიეფზე სხვადასხვა მოდელი ერთსა და იმავე წერტილზე ხშირად სხვადასხვა პასუხს იძლევა. ეს აპლიკაცია ოთხივე მოდელს ერთ ეკრანზე აჩენს, რომ თავად შეადარო და გადაწყვიტო რომელს ენდობი.

### ძირითადი ფუნქციები

- **🗺️ ინტერაქტიული რუკა** — რუკაზე ნებისმიერ წერტილს დააჭერ და მიიღებ პროგნოზს ზუსტად იმ ლოკაციისთვის. საბაზისო ფენა: OSM რუკა ან ტოპოგრაფიული (რელიეფი).
- **📊 4 მოდელის შედარება** — არჩეულ წერტილზე ამოდის პანელი, სადაც ECMWF, ICON-EU, GFS და YR გვერდიგვერდ ჩანს: ტემპერატურა, ნალექი, ქარი, ამინდის მდგომარეობა. **საათობრივი** (48 სთ) და **დღიური** (7 დღე) ხედი.
- **🌡️ ამინდის ფენები რუკაზე** — ტემპერატურის და ნალექის ფერადი overlay მთელ საქართველოზე (Windy-ის სტილში), დროის სლაიდერით. საბაზისო რუკის გამჭვირვალეობა რეგულირდება, რომ ფენა უკეთ გამოჩნდეს.
- **ℹ️ მოდელების აღწერა** — თითო მოდელზე: ვინ აწარმოებს, გარჩევადობა, ძლიერი და სუსტი მხარეები, და რატომ მუშაობს კონკრეტულად საქართველოს რელიეფზე ასე თუ ისე.
- **⚙️ პარამეტრები** — ენა (ქართული / English), თემა (ნათელი / მუქი / სისტემური), რუკის გამჭვირვალეობა. ყველა არჩევანი ინახება.

### რატომ ოთხი მოდელი

- **ECMWF** — მსოფლიოში ყველაზე ზუსტი გლობალური მოდელი; საიმედო ზოგადი სურათისთვის.
- **ICON-EU** — ყველაზე მაღალი გარჩევადობა (~6.5 კმ); საუკეთესო მთიანი რეგიონებისთვის (სვანეთი, ყაზბეგი, თუშეთი).
- **GFS** — ხშირი განახლება, გრძელი ჰორიზონტი; კარგია ტენდენციისთვის.
- **YR** — ნორვეგიის ინსტიტუტის დამუშავებული პროგნოზი; ძლიერი დამოუკიდებელი შედარების წერტილი.

---

## 🇬🇧 In English

### What it does

A weather forecast is a model computation, not a fact. Over Georgia's complex terrain different models often disagree about the very same point. This app puts all four models on one screen so you can compare them and decide which to trust.

### Key features

- **🗺️ Interactive map** — tap any point on the map to get a forecast for exactly that location. Base layer: OSM map or topographic (terrain).
- **📊 4-model comparison** — a panel shows ECMWF, ICON-EU, GFS and YR side by side for the chosen point: temperature, precipitation, wind and sky condition. **Hourly** (48 h) and **daily** (7 days) views.
- **🌡️ Weather overlays** — colored temperature and precipitation layers over all of Georgia (Windy-style), with a time slider. The base map opacity is adjustable so the layer stands out.
- **ℹ️ Model info** — for each model: who runs it, its resolution, strengths and weaknesses, and why it behaves the way it does over Georgian terrain specifically.
- **⚙️ Settings** — language (Georgian / English), theme (light / dark / system), map opacity. All choices are persisted.

### Why four models

- **ECMWF** — the most accurate global model; reliable for the big picture.
- **ICON-EU** — highest resolution (~6.5 km); best for mountain regions (Svaneti, Kazbegi, Tusheti).
- **GFS** — frequent updates, long horizon; good for trends.
- **YR** — a post-processed forecast from the Norwegian institute; a strong independent reference.

---

## Data sources · მონაცემთა წყაროები

| Model | Source | Resolution | Parameter |
|-------|--------|-----------|-----------|
| ECMWF | Open-Meteo | ~9 km | `models=ecmwf_ifs025` |
| ICON-EU | Open-Meteo | ~6.5 km | `models=icon_eu` |
| GFS | Open-Meteo | ~13 km | `models=gfs_seamless` |
| YR | MET Norway | point | `api.met.no/weatherapi/locationforecast/2.0` |

The repository layer normalizes every source into a shared `ForecastPoint` entity (°C, mm, m/s, weather code) so the UI renders all four models identically. / Repository-ს ფენა ყველა წყაროს საერთო `ForecastPoint`-ში ნორმალიზებას გაუკეთებს.

**Licenses:**
- Open-Meteo — free for non-commercial use; a paid/ad-supported app would need a commercial plan. The app is **free and ad-free**, so the free tier is sufficient.
- MET Norway (YR) — a mandatory identifying `User-Agent` (built into `core/network/api_client.dart`) and respect for `Expires` / `Last-Modified` caching.

## Tech stack · ტექნიკური სტეკი

Flutter · `flutter_map` + `latlong2` · `dio` · `flutter_riverpod` · `easy_localization` (ka/en) · `shared_preferences` · `geolocator` · `freezed` + `json_serializable`

## Structure · სტრუქტურა

```
lib/
├── main.dart
├── app/                  # MaterialApp, theme, locale
├── core/
│   ├── theme/            # light/dark ThemeData
│   ├── constants/        # Georgia bounds, API URLs
│   └── network/          # dio client, User-Agent interceptor
└── features/
    ├── map/              # map screen (OSM + OpenTopoMap, base opacity)
    ├── forecast/         # 4-model comparison panel
    ├── overlay/          # temperature/precipitation grid overlays
    ├── model_info/       # per-model descriptions (ka/en)
    └── settings/         # language + theme + opacity
```

## Roadmap

| Phase | Content | Status |
|-------|---------|--------|
| **1** | Project structure + flutter_map + OSM/terrain + Georgia bounds | ✅ |
| **2** | Open-Meteo + YR integration, tap → 4-model comparison | ✅ |
| **3** | Localization ka/en + light/dark theme + settings screen | ✅ |
| **4** | Model description screen | ✅ |
| **5** | Overlay: temperature + precipitation (grid + custom renderer, ICON-EU) with time slider | ✅ |
| **web** | GitHub Pages deployment → [meteo.qgis.ge](https://meteo.qgis.ge) | ✅ |
| **5+** | Wind animation / arrows on the overlay | ⏳ |

## Run locally · ლოკალური გაშვება

```bash
flutter pub get
flutter run              # mobile / desktop
flutter run -d chrome    # web
```

## Deployment · გაშვება

Every push to `main` builds the web app and publishes it to GitHub Pages via `.github/workflows/deploy.yml`. / ყოველი push `main`-ზე ავტომატურად აახლებს [meteo.qgis.ge](https://meteo.qgis.ge)-ს.
