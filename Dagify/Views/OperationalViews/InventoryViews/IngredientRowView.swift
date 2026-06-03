import SwiftUI

struct IngredientRowView: View {
    var ingredient: Ingredient
    var isExpired: Bool = false
    var isLowStock: Bool = false
    var onDiscard: (() -> Void)? = nil
    
    // ✅ FIX: Membedakan warna Merah (Basi) dan Kuning (Stok Minim)
    var iconColor: Color {
        if isExpired { return Color(hex: "#EF4444") }
        if isLowStock { return Color(hex: "#F59E0B") } // Kuning/Oranye Warning
        return Color(hex: "#00A3A3")
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: isExpired ? "trash.fill" : (isLowStock ? "exclamationmark.triangle.fill" : "shippingbox.fill"))
                    .foregroundColor(iconColor)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#111827"))
                HStack(spacing: 4) {
                    Text("Sisa:")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#6B7280"))
                    Text("\(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isLowStock || isExpired ? iconColor : Color(hex: "#111827"))
                }
            }
            
            Spacer()
            
            if isExpired, let onDiscard = onDiscard {
                Button(action: onDiscard) {
                    Text("Buang")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#EF4444"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}
