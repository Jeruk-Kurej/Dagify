//
//  ProductAnalyticsView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct ProductAnalyticsView: View {
    var viewModel: ProductAnalyticsViewModel
    let branchId: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Menganalisis data penjualan...")
                        .padding()
                } else {
                    AnalyticSection(title: "Paling Menguntungkan (Laba Bersih)", systemImage: "dollarsign.circle.fill", color: .themeSuccess) {
                        if viewModel.mostProfitableProducts.isEmpty { Text("Belum ada data.").foregroundColor(.themeTextSecondary) }
                        ForEach(viewModel.mostProfitableProducts.prefix(5), id: \.productName) { item in
                            HStack {
                                Text(item.productName).bold()
                                Spacer()
                                Text("Laba: Rp \(item.profitMargin, specifier: "%.0f")").foregroundColor(.themeSuccess)
                            }
                            .padding().background(Color.themeBgSecondary).cornerRadius(8)
                        }
                    }
                    
                    AnalyticSection(title: "Terlaris (Kuantitas Penjualan)", systemImage: "flame.fill", color: .themeWarning) {
                        if viewModel.bestSellers.isEmpty { Text("Belum ada data.").foregroundColor(.themeTextSecondary) }
                        ForEach(viewModel.bestSellers.prefix(5), id: \.productName) { item in
                            HStack {
                                Text(item.productName).bold()
                                Spacer()
                                Text("\(item.quantitySold) Terjual").foregroundColor(.themeWarning)
                            }
                            .padding().background(Color.themeBgSecondary).cornerRadius(8)
                        }
                    }
                    
                    AnalyticSection(title: "Evaluasi Menu (Kurang Laku)", systemImage: "arrow.down.right.circle.fill", color: .themeDestructive) {
                        if viewModel.leastPopular.isEmpty { Text("Belum ada data.").foregroundColor(.themeTextSecondary) }
                        ForEach(viewModel.leastPopular.prefix(3), id: \.productName) { item in
                            HStack {
                                Text(item.productName).foregroundColor(.themeTextSecondary)
                                Spacer()
                                Text("Hanya \(item.quantitySold) Terjual").foregroundColor(.themeDestructive)
                            }
                            .padding().background(Color.themeBgSecondary).cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.themeBgMain)
        .navigationTitle("Analitik Menu")
        .onAppear {
            Task { await viewModel.loadAnalyticsData(branchId: branchId) }
        }
    }
}

struct AnalyticSection<Content: View>: View {
    let title: String
    let systemImage: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: systemImage).foregroundColor(color)
                Text(title).font(.headline).foregroundColor(.themeTextPrimary)
            }
            .padding(.bottom, 5)
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.themeBorder, lineWidth: 1))
    }
}

#Preview {
    //ProductAnalyticsView()
}
