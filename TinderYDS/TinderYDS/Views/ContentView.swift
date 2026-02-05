import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var wordViewModel: WordViewModel
    @StateObject private var streakViewModel: StreakViewModel
    
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showInfo = false
    
    init(modelContext: ModelContext) {
        let wordVM = WordViewModel(modelContext: modelContext)
        let streakVM = StreakViewModel(modelContext: modelContext)
        _wordViewModel = StateObject(wrappedValue: wordVM)
        _streakViewModel = StateObject(wrappedValue: streakVM)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Study Tab
            StudyTabView(
                wordViewModel: wordViewModel,
                streakViewModel: streakViewModel
            )
            .tabItem {
                Image(systemName: "rectangle.stack.fill")
                Text("Study")
            }
            .tag(0)
            
            // Word List Tab
            WordListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Words")
                }
                .tag(1)
            
            // Stats Tab
            StatsView(wordViewModel: wordViewModel, streakViewModel: streakViewModel)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(2)
        }
        .tint(Color(hex: "#5c4a32"))
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
        .onChange(of: wordViewModel.wordsStudiedThisSession) { _, newCount in
            if newCount > 0 {
                streakViewModel.recordWordStudied()
            }
        }
    }
}

struct StudyTabView: View {
    @ObservedObject var wordViewModel: WordViewModel
    @ObservedObject var streakViewModel: StreakViewModel
    @State private var showSettings = false
    @State private var showInfo = false
    
    var body: some View {
        ZStack {
            Color(hex: "#f4ecd8")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HeaderView(streakViewModel: streakViewModel)
                
                // Card stack
                CardStackView(viewModel: wordViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color(hex: "#5c4a32"))
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(Color(hex: "#5c4a32"))
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
        .overlay {
            if streakViewModel.showCelebration {
                CelebrationView(isPresented: $streakViewModel.showCelebration)
            }
        }
    }
}

struct StatsView: View {
    @ObservedObject var wordViewModel: WordViewModel
    @ObservedObject var streakViewModel: StreakViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#f4ecd8")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Streak Card
                        StatCard(
                            title: "Current Streak",
                            value: "\(streakViewModel.streak.currentStreak)",
                            subtitle: "days",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        // Best Streak Card
                        StatCard(
                            title: "Best Streak",
                            value: "\(streakViewModel.streak.bestStreak)",
                            subtitle: "days",
                            icon: "trophy.fill",
                            color: .yellow
                        )
                        
                        // Total Words Card
                        StatCard(
                            title: "Total Words",
                            value: "\(wordViewModel.getTotalWordCount())",
                            subtitle: "in vocabulary",
                            icon: "book.fill",
                            color: .blue
                        )
                        
                        // Learned Words Card
                        StatCard(
                            title: "Words Learned",
                            value: "\(wordViewModel.getLearnedWordCount())",
                            subtitle: "mastered",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                        
                        // Due Words Card
                        StatCard(
                            title: "Due for Review",
                            value: "\(wordViewModel.getDueWordCount())",
                            subtitle: "words",
                            icon: "clock.fill",
                            color: .purple
                        )
                        
                        // Total Studied Card
                        StatCard(
                            title: "Total Studied",
                            value: "\(streakViewModel.streak.totalWordsStudied)",
                            subtitle: "all time",
                            icon: "graduationcap.fill",
                            color: Color(hex: "#5c4a32")
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#8b7355"))
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#5c4a32"))
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#7b6a52"))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.6))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
