import SwiftUI

struct FinancialBox: View {
    var title: String
    var amount: Double
    var color: Color
    var icon: String
    var isCurrency: Bool = true // ✅ DITAMBAHKAN: Sakelar Rupiah

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#6B7280"))
            }

            // ✅ LOGIKA BARU: Jika isCurrency false, buang tulisan "Rp"
            Text(isCurrency ? String(format: "Rp %.0f", amount) : String(format: "%.0f", amount))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#FFFFFF"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}
