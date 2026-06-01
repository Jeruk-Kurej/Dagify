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
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).foregroundColor(.dagifyTextSec)
            Text("Rp \(amount, specifier: "%.0f")").font(.title3).bold().foregroundColor(color).lineLimit(1).minimumScaleFactor(0.5)
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading).background(Color.dagifySecBG).clipShape(RoundedRectangle(cornerRadius: 12)).overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

#Preview{
//    FinancialBox()
}
