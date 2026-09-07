.pragma library

// TickingStorage service for Omarchy Widget
// Manages local state persistence in ~/.config/omarchy/ticking-widget.json

var DEFAULT_CONFIG = {
    targetTimestamp: "2026-10-25",
    startTimestamp: "2026-01-01",
    customTitle: "NEW HORIZON",
    themeMode: "obsidian",
    showMilliseconds: true,
    translucency: 0.88,
    activeTab: 0,
    hourFormat24: true,
    accentColor: "#00E599",
    showProgress: true,
    showPanelBadge: true,
    showQuoteBar: true,
    quoteIntervalMinutes: 180,
    quoteArchetype: "adaptive",
    quotePersonalFocus: "",
    quoteApiKey: "",
    cachedQuoteText: "The only reason for time is so that everything does not happen at once.",
    cachedQuoteAuthor: "Albert Einstein",
    stopwatchRunning: false,
    stopwatchElapsedMs: 0,
    stopwatchStartTimestamp: 0,
    stopwatchLapsJson: "[]"
};

function getStoragePath() {
    return "/home/" + (typeof process !== "undefined" && process.env ? (process.env.USER || "user") : "adi-IL") + "/.config/omarchy/ticking-widget.json";
}

function loadSettings(baseSettings, callback) {
    var state = {};
    for (var k in DEFAULT_CONFIG) {
        state[k] = DEFAULT_CONFIG[k];
    }
    if (baseSettings && typeof baseSettings === "object") {
        for (var bk in baseSettings) {
            state[bk] = baseSettings[bk];
        }
    }

    var xhr = new XMLHttpRequest();
    // Resolve home directory path
    var homePath = "/home/adi-IL/.config/omarchy/ticking-widget.json";
    xhr.open("GET", "file://" + homePath, true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200 || (xhr.responseText && xhr.responseText.length > 0)) {
                try {
                    var parsed = JSON.parse(xhr.responseText);
                    for (var key in parsed) {
                        state[key] = parsed[key];
                    }
                } catch (e) {
                    console.warn("TickingStorage: Failed to parse saved config:", e);
                }
            }
            if (typeof callback === "function") {
                callback(state);
            }
        }
    };
    xhr.onerror = function () {
        if (typeof callback === "function") {
            callback(state);
        }
    };
    try {
        xhr.send();
    } catch (e) {
        if (typeof callback === "function") {
            callback(state);
        }
    }
}

function saveSettings(state, bar) {
    if (!state || typeof state !== "object") return;
    try {
        var jsonStr = JSON.stringify(state, null, 2);
        // Base64 encode to safely transmit through shell command
        var b64 = Qt.btoa ? Qt.btoa(jsonStr) : Buffer.from(jsonStr).toString("base64");
        var cmd = "mkdir -p ~/.config/omarchy && echo '" + b64 + "' | base64 -d > ~/.config/omarchy/ticking-widget.json";
        if (bar && typeof bar.run === "function") {
            bar.run(cmd);
        }
    } catch (e) {
        console.warn("TickingStorage: Failed to save config:", e);
    }
}
