//
//  MetricCard.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

struct FinancialBox: View {
    let title: String; let amount: Double; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundColor(.themeTextSecondary)
            Text("Rp \(amount, specifier: "%.0f")").font(.title3).bold().foregroundColor(color)
        }
        .padding().frame(maxWidth: .infinity, alignment: .leading).background(Color.themeBgSecondary).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.themeBorder, lineWidth: 1))
    }
}
