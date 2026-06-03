import SwiftUI
import Charts // ✅ WAJIB UNTUK GRAFIK

struct DashboardView: View {
    var viewModel: DashboardViewModel
    let storeId: String
    let branchId: String
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.isLoading {
                        ProgressView("Mengolah rekam data...").frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Ringkasan Hari Ini").font(.title2).fontWeight(.bold).foregroundColor(Color(hex: "#111827"))
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("\(viewModel.storeName) - \(viewModel.branchName)")
                            }.font(.subheadline).foregroundColor(Color(hex: "#00A3A3")).fontWeight(.semibold)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            DashItemCard(title: "Total Omzet", value: viewModel.todayRevenue.toRupiah(), icon: "banknote.fill", color: Color(hex: "#10B981"))
                            DashItemCard(title: "Total Pengeluaran", value: viewModel.todayExpense.toRupiah(), icon: "arrow.down.backward.circle.fill", color: Color(hex: "#EF4444"))
                            DashItemCard(title: "Untung Bersih", value: viewModel.todayNetProfit.toRupiah(), icon: "chart.bar.doc.horizontal", color: Color(hex: "#00A3A3"))
                            DashItemCard(title: "Peringatan Stok", value: "\(viewModel.lowStockAlertsCount) Item", icon: "exclamationmark.triangle.fill", color: Color(hex: "#F59E0B"))
                        }.padding(.horizontal)
                    }
                    
                    // ✅ CHART BARU DI DASHBOARD
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Grafik Penjualan")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            // ✅ TOMBOL FILTER KATEGORI DI KANAN ATAS
                            Menu {
                                Button("Semua Kategori") { viewModel.selectedCategoryId = nil }
                                ForEach(viewModel.categories) { cat in
                                    Button(cat.name) { viewModel.selectedCategoryId = cat.id }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.selectedCategoryId == nil ? "Semua" : viewModel.categories.first(where: { $0.id == viewModel.selectedCategoryId })?.name ?? "Filter")
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                                .font(.caption).padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color(hex: "#00A3A3").opacity(0.1))
                                .foregroundColor(Color(hex: "#00A3A3")).clipShape(Capsule())
                            }
                        }.padding(.horizontal)
                        
                        VStack {
                            if viewModel.chartData.isEmpty {
                                // 🛠️ UBAH DI SINI: Bungkus dengan VStack + Spacer agar memenuhi ruang 250pt
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.bar.xaxis") // Ikon grafik bawaan SF Symbols
                                        .font(.system(size: 40))
                                        .foregroundColor(Color.gray.opacity(0.4))
                                    
                                    Text("Belum ada data penjualan.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Memaksa mengisi seluruh area card
                            } else {
                                Chart(viewModel.chartData) { data in
                                    BarMark(
                                        x: .value("Menu", data.productName),
                                        y: .value("Terjual", data.quantity)
                                    )
                                    .foregroundStyle(Color(hex: "#00A3A3").gradient)
                                    .cornerRadius(4)
                                }
                            }
                        }
                        .padding()
                        .frame(height: 250) // Tetap 250pt, tapi diisi penuh oleh layout di atas
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }.padding(.vertical)
            }
            .navigationTitle("Dasbor")
            .background(Color(hex: "#F9FAFB"))
            .onAppear { Task { await viewModel.loadDashboardSummary(storeId: storeId, branchId: branchId) } }
        }
    }
}
