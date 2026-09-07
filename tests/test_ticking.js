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

console.log("=== All Service Tests Passed Successfully ===");
