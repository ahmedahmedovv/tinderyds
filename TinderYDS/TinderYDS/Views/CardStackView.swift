import SwiftUI

struct CardStackView: View {
    @ObservedObject var viewModel: WordViewModel
    
    // Gesture state
    @State private var dragOffset: CGSize = .zero
    @State private var dragPredictedOffset: CGSize = .zero
    
    // Card swipe threshold
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#f4ecd8")
                .ignoresSafeArea()
            
            if viewModel.showNoWordsDue {
                NoWordsView()
            } else if viewModel.sessionComplete {
                SessionCompleteView(wordsStudied: viewModel.wordsStudiedThisSession)
            } else if let word = viewModel.currentCard {
                // Next card (background)
                if viewModel.currentIndex + 1 < viewModel.dueWords.count {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#e8dcc8"))
                        .frame(maxWidth: 340, maxHeight: 460)
                        .offset(y: 10)
                        .opacity(0.7)
                }
                
                // Current card
                FlashcardView(
                    word: word,
                    status: viewModel.cardStatus,
                    dragState: viewModel.dragState
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring()) {
                                viewModel.dragState.translation = value.translation
                                viewModel.dragState.predictedTranslation = value.predictedEndTranslation
                            }
                        }
                        .onEnded { value in
                            handleDragEnd(value: value)
                        }
                )
                .onAppear {
                    viewModel.prefetchNextCard()
                }
                
                // Action buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 60) {
                        // Don't Know button
                        ActionButton(
                            icon: "xmark",
                            color: .red,
                            action: { viewModel.handleSwipe(direction: .left) }
                        )
                        
                        // Know button
                        ActionButton(
                            icon: "checkmark",
                            color: .green,
                            action: { viewModel.handleSwipe(direction: .right) }
                        )
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func handleDragEnd(value: DragGesture.Value) {
        let translation = value.translation.width
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if translation > swipeThreshold {
                // Swiped right - Know
                viewModel.dragState.translation = CGSize(width: 500, height: value.translation.height)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.handleSwipe(direction: .right)
                }
            } else if translation < -swipeThreshold {
                // Swiped left - Don't Know
                viewModel.dragState.translation = CGSize(width: -500, height: value.translation.height)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.handleSwipe(direction: .left)
                }
            } else {
                // Return to center
                viewModel.dragState = DragState()
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 70, height: 70)
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
}

struct NoWordsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#4CAF50"))
            
            Text("All Caught Up!")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#5c4a32"))
            
            Text("No words are due for review right now. Great job keeping up with your studies!")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#7b6a52"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Text("Come back later for more words to review.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#9b8a72"))
                .padding(.top, 8)
        }
        .padding()
    }
}

struct SessionCompleteView: View {
    let wordsStudied: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FFD700"))
            
            Text("Session Complete!")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "#5c4a32"))
            
            Text("You reviewed \(wordsStudied) word\(wordsStudied == 1 ? "" : "s") in this session.")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#7b6a52"))
                .multilineTextAlignment(.center)
            
            Text("Keep up the great work!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#6b5a42"))
                .padding(.top, 8)
        }
        .padding()
    }
}
