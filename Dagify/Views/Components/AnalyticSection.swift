//
//  AnalyticSection.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct AnalyticSection<Content: View>: View {
    let title: String; let systemImage: String; let color: Color; @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Image(systemName: systemImage).foregroundColor(color).font(.title3); Text(title).font(.headline).foregroundColor(.dagifyTextPrimary) }
            Divider()
            content
        }.padding(16).background(Color.dagifySecBG).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.dagifyBorder, lineWidth: 1))
    }
}
#Preview {
    //AnalyticSection()
}
