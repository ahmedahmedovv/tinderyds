import Foundation
import SwiftData

@Model
class Word {
    @Attribute(.unique) var text: String
    var level: Int
    var nextReviewDate: Date
    var correctCount: Int
    var incorrectCount: Int
    var isLearned: Bool
    var addedDate: Date
    var lastReviewedDate: Date?
    
    // Cached content from API
    var definition: String?
    var example1: String?
    var example2: String?
    var cachedAt: Date?
    
    init(text: String) {
        self.text = text
        self.level = 0
        self.nextReviewDate = Date()
        self.correctCount = 0
        self.incorrectCount = 0
        self.isLearned = false
        self.addedDate = Date()
    }
    
    // Spaced repetition intervals in days
    static let intervals = [1, 3, 7, 14, 30, 60, 120]
    
    func markAsKnown() {
        level = min(level + 1, 6)
        correctCount += 1
        scheduleNextReview()
        isLearned = level >= 4
        lastReviewedDate = Date()
    }
    
    func markAsUnknown() {
        level = max(level - 1, 0)
        incorrectCount += 1
        // Review again in 10 minutes
        nextReviewDate = Date().addingTimeInterval(10 * 60)
        isLearned = false
        lastReviewedDate = Date()
    }
    
    private func scheduleNextReview() {
        let intervalDays = Word.intervals[min(level, Word.intervals.count - 1)]
        nextReviewDate = Calendar.current.date(byAdding: .day, value: intervalDays, to: Date()) ?? Date()
    }
    
    var isDue: Bool {
        return nextReviewDate <= Date()
    }
}

// For API responses
struct WordContent: Codable {
    let definition: String
    let example1: String
    let example2: String
}
