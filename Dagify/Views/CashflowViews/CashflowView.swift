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
                    
                    // ✅ UX BARU: NAVIGATOR BULAN
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) { viewModel.previousMonth() }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "#00A3A3").opacity(0.1))
                                .foregroundColor(Color(hex: "#00A3A3"))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text(viewModel.currentMonthString)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#111827"))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut) { viewModel.nextMonth() }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 36, height: 36)
                                .background(Color(hex: "#00A3A3").opacity(0.1))
                                .foregroundColor(Color(hex: "#00A3A3"))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    // --- SECTION 1: RINGKASAN SALDO ---
                    VStack(spacing: 12) {
                        FinancialBox(
                            title: "Laba Bersih Bulan Ini",
                            amount: viewModel.netProfit, // Otomatis ter-update mengikuti bulan
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

                        if viewModel.isLoading && viewModel.filteredRecords.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else if viewModel.filteredRecords.isEmpty {
                            ContentUnavailableView(
                                "Belum Ada Transaksi",
                                systemImage: "doc.text.magnifyingglass",
                                description: Text("Tidak ada catatan kas untuk bulan ini.")
                            )
                        } else {
                            LazyVStack(spacing: 0) {
                                // ✅ HANYA MENGAMBIL DATA FILTER BULAN
                                ForEach(viewModel.filteredRecords, id: \.id) { record in
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
                        // ✅ PDF SEKARANG HANYA MENCETAK LAPORAN BULAN YANG SEDANG DIBUKA
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
                    } label: {
                        Label("Ekspor PDF", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadRecords(branchId: branchId)
                }
            }
            .sheet(isPresented: $isShowingAdd) {
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
