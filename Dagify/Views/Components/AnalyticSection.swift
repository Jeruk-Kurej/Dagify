//
//  AnalyticSection.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct AnalyticSection<Content: View>: View {
    let title: String
    let systemImage: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: systemImage).foregroundColor(color)
                Text(title).font(.headline).foregroundColor(.themeTextPrimary)
            }
            .padding(.bottom, 5)
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.themeBorder, lineWidth: 1))
    }
}

#Preview {
    AnalyticSection()
}
