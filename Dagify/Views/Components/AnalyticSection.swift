//
//  AnalyticSection.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
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
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#111827"))
            }
            .padding(.horizontal)

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

#Preview {
    AnalyticSection(
        title: "Preview Section",
        icon: "star.fill",
        iconColor: .yellow
    ) {
        Text("Content Goes Here")
            .padding()
    }
}
