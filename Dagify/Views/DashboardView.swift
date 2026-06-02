import SwiftUI

struct DashboardView: View {
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
                    if viewModel.isLoading {
                        ProgressView("Mengolah rekam data...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        // ✅ NAMA TOKO & CABANG
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ringkasan Hari Ini")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#111827"))

                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text(
                                    "\(viewModel.storeName) - \(viewModel.branchName)"
                                )
                            }
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#00A3A3"))
                            .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 16) {
                            DashItemCard(
                                title: "Total Omzet",
                                value:
                                    "Rp \(viewModel.todayRevenue, default: "%.0f")",
                                icon: "banknote.fill",
                                color: Color(hex: "#10B981")
                            )
                            DashItemCard(
                                title: "Total Pengeluaran",
                                value:
                                    "Rp \(viewModel.todayExpense, default: "%.0f")",
                                icon: "arrow.down.backward.circle.fill",
                                color: Color(hex: "#EF4444")
                            )
                            DashItemCard(
                                title: "Untung Bersih",
                                value:
                                    "Rp \(viewModel.todayNetProfit, default: "%.0f")",
                                icon: "chart.bar.doc.horizontal",
                                color: Color(hex: "#00A3A3")
                            )
                            DashItemCard(
                                title: "Peringatan Stok",
                                value: "\(viewModel.lowStockAlertsCount) Item",
                                icon: "exclamationmark.triangle.fill",
                                color: Color(hex: "#F59E0B")
                            )
                        }
                        .padding(.horizontal)
                    }

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
            .background(Color(hex: "#F9FAFB"))
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

#Preview {
    let mockOp = MockOperationalRepository()
    let vm = DashboardViewModel(
        cashflowProtocol: MockCashflowRepository(),
        crmProtocol: MockCRMRepository(),
        operationalProtocol: mockOp,
        storeProtocol: mockOp
    )

    return DashboardView(viewModel: vm, storeId: "S-1", branchId: "B-1")
}
