import SwiftUI

struct FlashcardView: View {
    let word: Word
    let status: CardStatus
    let dragState: DragState
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#f4ecd8"))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Content
            VStack(spacing: 20) {
                switch status {
                case .loading:
                    LoadingView()
                case .loaded(let content):
                    LoadedCardView(word: word.text, content: content)
                case .error(let message):
                    ErrorView(message: message, word: word.text)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: 360, maxHeight: 480)
        .rotationEffect(.degrees(dragState.rotation))
        .offset(x: dragState.translation.width, y: dragState.translation.height)
        .opacity(dragState.opacity)
        .overlay(
            // Swipe indicators
            SwipeIndicators(dragState: dragState)
        )
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color(hex: "#5c4a32"))
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(Color(hex: "#8b7355"))
        }
    }
}

struct LoadedCardView: View {
    let word: String
    let content: WordContent
    
    var body: some View {
        VStack(spacing: 24) {
            // Word
            Text(word.capitalized)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#5c4a32"))
                .multilineTextAlignment(.center)
            
            Divider()
                .background(Color(hex: "#d4c4a8"))
            
            // Definition
            Text(content.definition)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(hex: "#6b5a42"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Divider()
                .background(Color(hex: "#d4c4a8"))
            
            // Examples
            VStack(alignment: .leading, spacing: 12) {
                Text(content.example1)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#7b6a52"))
                    .italic()
                    .lineSpacing(3)
                
                Text(content.example2)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "#7b6a52"))
                    .italic()
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ErrorView: View {
    let message: String
    let word: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text(word.capitalized)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#5c4a32"))
            
            Text("Failed to load content")
                .font(.headline)
                .foregroundColor(Color(hex: "#8b7355"))
            
            Text(message)
                .font(.caption)
                .foregroundColor(Color(hex: "#9b8a72"))
                .multilineTextAlignment(.center)
        }
    }
}

struct SwipeIndicators: View {
    let dragState: DragState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Know indicator (right)
                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .opacity(min(max(dragState.translation.width / 100, 0), 1))
                        
                        Text("KNOW")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.green)
                            .opacity(min(max(dragState.translation.width / 100, 0), 1))
                        
                        Spacer()
                    }
                    .padding(.trailing, 20)
                }
                
                // Don't know indicator (left)
                HStack {
                    VStack {
                        Spacer()
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                            .opacity(min(max(-dragState.translation.width / 100, 0), 1))
                        
                        Text("DON'T")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                            .opacity(min(max(-dragState.translation.width / 100, 0), 1))
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
