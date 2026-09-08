.pragma library

// TickingStorage service for Omarchy Widget
// Manages local state persistence in ~/.config/omarchy/ticking-widget.json

var DEFAULT_CONFIG = {
    targetTimestamp: "",
    startTimestamp: "",
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
    quoteIntervalMinutes: 15,
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
    var home = (typeof process !== "undefined" && process.env && process.env.HOME) ? process.env.HOME : (typeof Quickshell !== "undefined" && Quickshell.env ? Quickshell.env("HOME") : "");
    if (home) {
        return home + "/.config/omarchy/ticking-widget.json";
    }
    return "~/.config/omarchy/ticking-widget.json";
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

    if (typeof callback === "function") {
        callback(state);
    }
}

function toBase64(str) {
    if (typeof Buffer !== "undefined") {
        return Buffer.from(str).toString("base64");
    }
    if (typeof Qt !== "undefined" && Qt.btoa) {
        if (typeof TextEncoder !== "undefined") {
            try {
                return Qt.btoa(new TextEncoder().encode(str));
            } catch (e) {}
        }
        return Qt.btoa(str);
    }
    return "";
}

function saveSettings(state, bar) {
    if (!state || typeof state !== "object") return;
    try {
        var home = (bar && bar.home) ? bar.home : ((typeof process !== "undefined" && process.env && process.env.HOME) ? process.env.HOME : (typeof Quickshell !== "undefined" && Quickshell.env ? Quickshell.env("HOME") : ""));
        var dir = home ? (home + "/.config/omarchy") : "~/.config/omarchy";
        var filePath = home ? (home + "/.config/omarchy/ticking-widget.json") : "~/.config/omarchy/ticking-widget.json";
        var jsonStr = JSON.stringify(state, null, 2);
        var b64 = toBase64(jsonStr);
        var cmd = "mkdir -p " + dir + " && echo '" + b64 + "' | base64 -d > " + filePath;
        if (bar && typeof bar.run === "function") {
            bar.run(cmd);
        }
    } catch (e) {
        console.warn("TickingStorage: Failed to save config:", e);
    }
}
