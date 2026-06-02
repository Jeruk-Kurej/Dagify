import SwiftUI

struct ProductCardView: View {
    var product: Product
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder Gambar Produk
            ZStack {
                Color.themeBgMain
                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.themePrimary.opacity(0.6))
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.themeTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(String(format: "Rp %.0f", product.price))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.themePrimary)
            }

            Button(action: onAdd) {
                Text("Tambah")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.themePrimary.opacity(0.15))
                    .foregroundColor(.themePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color.themeBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}
