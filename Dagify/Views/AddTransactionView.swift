//
//  AddTransactionView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

// MARK: - Form Tambah Pendapatan & Pengeluaran
struct AddTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var amount: Double = 0
    @State private var isIncome = true
    @State private var notes = ""
    
    @State private var selectedCategory: ExpenseCategory = .operational
    
    let categories: [ExpenseCategory] = [.cogs, .operational, .incidental, .none]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Jenis Transaksi")) {
                    Picker("Tipe", selection: $isIncome) {
                        Text("Pendapatan / Masuk").tag(true)
                        Text("Pengeluaran / Keluar").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Detail Finansial")) {
                    HStack {
                        Text("Nominal (Rp)")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !isIncome {
                        Picker("Kategori", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                    }
                    
                    TextField("Catatan Tambahan (Opsional)", text: $notes)
                }
                
                if let err = viewModel.errorMessage {
                    Section {
                        Text(err).font(.caption).foregroundColor(.themeDestructive)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            let transactionType = isIncome ? TransactionType.income : TransactionType.expense
                            
                            let categoryType = isIncome ? ExpenseCategory.none : selectedCategory
                            
                            await viewModel.addTransaction(
                                branchId: branchId,
                                amount: amount,
                                type: transactionType,
                                category: categoryType,
                                notes: notes.isEmpty ? "Tanpa Catatan" : notes
                            )
                            
                            if viewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Simpan Transaksi").bold()
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(amount <= 0 || viewModel.isLoading ? Color.themeBorder : Color.themePrimary)
                    .disabled(amount <= 0 || viewModel.isLoading)
                }
            }
            .navigationTitle("Catat Keuangan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
        }
    }
}
