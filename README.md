# PlayHub

A three-mode iOS games app built in SwiftUI, wrapped in a proper app shell with real platform features (Core Location, User Notifications, Charts, MapKit, ShareLink).

Coursework submission for **BSc (Hons) Computing · iOS App Development · Week 4 — "The Real App"**.

---

## Overview

PlayHub bundles three mini games behind a four-tab shell:

| Tab | Purpose |
|:---|:---|
| **Home** | Landing screen with game cards for each mode. |
| **Stats** | Aggregates every completed play — totals, personal bests, recent games, and a bar chart per mode. |
| **Map** | Pins the location of every completed session using Core Location + MapKit. |
| **Settings** | Notification toggle, daily challenge time picker, and reset-all-stats. |

The three games are:

- **Tap Frenzy** — race the clock, chain rapid taps for a combo multiplier, watch out for trap colours.
- **Light It Up** — tap the glowing card before it goes dark. Difficulty ramps automatically through four levels in one 60-second round.
- **Quiz Rush** — 10 multiple-choice questions from the Open Trivia DB. Green/red answer feedback and a streak multiplier.

---

## Architecture

**Pattern:** MVVM (Model – View – ViewModel), SwiftUI only, no Combine subscriptions beyond `@Published`.

```
View          ── @StateObject ──▶  ViewModel  ── calls ──▶  Service / Store
(dumb render)                      (state + rules)          (side-effect boundary)
```

- **Views** only render. No game logic, no persistence, no network.
- **ViewModels** own runtime state (`@Published`) and every rule (scoring, combos, level ramp). They call services when they need to cross a system boundary.
- **Services** wrap Apple frameworks so the rest of the app never imports them directly (`LocationService` for `CLLocationManager`, `NotificationService` for `UNUserNotificationCenter`, `TriviaAPI` for `URLSession`).
- **Models** are pure `Codable` value types — safe to persist and pass around.
- **`SessionStore.shared`** is the single source of truth for `[GameSession]`. It writes/reads JSON in `UserDefaults` and publishes changes for observing views.

---

## Folder Structure

```
IosProject1/
├── App/
│   └── PlayHubApp.swift          @main entry point
├── Models/
│   ├── GameMode.swift            enum for the 3 games (title, icon, tint)
│   ├── GameSession.swift         one completed play (Codable, Identifiable)
│   └── TriviaQuestion.swift      Open Trivia DB response model
├── ViewModels/
│   ├── TapFrenzyVM.swift
│   ├── LightItUpVM.swift
│   ├── QuizRushVM.swift
│   └── StatsVM.swift             + SessionStore
├── Services/
│   ├── TriviaAPI.swift           async URLSession fetcher
│   ├── LocationService.swift     CLLocationManager wrapper
│   └── NotificationService.swift UNUserNotificationCenter wrapper
├── Views/
│   ├── Tabs/
│   │   ├── HomeTab.swift
│   │   ├── StatsTab.swift
│   │   ├── MapTab.swift
│   │   └── SettingsTab.swift
│   ├── Games/
│   │   ├── TapFrenzyView.swift
│   │   ├── LightItUpView.swift
│   │   └── QuizRushView.swift
│   └── Shared/
│       ├── ResultView.swift      reusable game-over screen + ShareLink
│       └── ScoreBadge.swift      reusable score pill
├── Assets.xcassets
└── ContentView.swift             TabView shell
```

---

## Features

### Implemented

- [x] Four-tab shell (Home / Stats / Map / Settings) with SF Symbol icons and per-tab `NavigationStack`.
- [x] `GameMode` enum centralizes title, icon, tint colour, and high-score key for each game.
- [x] `GameSession` model + `SessionStore` — every finished game appends one JSON-encoded record to `UserDefaults`.
- [x] Full MVVM refactor for all three games — no game logic lives in Views.
- [x] `LocationService` — one-shot `CLLocationManager` wrapper. Requests When-In-Use permission, publishes latest coordinate.
- [x] `NotificationService` — schedules a single repeating daily notification at the user's chosen time.
- [x] Modern SwiftUI UI: gradient backgrounds, glass materials, rounded typography, SF Symbol icons.
- [x] Quiz Rush green/red answer feedback with 0.8s pause before advancing.
- [x] `ResultView` — reusable game-over screen with `ShareLink` (generates "I just scored X on Y — beat that!").
- [x] `ScoreBadge` — reusable labeled-number pill used across game HUDs.
- [x] Per-game high scores in `@AppStorage`.

### Pending

- [ ] Wire the three Views to their new VMs (Step 5 refactor)
- [ ] `StatsVM` aggregates + bar chart via SwiftUI Charts (`BarMark`)
- [ ] `MapTab` renders `Marker` for each session, tap → mode + score + date
- [ ] `SettingsTab` reset-all-stats confirmation dialog
- [ ] `HomeTab` welcome + recent best + quick stats
- [ ] Info.plist location permission string

---

## Known Limitations

1. **Location permission string** is not yet added to Info.plist. Until it is, `LocationService.requestPermission()` will silently fail. Add `Privacy - Location When In Use Usage Description` under Target → Info → Custom iOS Target Properties.
2. **The three game Views still hold their own `@State`** rather than reading from their new VMs. This means completed games do not yet append `GameSession` records. Step 5 of the plan finishes this wiring.
3. **HTML entities in trivia questions** are decoded with a hard-coded lookup table (`&quot;`, `&amp;`, etc.). Any entity not in the list falls through un-decoded. A full HTML parser was avoided because `NSAttributedString(data:options:)` is `@MainActor` isolated and could not be called from the background decoding context.
4. **`ContentView.swift` still exists at the project root** rather than being folded into `PlayHubApp.swift`. It works, but the brief's folder tree does not include it.

---

## How to Run

1. Open `IosProject1.xcodeproj` in Xcode 15+.
2. Select an iOS 17+ simulator or device.
3. **Add the Info.plist key** for location permission (see Known Limitations).
4. Build and run (`⌘R`).

The trivia questions require an internet connection (the app calls `https://opentdb.com/api.php`). Everything else works offline.

---

## Reflection

The most valuable step in this brief was **restructuring first, adding features second**. Moving code into `Models/`, `ViewModels/`, `Services/`, `Views/Tabs/`, `Views/Games/`, and `Views/Shared/` before touching a single new API forced every new addition to land in the right place. When `LocationService` and `NotificationService` needed writing, there was no debate about where they belonged — the folder tree already said "here".

The MVVM refactor of Tap Frenzy and Light It Up was another turning point. When both games shipped with all state as `@State` inside the View, adding session recording meant duplicating the persistence call across three Views. Pulling everything into `TapFrenzyVM` and `LightItUpVM` means end-of-game logic lives in exactly one place per game, and the Views become tiny.

The trickiest part was Swift concurrency. `QuizRushVM` initially had `@MainActor` on the class, which conflicted with SwiftUI `Button` actions in the current Swift-6-ish concurrency mode; removing it and relying on the project's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` build setting was the fix. Similarly, `NSAttributedString`'s HTML decoder became main-actor-isolated at some point, so the trivia model uses a plain-string entity table instead.

If I were starting again I would set up the Info.plist permission strings and the `SessionStore` on day one — those two invisible pieces gate every visible feature in the second half of the brief.

---

## Credits

- Open Trivia DB (`opentdb.com`) — quiz question source.
- Apple SF Symbols — every icon in the app.
- Coursework brief: BSc (Hons) Computing · iOS App Development · Week 4.
