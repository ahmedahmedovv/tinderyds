# Tinder YDS - Native iOS App

A native iPhone app for YDS (Yabancı Dil Sınavı) vocabulary learning, converted from the original web app to a full SwiftUI native application.

## Features

- 🎯 **Tinder-like Interface**: Swipe right for words you know, left for words you don't
- 🔥 **Daily Streak System**: Track your daily learning progress with a streak counter
- 📊 **Spaced Repetition**: 7-level algorithm for optimal long-term retention
- 📚 **1,264 Academic Words**: Comprehensive YDS vocabulary database
- 🤖 **AI-Powered Content**: Dynamic definitions and examples using Mistral AI
- 📱 **Native iOS UI**: Smooth, responsive interface built with SwiftUI
- 💾 **Offline Support**: CoreData persistence with cached word content

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Mistral AI API key

## Setup

1. Open `TinderYDS.xcodeproj` in Xcode
2. Build and run on iPhone simulator or device
3. On first launch, go to Settings and add your Mistral AI API key

## Architecture

```
TinderYDS/
├── Models/
│   ├── Word.swift          # SwiftData model for vocabulary words
│   ├── Streak.swift        # Daily streak tracking
│   └── CardState.swift     # UI state management
├── Views/
│   ├── ContentView.swift   # Main app container
│   ├── FlashcardView.swift # Individual flashcard UI
│   ├── CardStackView.swift # Swipe gesture handling
│   ├── HeaderView.swift    # Streak and progress header
│   ├── WordListView.swift  # All words list with search
│   ├── SettingsView.swift  # App settings
│   └── CelebrationView.swift # Goal achievement animation
├── ViewModels/
│   ├── WordViewModel.swift # Word management logic
│   └── StreakViewModel.swift # Streak tracking logic
├── Services/
│   ├── MistralService.swift # API integration
│   └── VocabularyData.swift # 1,264 word dataset
└── TinderYDSApp.swift      # App entry point
```

## Data Persistence

- **SwiftData**: Used for word progress and streak data
- **UserDefaults**: Used for API key and preferences
- **Offline Caching**: Word content is cached for 30 days

## Spaced Repetition Intervals

| Level | Interval |
|-------|----------|
| 0 | Immediate |
| 1 | 1 day |
| 2 | 3 days |
| 3 | 7 days |
| 4 | 14 days |
| 5 | 30 days |
| 6 | 60 days |
| 7+ | 120 days (Mastered) |

## License

Same as original project.
