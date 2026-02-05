import Foundation
import SwiftData

@Model
class Streak {
    var currentStreak: Int
    var lastStudyDate: Date?
    var wordsStudiedToday: Int
    var dailyGoal: Int
    var totalWordsStudied: Int
    var bestStreak: Int
    
    init() {
        self.currentStreak = 0
        self.wordsStudiedToday = 0
        self.dailyGoal = 10
        self.totalWordsStudied = 0
        self.bestStreak = 0
    }
    
    var isGoalMet: Bool {
        return wordsStudiedToday >= dailyGoal
    }
    
    var progressPercentage: Double {
        return min(Double(wordsStudiedToday) / Double(dailyGoal), 1.0)
    }
    
    func recordStudySession() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if this is a new day
        if let lastDate = lastStudyDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysSinceLastStudy = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysSinceLastStudy == 1 {
                // Continued streak
                currentStreak += 1
            } else if daysSinceLastStudy > 1 {
                // Streak broken
                if currentStreak > bestStreak {
                    bestStreak = currentStreak
                }
                currentStreak = 1
            }
            // If same day, don't change streak
        } else {
            // First time studying
            currentStreak = 1
        }
        
        // Reset daily count if new day
        if lastStudyDate == nil || !calendar.isDate(lastStudyDate!, inSameDayAs: Date()) {
            wordsStudiedToday = 0
        }
        
        wordsStudiedToday += 1
        totalWordsStudied += 1
        lastStudyDate = Date()
    }
    
    func checkAndResetDaily() {
        let calendar = Calendar.current
        if let lastDate = lastStudyDate,
           !calendar.isDate(lastDate, inSameDayAs: Date()) {
            wordsStudiedToday = 0
        }
    }
}
