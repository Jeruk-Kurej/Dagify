//
//  DashboardView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import Charts
import SwiftUI

struct DashboardView: View {
    var viewModel: DashboardViewModel
    let storeId: String
    let branchId: String
    let columns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Menyiapkan Metrik...").frame(
                            maxHeight: .infinity
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            DashItemCard(
                                title: "Pendapatan Hari Ini",
                                value:
                                    "Rp \(viewModel.todayRevenue, default: "%.0f")",
                                icon: "arrow.up.circle.fill",
                                color: .themeSuccess
                            )
                            DashItemCard(
                                title: "Laba Bersih",
                                value:
                                    "Rp \(viewModel.todayNetProfit, default: "%.0f")",
                                icon: "banknote.fill",
                                color: .themePrimary
                            )
                            DashItemCard(
                                title: "Pelanggan Loyal",
                                value: "\(viewModel.totalLoyalCustomers)",
                                icon: "person.2.fill",
                                color: .themeWarning
                            )
                            DashItemCard(
                                title: "Stok Menipis",
                                value: "\(viewModel.lowStockAlertsCount)",
                                icon: "exclamationmark.triangle.fill",
                                color: .themeDestructive
                            )
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text("Tren Penjualan").font(.headline)
                                Spacer()
                                Picker(
                                    "Periode",
                                    selection: $viewModel.selectedPeriod
                                ) {
                                    ForEach(ChartPeriod.allCases, id: \.self) {
                                        Text($0.rawValue).tag($0)
                                    }
                                }.pickerStyle(.menu)
                            }

                            if viewModel.revenueTrend.isEmpty {
                                ContentUnavailableView(
                                    "Tidak Ada Data",
                                    systemImage: "chart.xyaxis.line"
                                ).frame(height: 200)
                            } else {
                                Chart {
                                    ForEach(viewModel.revenueTrend, id: \.date)
                                    { item in
                                        LineMark(
                                            x: .value("Tanggal", item.date),
                                            y: .value("Total", item.amount)
                                        )
                                        .foregroundStyle(Color.themePrimary)
                                        .symbol(
                                            Circle().strokeBorder(lineWidth: 2)
                                        )
                                        AreaMark(
                                            x: .value("Tanggal", item.date),
                                            y: .value("Total", item.amount)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.themePrimary.opacity(
                                                        0.4
                                                    ), .clear,
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                }.frame(height: 250)
                            }
                        }.padding().background(Color.themeBgSecondary)
                            .cornerRadius(12)
                    }
                }.padding()
            }
            .navigationTitle("Dashboard").background(Color.themeBgMain)
            .onAppear {
                Task {
                    await viewModel.loadDashboardSummary(
                        storeId: storeId,
                        branchId: branchId
                    )
                }
            }
        }
    }
}
