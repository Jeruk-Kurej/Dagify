import SwiftUI

struct DashItemCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(color)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.themeTextSecondary)

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.themeTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .padding(16)
        .background(Color.themeBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        Color.themeBgMain.ignoresSafeArea()
        HStack {
            DashItemCard(
                title: "Pendapatan",
                value: "Rp 1.500.000",
                icon: "arrow.up.forward.circle.fill",
                color: .themeSuccess
            )
            DashItemCard(
                title: "Stok Kritis",
                value: "3 Item",
                icon: "exclamationmark.triangle.fill",
                color: .themeWarning
            )
        }
        .padding()
    }
}
