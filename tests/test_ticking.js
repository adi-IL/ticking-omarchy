const fs = require("fs");
const path = require("path");
const assert = require("assert");

console.log("=== Testing Ticking Omarchy Services ===");

// 1. Test QuoteLibrary
const qLibPath = path.join(__dirname, "../services/QuoteLibrary.js");
const qLibCode = fs.readFileSync(qLibPath, "utf-8").replace(".pragma library", "");
const qLibScope = {};
new Function("var quotes, getCuratedQuote; " + qLibCode + "\nthis.quotes = quotes; this.getCuratedQuote = getCuratedQuote;").call(qLibScope);

assert(qLibScope.quotes, "quotes object exists");
assert.strictEqual(qLibScope.quotes.stoic.length, 10, "stoic has 10 quotes");
assert.strictEqual(qLibScope.quotes.builder.length, 10, "builder has 10 quotes");
assert.strictEqual(qLibScope.quotes.cosmic.length, 10, "cosmic has 10 quotes");
assert.strictEqual(qLibScope.quotes.intensity.length, 10, "intensity has 10 quotes");
console.log("✔ QuoteLibrary database verified (40 quotes loaded across 4 archetypes).");

const sampleQuote = qLibScope.getCuratedQuote("builder", 0.5);
assert(sampleQuote && sampleQuote.text && sampleQuote.author, "Curated quote returns text and author");
console.log(`✔ Sample Quote: "${sampleQuote.text}" - ${sampleQuote.author}`);

// Test duplicate exclusion
const stoic1 = qLibScope.quotes.stoic[0];
for (let i = 0; i < 20; i++) {
    const q = qLibScope.getCuratedQuote("stoic", 0.5, stoic1.text);
    assert.notStrictEqual(q.text.toLowerCase().trim(), stoic1.text.toLowerCase().trim(), "Exclusion works");
}
console.log("✔ Duplicate quote exclusion filter verified.");

// 2. Test QuoteClient
const qClientPath = path.join(__dirname, "../services/QuoteClient.js");
const qClientCode = fs.readFileSync(qClientPath, "utf-8").replace(".pragma library", "");
const qClientScope = {};
new Function(qClientCode + "\nthis.cleanQuoteText = cleanQuoteText; this.cleanQuoteAuthor = cleanQuoteAuthor; this.parseModelContent = parseModelContent;").call(qClientScope);

// Test author cleaning
assert.strictEqual(qClientScope.cleanQuoteAuthor("Marcus Aurelius"), "Marcus Aurelius");
assert.strictEqual(qClientScope.cleanQuoteAuthor("Bruce Lee. That's a quote about focus, but"), "Bruce Lee");
assert.strictEqual(qClientScope.cleanQuoteAuthor("Attributed to high-performance coaching circles"), "");
assert.strictEqual(qClientScope.cleanQuoteAuthor("Seneca, who was a Roman Stoic philosopher"), "Seneca");
console.log("✔ QuoteClient author sanitization verified.");

// Test parseModelContent
const rawContent1 = "\"The obstacle is the way.\" - Marcus Aurelius";
const parsed1 = qClientScope.parseModelContent(rawContent1);
assert.deepStrictEqual(parsed1, { text: "The obstacle is the way.", author: "Marcus Aurelius" });

const thinkContent = "<think>Analyzing user request...</think> \"Action cures fear.\" - David Schwartz";
const parsed2 = qClientScope.parseModelContent(thinkContent);
assert.deepStrictEqual(parsed2, { text: "Action cures fear.", author: "David Schwartz" });
console.log("✔ QuoteClient content parsing and think-tag removal verified.");

// 3. Test TickingStorage
const storagePath = path.join(__dirname, "../services/TickingStorage.js");
const storageCode = fs.readFileSync(storagePath, "utf-8").replace(".pragma library", "");
const storageScope = {};
new Function(storageCode + "\nthis.getStoragePath = getStoragePath; this.saveSettings = saveSettings; this.loadSettings = loadSettings; this.DEFAULT_CONFIG = DEFAULT_CONFIG;").call(storageScope);

const resolvedPath = storageScope.getStoragePath();
assert(resolvedPath.endsWith("/.config/omarchy/ticking-widget.json"), "Storage path ends with expected file name");
assert(!resolvedPath.includes("adi-IL"), "Storage path has no hardcoded username");

let executedCmd = "";
const fakeBar = {
    home: "/custom/home",
    run: function (cmd) {
        executedCmd = cmd;
    }
};
storageScope.saveSettings({ customTitle: "TEST" }, fakeBar);
assert(executedCmd.includes("/custom/home/.config/omarchy/ticking-widget.json"), "saveSettings respects bar.home");
console.log("✔ TickingStorage dynamic path and persistence verified.");

// 4. Test TickingState dynamic milestones & robust date parsing
const stateQmlPath = path.join(__dirname, "../TickingState.qml");
const stateQml = fs.readFileSync(stateQmlPath, "utf-8");

function extractFunction(src, name) {
    const fullSignatureMatch = src.match(new RegExp("function\\s+" + name + "\\s*\\(([^)]*)\\)\\s*\\{([\\s\\S]*?)\\n\\s{4}\\}"));
    if (!fullSignatureMatch) throw new Error("Could not find function " + name + " in TickingState.qml");
    return new Function(fullSignatureMatch[1], fullSignatureMatch[2]);
}

const parseHorizonDate = extractFunction(stateQml, "parseHorizonDate");
const defaultTargetDate = extractFunction(stateQml, "defaultTargetDate");
const defaultStartDate = extractFunction(stateQml, "defaultStartDate");

// Verify default config in TickingStorage has empty milestone dates
assert.strictEqual(storageScope.DEFAULT_CONFIG.targetTimestamp, "", "DEFAULT_CONFIG targetTimestamp is empty string");
assert.strictEqual(storageScope.DEFAULT_CONFIG.startTimestamp, "", "DEFAULT_CONFIG startTimestamp is empty string");

// Verify defaultTargetDate returns a future date
const targetDate = defaultTargetDate();
assert(targetDate instanceof Date, "defaultTargetDate returns Date instance");
assert(targetDate.getTime() > Date.now(), "default target date is in the future");
assert.strictEqual(targetDate.getMonth(), 11, "defaultTargetDate is in December");
assert.strictEqual(targetDate.getDate(), 31, "defaultTargetDate is on Dec 31");
assert.strictEqual(targetDate.getHours(), 23, "defaultTargetDate hour is 23");
assert.strictEqual(targetDate.getMinutes(), 59, "defaultTargetDate minute is 59");

// Verify defaultStartDate returns a date in the past or now
const startDate = defaultStartDate();
assert(startDate instanceof Date, "defaultStartDate returns Date instance");
assert(startDate.getTime() <= Date.now(), "default start date is in the past or now");
assert.strictEqual(startDate.getMonth(), 0, "defaultStartDate is in January");
assert.strictEqual(startDate.getDate(), 1, "defaultStartDate is on Jan 1");
assert.strictEqual(startDate.getHours(), 0, "defaultStartDate hour is 0");
assert.strictEqual(startDate.getMinutes(), 0, "defaultStartDate minute is 0");

// Verify 14-day threshold for defaultTargetDate rollover to next year
const RealDate = global.Date;
try {
    global.Date = class extends RealDate {
        constructor(...args) {
            if (args.length === 0) {
                super(2026, 11, 25, 12, 0, 0, 0); // Dec 25 (< 14 days left in year)
            } else {
                super(...args);
            }
        }
    };
    const rolledOverTarget = defaultTargetDate();
    assert.strictEqual(rolledOverTarget.getFullYear(), 2027, "Near year-end, default target rolls over to next year");
} finally {
    global.Date = RealDate;
}

// Verify date parsing: YYYY-MM-DD
const parsedCivil = parseHorizonDate("2027-06-15");
assert(parsedCivil instanceof Date, "parsedCivil is Date instance");
assert.strictEqual(parsedCivil.getFullYear(), 2027);
assert.strictEqual(parsedCivil.getMonth(), 5); // June
assert.strictEqual(parsedCivil.getDate(), 15);
assert.strictEqual(parsedCivil.getHours(), 0);
assert.strictEqual(parsedCivil.getMinutes(), 0);

// Verify date parsing: ISO strings
const parsedIsoLocal = parseHorizonDate("2027-06-15T18:45:30");
assert(parsedIsoLocal instanceof Date, "parsedIsoLocal is Date instance");
assert.strictEqual(parsedIsoLocal.getFullYear(), 2027);
assert.strictEqual(parsedIsoLocal.getMonth(), 5);
assert.strictEqual(parsedIsoLocal.getDate(), 15);
assert.strictEqual(parsedIsoLocal.getHours(), 18);
assert.strictEqual(parsedIsoLocal.getMinutes(), 45);
assert.strictEqual(parsedIsoLocal.getSeconds(), 30);

const parsedIsoUtc = parseHorizonDate("2027-06-15T18:45:30Z");
assert(parsedIsoUtc instanceof Date, "parsedIsoUtc is Date instance");
assert.strictEqual(parsedIsoUtc.toISOString(), "2027-06-15T18:45:30.000Z");

// Verify invalid date strings and null/empty handling
assert.strictEqual(parseHorizonDate("invalid-date-string"), null, "invalid date string returns null");
assert.strictEqual(parseHorizonDate(""), null, "empty string returns null");
assert.strictEqual(parseHorizonDate(null), null, "null returns null");
assert.strictEqual(parseHorizonDate(undefined), null, "undefined returns null");
console.log("✔ Dynamic milestone defaults and robust date parsing verified.");

// Verify setMilestone helper function
const mockScope = {
    targetTimestamp: "",
    startTimestamp: "",
    customTitle: "INITIAL TITLE",
    lastCountdownSec: 0,
    metricsUpdated: false,
    persisted: false,
    pad2: function(n) { return (n < 10 ? "0" : "") + n; },
    formatHorizonDate: function(d) {
        return d.getFullYear() + "-" + this.pad2(d.getMonth() + 1) + "-" + this.pad2(d.getDate());
    },
    updateAllMetrics: function() { this.metricsUpdated = true; },
    persistConfig: function() { this.persisted = true; }
};

const setMilestoneMatch = stateQml.match(/function\s+setMilestone\s*\([^)]*\)\s*\{([\s\S]*?)\n\s{4}\}/);
assert(setMilestoneMatch, "setMilestone exists in TickingState.qml");
const boundSetMilestone = new Function("scope", "return function(targetDateStr, startDateStr, title) { with(scope) { " + setMilestoneMatch[1] + " } }")(mockScope);

boundSetMilestone("2028-01-01", "2027-01-01", "MARS MISSION");
assert.strictEqual(mockScope.targetTimestamp, "2028-01-01");
assert.strictEqual(mockScope.startTimestamp, "2027-01-01");
assert.strictEqual(mockScope.customTitle, "MARS MISSION");
assert.strictEqual(mockScope.metricsUpdated, true);
assert.strictEqual(mockScope.persisted, true);

mockScope.metricsUpdated = false;
mockScope.persisted = false;
boundSetMilestone("2029-05-20");
assert.strictEqual(mockScope.targetTimestamp, "2029-05-20");
const expectedToday = mockScope.formatHorizonDate(new Date());
assert.strictEqual(mockScope.startTimestamp, expectedToday, "Empty start date defaults to today");
assert.strictEqual(mockScope.customTitle, "MARS MISSION", "Title is preserved when omitted");
assert.strictEqual(mockScope.metricsUpdated, true);
assert.strictEqual(mockScope.persisted, true);
console.log("✔ setMilestone helper function verified.");

// 5. Test Settings and Tab 3 Integration
const widgetQmlPath = path.join(__dirname, "../TickingWidget.qml");
const widgetQml = fs.readFileSync(widgetQmlPath, "utf-8");
const selectTabMatch = widgetQml.match(/function\s+selectTab\s*\([^)]*\)\s*:\s*void\s*\{([\s\S]*?)\n\s{8}\}/);
assert(selectTabMatch, "selectTab exists in TickingWidget.qml");
const mockWidgetState = {
    activeTab: 0,
    metricsUpdated: false,
    updateAllMetrics: function() { this.metricsUpdated = true; }
};
const boundSelectTab = new Function("stateEngine", "idx", selectTabMatch[1]);
boundSelectTab(mockWidgetState, 3);
assert.strictEqual(mockWidgetState.activeTab, 3, "selectTab allows tab 3 for settings");
assert.strictEqual(mockWidgetState.metricsUpdated, true, "selectTab triggers updateAllMetrics");

mockWidgetState.metricsUpdated = false;
boundSelectTab(mockWidgetState, 5); // out-of-bounds
assert.strictEqual(mockWidgetState.activeTab, 3, "out-of-bounds tab is rejected");
assert.strictEqual(mockWidgetState.metricsUpdated, false, "out-of-bounds does not update metrics");

const settingsQmlPath = path.join(__dirname, "../components/SettingsView.qml");
assert(fs.existsSync(settingsQmlPath), "components/SettingsView.qml exists");
const settingsQml = fs.readFileSync(settingsQmlPath, "utf-8");
assert(settingsQml.includes("closeSettingsRequested"), "SettingsView defines closeSettingsRequested signal");
assert(settingsQml.includes("+30d") && settingsQml.includes("+90d") && settingsQml.includes("Year End"), "SettingsView includes quick preset buttons");
assert(settingsQml.includes("showMilliseconds") && settingsQml.includes("showProgress") && settingsQml.includes("showPanelBadge") && settingsQml.includes("showQuoteBar") && settingsQml.includes("hourFormat24"), "SettingsView includes all 5 required display toggles");
assert(settingsQml.includes("#00E599") && settingsQml.includes("#38BDF8") && settingsQml.includes("#A855F7") && settingsQml.includes("#F59E0B") && settingsQml.includes("#F43F5E") && settingsQml.includes("#EDEDED"), "SettingsView includes all 6 accent color swatches");
console.log("✔ Settings View and Tab 3 IPC Integration verified.");

console.log("=== All Service Tests Passed Successfully ===");
