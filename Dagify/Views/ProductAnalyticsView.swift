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
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading { ProgressView("Memproses Analitik...").frame(height: 300) }
                else {
                    AnalyticSection(title: "Menu Paling Menguntungkan", systemImage: "arrow.up.right.circle.fill", color: .dagifySuccess) {
                        ForEach(viewModel.mostProfitableProducts, id: \.name) { item in HStack { Text(item.name).foregroundColor(.dagifyTextPrimary); Spacer(); Text("Margin: Rp \(item.margin, specifier: "%.0f")").bold().foregroundColor(.dagifySuccess) }.padding(.vertical, 4) }
                    }
                    AnalyticSection(title: "Menu Terlaris (Kuantitas)", systemImage: "star.fill", color: .dagifyWarning) {
                        ForEach(viewModel.bestSellers, id: \.name) { item in HStack { Text(item.name).foregroundColor(.dagifyTextPrimary); Spacer(); Text("\(item.quantity) Terjual").bold().foregroundColor(.dagifyPrimary) }.padding(.vertical, 4) }
                    }
                }
            }.padding(16)
        }.background(Color.dagifyMainBG.ignoresSafeArea()).navigationTitle("Analitik Produk")
        .onAppear { Task { await viewModel.loadAnalyticsData(branchId: branchId) } }
    }
}

#Preview {
    //ProductAnalyticsView()
}
