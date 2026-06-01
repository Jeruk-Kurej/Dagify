//
//  CashflowView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI
import Charts

struct CashflowView: View {
    @Environment(\.modelContext) private var context
    @Bindable var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var showAddSheet = false; @State private var showPDFShare = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) { FinancialBox(title: "Pemasukan", amount: viewModel.totalIncome, color: .dagifySuccess); FinancialBox(title: "Pengeluaran", amount: viewModel.totalExpense, color: .dagifyDestructive) }.padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack { Text("Arus Kas").font(.title3).bold().foregroundColor(.dagifyTextPrimary); Spacer(); Picker("Periode", selection: $viewModel.selectedPeriod) { ForEach(ChartPeriod.allCases) { Text($0.rawValue).tag($0) } }.pickerStyle(.menu).tint(.dagifyPrimary) }
                        if viewModel.chartData.isEmpty { ContentUnavailableView("Belum Ada Transaksi", systemImage: "chart.bar.xaxis").frame(height: 220) }
                        else {
                            Chart { ForEach(viewModel.chartData, id: \.date) { item in BarMark(x: .value("Tanggal", item.date), y: .value("Nominal", item.income)).foregroundStyle(Color.dagifySuccess).position(by: .value("Tipe", "Pemasukan")); BarMark(x: .value("Tanggal", item.date), y: .value("Nominal", item.expense)).foregroundStyle(Color.dagifyDestructive).position(by: .value("Tipe", "Pengeluaran")) } }
                            .chartForegroundStyleScale(["Pemasukan": Color.dagifySuccess, "Pengeluaran": Color.dagifyDestructive]).frame(height: 250)
                        }
                    }.padding(16).background(Color.dagifySecBG).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Riwayat Transaksi").font(.title3).bold().foregroundColor(.dagifyTextPrimary).padding(.horizontal, 16)
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.groupedRecords, id: \.month) { group in
                                Section(header: Text(group.month).font(.subheadline).bold().foregroundColor(.dagifyTextSec).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16)) {
                                    ForEach(group.records) { record in
                                        HStack(spacing: 16) {
                                            Circle().fill(record.type == .income ? Color.dagifySuccess.opacity(0.15) : Color.dagifyDestructive.opacity(0.15)).frame(width: 48, height: 48).overlay(Image(systemName: record.type == .income ? "arrow.down.left" : "arrow.up.right").foregroundColor(record.type == .income ? .dagifySuccess : .dagifyDestructive).font(.system(size: 20, weight: .bold)))
                                            VStack(alignment: .leading, spacing: 4) { Text(record.notes).font(.body).bold().foregroundColor(.dagifyTextPrimary); Text(record.category.rawValue).font(.caption).foregroundColor(.dagifyTextSec) }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) { Text("\(record.type == .income ? "+" : "-") Rp \(record.amount, specifier: "%.0f")").font(.body).bold().foregroundColor(record.type == .income ? .dagifySuccess : .dagifyTextPrimary); if !record.isSynced { Image(systemName: "icloud.slash").font(.caption2).foregroundColor(.dagifyWarning) } }
                                        }.padding(16).background(Color.dagifySecBG).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal, 16)
                                        .swipeActions(edge: .trailing) { Button(role: .destructive) { Task { await viewModel.deleteTransaction(record, branchId: branchId, context: context) } } label: { Label("Hapus", systemImage: "trash") } }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.vertical, 16)
            }.background(Color.dagifyMainBG.ignoresSafeArea()).navigationTitle("Arus Kas")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { HStack(spacing: 16) { Button { viewModel.requestPDFGeneration(branchId: branchId); if viewModel.generatedPDFURL != nil { showPDFShare = true } } label: { Image(systemName: "printer.fill").foregroundColor(.dagifyPrimary) }; Button { showAddSheet = true } label: { Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.dagifyPrimary) } } } }
            .sheet(isPresented: $showAddSheet) { AddTransactionView(viewModel: viewModel, branchId: branchId) }
            .sheet(isPresented: $showPDFShare) { if let url = viewModel.generatedPDFURL { ShareSheet(activityItems: [url]) } }
            .onAppear { viewModel.loadData(branchId: branchId, context: context) }
        }
    }
}
