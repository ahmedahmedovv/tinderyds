import Foundation
import SwiftData

@MainActor
class StreakViewModel: ObservableObject {
    @Published var streak: Streak
    @Published var showCelebration = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.streak = Streak()
        loadStreak()
    }
    
    private func loadStreak() {
        let descriptor = FetchDescriptor<Streak>()
        if let fetched = try? modelContext.fetch(descriptor), let first = fetched.first {
            streak = first
        } else {
            // Create new streak
            streak = Streak()
            modelContext.insert(streak)
            try? modelContext.save()
        }
        
        // Check for daily reset
        streak.checkAndResetDaily()
    }
    
    func recordWordStudied() {
        let wasGoalMet = streak.isGoalMet
        streak.recordStudySession()
        try? modelContext.save()
        
        // Show celebration if goal was just met
        if !wasGoalMet && streak.isGoalMet {
            showCelebration = true
        }
    }
    
    func getProgressColor() -> String {
        if streak.isGoalMet {
            return "#4CAF50" // Green
        } else {
            return "#FF9800" // Orange
        }
    }
    
    func getMotivationalMessage() -> String {
        let remaining = streak.dailyGoal - streak.wordsStudiedToday
        
        if streak.isGoalMet {
            let messages = [
                "Goal achieved! Keep the momentum! 🔥",
                "Amazing work today! 🎉",
                "You're crushing it! 💪",
                "Daily goal complete! 🌟"
            ]
            return messages.randomElement()!
        } else if remaining <= 3 {
            return "Almost there! Just \(remaining) more word\(remaining == 1 ? "" : "s")!"
        } else {
            return "\(streak.wordsStudiedToday)/\(streak.dailyGoal) words today"
        }
    }
    
    func getStreakMessage() -> String {
        if streak.currentStreak == 0 {
            return "Start your streak today!"
        } else if streak.currentStreak == 1 {
            return "🔥 1 day streak"
        } else {
            return "🔥 \(streak.currentStreak) day streak"
        }
    }
}
