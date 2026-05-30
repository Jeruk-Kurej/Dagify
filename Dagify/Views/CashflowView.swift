//
//  CashflowView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

struct CashflowView: View {
    var viewModel: CashflowViewModel
    let branchId = "B-1"
    @State private var showAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                FinancialBox(title: "Total Pemasukan", amount: viewModel.totalIncome, color: .themeSuccess)
                FinancialBox(title: "Total Pengeluaran", amount: viewModel.totalExpense, color: .themeDestructive)
            }
            .padding().background(Color.themeBgMain)
            
            if viewModel.isLoading {
                ProgressView("Menyusun pembukuan...").frame(maxHeight: .infinity)
            } else {
                List(viewModel.records) { record in
                    HStack {
                        Image(systemName: record.type == .income ? "arrow.down.left.circle.fill" : "arrow.up.right.circle.fill")
                            .font(.title2).foregroundColor(record.type == .income ? .themeSuccess : .themeDestructive)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.notes).font(.body).bold().foregroundColor(.themeTextPrimary)
                            Text(record.category.rawValue).font(.caption).foregroundColor(.themeTextSecondary)
                        }
                        Spacer()
                        Text("Rp \(record.amount, specifier: "%.0f")").font(.subheadline).bold()
                            .foregroundColor(record.type == .income ? .themeSuccess : .themeTextPrimary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Arus Kas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.themePrimary)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionSheet(viewModel: viewModel, branchId: branchId)
        }
        .onAppear { Task { await viewModel.loadRecords(branchId: branchId) } }
    }
}
