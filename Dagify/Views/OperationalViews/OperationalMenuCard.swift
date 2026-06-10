//
//  OperationalMenuCard.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import SwiftUI

struct OperationalMenuCard: View {
    let title: String
    let description: String?
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#111827"))
                
                if let desc = description {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#6B7280"))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#9CA3AF"))
                .font(.subheadline)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(hex: "#FFFFFF"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    OperationalMenuCard(
        title: "Kasir (POS)",
        description: "Lakukan transaksi kasir dan catat pesanan pelanggan.",
        icon: "cart.fill",
        color: Color(hex: "#00A3A3")
    )
    .padding()
    .background(Color(hex: "#F9FAFB"))
}
