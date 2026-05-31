//
//  DashboardView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct DashboardView: View {
    var viewModel: DashboardViewModel
    let storeId: String
    let branchId: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ringkasan Keuangan Hari Ini")
                        .font(.headline)
                        .foregroundColor(.themeTextSecondary)

                    HStack {
                        FinancialBox(
                            title: "Pendapatan Harian",
                            amount: viewModel.todayRevenue,
                            color: .themeSuccess
                        )
                        FinancialBox(
                            title: "Laba Bersih",
                            amount: viewModel.todayNetProfit,
                            color: .themePrimary
                        )
                    }
                }
                .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Peringatan Stok Gudang")
                            .font(.caption)
                            .foregroundColor(.themeTextSecondary)
                        Text("\(viewModel.lowStockAlertsCount) Item Menipis")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.themeWarning)
                    }
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.themeWarning)
                }
                .padding()
                .background(Color.themeBgSecondary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(
                        Color.themeBorder,
                        lineWidth: 1
                    )
                )
                .padding(.horizontal)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Pelanggan Loyal")
                            .font(.caption)
                            .foregroundColor(.themeTextSecondary)
                        Text("\(viewModel.totalLoyalCustomers) Orang")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.themeTextPrimary)
                    }
                    Spacer()
                    Image(systemName: "heart.fill")
                        .font(.largeTitle)
                        .foregroundColor(.themeHighlight)
                }
                .padding()
                .background(Color.themeBgSecondary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(
                        Color.themeBorder,
                        lineWidth: 1
                    )
                )
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Dasbor Utama")
        .background(Color.themeBgMain.edgesIgnoringSafeArea(.all))
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
