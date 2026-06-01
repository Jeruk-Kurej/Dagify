//
//  AnalyticSection.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct AnalyticSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content

    init(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#111827"))
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                content
            }
            .background(Color(hex: "#FFFFFF"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}
