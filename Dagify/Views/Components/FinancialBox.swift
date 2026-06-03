import SwiftUI

/// Global extension to format Double as Rupiah string.
// Karena ditaruh di sini, seluruh file di aplikasi Dagify bisa menggunakannya!
extension Double {
    func toRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let formatted = formatter.string(from: NSNumber(value: self)) ?? "0,00"
        return "Rp \(formatted)"
    }
}

struct FinancialBox: View {
    var title: String
    var amount: Double
    var color: Color
    var icon: String
    var isCurrency: Bool = true

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

            /// Uses the latest Rupiah formatter
            Text(isCurrency ? amount.toRupiah() : String(format: "%.0f", amount))
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
