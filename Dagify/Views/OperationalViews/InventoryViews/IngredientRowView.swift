import SwiftUI

struct IngredientRowView: View {
    var ingredient: Ingredient
    var isExpired: Bool = false
    var isLowStock: Bool = false
    var onDiscard: (() -> Void)? = nil
    
    // Prioritas icon: Merah (Basi) -> Kuning (Minim)
    var iconColor: Color {
        if isExpired { return Color(hex: "#EF4444") }
        if isLowStock { return Color(hex: "#F59E0B") }
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
            
            VStack(alignment: .leading, spacing: 6) {
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
                
                // Menampilkan 2 Tag Peringatan Sekaligus
                if isExpired || isLowStock {
                    HStack(spacing: 8) {
                        if isExpired {
                            Text("Basi")
                                .font(.caption2).fontWeight(.bold)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color(hex: "#EF4444").opacity(0.15))
                                .foregroundColor(Color(hex: "#EF4444"))
                                .clipShape(Capsule())
                        }
                        if isLowStock {
                            Text("Stok Minim")
                                .font(.caption2).fontWeight(.bold)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color(hex: "#F59E0B").opacity(0.15))
                                .foregroundColor(Color(hex: "#F59E0B"))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // ✅ UPDATE HIG: Tombol Buang menggunakan icon Trash standar iOS
            if isExpired, ingredient.currentStock > 0, let onDiscard = onDiscard {
                Button(action: onDiscard) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#EF4444")) // Warna Destructive
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "#EF4444").opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
}
