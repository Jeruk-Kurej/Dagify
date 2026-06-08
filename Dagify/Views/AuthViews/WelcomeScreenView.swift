//
//  WelcomeScreenView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

struct WelcomeScreenView: View {
    @Binding var showAuthForm: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // MARK: - Logo & Branding
            Image("Dagify_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
            
            Text("Dagify")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "#111827"))
            
            Text("Business Management")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "#6B7280"))
            
            Spacer()
            
            // MARK: - Call to Action
            Button(action: {
                withAnimation { showAuthForm = true }
            }) {
                HStack(spacing: 12) {
                    Text("Mulai Kelola Bisnis")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(Color(hex: "#111827"))
                .padding(.horizontal, 32)
                .padding(.vertical, 18)
                .background(Color(hex: "#FFFFFF"))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    WelcomeScreenView(showAuthForm: .constant(false))
}
