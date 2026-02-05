import SwiftUI

struct HeaderView: View {
    @ObservedObject var streakViewModel: StreakViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row - Title and Streak
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tinder YDS")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "#5c4a32"))
                    
                    Text("Vocabulary Learning")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#8b7355"))
                }
                
                Spacer()
                
                // Streak badge
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.orange)
                    
                    Text("\(streakViewModel.streak.currentStreak)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#5c4a32"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(hex: "#e8dcc8"))
                )
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(streakViewModel.getMotivationalMessage())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#6b5a42"))
                    
                    Spacer()
                    
                    Text("\(streakViewModel.streak.wordsStudiedToday)/\(streakViewModel.streak.dailyGoal)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(streakViewModel.streak.isGoalMet ? Color(hex: "#4CAF50") : Color(hex: "#FF9800"))
                }
                
                // Progress bar background
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(hex: "#e0d4c0"))
                            .frame(height: 10)
                            .cornerRadius(5)
                        
                        Rectangle()
                            .fill(streakViewModel.streak.isGoalMet ? Color(hex: "#4CAF50") : Color(hex: "#FF9800"))
                            .frame(width: geometry.size.width * CGFloat(streakViewModel.streak.progressPercentage), height: 10)
                            .cornerRadius(5)
                            .animation(.easeInOut(duration: 0.3), value: streakViewModel.streak.progressPercentage)
                    }
                }
                .frame(height: 10)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(
            Color(hex: "#f4ecd8")
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
