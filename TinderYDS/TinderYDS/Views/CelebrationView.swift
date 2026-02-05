import SwiftUI

struct CelebrationView: View {
    @Binding var isPresented: Bool
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Celebration content
            VStack(spacing: 24) {
                // Trophy icon with animation
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFD700").opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#FFD700"))
                        .shadow(color: Color(hex: "#FFD700").opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("Daily Goal Reached!")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "#5c4a32"))
                    
                    Text("Great job! You've hit your daily target.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#7b6a52"))
                        .multilineTextAlignment(.center)
                }
                
                Button(action: dismiss) {
                    Text("Keep Learning!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#4CAF50"))
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#f4ecd8"))
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// Confetti effect (simplified version)
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var path = Path()
                    path.addRect(CGRect(x: 0, y: 0, width: 8, height: 8))
                    
                    context.translateBy(x: particle.x, y: particle.y)
                    context.rotate(by: .degrees(particle.rotation))
                    context.fill(path, with: .color(particle.color))
                }
            }
            .onChange(of: timeline.date) { _ in
                updateParticles()
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
        particles = (0..<50).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: -100...0),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                velocity: CGFloat.random(in: 2...5),
                rotationSpeed: Double.random(in: -5...5)
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            particles[i].y += particles[i].velocity
            particles[i].rotation += particles[i].rotationSpeed
            
            if particles[i].y > 800 {
                particles[i].y = -20
                particles[i].x = CGFloat.random(in: 0...400)
            }
        }
    }
}

struct ConfettiParticle {
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var color: Color
    var velocity: CGFloat
    var rotationSpeed: Double
}
