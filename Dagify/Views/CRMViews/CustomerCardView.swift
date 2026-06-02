import SwiftUI

struct CustomerCardView: View {
    var customer: Customer

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color(hex: "#00A3A3").opacity(0.15)).frame(width: 50, height: 50)
                Text(String(customer.name.prefix(1).uppercased())).font(.title2).fontWeight(.bold).foregroundColor(Color(hex: "#00A3A3"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(customer.name).font(.headline).foregroundColor(Color(hex: "#111827"))
                Text(customer.phoneNumber).font(.subheadline).foregroundColor(Color(hex: "#6B7280"))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if customer.isLoyal {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.caption2).foregroundColor(Color(hex: "#F59E0B"))
                        Text("Loyal").font(.caption2).fontWeight(.bold).foregroundColor(Color(hex: "#F59E0B"))
                    }.padding(.horizontal, 6).padding(.vertical, 2).background(Color(hex: "#F59E0B").opacity(0.15)).clipShape(Capsule())
                }
                // ✅ RUPIAH FORMAT DI CRM
                Text(customer.totalSpent.toRupiah()).font(.caption).fontWeight(.bold).foregroundColor(Color(hex: "#10B981"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}
