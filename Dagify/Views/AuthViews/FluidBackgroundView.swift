import SwiftUI

struct FluidBackgroundView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // ✅ Background Utama: Dark Slate (#111827)
            Color(hex: "#111827").ignoresSafeArea()
            
            // ✅ Efek Aura Primary (#00A3A3)
            Circle()
                .fill(Color(hex: "#00A3A3").opacity(0.5))
                .frame(width: 350, height: 350)
                .blur(radius: 100)
                .offset(
                    x: isAnimating ? 150 : -100,
                    y: isAnimating ? -200 : -150
                )
            
            // ✅ Efek Aura Primary Highlight (#4DBDBD)
            Circle()
                .fill(Color(hex: "#4DBDBD").opacity(0.4))
                .frame(width: 350, height: 350)
                .blur(radius: 120)
                .offset(
                    x: isAnimating ? -100 : 150,
                    y: isAnimating ? 250 : 150
                )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8).repeatForever(autoreverses: true)
            ) {
                isAnimating.toggle()
            }
        }
    }
}
