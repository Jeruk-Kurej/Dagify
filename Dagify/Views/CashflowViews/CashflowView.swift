import SwiftUI
import Charts

enum CashflowSheetType: Identifiable {
    case add
    case edit(FinancialRecord)
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let r): return "edit_\(r.id ?? UUID().uuidString)"
        }
    }
}

struct CashflowView: View {
    var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var activeSheet: CashflowSheetType? = nil
    @State private var generatedPDFURL: URL? = nil
    @State private var isShowingShareSheet = false
    @State private var selectedRecord: FinancialRecord? = nil
    
    private func formatCompact(_ value: Double) -> String {
        let absValue = abs(value)
        if absValue >= 1_000_000_000 { return String(format: "%.1f M", value / 1_000_000_000) }
        if absValue >= 1_000_000 { return String(format: "%.1f Jt", value / 1_000_000) }
        if absValue >= 1_000 { return String(format: "%.0f K", value / 1_000) }
        return String(format: "%.0f", value)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- GRAFIK CASHFLOW ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Grafik Cashflow")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
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
                                .frame(maxWidth: .infinity, minHeight: 240, alignment: .center)
                        } else {
                            Chart(viewModel.chartData) { data in
                                BarMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Pemasukan", data.income)
                                )
                                .foregroundStyle(Color(hex: "#10B981"))
                                .position(by: .value("Tipe", "Pemasukan"))
                                
                                BarMark(
                                    x: .value("Waktu", data.date, unit: viewModel.chartUnit),
                                    y: .value("Pengeluaran", data.expense)
                                )
                                .foregroundStyle(Color(hex: "#EF4444"))
                                .position(by: .value("Tipe", "Pengeluaran"))
                            }
                            .frame(height: 240)
                            .chartYScale(domain: .automatic(includesZero: true))
                            .chartYAxis {
                                AxisMarks(position: .leading) { mark in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let val = mark.as(Double.self) {
                                            Text(formatCompact(val))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 4) { Circle().fill(Color(hex: "#10B981")).frame(width: 8, height: 8); Text("Pemasukan").font(.caption2).foregroundColor(.gray) }
                                HStack(spacing: 4) { Circle().fill(Color(hex: "#EF4444")).frame(width: 8, height: 8); Text("Pengeluaran").font(.caption2).foregroundColor(.gray) }
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
                    
                    // --- NAVIGATOR BULAN ---
                    HStack {
                        Button(action: { withAnimation(.easeInOut) { viewModel.previousMonth() } }) {
                            Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold)).frame(width: 36, height: 36).background(Color(hex: "#00A3A3").opacity(0.1)).foregroundColor(Color(hex: "#00A3A3")).clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text(viewModel.currentMonthString)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#111827"))
                        
                        Spacer()
                        
                        /// Hide or dim the next button if currently viewing the latest month.
                        Button(action: { withAnimation(.easeInOut) { viewModel.nextMonth() } }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "#00A3A3").opacity(viewModel.isCurrentMonthTheLatest ? 0.0 : 0.1))
                                .foregroundColor(viewModel.isCurrentMonthTheLatest ? .clear : Color(hex: "#00A3A3"))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.isCurrentMonthTheLatest) // Menonaktifkan fungsionalitas klik
                    }
                    .padding(.horizontal)
                    
                    // --- RINGKASAN SALDO ---
                    VStack(spacing: 12) {
                        FinancialBox(title: "Laba Bersih Bulan Ini", amount: viewModel.netProfit, color: Color(hex: "#00A3A3"), icon: "building.columns.fill")
                        HStack(spacing: 12) {
                            FinancialBox(title: "Pemasukan", amount: viewModel.totalIncome, color: Color(hex: "#10B981"), icon: "arrow.down.left.circle.fill")
                            FinancialBox(title: "Pengeluaran", amount: viewModel.totalExpense, color: Color(hex: "#EF4444"), icon: "arrow.up.right.circle.fill")
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- RIWAYAT TRANSAKSI ---
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Riwayat Transaksi").font(.headline).foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Button("Tambah Manual") { activeSheet = .add }.font(.footnote).fontWeight(.bold).foregroundColor(Color(hex: "#00A3A3"))
                        }
                        .padding()
                        
                        if viewModel.isLoading && viewModel.filteredRecords.isEmpty {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else if viewModel.filteredRecords.isEmpty {
                            ContentUnavailableView("Belum Ada Transaksi", systemImage: "doc.text.magnifyingglass", description: Text("Tidak ada catatan kas untuk bulan ini."))
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.filteredRecords, id: \.id) { record in
                                    Button(action: {
                                        selectedRecord = record
                                    }) {
                                        TransactionRowView(record: record)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                    .contextMenu {
                                        Button { activeSheet = .edit(record) } label: { Label("Edit Transaksi", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            if let id = record.id { Task { await viewModel.deleteTransaction(recordId: id, branchId: branchId) } }
                                        } label: { Label("Hapus Transaksi", systemImage: "trash") }
                                    }
                                    
                                    Divider().background(Color(hex: "#E5E7EB")).padding(.leading, 70)
                                }
                            }
                            .background(Color(hex: "#FFFFFF"))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity, alignment: .top)
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
            .popover(item: $activeSheet) { sheetType in
                switch sheetType {
                case .add: AddTransactionView(viewModel: viewModel, branchId: branchId)
                case .edit(let record): AddTransactionView(viewModel: viewModel, branchId: branchId, recordToEdit: record)
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = generatedPDFURL { ShareSheet(activityItems: [url]) }
            }
            .alert("Detail Transaksi", isPresented: Binding<Bool>(
                get: { selectedRecord != nil },
                set: { if !$0 { selectedRecord = nil } }
            )) {
                Button("Tutup", role: .cancel) { selectedRecord = nil }
            } message: {
                if let record = selectedRecord {
                    let status = record.type == .income ? "Pemasukan" : "Pengeluaran"
                    let noteStr = record.notes.isEmpty ? status : record.notes
                    let dateStr = record.timestamp.formatted(date: .abbreviated, time: .shortened)
                    
                    Text("\(status) sejumlah \(record.amount.toRupiah())\nTanggal: \(dateStr)\n\nCatatan:\n\(noteStr)")
                }
            }
        }
    }
}

#Preview {
    let previewViewModel: CashflowViewModel = {
        let mockRepo = MockCashflowRepository()
        mockRepo.records = [
            FinancialRecord(
                id: "1",
                branchId: "B-1",
                amount: 150000,
                type: .income,
                category: .none,
                timestamp: Date(),
                notes:
                    "Penjualan Kasir yang catatannya sangat panjang sekali sehingga harus dipotong"
            ),
            FinancialRecord(
                id: "2",
                branchId: "B-1",
                amount: 50000,
                type: .expense,
                category: .operational,
                timestamp: Date().addingTimeInterval(-3600),
                notes: "Beli Sabun Cuci"
            ),
        ]
        return CashflowViewModel(cashProtocol: mockRepo)
    }()
    CashflowView(viewModel: previewViewModel, branchId: "B-1")
}
