import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("mistral_api_key") private var apiKey = ""
    @AppStorage("daily_goal") private var dailyGoal = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#f4ecd8")
                    .ignoresSafeArea()
                
                List {
                    Section("API Configuration") {
                        SecureField("Mistral API Key", text: $apiKey)
                            .textContentType(.password)
                        
                        Text("Your API key is stored securely on your device.")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#8b7355"))
                    }
                    
                    Section("Study Preferences") {
                        Stepper("Daily Goal: \(dailyGoal) words", value: $dailyGoal, in: 5...50)
                        
                        Text("Set how many words you want to study each day.")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#8b7355"))
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Color(hex: "#8b7355"))
                        }
                        
                        HStack {
                            Text("Built with")
                            Spacer()
                            Text("SwiftUI & SwiftData")
                                .foregroundColor(Color(hex: "#8b7355"))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#5c4a32"))
                }
            }
        }
    }
}

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#f4ecd8")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // App info
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "rectangle.stack.fill.badge.person.crop")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#5c4a32"))
                            
                            Text("Tinder YDS")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color(hex: "#5c4a32"))
                            
                            Text("YDS Vocabulary Learning")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#7b6a52"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        
                        // How to use
                        InfoSection(title: "How to Use") {
                            InfoItem(icon: "hand.swipe.right", text: "Swipe right if you know the word")
                            InfoItem(icon: "hand.swipe.left", text: "Swipe left if you don't know it")
                            InfoItem(icon: "flame.fill", text: "Maintain your daily streak by studying")
                            InfoItem(icon: "chart.bar.fill", text: "Track progress in the Stats tab")
                        }
                        
                        // Spaced Repetition
                        InfoSection(title: "Spaced Repetition") {
                            Text("This app uses a 7-level spaced repetition system to help you remember words long-term:")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#6b5a42"))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Level 1: Review after 1 day")
                                Text("• Level 2: Review after 3 days")
                                Text("• Level 3: Review after 7 days")
                                Text("• Level 4+: Considered learned!")
                            }
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#7b6a52"))
                            .padding(.top, 4)
                        }
                        
                        // About YDS
                        InfoSection(title: "About YDS") {
                            Text("YDS (Yabancı Dil Sınavı) is a standardized foreign language proficiency exam in Turkey. This app helps you prepare by learning academic English vocabulary commonly found on the exam.")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#6b5a42"))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#5c4a32"))
                }
            }
        }
    }
}

struct InfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#5c4a32"))
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
    }
}

struct InfoItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#5c4a32"))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#6b5a42"))
            
            Spacer()
        }
    }
}
