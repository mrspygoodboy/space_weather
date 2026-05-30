# Space Weather 🌞

A Flutter app for tracking solar activity and near-Earth objects using NASA's free public APIs.

## What it does

Space Weather shows you real-time data from NASA:
- **Solar Flares** — browse and search flare events by class (B/C/M/X), source location, and notes. Each event links to a detail screen with timing, severity, and linked CME events.
- **Near-Earth Objects** — this week's asteroid approaches with diameter, velocity, miss distance, and hazard status.
- **Search** — validated search across all loaded flares.
- **Settings** — light/dark/system theme (stored in shared preferences), adjustable date range, optional NASA API key.
- **About** — developer info and data source credits.

Falls back to bundled JSON data when offline.

---

## Screenshots

> Run the app and take screenshots — place them in `screenshots/` and reference here.

---

## Setup & run

**Requirements**: Flutter 3.19+ (tested on 3.22), Dart 3.x, Android or iOS emulator.

```bash
# 1. Clone / unzip the project
cd space_weather

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run

# 4. Tests
flutter test
```

NASA's `DEMO_KEY` is used by default (30 req/hour, 50/day). For higher limits, get a free key at [api.nasa.gov](https://api.nasa.gov) and paste it in **Settings → NASA API Key**.

---

## Main packages

| Package | Why |
|---|---|
| `provider ^6.1.2` | State management — ChangeNotifier-based, lightweight, well-documented |
| `go_router ^13.2.4` | Named route navigation, supports `extra` for passing model objects |
| `http ^1.2.1` | HTTP client for NASA DONKI and NeoWs API calls |
| `shared_preferences ^2.2.3` | Persists theme mode, API key, and default date range across sessions |
| `intl ^0.19.0` | Date formatting (`DateFormat`) |
| `cached_network_image ^3.3.1` | Image caching (ready for APOD extension) |
| `url_launcher ^6.2.6` | Opens NASA JPL asteroid pages in browser |
| `mocktail ^1.0.4` | Mock generation for unit and widget tests |

---

## Architecture

```
lib/
  models/         # Data classes with fromJson/toJson (SolarFlare, NearEarthObject)
  services/       # API calls + JSON parsing (NasaApiService, SettingsService)
  providers/      # Business logic + state (SolarFlaresProvider, NeoProvider, SettingsProvider)
  screens/        # Full screens (HomeScreen, FlareDetailScreen, NeoScreen, ...)
  widgets/        # Reusable widgets (SolarFlareTile, NeoTile, FlareClassBadge, ...)
  utils/          # Theme, router, validators
test/
  unit_test.dart  # Model fromJson/toJson, all validators, provider methods
  widget_test.dart # Widget rendering and interaction tests
assets/
  data/
    solar_flares.json  # Offline fallback data
```

**Layered architecture**:
- **Data layer** (`models/`, `services/`) — pure Dart, no Flutter dependencies
- **Logic layer** (`providers/`) — ChangeNotifiers consuming services
- **UI layer** (`screens/`, `widgets/`) — reads from providers via `context.watch`

---

## Data sources

- [NASA DONKI](https://ccmc.gsfc.nasa.gov/tools/DONKI/) — solar flare event data
- [NASA NeoWs](https://api.nasa.gov/api.html#NeoWS) — near-Earth object feed
- Both are free with or without an API key (rate limits apply to `DEMO_KEY`)

---

## Author

**Aliyan** — TAMK Mobile Applications, 2025
