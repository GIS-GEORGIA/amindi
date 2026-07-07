# ამინდი (Amindi)

მრავალმოდელიანი ამინდის პროგნოზის აპლიკაცია საქართველოსთვის — **ECMWF, ICON-EU, GFS და YR** გვერდიგვერდ, ერთ ინტერფეისში.

**პლატფორმა:** Flutter (Android / iOS) · **ენები:** ქართული / ინგლისური · **თემა:** Light / Dark

## რატომ

საქართველოს რთულ რელიეფზე სხვადასხვა მოდელი სხვადასხვანაირად ცდება. მომხმარებელი რუკაზე ირჩევს წერტილს და ხედავს ოთხივე მოდელის პროგნოზს გვერდიგვერდ — თავად ადარებს და ირჩევს სანდო წყაროს კონკრეტული ლოკაციისთვის.

## მონაცემთა წყაროები

| მოდელი | წყარო | გარჩევადობა | პარამეტრი |
|--------|-------|-------------|-----------|
| ECMWF | Open-Meteo | ~9 კმ | `models=ecmwf_ifs025` |
| ICON-EU | Open-Meteo | ~6.5 კმ | `models=icon_eu` |
| GFS | Open-Meteo | ~13 კმ | `models=gfs_seamless` |
| YR | MET Norway | წერტილოვანი | `api.met.no/weatherapi/locationforecast/2.0` |

**ლიცენზიები:**
- Open-Meteo — უფასო non-commercial გამოყენებისთვის; ფასიანი აპი/რეკლამა → commercial plan.
- MET Norway (YR) — სავალდებულო identifying `User-Agent` (ჩაშენებულია `core/network/api_client.dart`-ში) + `Expires`/`Last-Modified` caching-ის დაცვა.

## ტექნიკური სტეკი

Flutter · `flutter_map` + `latlong2` · `dio` · `flutter_riverpod` · `easy_localization` (ka/en) · `shared_preferences` · `geolocator` · `freezed` + `json_serializable`

## სტრუქტურა

```
lib/
├── main.dart
├── app/                  # MaterialApp, theme, locale
├── core/
│   ├── theme/            # light/dark ThemeData
│   ├── constants/        # Georgia bounds, API URLs
│   └── network/          # dio client, User-Agent interceptor
├── features/
│   ├── map/              # რუკის ეკრანი (OSM + OpenTopoMap)
│   ├── forecast/         # Phase 2 — 4 მოდელის შედარება
│   ├── model_info/       # Phase 4 — მოდელების აღწერა
│   └── settings/         # ენა + თემა
└── shared/
```

Repository-ს ფენა ყველა წყაროს საერთო `ForecastPoint` entity-ში ნორმალიზებას გაუკეთებს (°C, mm, m/s, weatherCode), რომ UI-მ ოთხივე მოდელი ერთნაირად აჩვენოს.

## Roadmap

| ფაზა | შინაარსი | სტატუსი |
|------|----------|---------|
| **Phase 1** | სტრუქტურა + flutter_map + OSM/რელიეფი + საქართველოს bounds | ✅ |
| **Phase 2** | Open-Meteo + YR ინტეგრაცია, tap → 4 მოდელის შედარება | ✅ |
| **Phase 3** | ლოკალიზაცია ka/en + light/dark თემა (საფუძველი უკვე ჩაშენებულია) | ⏳ |
| **Phase 4** | მოდელების აღწერის ეკრანი | ⏳ |
| **Phase 5** | Overlay (wind/precipitation) — Open-Meteo raster tiles-ს არ იძლევა, ალტერნატივა გადასაწყვეტია | ⏳ |

## გადაწყვეტილი საკითხები

- **Tile სერვერები:** რჩება OSM/OpenTopoMap-ის საჯარო სერვერები — აპის ტრაფიკი მცირეა და usage policy-ში ჯდება (identifying User-Agent გაგზავნილია).
- **Monetization:** აპი **უფასოა**, რეკლამის გარეშე → Open-Meteo-ს free non-commercial tier საკმარისია.
- **Overlay (Phase 5):** ალტერნატიული მიდგომით — Open-Meteo raster tiles-ს არ იძლევა, ამიტომ grid-მოთხოვნები + საკუთარი რენდერი ან სხვა tile წყარო.

## გაშვება

```bash
flutter pub get
flutter run
```
