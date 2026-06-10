//
//  ProductAnalyticsView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import Charts
import SwiftUI

struct ProductAnalyticsView: View {
    var viewModel: ProductAnalyticsViewModel
    let branchId: String

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading {
                    ProgressView("Mengolah algoritma data...").frame(
                        maxWidth: .infinity,
                        minHeight: 300
                    )
                } else if viewModel.orders.isEmpty {
                    ContentUnavailableView(
                        "Belum Ada Data",
                        systemImage: "chart.pie",
                        description: Text(
                            "Lakukan transaksi di Kasir terlebih dahulu."
                        )
                    )
                } else {

                    // Grafik 
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Grafik Penjualan")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Menu {
                                Button("Semua Kategori") {
                                    viewModel.selectedCategoryId = nil
                                }
                                ForEach(viewModel.categories) { cat in
                                    Button(cat.name) {
                                        viewModel.selectedCategoryId = cat.id
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(
                                        viewModel.selectedCategoryId == nil
                                            ? "Semua"
                                            : viewModel.categories.first(
                                                where: {
                                                    $0.id
                                                        == viewModel
                                                        .selectedCategoryId
                                                })?.name ?? "Filter"
                                    )
                                    Image(
                                        systemName:
                                            "line.3.horizontal.decrease.circle"
                                    )
                                }
                                .font(.caption).padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(hex: "#00A3A3").opacity(0.1))
                                .foregroundColor(Color(hex: "#00A3A3"))
                                .clipShape(Capsule())
                            }
                        }.padding(.horizontal)

                        VStack {
                            if viewModel.chartData.isEmpty {
                                Text(
                                    "Belum ada data penjualan pada kategori ini."
                                ).foregroundColor(.gray)
                            } else {
                                Chart(viewModel.chartData) { data in
                                    BarMark(
                                        x: .value("Menu", data.productName),
                                        y: .value("Terjual", data.quantity)
                                    )
                                    .foregroundStyle(
                                        Color(hex: "#00A3A3").gradient
                                    )
                                    .cornerRadius(4)
                                }
                            }
                        }
                        .padding().frame(height: 250).background(Color.white)
                        .cornerRadius(16).shadow(
                            color: Color.black.opacity(0.04),
                            radius: 5,
                            x: 0,
                            y: 2
                        ).padding(.horizontal)
                    }

                    AnalyticSection(
                        title: "Paling Laris (Best Seller)",
                        icon: "flame.fill",
                        iconColor: Color(hex: "#F59E0B")
                    ) {
                        ForEach(
                            Array(viewModel.bestSellers.prefix(3).enumerated()),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail: "\(item.quantitySold) Terjual",
                                highlightColor: Color(hex: "#00A3A3")
                            )
                        }
                    }
                    AnalyticSection(
                        title: "Margin Tertinggi",
                        icon: "arrow.up.right.circle.fill",
                        iconColor: Color(hex: "#10B981")
                    ) {
                        ForEach(
                            Array(
                                viewModel.mostProfitableProducts.prefix(3)
                                    .enumerated()
                            ),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail:
                                    "Untung \(item.profitMargin.toRupiah())",
                                highlightColor: Color(hex: "#10B981")
                            )
                        }
                    }
                    AnalyticSection(
                        title: "Perlu Evaluasi",
                        icon: "arrow.down.right.circle.fill",
                        iconColor: Color(hex: "#EF4444")
                    ) {
                        ForEach(
                            Array(
                                viewModel.leastPopular.prefix(3).enumerated()
                            ),
                            id: \.element.productName
                        ) { index, item in
                            AnalyticRow(
                                rank: index + 1,
                                name: item.productName,
                                detail: "Hanya \(item.quantitySold) Terjual",
                                highlightColor: Color(hex: "#EF4444")
                            )
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color(hex: "#F9FAFB").ignoresSafeArea())
        .navigationTitle("Analitik Menu")
        .onAppear {
            Task { await viewModel.loadAnalyticsData(branchId: branchId) }
        }
        .refreshable { await viewModel.loadAnalyticsData(branchId: branchId) }
    }
}
