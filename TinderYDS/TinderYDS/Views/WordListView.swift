import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.text) private var words: [Word]
    
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case due = "Due"
        case learned = "Learned"
        case new = "New"
    }
    
    var filteredWords: [Word] {
        var result = words
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .due:
            result = result.filter { $0.isDue }
        case .learned:
            result = result.filter { $0.isLearned }
        case .new:
            result = result.filter { $0.level == 0 }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#f4ecd8")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "#8b7355"))
                        
                        TextField("Search words...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(hex: "#8b7355"))
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.6))
                    )
                    .padding()
                    
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(FilterOption.allCases, id: \.self) { option in
                                FilterTab(
                                    title: option.rawValue,
                                    count: getCount(for: option),
                                    isSelected: selectedFilter == option
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedFilter = option
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Word list
                    List {
                        Section(header: Text("\(filteredWords.count) Words")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#8b7355"))
                        ) {
                            ForEach(filteredWords) { word in
                                WordListRow(word: word)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationTitle("Word List")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func getCount(for option: FilterOption) -> Int {
        switch option {
        case .all:
            return words.count
        case .due:
            return words.filter { $0.isDue }.count
        case .learned:
            return words.filter { $0.isLearned }.count
        case .new:
            return words.filter { $0.level == 0 }.count
        }
    }
}

struct FilterTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color(hex: "#e0d4c0"))
                    )
            }
            .foregroundColor(isSelected ? .white : Color(hex: "#5c4a32"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "#5c4a32") : Color(hex: "#e8dcc8"))
            )
        }
    }
}

struct WordListRow: View {
    let word: Word
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.text.capitalized)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#5c4a32"))
                
                HStack(spacing: 8) {
                    LevelBadge(level: word.level)
                    
                    if word.isLearned {
                        Text("Learned")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    if word.isDue {
                        Text("Due")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("\(word.correctCount)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#6b5a42"))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("\(word.incorrectCount)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#6b5a42"))
                }
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.4))
        )
    }
}

struct LevelBadge: View {
    let level: Int
    
    var color: Color {
        switch level {
        case 0: return .gray
        case 1: return Color(hex: "#8BC34A")
        case 2: return Color(hex: "#4CAF50")
        case 3: return Color(hex: "#009688")
        case 4...6: return Color(hex: "#3F51B5")
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<min(level + 1, 5), id: \.self) { _ in
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 4)
                    .cornerRadius(1)
            }
        }
    }
}
