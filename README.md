# Ticking: Horizon & Time HUD for Omarchy Linux (Quattro)

[![Author: Aditya Gaurav](https://img.shields.io/badge/Author-Aditya%20Gaurav-blue?style=flat-square)](https://github.com/adi-IL)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPLv3-blue?style=flat-square)](LICENSE)
[![Platform: Omarchy Quattro](https://img.shields.io/badge/Omarchy-Quattro%204.0+-00E599?style=flat-square)](https://omarchy.org/)

A desktop and status bar HUD for Omarchy Linux (Quattro). Ticking is packaged as an official Omarchy Quattro plugin with a valid `manifest.json`. Track a milestone countdown with live millisecond precision, read a world clock with UTC offset and ISO week number, run a split-lap stopwatch, and keep a quiet philosophy quote companion on the bar.

Crafted in obsidian glass, adapting to Omarchy system themes and Quickshell desktop architecture.

---

## Features

- Horizon countdown: Tabular metric cards for days, hours, minutes, seconds, and centiseconds, accompanied by a journey progress track.
- Live world clock: Clean digital clock with 12h/24h toggle, date string, UTC timezone offset, day of year, and ISO week number.
- Precision stopwatch: Start, pause, split lap recording, and reset. State and laps persist across sessions.
- Intellect quote companion: Rotating philosophical reflections on discipline, craftsmanship, time, and focus (Seneca, Marcus Aurelius, Feynman, Da Vinci, Sagan, Einstein). Includes an optional OpenCode Zen API client with automatic author sanitization and duplicate filtering.
- In-HUD settings view: Click the ⚙ gear icon in the header to configure milestone title, target date (with +30d, +90d, and Year End presets), baseline reset, accent color swatches, and display toggles directly in the UI without editing raw JSON files.
- Native Omarchy bar widget: Sits on the bar as a compact pill with an icon and time-remaining badge (`45d 12h`). Left-click opens the floating HUD popout anchored directly below the bar. Dismisses on outside click or `Escape`.

---

## Architecture

This project is packaged as an Omarchy Quattro plugin (`adi.ticking`):

```
ticking-omarchy/
├── manifest.json              # Official Omarchy Quattro plugin manifest
├── TickingWidget.qml          # Bar face Item (injected with bar, moduleName, settings)
├── TickingPopupWindow.qml     # Native Omarchy KeyboardPanel layer-shell surface
├── TickingPopup.qml           # Obsidian card container holding the full HUD
├── TickingState.qml           # Reactive central state engine (timers and metrics)
├── components/
│   ├── MetricCard.qml         # Tabular metric card with specular glint
│   ├── ProgressTrack.qml      # Gradient journey progress bar
│   ├── SegmentedNav.qml       # Tab navigation pill (Countdown / Clock / Stopwatch)
│   ├── QuoteBar.qml           # Adaptive typography capsule with copy-to-clipboard
│   ├── CountdownView.qml      # Countdown cards and milestone banner
│   ├── ClockView.qml          # Digital time and secondary timezone/week info
│   ├── StopwatchView.qml      # Millisecond stopwatch and split lap table
│   └── SettingsView.qml       # Interactive In-HUD configuration view
├── services/
│   ├── QuoteLibrary.js        # Curated offline quote database
│   ├── QuoteClient.js         # Zen model cascade and quote sanitization
│   └── TickingStorage.js      # JSON state persistence in ~/.config/omarchy/
├── scripts/
│   └── install.sh             # Fast symlink and validation helper for development
└── sample-shell.json          # Example Omarchy bar configuration
```

---

## Installation

### Standard plugin installation

Install and enable the plugin directly using the Omarchy CLI:

```bash
omarchy plugin add https://github.com/adi-IL/ticking-omarchy.git --enable
```

### Manual installation

Clone the repository into your Omarchy plugins directory, rescan plugins, and enable the plugin:

```bash
git clone https://github.com/adi-IL/ticking-omarchy.git ~/.config/omarchy/plugins/adi.ticking
omarchy-shell shell rescanPlugins
omarchy plugin enable adi.ticking
```

### Local development installation

When developing locally, run the install helper to link the repository into `~/.config/omarchy/plugins/adi.ticking`, validate the manifest, rescan plugins, and enable the widget:

```bash
./scripts/install.sh
```

---

## Configuration

Settings can be adjusted directly inside the HUD using the ⚙ gear icon in the header.

To customize settings through your bar layout in `~/.config/omarchy/shell.json`, add properties to the `adi.ticking` widget entry:

```json
{
  "version": 1,
  "bar": {
    "layout": {
      "right": [
        {
          "id": "adi.ticking",
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

Reload the shell configuration after manual file edits:

```bash
omarchy-restart-shell
# or via IPC:
omarchy-shell shell reloadConfig
```

---

## IPC control

Ticking registers a native `IpcHandler` target with the shell for scripting, keybinds, and automation:

```bash
# Toggle the HUD popout
omarchy-shell ticking toggle

# Open or close explicitly
omarchy-shell ticking open
omarchy-shell ticking close

# Switch tabs (0: Countdown, 1: Clock, 2: Stopwatch, 3: Settings)
omarchy-shell ticking selectTab 0
omarchy-shell ticking selectTab 1
omarchy-shell ticking selectTab 2
omarchy-shell ticking selectTab 3

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

## Configuration reference

Settings can be edited inside the HUD via the settings view, specified inline in `shell.json` under the widget object, or saved in `~/.config/omarchy/ticking-widget.json`:

| Key | Type | Default | Description |
|---|---|---|---|
| `targetTimestamp` | string | `""` | Target civil date (`YYYY-MM-DD`, defaults to Dec 31 of current year) |
| `startTimestamp` | string | `""` | Baseline date (`YYYY-MM-DD`, defaults to Jan 1 of current year) |
| `customTitle` | string | `"NEW HORIZON"` | Headline displayed above countdown |
| `accentColor` | string | `"#00E599"` | Emerald or custom accent glow color |
| `showMilliseconds` | bool | `true` | Display sub-second ticker on countdown |
| `showProgress` | bool | `true` | Display journey progress track |
| `showPanelBadge` | bool | `true` | Show compact remaining time badge on horizontal bar |
| `showQuoteBar` | bool | `true` | Display intellect quote companion |
| `quoteArchetype` | string | `"adaptive"` | Quote resonance (`adaptive`, `stoic`, `builder`, `cosmic`, `intensity`) |
| `quoteApiKey` | string | `""` | Optional OpenCode Zen API key override for remote quotes |
| `hourFormat24` | bool | `true` | 24-hour time format in Clock view |

---

## Author & license

- Author: Aditya Gaurav ([@adi-IL](https://github.com/adi-IL))
- License: GNU General Public License v3.0 or later (GPL-3.0-or-later)
