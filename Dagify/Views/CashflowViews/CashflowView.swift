import SwiftUI
import Charts // ✅ WAJIB DIIMPOR UNTUK CHART

struct CashflowView: View {
    var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var isShowingAdd = false
    @State private var generatedPDFURL: URL? = nil
    @State private var isShowingShareSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ✅ BAGIAN BARU: GRAFIK CASHFLOW DENGAN FILTER INDEPENDEN
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Grafik Cashflow")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            // Tombol Filter Khusus Chart
                            Menu {
                                ForEach(ChartFilter.allCases) { filter in
                                    Button(filter.rawValue) {
                                        withAnimation { viewModel.chartFilter = filter }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.chartFilter.rawValue)
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                                .font(.caption)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color(hex: "#00A3A3").opacity(0.1))
                                .foregroundColor(Color(hex: "#00A3A3"))
                                .clipShape(Capsule())
                            }
                        }
                        
                        if viewModel.chartData.isEmpty {
                            Text("Belum ada data untuk periode ini.")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 30)
                        } else {
                            Chart(viewModel.chartData) { data in
                                // 1. Bar Pemasukan (Ke Atas / Positif)
                                BarMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Pemasukan", data.income)
                                )
                                .foregroundStyle(Color(hex: "#10B981"))
                                .position(by: .value("Tipe", "Pemasukan"))
                                
                                // 2. Bar Pengeluaran (Ke Bawah / Negatif)
                                BarMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Pengeluaran", -data.expense)
                                )
                                .foregroundStyle(Color(hex: "#F59E0B")) // Oranye ala Expenses di foto
                                .position(by: .value("Tipe", "Pengeluaran"))
                                
                                // 3. Garis Tren Kumulatif (Cash Flow)
                                LineMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Cash Flow", data.cumulativeNet)
                                )
                                .foregroundStyle(Color.blue)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .interpolationMethod(.monotone)
                                
                                PointMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Cash Flow", data.cumulativeNet)
                                )
                                .foregroundStyle(Color.blue)
                            }
                            .frame(height: 240)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            
                            // Legend Penjelasan
                            HStack(spacing: 16) {
                                HStack(spacing: 4) { Circle().fill(Color(hex: "#10B981")).frame(width: 8, height: 8); Text("Income").font(.caption2).foregroundColor(.gray) }
                                HStack(spacing: 4) { Circle().fill(Color(hex: "#F59E0B")).frame(width: 8, height: 8); Text("Expenses").font(.caption2).foregroundColor(.gray) }
                                HStack(spacing: 4) { Circle().fill(Color.blue).frame(width: 8, height: 8); Text("Cash Flow").font(.caption2).foregroundColor(.gray) }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // --- NAVIGATOR BULAN (LIST & PDF) ---
                    HStack {
                        Button(action: { withAnimation(.easeInOut) { viewModel.previousMonth() } }) {
                            Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold)).frame(width: 36, height: 36).background(Color(hex: "#00A3A3").opacity(0.1)).foregroundColor(Color(hex: "#00A3A3")).clipShape(Circle())
                        }
                        Spacer()
                        Text(viewModel.currentMonthString).font(.title3).fontWeight(.bold).foregroundColor(Color(hex: "#111827"))
                        Spacer()
                        Button(action: { withAnimation(.easeInOut) { viewModel.nextMonth() } }) {
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).frame(width: 36, height: 36).background(Color(hex: "#00A3A3").opacity(0.1)).foregroundColor(Color(hex: "#00A3A3")).clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- SECTION 1: RINGKASAN SALDO ---
                    VStack(spacing: 12) {
                        FinancialBox(title: "Laba Bersih Bulan Ini", amount: viewModel.netProfit, color: Color(hex: "#00A3A3"), icon: "building.columns.fill")
                        HStack(spacing: 12) {
                            FinancialBox(title: "Pemasukan", amount: viewModel.totalIncome, color: Color(hex: "#10B981"), icon: "arrow.down.left.circle.fill")
                            FinancialBox(title: "Pengeluaran", amount: viewModel.totalExpense, color: Color(hex: "#EF4444"), icon: "arrow.up.right.circle.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- SECTION 2: RIWAYAT TRANSAKSI ---
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Riwayat Transaksi").font(.headline).foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Button("Tambah Manual") { isShowingAdd = true }.font(.footnote).fontWeight(.bold).foregroundColor(Color(hex: "#00A3A3"))
                        }
                        .padding()
                        
                        if viewModel.isLoading && viewModel.filteredRecords.isEmpty {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else if viewModel.filteredRecords.isEmpty {
                            ContentUnavailableView("Belum Ada Transaksi", systemImage: "doc.text.magnifyingglass", description: Text("Tidak ada catatan kas untuk bulan ini."))
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredRecords, id: \.id) { record in
                                    TransactionRowView(record: record).padding(.horizontal)
                                    Divider().background(Color(hex: "#E5E7EB")).padding(.leading, 70)
                                }
                            }
                            .background(Color(hex: "#FFFFFF"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color(hex: "#F9FAFB"))
            .navigationTitle("Arus Kas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if let url = PDFGeneratorService.generateCashflowReport(
                            monthYear: viewModel.currentMonthString,
                            records: viewModel.filteredRecords,
                            totalIncome: viewModel.totalIncome,
                            totalExpense: viewModel.totalExpense,
                            filename: "Laporan_Kas_\(viewModel.currentMonthString.replacingOccurrences(of: " ", with: "_"))"
                        ) {
                            self.generatedPDFURL = url
                            self.isShowingShareSheet = true
                        }
                    } label: { Label("Ekspor PDF", systemImage: "square.and.arrow.up") }
                }
            }
            .onAppear { Task { await viewModel.loadRecords(branchId: branchId) } }
            .sheet(isPresented: $isShowingAdd) { AddTransactionView(viewModel: viewModel, branchId: branchId) }
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = generatedPDFURL { ShareSheet(activityItems: [url]) }
            }
        }
    }
}

// MARK: - Komponen Pembungkus Share Sheet iOS
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let previewViewModel: CashflowViewModel = {
        let mockRepo = MockCashflowRepository()
        mockRepo.records = [
            FinancialRecord(id: "1", branchId: "B-1", amount: 150000, type: .income, category: .none, timestamp: Date(), notes: "Penjualan Kasir"),
            FinancialRecord(id: "2", branchId: "B-1", amount: 50000, type: .expense, category: .operational, timestamp: Date().addingTimeInterval(-3600), notes: "Beli Sabun Cuci")
        ]
        return CashflowViewModel(cashProtocol: mockRepo)
    }()
    CashflowView(viewModel: previewViewModel, branchId: "B-1")
}
