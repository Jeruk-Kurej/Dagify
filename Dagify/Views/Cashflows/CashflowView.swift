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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        FinancialBox(title: "Pemasukan", amount: viewModel.totalIncome, color: .themeSuccess)
                        FinancialBox(title: "Pengeluaran", amount: viewModel.totalExpense, color: .themeDestructive)
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Arus Kas").font(.headline)
                            Spacer()
                            Picker("Periode", selection: $viewModel.selectedPeriod) {
                                ForEach(ChartPeriod.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                            }.pickerStyle(.menu)
                        }
                        
                        if viewModel.chartData.isEmpty {
                            ContentUnavailableView("Tidak Ada Data", systemImage: "chart.bar.xaxis").frame(height: 200)
                        } else {
                            Chart {
                                ForEach(viewModel.chartData, id: \.date) { item in
                                    BarMark(x: .value("Tanggal", item.date), y: .value("Nominal", item.income))
                                        .foregroundStyle(Color.themeSuccess).position(by: .value("Tipe", "Pemasukan"))
                                    BarMark(x: .value("Tanggal", item.date), y: .value("Nominal", item.expense))
                                        .foregroundStyle(Color.themeDestructive).position(by: .value("Tipe", "Pengeluaran"))
                                }
                            }.chartForegroundStyleScale(["Pemasukan": Color.themeSuccess, "Pengeluaran": Color.themeDestructive]).frame(height: 250)
                        }
                    }.padding().background(Color.themeBgSecondary).cornerRadius(12).padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Riwayat Transaksi").font(.headline).padding(.horizontal)
                        ForEach(viewModel.groupedRecordsByMonth, id: \.month) { group in
                            VStack(alignment: .leading) {
                                Text(group.month).font(.subheadline).bold().foregroundColor(.themeTextSecondary).padding(.horizontal)
                                ForEach(group.records) { record in
                                    HStack {
                                        Image(systemName: record.type == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill").foregroundColor(record.type == .income ? .themeSuccess : .themeDestructive)
                                        VStack(alignment: .leading) {
                                            Text(record.notes).font(.body).bold()
                                            Text(record.category.rawValue).font(.caption).foregroundColor(.themeTextSecondary)
                                        }
                                        Spacer()
                                        Text("Rp \(record.amount, specifier: "%.0f")").bold()
                                    }.padding().background(Color.themeBgSecondary).cornerRadius(8).padding(.horizontal)
                                    .swipeActions { Button(role: .destructive) { Task { await viewModel.deleteTransaction(recordId: record.id ?? "", branchId: branchId) } } label: { Label("Hapus", systemImage: "trash") } }
                                }
                            }
                        }
                    }
                }.padding(.vertical)
            }.navigationTitle("Arus Kas").background(Color.themeBgMain)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        if let pdfURL = viewModel.generatedPDFURL { ShareLink(item: pdfURL) { Image(systemName: "square.and.arrow.up").foregroundColor(.themePrimary) } }
                        Button(action: { showAddSheet = true }) { Image(systemName: "plus.circle.fill").foregroundColor(.themePrimary) }
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) { AddTransactionView(viewModel: viewModel, branchId: branchId) }
            .onAppear { Task { await viewModel.loadRecords(branchId: branchId); viewModel.generateFinancialReport(branchId: branchId) } }
        }
    }
}
