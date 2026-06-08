//
//  AnalyticRow.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import SwiftUI

struct AnalyticRow: View {
    let rank: Int
    let name: String
    let detail: String
    let highlightColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(highlightColor)
                .frame(width: 30, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#111827"))
                Text(detail)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#6B7280"))
            }
            Spacer()
        }
        .padding()
        Divider().padding(.leading, 60)
    }
}

#Preview {
    AnalyticRow(
        rank: 1,
        name: "Nasi Goreng",
        detail: "120 Terjual",
        highlightColor: .green
    )
}
