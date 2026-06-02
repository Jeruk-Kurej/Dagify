import SwiftUI

struct ProductCardView: View {
    var product: Product
    var quantity: Int
    var onAdd: () -> Void
    var onDecrease: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // ✅ MENAMPILKAN GAMBAR HASIL UPLOAD DI KASIR
            ZStack {
                Color.themeBgMain
                if let data = product.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    Image(systemName: "cup.and.saucer.fill").resizable().scaledToFit().frame(height: 40).foregroundColor(.themePrimary.opacity(0.6))
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name).font(.headline).foregroundColor(.themeTextPrimary).lineLimit(2).minimumScaleFactor(0.8)
                Text(String(format: "Rp %.0f", product.price)).font(.subheadline).fontWeight(.semibold).foregroundColor(.themePrimary)
            }
            Spacer(minLength: 0)

            if quantity > 0 {
                HStack {
                    Button(action: onDecrease) { Image(systemName: "minus").font(.system(size: 14, weight: .bold)).frame(width: 32, height: 32).background(Color.themePrimary.opacity(0.15)).foregroundColor(.themePrimary).clipShape(Circle()) }
                    Spacer()
                    Text("\(quantity)").font(.headline).fontWeight(.bold).foregroundColor(.themeTextPrimary)
                    Spacer()
                    Button(action: onAdd) { Image(systemName: "plus").font(.system(size: 14, weight: .bold)).frame(width: 32, height: 32).background(Color.themePrimary).foregroundColor(.white).clipShape(Circle()) }
                }
            } else {
                Button(action: onAdd) {
                    Text("Tambah").font(.footnote).fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 8).background(Color.themePrimary.opacity(0.15)).foregroundColor(.themePrimary).clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(12)
        .background(Color.themeBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}
