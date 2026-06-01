//
//  AddTransactionView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var amount: Double = 0
    @State private var isIncome = true
    @State private var notes = ""
    @State private var selectedCategory: ExpenseCategory = .operational
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tipe Transaksi")) { Picker("Tipe", selection: $isIncome) { Text("Pendapatan").tag(true); Text("Pengeluaran").tag(false) }.pickerStyle(.segmented).listRowBackground(Color.clear) }
                Section(header: Text("Detail")) {
                    HStack { Text("Nominal (Rp)").foregroundColor(.dagifyTextPrimary); Spacer(); TextField("0", value: $amount, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing).foregroundColor(.dagifyPrimary).bold() }
                    if !isIncome { Picker("Kategori", selection: $selectedCategory) { ForEach(ExpenseCategory.allCases.filter { $0 != .none }) { Text($0.rawValue).tag($0) } } }
                    TextField("Catatan", text: $notes)
                }
            }.navigationTitle("Catat Transaksi").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task { await viewModel.addTransaction(amount: amount, type: isIncome ? .income : .expense, category: isIncome ? .none : selectedCategory, notes: notes.isEmpty ? (isIncome ? "Pendapatan" : "Pengeluaran") : notes, branchId: branchId, context: context); dismiss() }
                    }.disabled(amount <= 0 || viewModel.isLoading)
                }
            }
        }
    }
}
