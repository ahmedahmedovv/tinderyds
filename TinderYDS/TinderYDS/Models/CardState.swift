import Foundation

enum SwipeDirection {
    case left, right, none
}

enum CardStatus {
    case loading
    case loaded(WordContent)
    case error(String)
}

struct DragState {
    var translation: CGSize = .zero
    var predictedTranslation: CGSize = .zero
    
    var swipeDirection: SwipeDirection {
        if translation.width > 50 {
            return .right
        } else if translation.width < -50 {
            return .left
        }
        return .none
    }
    
    var rotation: Double {
        Double(translation.width) / 20.0
    }
    
    var opacity: Double {
        let progress = min(abs(translation.width) / 100.0, 1.0)
        return 1.0 - (progress * 0.3)
    }
}
