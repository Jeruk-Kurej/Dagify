//
//  DashboardView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct DashboardView: View {
    var viewModel: DashboardViewModel
    let storeId = "S-1"
    let branchId = "B-1"
    let adaptiveColumns = [
        GridItem(.adaptive(minimum: 240, maximum: .infinity), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if viewModel.isLoading {
                    ProgressView("Mengolah rekam data keuangan...").frame(
                        maxWidth: .infinity,
                        minHeight: 300
                    )
                } else {
                    Text("Performa Operasional Hari Ini").font(.title2).bold()
                        .foregroundColor(.themeTextPrimary)

                    LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                        DashItemCard(
                            title: "Pendapatan Kotor",
                            value:
                                "Rp \(viewModel.todayRevenue, default: "%.0f")",
                            icon: "arrow.up.forward.circle.fill",
                            color: .themeSuccess
                        )
                        DashItemCard(
                            title: "Beban Pengeluaran",
                            value:
                                "Rp \(viewModel.todayExpense, default: "%.0f")",
                            icon: "arrow.down.backward.circle.fill",
                            color: .themeDestructive
                        )
                        DashItemCard(
                            title: "Estimasi Untung Bersih",
                            value:
                                "Rp \(viewModel.todayNetProfit, default: "%.0f")",
                            icon: "banknote.fill",
                            color: .themePrimary
                        )
                        DashItemCard(
                            title: "Indikator Stok Kritis",
                            value: "\(viewModel.lowStockAlertsCount) Item",
                            icon: "exclamationmark.triangle.fill",
                            color: .themeWarning
                        )
                    }
                }
            }.padding()
        }
        .background(Color.themeBgMain).navigationTitle("Dasbor Analitik")
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

struct DashItemCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 36)).foregroundColor(
                color
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundColor(.themeTextSecondary)
                Text(value).font(.title3).bold().foregroundColor(
                    .themeTextPrimary
                )
            }
            Spacer()
        }
        .padding().background(Color.themeBgSecondary).cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(
                Color.themeBorder,
                lineWidth: 1
            )
        )
    }
}
