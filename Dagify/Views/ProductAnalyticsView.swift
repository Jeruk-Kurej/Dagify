//
//  ProductAnalyticsView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI
import Charts

struct ProductAnalyticsView: View {
    var viewModel: ProductAnalyticsViewModel
    let branchId: String
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Menganalisis Performa Menu...").frame(maxHeight: .infinity)
            } else if viewModel.products.isEmpty {
                ContentUnavailableView("Belum Ada Data", systemImage: "chart.pie.fill", description: Text("Tambahkan menu di Master Data terlebih dahulu."))
            } else {
                List {
                    Section(header: Text("Peringkat Harga Menu Tertinggi")) {
                        ForEach(viewModel.mostProfitableProducts) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.name).font(.headline).foregroundColor(.themeTextPrimary)
                                    Text("Menu Kasir").font(.caption).foregroundColor(.themeTextSecondary)
                                }
                                Spacer()
                                Text("Rp \(product.price, specifier: "%.0f")")
                                    .bold()
                                    .foregroundColor(.themeSuccess)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .background(Color.themeBgMain)
            }
        }
        .navigationTitle("Analitik Produk")
        .onAppear { Task { await viewModel.loadProducts(branchId: branchId) } }
    }
}

#Preview {
    //ProductAnalyticsView()
}
