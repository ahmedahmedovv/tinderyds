// Academic Linking Words for Example Sentences
// Used by Tinder YDS app to generate connected example sentences

const LINKING_WORDS = {
    addition: [
        "furthermore",
        "moreover",
        "in addition",
        "additionally",
        "also",
        "besides",
        "likewise",
        "similarly"
    ],
    contrast: [
        "however",
        "nevertheless",
        "nonetheless",
        "conversely",
        "on the other hand",
        "in contrast",
        "although",
        "despite",
        "whereas",
        "while"
    ],
    causeEffect: [
        "therefore",
        "consequently",
        "as a result",
        "thus",
        "hence",
        "accordingly",
        "because",
        "since",
        "due to",
        "leading to"
    ],
    example: [
        "for example",
        "for instance",
        "specifically",
        "in particular",
        "notably",
        "such as",
        "namely"
    ],
    sequence: [
        "subsequently",
        "eventually",
        "previously",
        "thereafter",
        "meanwhile",
        "simultaneously",
        "initially",
        "finally"
    ],
    emphasis: [
        "indeed",
        "in fact",
        "particularly",
        "especially",
        "significantly",
        "importantly"
    ],
    condition: [
        "although",
        "even though",
        "unless",
        "provided that",
        "given that"
    ],
    conclusion: [
        "in conclusion",
        "to summarize",
        "overall",
        "ultimately"
    ]
};

// Helper function to format linking words for AI prompt
function getLinkingWordsPrompt() {
    return Object.entries(LINKING_WORDS)
        .map(([category, words]) => {
            const shortName = category
                .replace(/([A-Z])/g, '/$1')
                .toLowerCase();
            return `${shortName}: ${words.slice(0, 5).join(", ")}`;
        })
        .join("; ");
}

// Get a random linking word from all categories
function getRandomLinkingWord() {
    const allWords = Object.values(LINKING_WORDS).flat();
    return allWords[Math.floor(Math.random() * allWords.length)];
}

// Get a random linking word from a specific category
function getRandomLinkingWordFromCategory(category) {
    const words = LINKING_WORDS[category];
    if (!words) return getRandomLinkingWord();
    return words[Math.floor(Math.random() * words.length)];
}

// Suggest a linking word for the AI to use (for variety)
function suggestLinkingWord() {
    const categories = Object.keys(LINKING_WORDS);
    const randomCategory = categories[Math.floor(Math.random() * categories.length)];
    return getRandomLinkingWordFromCategory(randomCategory);
}

// Export for use in other files if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { LINKING_WORDS, getLinkingWordsPrompt };
}
