# Tinder YDS - AI Coding Agent Guide

## Project Overview

**Tinder YDS** is a vocabulary learning flashcard application designed for Turkish students preparing for the YDS (Yabancı Dil Sınavı - Foreign Language Exam). It uses a Tinder-like swipe interface where users swipe right to mark a word as "known" and left to mark it as "not known".

Key characteristics:
- **Pure frontend application**: No backend server, runs entirely in the browser
- **Mobile-first design**: Optimized for iPhone and mobile devices with PWA support
- **AI-powered content**: Uses Mistral AI API to generate definitions and example sentences
- **Spaced repetition**: Implements a 7-level spaced repetition system for effective learning
- **Gamification**: Features a daily streak system (10 words/day goal)

## File Structure

```
/
├── index.html          # Main application (~2400 lines, contains HTML, CSS, and JS)
├── mywords.js          # Vocabulary list (1264 English words/phrases)
├── linkingwords.js     # Academic linking words for example sentences
├── README.md           # Project name only
└── AGENTS.md           # This file
```

**Note**: This project intentionally uses a simple structure with minimal files. All CSS and JavaScript are embedded in `index.html` except for the word list and linking words which are in separate JS files for maintainability.

## Technology Stack

- **HTML5**: Semantic markup with mobile viewport configuration
- **CSS3**: 
  - Vanilla CSS with CSS variables for colors
  - Responsive design with `clamp()` for fluid typography
  - CSS animations and transitions
  - iOS-specific optimizations (safe areas, tap highlight removal)
- **JavaScript (ES6+)**:
  - ES6 Classes for state management
  - Async/await for API calls
  - LocalStorage for data persistence
  - Touch and mouse event handlers for swipe gestures
- **External APIs**:
  - Mistral AI API (`mistral-large-latest` model) for content generation
- **PWA Features**:
  - Apple mobile web app meta tags
  - Touch icons
  - Theme colors

## Code Organization

### Main Classes (in `index.html`)

1. **`StreakManager`** (lines 1566-1660)
   - Manages daily streak system
   - Tracks words reviewed per day
   - Handles streak reset logic when user misses a day
   - Stores data in LocalStorage (`streakData` key)

2. **`SpacedRepetition`** (lines 1663-1740)
   - Implements spaced repetition algorithm with 7 levels
   - Intervals: `[1, 3, 7, 14, 30, 60, 120]` days
   - Tracks word progress (level, next review date, correct/incorrect counts)
   - Stores data in LocalStorage (`wordProgress` key)

### Key Functions

- **`fetchWordData(word)`**: Fetches definition and examples from Mistral AI
- **`renderCard()`**: Renders the current flashcard with loading states
- **`handleKnow()` / `handleDontKnow()`**: Process user swipe actions
- **`enableSwipe()`**: Sets up touch/mouse event listeners for swipe gestures
- **`prefetchUpcomingCards()`**: Background prefetching for smooth UX

### Data Sources

- **`MYWORDS`**: Array of 1264 vocabulary words (duplicated in `index.html` lines 1352-1559 and `mywords.js`)
- **`LINKING_WORDS`**: Object with academic linking words by category (in `linkingwords.js`)

## Build and Deployment

### No Build Process

This project has **no build tools** (no webpack, vite, parcel, etc.). Files are served statically.

### Local Development

Simply open `index.html` in a browser, or serve with any static file server:

```bash
# Using Python
python -m http.server 8000

# Using Node.js (npx serve)
npx serve .

# Using PHP
php -S localhost:8000
```

### Deployment

Deploy as a static site to any hosting platform:
- GitHub Pages
- Netlify
- Vercel
- Any web server (nginx, Apache)

## Key Features Implementation

### Spaced Repetition Algorithm

```javascript
// Intervals in days for each level
const intervals = [1, 3, 7, 14, 30, 60, 120];

// Level progression:
// Level 0: New word (immediate review)
// Level 1: Review after 1 day
// Level 2: Review after 3 days
// ...
// Level 4+: Considered "learned"
```

- When user marks "Know": level increases, next review scheduled based on new level
- When user marks "Don't Know": level decreases, next review in 10 minutes

### Daily Streak System

- Goal: Review at least 10 words per day
- Both correct and incorrect answers count toward the goal
- Streak resets if user misses a day
- Progress bar shows daily progress (orange = in progress, green = goal met)

### OpenAI Integration

The app generates dynamic content for each word using OpenAI's Responses API:

```javascript
const OPENAI_API_KEY = '...'; // Stored in Netlify Environment Variables
const OPENAI_API_URL = '/api/mistral'; // Proxied through Netlify Function
```

Model: `gpt-5-nano`

Prompt asks for:
- Brief academic definition (max 20 words)
- One academic example sentence using both the target word and a linking word
- Response in JSON format

## Code Style Guidelines

### CSS

- Use semantic color names (e.g., `#f4ecd8` - background, `#5c4a32` - text)
- Mobile-first responsive design with `clamp()` for fluid sizing
- Use CSS variables sparingly (currently mostly hardcoded)
- Include iOS-specific optimizations (`env(safe-area-inset-*)`)

### JavaScript

- Use ES6+ features (const/let, arrow functions, classes, async/await)
- Class names use PascalCase
- Function and variable names use camelCase
- Global constants use UPPER_SNAKE_CASE
- Prefer `const` over `let`, avoid `var`

### HTML

- Semantic HTML5 elements
- SVG icons inline (no external dependencies)
- Mobile viewport meta tags required

## Testing

No automated tests are currently implemented. Manual testing checklist:

1. **Swipe functionality**: Test touch swipe on mobile, mouse drag on desktop
2. **Keyboard shortcuts**: Left/right arrow keys
3. **Streak system**: Review 10+ words, verify streak increments
4. **Modal functionality**: Info and Word List modals open/close correctly
5. **Word List features**: Search, filter tabs, scroll behavior
6. **Empty states**: No words due, session complete
7. **Responsive design**: Test on various screen sizes (iPhone, tablet, desktop)

## Security Considerations

✅ **SECURED**: The OpenAI API key is stored securely in Netlify Environment Variables and accessed through a Netlify Function proxy.

**Implementation**:
- API key is stored in Netlify dashboard (Site settings → Environment variables)
- Frontend calls `/api/mistral` which proxies to `netlify/functions/mistral-proxy.js`
- The function injects the API key server-side, keeping it hidden from clients

**Setup Required**:
1. Go to Netlify dashboard → Site settings → Environment variables
2. Add variable: `OPENAI_API_KEY` with your OpenAI API key value
3. Remove the old `MISTRAL_API_KEY` if it exists
4. Redeploy the site

## Data Persistence

User data is stored in browser LocalStorage:

| Key | Data |
|-----|------|
| `wordProgress` | Spaced repetition data for each word |
| `streakData` | Daily streak information |

**No data backup/sync**: Data is device-specific and will be lost if user clears browser data.

## Known Limitations

1. **No offline support**: Requires internet connection for OpenAI API
2. **API rate limits**: Subject to Mistral AI rate limiting
3. **Single device**: No cloud sync between devices
4. ~~**Hardcoded API key**~~: ✅ Fixed - Now uses Netlify Functions
5. **Single vocabulary list**: No user-created word lists
6. **No audio**: No pronunciation audio

## Future Enhancement Ideas

- ~~Backend proxy for API calls~~ ✅ Done - Using Netlify Functions
- ~~Switch from Mistral to OpenAI~~ ✅ Done - Now using GPT-5-nano via Responses API
- User accounts and cloud sync
- Offline mode with service worker
- Additional vocabulary sets
- Pronunciation audio (Web Speech API)
- Statistics and progress charts
- Dark mode

## Language and Locale

- **UI Language**: English
- **Target Users**: Turkish students (YDS exam prep)
- **Vocabulary**: Academic English words and phrases
- **Comments**: English

---

Last updated: 2026-02-04
