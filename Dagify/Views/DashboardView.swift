//
//  DashboardView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct DashboardView: View {
    // ✅ MVVM SOLID: Terima ViewModel hasil injeksi dari MainAppView
    var viewModel: DashboardViewModel
    let storeId: String
    let branchId: String

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // --- SECTION 1: Ringkasan Metrik Cepat ---
                    if viewModel.isLoading {
                        ProgressView("Mengolah rekam data...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            DashItemCard(
                                title: "Total Omzet",
                                value:
                                    "Rp \(viewModel.todayRevenue, default: "%.0f")",
                                icon: "banknote.fill",
                                color: Color(hex: "#10B981")  // Sukses/Pemasukan
                            )
                            DashItemCard(
                                title: "Total Pengeluaran",
                                value:
                                    "Rp \(viewModel.todayExpense, default: "%.0f")",
                                icon: "arrow.down.backward.circle.fill",
                                color: Color(hex: "#EF4444")  // Destructive
                            )
                            DashItemCard(
                                title: "Untung Bersih",
                                value:
                                    "Rp \(viewModel.todayNetProfit, default: "%.0f")",
                                icon: "chart.bar.doc.horizontal",
                                color: Color(hex: "#00A3A3")  // Brand Primary
                            )
                            DashItemCard(
                                title: "Peringatan Stok",
                                value: "\(viewModel.lowStockAlertsCount) Item",
                                icon: "exclamationmark.triangle.fill",
                                color: Color(hex: "#F59E0B")  // Warning
                            )
                        }
                        .padding(.horizontal)
                    }

                    // --- SECTION 2: Menu Paling Laris (Best Seller) ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Analitik Menu")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))
                            .padding(.horizontal)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "#FFFFFF"))
                            .frame(height: 150)
                            .padding(.horizontal)
                            .overlay(
                                Text("Grafik Penjualan Akan Muncul Di Sini")
                                    .foregroundColor(Color(hex: "#6B7280"))
                            )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dasbor")
            .background(Color(hex: "#F9FAFB"))  // Main Background
            .onAppear {
                Task {
                    // ✅ SINKRON: Menggunakan nama fungsi asli dari ViewModel Anda
                    await viewModel.loadDashboardSummary(
                        storeId: storeId,
                        branchId: branchId
                    )
                }
            }
        }
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardViewModel(
            cashflowProtocol: MockCashflowRepository(),
            crmProtocol: MockCRMRepository(),
            operationalProtocol: MockOperationalRepository()
        ),
        storeId: "S-1",
        branchId: "B-1"
    )
}
