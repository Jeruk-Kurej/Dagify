import SwiftUI

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

                    // --- SECTION 1: RINGKASAN SALDO ---
                    VStack(spacing: 12) {
                        FinancialBox(
                            title: "Laba Bersih Saat Ini",
                            amount: viewModel.netProfit,
                            color: Color(hex: "#00A3A3"),
                            icon: "building.columns.fill"
                        )

                        HStack(spacing: 12) {
                            FinancialBox(
                                title: "Pemasukan",
                                amount: viewModel.totalIncome,
                                color: Color(hex: "#10B981"),
                                icon: "arrow.down.left.circle.fill"
                            )
                            FinancialBox(
                                title: "Pengeluaran",
                                amount: viewModel.totalExpense,
                                color: Color(hex: "#EF4444"),
                                icon: "arrow.up.right.circle.fill"
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // --- SECTION 2: RIWAYAT TRANSAKSI ---
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Riwayat Transaksi")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Button("Tambah Manual") {
                                isShowingAdd = true
                            }
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#00A3A3"))
                        }
                        .padding()

                        if viewModel.isLoading && viewModel.records.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.records.isEmpty {
                            ContentUnavailableView(
                                "Belum Ada Transaksi",
                                systemImage: "doc.text.magnifyingglass"
                            )
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.records, id: \.id) { record in
                                    TransactionRowView(record: record)
                                        .padding(.horizontal)
                                    Divider()
                                        .background(Color(hex: "#E5E7EB"))
                                        .padding(.leading, 70)
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
                        let pdfView = CashflowPDFTemplate(
                            monthYear: "Bulan Ini",
                            records: viewModel.records,
                            totalIncome: viewModel.totalIncome,
                            totalExpense: viewModel.totalExpense
                        )

                        if let url = PDFGeneratorService.renderViewToPDF(
                            view: pdfView,
                            filename: "Laporan_Keuangan_Dagify"
                        ) {
                            self.generatedPDFURL = url
                            self.isShowingShareSheet = true
                        }
                    } label: {
                        Label("Ekspor PDF", systemImage: "square.and.arrow.up")
                    }
                    .disabled(viewModel.records.isEmpty)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadRecords(branchId: branchId)
                }
            }
            .sheet(isPresented: $isShowingAdd) {
                // ✅ DIPERBAIKI: Kirim viewModel dan branchId
                AddTransactionView(viewModel: viewModel, branchId: branchId)
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = generatedPDFURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
}

// MARK: - Komponen Pembungkus Share Sheet iOS
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    // Kita bungkus semua logika setup data ke dalam closure agar ViewBuilder tidak error
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
                notes: "Penjualan Kasir"
            ),
            FinancialRecord(
                id: "2",
                branchId: "B-1",
                amount: 50000,
                type: .expense,
                category: .operational,
                timestamp: Date().addingTimeInterval(-3600),
                notes: "Beli Sabun Cuci"
            )
        ]
        
        return CashflowViewModel(cashProtocol: mockRepo)
    }()

    CashflowView(viewModel: previewViewModel, branchId: "B-1")
}
