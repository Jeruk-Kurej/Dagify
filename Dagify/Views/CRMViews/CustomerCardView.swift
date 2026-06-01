import SwiftUI

struct CustomerCardView: View {
    var customer: Customer

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#00A3A3").opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundColor(Color(hex: "#00A3A3"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(
                    customer.name.isEmpty ? customer.phoneNumber : customer.name
                )
                .font(.headline)
                .foregroundColor(Color(hex: "#111827"))
                .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "#F59E0B"))  // Warning/Yellow
                        .font(.caption)
                    Text("\(customer.visitHistory.count) Kunjungan")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#6B7280"))
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if customer.isLoyal {
                    Text("Loyal")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#10B981").opacity(0.2))
                        .foregroundColor(Color(hex: "#10B981"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                Text(String(format: "Rp %.0f", customer.totalSpent))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#111827"))
            }
        }
        .padding()
        .background(Color(hex: "#FFFFFF"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}
