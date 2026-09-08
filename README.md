# Ticking: Horizon & Time HUD for Omarchy Linux (Quattro)

[![Author: Aditya Gaurav](https://img.shields.io/badge/Author-Aditya%20Gaurav-blue?style=flat-square)](https://github.com/adi-IL)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue?style=flat-square)](LICENSE)
[![Platform: Omarchy Quattro](https://img.shields.io/badge/Omarchy-Quattro%204.0+-00E599?style=flat-square)](https://omarchy.org/)

A desktop and status bar HUD for **Omarchy Linux (Quattro)**. Track a milestone countdown with live millisecond precision, read a world clock with UTC offset and ISO week number, run a split-lap stopwatch, and keep a quiet philosophy quote companion on the bar.

Crafted in obsidian glass, adapting to Omarchy's system themes and Quickshell desktop architecture.

---

## Features

- **Horizon Countdown:** Tabular metric cards for Days, Hours, Minutes, Seconds, and Centiseconds, accompanied by a journey progress track.
- **Live World Clock:** Clean digital clock with 12h/24h toggle, date string, UTC timezone offset, day of year, and ISO week number.
- **Precision Stopwatch:** Start, pause, split lap recording, and reset. State and laps persist across sessions.
- **Intellect Quote Companion:** Rotating philosophical reflections on discipline, craftsmanship, time, and focus (Seneca, Marcus Aurelius, Feynman, Da Vinci, Sagan, Einstein). Includes an optional OpenCode Zen API client with automatic author sanitization and negative prompt duplicate filtering.
- **Native Omarchy Bar Widget:** Sits on the bar as a compact pill with an icon and time-remaining badge (`45d 12h`). Left-click opens the floating HUD popout anchored directly below the bar. Dismisses on outside click or `Escape`.

---

## Architecture

This project is built as a **native Omarchy bar widget module** (`type: "qml"` in `shell.json`), not a packaged plugin:

```
ticking-omarchy/
├── TickingWidget.qml          # Bar face Item (injected with `bar`, `moduleName`, `settings`)
├── TickingPopupWindow.qml     # Native Omarchy KeyboardPanel layer-shell surface
├── TickingPopup.qml           # Obsidian card container holding the full HUD
├── TickingState.qml           # Reactive central state engine (timers & metrics)
├── components/
│   ├── MetricCard.qml         # Tabular metric card with specular glint
│   ├── ProgressTrack.qml      # Gradient journey progress bar
│   ├── SegmentedNav.qml       # Tab navigation pill (Countdown / Clock / Stopwatch)
│   ├── QuoteBar.qml           # Adaptive typography capsule with copy-to-clipboard
│   ├── CountdownView.qml      # Countdown cards & milestone banner
│   ├── ClockView.qml          # Digital time & secondary timezone/week info
│   └── StopwatchView.qml      # Millisecond stopwatch & split lap table
├── services/
│   ├── QuoteLibrary.js        # Curated offline quote database
│   ├── QuoteClient.js         # Zen model cascade & quote sanitization
│   └── TickingStorage.js      # JSON state persistence in ~/.config/omarchy/
├── scripts/
│   └── install.sh             # Fast symlink and install helper
└── sample-shell.json          # Example Omarchy bar configuration
```

---

## Installation & Setup

### 1. Link the Widget
Run the install helper to link `TickingWidget.qml` into your Omarchy modules directory:

```bash
./scripts/install.sh
```

### 2. Configure `~/.config/omarchy/shell.json`
Add the widget entry to `bar.layout.right` or `bar.layout.center`:

```json
{
  "version": 1,
  "bar": {
    "layout": {
      "right": [
        {
          "id": "ticking",
          "type": "qml",
          "source": "~/.config/omarchy/bar/modules/ticking.qml",
          "customTitle": "NEW HORIZON",
          "targetTimestamp": "2026-10-25",
          "startTimestamp": "2026-09-03",
          "accentColor": "#00E599",
          "showMilliseconds": true,
          "showProgress": true,
          "showPanelBadge": true,
          "showQuoteBar": true
        }
      ]
    }
  }
}
```

### 3. Reload Shell
Apply the changes:

```bash
omarchy-restart-shell
# or via IPC:
omarchy-shell shell reloadConfig
```

---

## IPC Control

Ticking registers a native `IpcHandler` target with the shell for scripting, keybinds, and automation:

```bash
# Toggle the HUD popout
omarchy-shell ticking toggle

# Open or close explicitly
omarchy-shell ticking open
omarchy-shell ticking close

# Switch tabs (0: Countdown, 1: Clock, 2: Stopwatch)
omarchy-shell ticking selectTab 1

# Stopwatch controls
omarchy-shell ticking startStopwatch
omarchy-shell ticking pauseStopwatch
omarchy-shell ticking resetStopwatch

# Fetch or rotate to next quote
omarchy-shell ticking nextQuote

# Query live state as JSON
omarchy-shell ticking status
```

---

## Configuration Reference

Settings can be specified inline in `shell.json` under the widget object, or edited in `~/.config/omarchy/ticking-widget.json`:

| Key | Type | Default | Description |
|---|---|---|---|
| `targetTimestamp` | string | `"2026-10-25"` | Target civil date (`YYYY-MM-DD`, local midnight) |
| `startTimestamp` | string | `"2026-09-03"` | Baseline date (`YYYY-MM-DD`) for progress calculation |
| `customTitle` | string | `"NEW HORIZON"` | Headline displayed above countdown |
| `accentColor` | string | `"#00E599"` | Emerald / custom accent glow color |
| `showMilliseconds` | bool | `true` | Display sub-second ticker on countdown |
| `showProgress` | bool | `true` | Display journey progress track |
| `showPanelBadge` | bool | `true` | Show compact remaining time badge on horizontal bar |
| `showQuoteBar` | bool | `true` | Display intellect quote companion |
| `quoteArchetype` | string | `"adaptive"` | Quote resonance (`adaptive`, `stoic`, `builder`, `cosmic`, `intensity`) |
| `quoteApiKey` | string | `""` | Optional OpenCode Zen API key override for remote quotes |
| `hourFormat24` | bool | `true` | 24-hour time format in Clock view |

---

## Author & License

- **Author:** Aditya Gaurav ([@adi-IL](https://github.com/adi-IL))
- **License:** GNU General Public License v3.0 or later (GPL-3.0-or-later)
