//
//  ProductCardView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import SwiftUI

struct ProductCardView: View {
    var product: Product
    var quantity: Int
    var onAdd: () -> Void
    var onDecrease: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            /// Displays uploaded image in POS.
            ZStack {
                Color.themeBgMain
                if let urlStr = product.imageUrl, let url = URL(string: urlStr)
                {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.themeBgMain
                    }
                } else {
                    Image(systemName: "cup.and.saucer.fill").resizable()
                        .scaledToFit().frame(height: 40).foregroundColor(
                            .themePrimary.opacity(0.6)
                        )
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name).font(.headline).foregroundColor(
                    .themeTextPrimary
                ).lineLimit(2).minimumScaleFactor(0.8)
                Text(product.price.toRupiah()).font(.subheadline).fontWeight(
                    .semibold
                ).foregroundColor(.themePrimary)
            }
            Spacer(minLength: 0)

            if quantity > 0 {
                HStack {
                    Button(action: onDecrease) {
                        Image(systemName: "minus").font(
                            .system(size: 14, weight: .bold)
                        ).frame(width: 32, height: 32).background(
                            Color.themePrimary.opacity(0.15)
                        ).foregroundColor(.themePrimary).clipShape(Circle())
                    }
                    Spacer()
                    Text("\(quantity)").font(.headline).fontWeight(.bold)
                        .foregroundColor(.themeTextPrimary)
                    Spacer()
                    Button(action: onAdd) {
                        Image(systemName: "plus").font(
                            .system(size: 14, weight: .bold)
                        ).frame(width: 32, height: 32).background(
                            Color.themePrimary
                        ).foregroundColor(.white).clipShape(Circle())
                    }
                }
            } else {
                Button(action: onAdd) {
                    Text("Tambah").font(.footnote).fontWeight(.bold).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 8).background(
                        Color.themePrimary.opacity(0.15)
                    ).foregroundColor(.themePrimary).clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                }
            }
        }
        .padding(12)
        .background(Color.themeBgSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProductCardView(
        product: Product(
            id: "1",
            branchId: "B-1",
            categoryId: "C-1",
            name: "Kopi Hitam",
            price: 15000,
            recipe: []
        ),
        quantity: 0,
        onAdd: {},
        onDecrease: {}
    )
}
