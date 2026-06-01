import SwiftUI

struct FluidBackgroundView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background Gelap agar efek Glassmorphism terlihat
            Color(hex: "#111827").ignoresSafeArea()

            Circle()
                .fill(Color(hex: "#00A3A3").opacity(0.6))  // Primary
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(
                    x: isAnimating ? 150 : -150,
                    y: isAnimating ? -200 : 100
                )

            Circle()
                .fill(Color(hex: "#4DBDBD").opacity(0.5))  // Primary Highlight
                .frame(width: 350, height: 350)
                .blur(radius: 120)
                .offset(
                    x: isAnimating ? -150 : 150,
                    y: isAnimating ? 200 : -150
                )

            Circle()
                .fill(Color(hex: "#10B981").opacity(0.4))  // Success/Green tint
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: isAnimating ? 50 : -200, y: isAnimating ? -50 : 250)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6).repeatForever(autoreverses: true)
            ) {
                isAnimating.toggle()
            }
        }
    }
}
