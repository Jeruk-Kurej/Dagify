//
//  CashflowView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI
import Charts

struct CashflowView: View {
    var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var showAddSheet = false
    @State private var generatedPDFURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        FinancialBox(title: "Total Pemasukan", amount: viewModel.totalIncome, color: .themeSuccess)
                        FinancialBox(title: "Total Pengeluaran", amount: viewModel.totalExpense, color: .themeDestructive)
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Arus Kas").font(.headline)
                            Spacer()
                            Picker("Periode", selection: $viewModel.selectedPeriod) {
                                ForEach(CashflowPeriod.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }.pickerStyle(.menu)
                        }
                        
                        if viewModel.chartData.isEmpty {
                            ContentUnavailableView("Tidak Ada Data", systemImage: "chart.bar.xaxis")
                                .frame(height: 200)
                        } else {
                            Chart {
                                ForEach(viewModel.chartData, id: \.period) { item in
                                    BarMark(x: .value("Periode", item.period), y: .value("Nominal", item.income))
                                        .foregroundStyle(Color.themeSuccess).position(by: .value("Tipe", "Pemasukan"))
                                    BarMark(x: .value("Periode", item.period), y: .value("Nominal", item.expense))
                                        .foregroundStyle(Color.themeDestructive).position(by: .value("Tipe", "Pengeluaran"))
                                }
                            }
                            .chartForegroundStyleScale(["Pemasukan": Color.themeSuccess, "Pengeluaran": Color.themeDestructive])
                            .frame(height: 250)
                        }
                    }.padding().background(Color.themeBgSecondary).cornerRadius(12).padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Riwayat Transaksi").font(.headline).padding(.horizontal)
                        ForEach(viewModel.groupedRecordsByMonth, id: \.month) { group in
                            VStack(alignment: .leading) {
                                Text(group.month).font(.subheadline).bold().foregroundColor(.themeTextSecondary).padding(.horizontal)
                                ForEach(group.records) { record in
                                    HStack {
                                        Image(systemName: record.type == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                                            .foregroundColor(record.type == .income ? .themeSuccess : .themeDestructive)
                                        VStack(alignment: .leading) {
                                            Text(record.notes).font(.body).bold()
                                            Text(record.category.rawValue).font(.caption).foregroundColor(.themeTextSecondary)
                                        }
                                        Spacer()
                                        Text("Rp \(record.amount, specifier: "%.0f")").bold()
                                    }
                                    .padding().background(Color.themeBgSecondary).cornerRadius(8).padding(.horizontal)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            Task { await viewModel.deleteTransaction(recordId: record.id ?? "", branchId: branchId) }
                                        } label: { Label("Hapus", systemImage: "trash") }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.vertical)
            }
            .navigationTitle("Arus Kas")
            .background(Color.themeBgMain)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        if let pdfURL = generatedPDFURL {
                            ShareLink(item: pdfURL) { Image(systemName: "square.and.arrow.up").font(.title3).foregroundColor(.themePrimary) }
                        } else {
                            Button(action: generatePDF) { Image(systemName: "doc.text.fill").font(.title3).foregroundColor(.themeTextSecondary) }
                        }
                        Button(action: { showAddSheet = true }) { Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.themePrimary) }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) { AddTransactionView(viewModel: viewModel, branchId: branchId) }
            .onAppear { Task { await viewModel.loadRecords(branchId: branchId); generatePDF() } }
        }
    }
    
    private func generatePDF() {
        let reportView = VStack(spacing: 20) {
            Text("Laporan Keuangan Dagify").font(.largeTitle).bold()
            HStack { Text("Total Pemasukan:"); Spacer(); Text("Rp \(viewModel.totalIncome, specifier: "%.0f")").foregroundColor(.green) }
            HStack { Text("Total Pengeluaran:"); Spacer(); Text("Rp \(viewModel.totalExpense, specifier: "%.0f")").foregroundColor(.red) }
            HStack { Text("Laba Bersih:"); Spacer(); Text("Rp \(viewModel.netProfit, specifier: "%.0f")").bold() }
        }.padding().frame(width: 400, height: 600)
        self.generatedPDFURL = PDFGeneratorService.renderViewToPDF(view: reportView, filename: "Laporan_Keuangan_\(branchId)")
    }
}
