//
//  AddTransactionView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 30/05/26.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: CashflowViewModel
    let branchId: String
    
    @State private var amount: Double = 0
    @State private var isIncome = true
    @State private var notes = ""
    @State private var selectedCategory = "operational"
    
    let categories = ["operational", "incidental", "marketing", "supply"]
    
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
                            .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0.capitalized) }
                    }
                    
                    TextField("Catatan Tambahan", text: $notes)
                }
                
                Section {
                    Button(action: {
                        Task {
                            // Panggil fungsi createRecord bawaan dari ViewModel Anda
                            await viewModel.createRecord(
                                branchId: branchId,
                                amount: amount,
                                type: isIncome ? .income : .expense,
                                category: ExpenseCategory(rawValue: selectedCategory) ?? .operational,
                                notes: notes
                            )
                            dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Simpan Transaksi").bold()
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(amount <= 0 ? Color.themeBorder : Color.themePrimary)
                    .disabled(amount <= 0)
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
