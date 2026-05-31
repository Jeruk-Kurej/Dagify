//
//  CashflowView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

struct CashflowView: View {
    var viewModel: CashflowViewModel
    let branchId: String 
    @State private var showAddSheet = false
    @State private var generatedPDFURL: URL? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                FinancialBox(title: "Total Pemasukan", amount: viewModel.totalIncome, color: .themeSuccess)
                FinancialBox(title: "Total Pengeluaran", amount: viewModel.totalExpense, color: .themeDestructive)
            }
            .padding()
            .background(Color.themeBgMain)
            
            if viewModel.isLoading {
                ProgressView("Menyusun pembukuan...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.records.isEmpty {
                ContentUnavailableView("Belum ada transaksi", systemImage: "doc.text.magnifyingglass", description: Text("Catatan keuangan Anda masih kosong."))
            } else {
                List {
                    let grouped = viewModel.groupedRecordsByMonth.sorted(by: { $0.key > $1.key })
                    ForEach(grouped, id: \.key) { month, records in
                        Section(header: Text(month).font(.headline).foregroundColor(.themeTextPrimary)) {
                            ForEach(records) { record in
                                HStack {
                                    Image(systemName: record.type == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(record.type == .income ? .themeSuccess : .themeDestructive)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(record.notes).font(.body).bold().foregroundColor(.themeTextPrimary)
                                        Text(record.category.rawValue).font(.caption).foregroundColor(.themeTextSecondary)
                                    }
                                    Spacer()
                                    Text("Rp \(record.amount, specifier: "%.0f")")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(record.type == .income ? .themeSuccess : .themeTextPrimary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Arus Kas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 16) {
                    if let pdfURL = generatedPDFURL {
                        ShareLink(item: pdfURL) {
                            Image(systemName: "square.and.arrow.up").font(.title3).foregroundColor(.themePrimary)
                        }
                    } else {
                        Button(action: generatePDF) {
                            Image(systemName: "doc.text.fill").font(.title3).foregroundColor(.themeTextSecondary)
                        }
                    }
                    
                    // Tombol Tambah Transaksi
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.themePrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView(viewModel: viewModel, branchId: branchId)
        }
        .onAppear {
            Task {
                await viewModel.loadRecords(branchId: branchId)
                generatePDF()
            }
        }
    }
    
    private func generatePDF() {
        let simpleReportView = VStack(spacing: 20) {
            Text("Laporan Keuangan Dagify")
                .font(.largeTitle)
                .bold()
            
            HStack {
                Text("Total Pemasukan:")
                Spacer()
                Text("Rp \(viewModel.totalIncome, specifier: "%.0f")").foregroundColor(.green)
            }
            HStack {
                Text("Total Pengeluaran:")
                Spacer()
                Text("Rp \(viewModel.totalExpense, specifier: "%.0f")").foregroundColor(.red)
            }
            HStack {
                Text("Laba Bersih:")
                Spacer()
                Text("Rp \(viewModel.netProfit, specifier: "%.0f")").bold()
            }
        }
        .padding()
        .frame(width: 400, height: 600)
        
        self.generatedPDFURL = PDFGeneratorService.renderViewToPDF(view: simpleReportView, filename: "Laporan_Keuangan_\(branchId)")
    }
}
