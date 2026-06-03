import SwiftUI

struct OperationalMenuCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#111827"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(hex: "#FFFFFF"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    OperationalMenuCard(
        title: "Kasir (POS)",
        icon: "cart.fill",
        color: Color(hex: "#00A3A3")
    )
    .padding()
    .background(Color(hex: "#F9FAFB"))
}
