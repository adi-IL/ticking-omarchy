import QtQuick
import "./services/QuoteLibrary.js" as QuoteLibrary
import "./services/QuoteClient.js" as QuoteClient
import "./services/TickingStorage.js" as TickingStorage

QtObject {
    id: stateRoot

    property var bar: null

    // Configuration Properties
    property string targetTimestamp: "2026-10-25"
    property string startTimestamp: "2026-01-01"
    property string customTitle: "NEW HORIZON"
    property string themeMode: "obsidian"
    property bool showMilliseconds: true
    property real translucency: 0.88
    property int activeTab: 0
    property bool hourFormat24: true
    property color accentColor: "#00E599"
    property bool showProgress: true
    property bool showPanelBadge: true
    property bool showQuoteBar: true
    property int quoteIntervalMinutes: 180
    property string quoteArchetype: "adaptive"
    property string quotePersonalFocus: ""
    property string quoteApiKey: ""
    property string currentQuoteText: QuoteClient.DEFAULT_QUOTE_TEXT
    property string currentQuoteAuthor: QuoteClient.DEFAULT_QUOTE_AUTHOR
    property bool isQuoteLoading: false

    // Calculated / Active Data
    property var countdownData: ({
        days: "00",
        hours: "00",
        minutes: "00",
        seconds: "00",
        milliseconds: "00",
        progressRatio: 0.0,
        progressPercent: "0.000%",
        isExpired: false
    })

    property var clockData: ({
        hours: "00",
        minutes: "00",
        seconds: "00",
        amPm: "",
        dateString: "",
        timeZone: "UTC",
        dayOfYear: 1,
        weekOfYear: 1
    })

    property var stopwatchData: ({
        formattedTime: "00:00.00",
        hours: "00",
        minutes: "00",
        seconds: "00",
        hundredths: "00",
        hasHours: false,
        running: false,
        laps: []
    })

    property bool stopwatchRunning: false
    property double stopwatchElapsedMs: 0
    property double stopwatchLastTimestamp: 0
    property double stopwatchLastLapMs: 0
    property double stopwatchLastSyncMs: 0
    property var stopwatchLaps: []

    property int lastCountdownSec: -1
    property int lastClockSec: -1
    property string cachedDateKey: ""
    property string cachedDateFormatted: ""
    property string cachedTzString: ""
    property int cachedDayOfYear: 1
    property int cachedWeekOfYear: 1

    property bool isPopupOpen: false

    readonly property color onAccentFg: {
        var lum = 0.2126 * accentColor.r + 0.7152 * accentColor.g + 0.0722 * accentColor.b;
        return lum > 0.55 ? "#0A0A0A" : "#FFFFFF";
    }

    readonly property var themeColors: ({
        cardBg: Qt.rgba(0.03, 0.03, 0.03, translucency),
        cardBorder: Qt.rgba(1, 1, 1, 0.09),
        cardBorderHover: Qt.rgba(1, 1, 1, 0.18),
        specularGlint: Qt.rgba(1, 1, 1, 0.45),
        textPrimary: "#EDEDED",
        textSecondary: "#A1A1AA",
        textMuted: "#71717A",
        subCardBg: Qt.rgba(0.06, 0.06, 0.06, 0.88),
        subCardHover: Qt.rgba(0.12, 0.12, 0.12, 0.96),
        dangerBg: Qt.rgba(0.8, 0.2, 0.2, 0.8),
        dangerBgHover: Qt.rgba(0.9, 0.3, 0.3, 0.9),
        successBg: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.8),
        successBgHover: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.95),
        buttonBg: Qt.rgba(1, 1, 1, 0.08),
        buttonBgHover: Qt.rgba(1, 1, 1, 0.14),
        buttonFg: "#EDEDED",
        onAccentFg: stateRoot.onAccentFg,
        onDangerFg: "#FFFFFF",
        rowAlt: Qt.rgba(1, 1, 1, 0.04)
    })

    // Ticker Timer
    property var tickerTimer: Timer {
        interval: {
            if (!stateRoot.isPopupOpen) {
                if (stateRoot.stopwatchRunning) return 1000;
                return stateRoot.showPanelBadge ? 30000 : 60000;
            }
            if (stateRoot.activeTab === 2) {
                return stateRoot.stopwatchRunning ? 40 : 1000;
            }
            if (stateRoot.activeTab === 0) {
                return stateRoot.showMilliseconds ? 100 : 1000;
            }
            return 1000;
        }
        running: true
        repeat: true
        onTriggered: stateRoot.updateAllMetrics()
    }

    // Quote Timer
    property var quoteTimer: Timer {
        interval: Math.max(45, stateRoot.quoteIntervalMinutes) * 60 * 1000
        running: stateRoot.showQuoteBar && stateRoot.isPopupOpen
        repeat: true
        onTriggered: stateRoot.fetchNextQuote(false)
    }

    function pad2(n) {
        var num = Math.floor(Math.abs(Number(n)) || 0);
        return num < 10 ? "0" + num : "" + num;
    }

    function parseHorizonDate(value) {
        var s = (value || "").toString().trim();
        var m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
        if (m) {
            var y = parseInt(m[1], 10);
            var mo = parseInt(m[2], 10) - 1;
            var d = parseInt(m[3], 10);
            var local = new Date(y, mo, d, 0, 0, 0, 0);
            if (!isNaN(local.getTime())) {
                return local;
            }
        }
        return null;
    }

    function formatHorizonDate(dateObj) {
        return dateObj.getFullYear() + "-" + pad2(dateObj.getMonth() + 1) + "-" + pad2(dateObj.getDate());
    }

    function defaultTargetDate() {
        return new Date(2026, 9, 25, 0, 0, 0, 0);
    }

    function defaultStartDate() {
        return new Date(2026, 0, 1, 0, 0, 0, 0);
    }

    function isoWeekNumber(dateObj) {
        var d = new Date(dateObj.getFullYear(), dateObj.getMonth(), dateObj.getDate());
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() + 3 - ((d.getDay() + 6) % 7));
        var week1 = new Date(d.getFullYear(), 0, 4);
        return 1 + Math.round(((d.getTime() - week1.getTime()) / 86400000 - 3 + ((week1.getDay() + 6) % 7)) / 7);
    }

    function dayOfYearLocal(dateObj) {
        var nowUtc = Date.UTC(dateObj.getFullYear(), dateObj.getMonth(), dateObj.getDate());
        var startUtc = Date.UTC(dateObj.getFullYear(), 0, 1);
        return Math.floor((nowUtc - startUtc) / 86400000) + 1;
    }

    readonly property double targetMs: {
        var d = parseHorizonDate(targetTimestamp) || defaultTargetDate();
        return d.getTime();
    }

    readonly property double startMs: {
        var d = parseHorizonDate(startTimestamp) || defaultStartDate();
        return d.getTime();
    }

    function resetBaselineToNow() {
        startTimestamp = formatHorizonDate(new Date());
        lastCountdownSec = -1;
        updateAllMetrics();
        persistConfig();
    }

    function updateAllMetrics() {
        var now = new Date();
        var nowMs = now.getTime();
        var nowSec = Math.floor(nowMs / 1000);

        var isCountdownActive = isPopupOpen && activeTab === 0;
        var needsSubsecondCountdown = isCountdownActive && showMilliseconds;

        if (needsSubsecondCountdown || nowSec !== lastCountdownSec) {
            lastCountdownSec = nowSec;

            var tMs = targetMs;
            var sMs = startMs;
            var diffMs = tMs - nowMs;
            var isExpired = diffMs <= 0;

            var d = 0, h = 0, m = 0, s = 0, ms = 0;
            if (!isExpired) {
                d = Math.floor(diffMs / 86400000);
                h = Math.floor((diffMs % 86400000) / 3600000);
                m = Math.floor((diffMs % 3600000) / 60000);
                s = Math.floor((diffMs % 60000) / 1000);
                ms = Math.floor((diffMs % 1000) / 10);
            }

            var totalSpan = tMs - sMs;
            var elapsedSpan = nowMs - sMs;
            var ratio = 0.0;
            if (isExpired) {
                ratio = 1.0;
            } else if (nowMs <= sMs) {
                ratio = 0.0;
            } else if (totalSpan > 0) {
                ratio = Math.max(0.0, Math.min(1.0, elapsedSpan / totalSpan));
            }

            countdownData = {
                days: pad2(d),
                hours: pad2(h),
                minutes: pad2(m),
                seconds: pad2(s),
                milliseconds: pad2(ms),
                progressRatio: ratio,
                progressPercent: (ratio * 100).toFixed(3) + "%",
                isExpired: isExpired
            };
        }

        var clockSec = now.getSeconds();
        if (clockSec !== lastClockSec) {
            lastClockSec = clockSec;

            var hoursNum = now.getHours();
            var amPmStr = "";
            if (!hourFormat24) {
                amPmStr = hoursNum >= 12 ? "PM" : "AM";
                hoursNum = hoursNum % 12;
                if (hoursNum === 0) hoursNum = 12;
            }

            var dateKey = now.getFullYear() + "-" + now.getMonth() + "-" + now.getDate() + "@" + now.getTimezoneOffset();
            if (dateKey !== cachedDateKey) {
                cachedDateKey = dateKey;
                var df = Qt.formatDate(now, Locale.LongFormat);
                if (!df || df.length === 0) {
                    df = now.toLocaleDateString(Qt.locale(), Locale.LongFormat);
                }
                cachedDateFormatted = df;

                var tzOffsetMin = -now.getTimezoneOffset();
                var tzSign = tzOffsetMin >= 0 ? "+" : "-";
                var tzHours = Math.floor(Math.abs(tzOffsetMin) / 60);
                var tzMins = Math.abs(tzOffsetMin) % 60;
                cachedTzString = "UTC" + tzSign + pad2(tzHours) + ":" + pad2(tzMins);
                cachedDayOfYear = dayOfYearLocal(now);
                cachedWeekOfYear = isoWeekNumber(now);
            }

            clockData = {
                hours: pad2(hoursNum),
                minutes: pad2(now.getMinutes()),
                seconds: pad2(clockSec),
                amPm: amPmStr,
                dateString: cachedDateFormatted,
                timeZone: cachedTzString,
                dayOfYear: cachedDayOfYear,
                weekOfYear: cachedWeekOfYear
            };
        }

        if (stopwatchRunning) {
            var currentClock = Date.now();
            var delta = currentClock - stopwatchLastTimestamp;
            stopwatchLastTimestamp = currentClock;
            stopwatchElapsedMs += delta;
            if (stopwatchElapsedMs - stopwatchLastSyncMs >= 5000) {
                stopwatchLastSyncMs = stopwatchElapsedMs;
                persistConfig();
            }
            updateStopwatchDisplay();
        }
    }

    function updateStopwatchDisplay() {
        var totalSec = Math.floor(stopwatchElapsedMs / 1000);
        var hrs = Math.floor(totalSec / 3600);
        var min = Math.floor((totalSec % 3600) / 60);
        var sec = totalSec % 60;
        var hundredths = Math.floor((stopwatchElapsedMs % 1000) / 10);
        var formatted = (hrs > 0 ? (pad2(hrs) + ":") : "") + pad2(min) + ":" + pad2(sec) + "." + pad2(hundredths);

        stopwatchData = {
            formattedTime: formatted,
            hours: pad2(hrs),
            minutes: pad2(min),
            seconds: pad2(sec),
            hundredths: pad2(hundredths),
            hasHours: hrs > 0,
            running: stopwatchRunning,
            laps: stopwatchLaps.slice()
        };
    }

    function startStopwatch() {
        var now = Date.now();
        stopwatchLastTimestamp = now;
        stopwatchLastSyncMs = stopwatchElapsedMs;
        stopwatchRunning = true;
        updateStopwatchDisplay();
        persistConfig();
    }

    function pauseStopwatch() {
        stopwatchRunning = false;
        stopwatchLastTimestamp = 0;
        updateStopwatchDisplay();
        persistConfig();
    }

    function resetStopwatch() {
        stopwatchRunning = false;
        stopwatchElapsedMs = 0;
        stopwatchLastLapMs = 0;
        stopwatchLastSyncMs = 0;
        stopwatchLaps = [];
        updateStopwatchDisplay();
        persistConfig();
    }

    function lapStopwatch() {
        if (!stopwatchRunning) return;

        var currentTotal = stopwatchElapsedMs;
        var split = currentTotal - stopwatchLastLapMs;
        stopwatchLastLapMs = currentTotal;

        var formatMs = function (t) {
            var s = Math.floor(t / 1000);
            var hrs = Math.floor(s / 3600);
            var m = Math.floor((s % 3600) / 60);
            var sc = s % 60;
            var hd = Math.floor((t % 1000) / 10);
            return (hrs > 0 ? (pad2(hrs) + ":") : "") + pad2(m) + ":" + pad2(sc) + "." + pad2(hd);
        };

        var newLap = {
            lapNumber: stopwatchLaps.length + 1,
            splitTime: formatMs(split),
            totalTime: formatMs(currentTotal)
        };

        stopwatchLaps = [newLap].concat(stopwatchLaps);
        updateStopwatchDisplay();
        persistConfig();
    }

    function applyQuote(text, author) {
        var cleanedText = QuoteClient.cleanQuoteText(text);
        var cleanedAuthor = QuoteClient.cleanQuoteAuthor(author);
        if (cleanedText.length === 0) {
            var fallback = QuoteLibrary.getCuratedQuote(quoteArchetype, countdownData.progressRatio, currentQuoteText);
            cleanedText = QuoteClient.cleanQuoteText(fallback.text);
            cleanedAuthor = QuoteClient.cleanQuoteAuthor(fallback.author);
        }
        currentQuoteText = cleanedText;
        currentQuoteAuthor = cleanedAuthor;
        isQuoteLoading = false;
        persistConfig();
    }

    function fetchNextQuote(forceOffline) {
        if (isQuoteLoading) return;
        isQuoteLoading = true;

        var params = {
            apiKey: (quoteApiKey || "").trim(),
            archetype: quoteArchetype || "adaptive",
            progressRatio: countdownData.progressRatio || 0.0,
            milestoneTitle: customTitle || "NEW HORIZON",
            personalFocus: (quotePersonalFocus || "").trim(),
            forceOffline: !!forceOffline,
            currentQuoteText: currentQuoteText || "",
            currentQuoteAuthor: currentQuoteAuthor || ""
        };

        QuoteClient.fetchQuote(params, QuoteLibrary, {
            onSuccess: function (text, author) {
                applyQuote(text, author);
            },
            onComplete: function () {
                isQuoteLoading = false;
            }
        });
    }

    function loadInitialConfig(injectedSettings) {
        TickingStorage.loadSettings(injectedSettings, function (cfg) {
            if (!cfg) return;
            if (cfg.targetTimestamp) targetTimestamp = cfg.targetTimestamp;
            if (cfg.startTimestamp) startTimestamp = cfg.startTimestamp;
            if (cfg.customTitle) customTitle = cfg.customTitle;
            if (cfg.themeMode) themeMode = cfg.themeMode;
            if (cfg.showMilliseconds !== undefined) showMilliseconds = cfg.showMilliseconds;
            if (cfg.translucency !== undefined) translucency = cfg.translucency;
            if (cfg.activeTab !== undefined) activeTab = cfg.activeTab;
            if (cfg.hourFormat24 !== undefined) hourFormat24 = cfg.hourFormat24;
            if (cfg.accentColor) accentColor = cfg.accentColor;
            if (cfg.showProgress !== undefined) showProgress = cfg.showProgress;
            if (cfg.showPanelBadge !== undefined) showPanelBadge = cfg.showPanelBadge;
            if (cfg.showQuoteBar !== undefined) showQuoteBar = cfg.showQuoteBar;
            if (cfg.quoteIntervalMinutes !== undefined) quoteIntervalMinutes = cfg.quoteIntervalMinutes;
            if (cfg.quoteArchetype) quoteArchetype = cfg.quoteArchetype;
            if (cfg.quotePersonalFocus !== undefined) quotePersonalFocus = cfg.quotePersonalFocus;
            if (cfg.quoteApiKey !== undefined) quoteApiKey = cfg.quoteApiKey;
            if (cfg.cachedQuoteText) currentQuoteText = cfg.cachedQuoteText;
            if (cfg.cachedQuoteAuthor) currentQuoteAuthor = cfg.cachedQuoteAuthor;

            if (cfg.stopwatchLapsJson) {
                try {
                    var parsedLaps = JSON.parse(cfg.stopwatchLapsJson);
                    if (Array.isArray(parsedLaps)) stopwatchLaps = parsedLaps;
                } catch (e) {}
            }
            if (cfg.stopwatchElapsedMs !== undefined) stopwatchElapsedMs = cfg.stopwatchElapsedMs;
            if (cfg.stopwatchRunning && cfg.stopwatchStartTimestamp > 0) {
                var now = Date.now();
                var added = Math.max(0, now - cfg.stopwatchStartTimestamp);
                stopwatchElapsedMs += added;
                stopwatchLastTimestamp = now;
                stopwatchRunning = true;
            }
            updateAllMetrics();
        });
    }

    function persistConfig() {
        var cfg = {
            targetTimestamp: targetTimestamp,
            startTimestamp: startTimestamp,
            customTitle: customTitle,
            themeMode: themeMode,
            showMilliseconds: showMilliseconds,
            translucency: translucency,
            activeTab: activeTab,
            hourFormat24: hourFormat24,
            accentColor: accentColor.toString(),
            showProgress: showProgress,
            showPanelBadge: showPanelBadge,
            showQuoteBar: showQuoteBar,
            quoteIntervalMinutes: quoteIntervalMinutes,
            quoteArchetype: quoteArchetype,
            quotePersonalFocus: quotePersonalFocus,
            quoteApiKey: quoteApiKey,
            cachedQuoteText: currentQuoteText,
            cachedQuoteAuthor: currentQuoteAuthor,
            stopwatchRunning: stopwatchRunning,
            stopwatchElapsedMs: stopwatchElapsedMs,
            stopwatchStartTimestamp: stopwatchRunning ? Date.now() : 0,
            stopwatchLapsJson: JSON.stringify(stopwatchLaps)
        };
        TickingStorage.saveSettings(cfg, bar);
    }
}
