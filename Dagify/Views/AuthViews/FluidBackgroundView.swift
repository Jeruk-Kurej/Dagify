//
//  FluidBackgroundView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

struct FluidBackgroundView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()

            Circle()
                .fill(Color(hex: "#00A3A3").opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(
                    x: isAnimating ? 100 : -50,
                    y: isAnimating ? -200 : -100
                )

            Circle()
                .fill(Color(hex: "#2DD4BF").opacity(0.2))
                .frame(width: 350, height: 350)
                .blur(radius: 90)
                .offset(x: isAnimating ? -100 : 50, y: isAnimating ? 200 : 100)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 10).repeatForever(autoreverses: true)
            ) {
                isAnimating.toggle()
            }
        }
    }
}

#Preview {
    FluidBackgroundView()
}
