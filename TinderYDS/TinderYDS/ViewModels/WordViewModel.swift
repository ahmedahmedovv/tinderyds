import Foundation
import SwiftData
import Combine

@MainActor
class WordViewModel: ObservableObject {
    @Published var currentCard: Word?
    @Published var cardStatus: CardStatus = .loading
    @Published var dragState = DragState()
    @Published var isLoading = false
    @Published var showNoWordsDue = false
    @Published var sessionComplete = false
    @Published var wordsStudiedThisSession = 0
    
    private let modelContext: ModelContext
    private var words: [Word] = []
    private var dueWords: [Word] = []
    private var currentIndex = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadWords()
    }
    
    func loadWords() {
        // Fetch all words
        let descriptor = FetchDescriptor<Word>(sortBy: [SortDescriptor(\.text)])
        if let fetched = try? modelContext.fetch(descriptor) {
            words = fetched
            
            // If no words exist, create them from vocabulary list
            if words.isEmpty {
                createInitialWords()
            }
        }
        
        updateDueWords()
    }
    
    private func createInitialWords() {
        for wordText in VocabularyData.words {
            let word = Word(text: wordText)
            modelContext.insert(word)
        }
        try? modelContext.save()
        
        // Reload
        let descriptor = FetchDescriptor<Word>(sortBy: [SortDescriptor(\.text)])
        if let fetched = try? modelContext.fetch(descriptor) {
            words = fetched
        }
    }
    
    func updateDueWords() {
        dueWords = words.filter { $0.isDue }
            .shuffled()
            .prefix(20)
            .map { $0 }
        
        currentIndex = 0
        sessionComplete = false
        
        if dueWords.isEmpty {
            showNoWordsDue = true
            currentCard = nil
        } else {
            showNoWordsDue = false
            currentCard = dueWords.first
            loadCardContent()
        }
    }
    
    func loadCardContent() {
        guard let word = currentCard else { return }
        
        // Check if we have cached content and it's recent (less than 30 days old)
        if let cached = word.cachedAt,
           Date().timeIntervalSince(cached) < 30 * 24 * 60 * 60,
           let def = word.definition,
           let ex1 = word.example1,
           let ex2 = word.example2 {
            cardStatus = .loaded(WordContent(definition: def, example1: ex1, example2: ex2))
            return
        }
        
        cardStatus = .loading
        
        Task {
            do {
                let content = try await MistralService.shared.fetchWordContent(for: word.text)
                
                // Cache the content
                word.definition = content.definition
                word.example1 = content.example1
                word.example2 = content.example2
                word.cachedAt = Date()
                try? modelContext.save()
                
                await MainActor.run {
                    cardStatus = .loaded(content)
                }
            } catch {
                await MainActor.run {
                    cardStatus = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func handleSwipe(direction: SwipeDirection) {
        guard let word = currentCard else { return }
        
        // Record the answer
        switch direction {
        case .right:
            word.markAsKnown()
        case .left:
            word.markAsUnknown()
        case .none:
            return
        }
        
        try? modelContext.save()
        wordsStudiedThisSession += 1
        
        // Move to next card
        currentIndex += 1
        
        if currentIndex >= dueWords.count {
            sessionComplete = true
            currentCard = nil
        } else {
            currentCard = dueWords[currentIndex]
            loadCardContent()
        }
        
        // Reset drag state
        dragState = DragState()
    }
    
    func prefetchNextCard() {
        let nextIndex = currentIndex + 1
        guard nextIndex < dueWords.count else { return }
        
        let nextWord = dueWords[nextIndex]
        
        // If already cached, skip
        if nextWord.cachedAt != nil { return }
        
        Task {
            do {
                let content = try await MistralService.shared.fetchWordContent(for: nextWord.text)
                nextWord.definition = content.definition
                nextWord.example1 = content.example1
                nextWord.example2 = content.example2
                nextWord.cachedAt = Date()
                try? modelContext.save()
            } catch {
                // Silent fail for prefetch
            }
        }
    }
    
    func skipCard() {
        handleSwipe(direction: .left)
    }
    
    func getTotalWordCount() -> Int {
        return words.count
    }
    
    func getLearnedWordCount() -> Int {
        return words.filter { $0.isLearned }.count
    }
    
    func getDueWordCount() -> Int {
        return words.filter { $0.isDue }.count
    }
}
