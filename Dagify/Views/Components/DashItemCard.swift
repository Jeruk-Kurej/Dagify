//
//  DashItemCard.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct DashItemCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 36)).foregroundColor(
                color
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(.themeTextSecondary)
                Text(value).font(.title3).bold().foregroundColor(
                    .themeTextPrimary
                )
            }
            Spacer()
        }
        .padding().background(Color.themeBgSecondary).cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(
                Color.themeBorder,
                lineWidth: 1
            )
        )
    }
}

#Preview {
    //DashItemCard()
}
