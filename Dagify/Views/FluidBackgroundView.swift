//
//  FluidBackgroundView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct FluidBackgroundView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.themeTextPrimary.ignoresSafeArea()

            Circle()
                .fill(Color.themePrimary.opacity(0.7))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(
                    x: isAnimating ? 150 : -150,
                    y: isAnimating ? -200 : 100
                )

            Circle()
                .fill(Color.purple.opacity(0.7))
                .frame(width: 350, height: 350)
                .blur(radius: 120)
                .offset(
                    x: isAnimating ? -150 : 150,
                    y: isAnimating ? 200 : -150
                )

            Circle()
                .fill(Color.themeHighlight.opacity(0.6))
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
