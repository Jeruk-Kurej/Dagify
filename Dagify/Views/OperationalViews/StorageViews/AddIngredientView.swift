//
//  StorageViews.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import SwiftUI

struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: InventoryViewModel
    let branchId: String

    @State private var name = ""
    @State private var currentStock = ""
    @State private var unit = "Kg"
    @State private var minimumStockWarning = ""
    @State private var costPerUnit = ""
    @State private var hasExpiry = false
    @State private var expiryDate = Date()

    let units = ["Kg", "Gram", "Liter", "Ml", "Pcs", "Box", "Cup"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Utama") {
                    TextField("Nama Bahan (Cth: Biji Kopi Arabica)", text: $name)
                    HStack {
                        TextField("Stok Awal", text: $currentStock).keyboardType(.decimalPad)
                        Picker("Satuan", selection: $unit) {
                            ForEach(units, id: \.self) { Text($0) }
                        }.pickerStyle(.menu)
                    }
                }
                
                Section("Harga Modal & Peringatan") {
                    TextField("Harga Modal per Satuan (Rp)", text: $costPerUnit).keyboardType(.decimalPad)
                    TextField("Batas Peringatan Stok Tipis", text: $minimumStockWarning).keyboardType(.decimalPad)
                }
                
                Section("Kedaluwarsa (Opsional)") {
                    Toggle("Ada Batas Kedaluwarsa?", isOn: $hasExpiry)
                        .tint(Color(hex: "#00A3A3"))
                    if hasExpiry {
                        DatePicker("Tanggal Basi", selection: $expiryDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Tambah Bahan Baku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task {
                            await viewModel.createIngredient(
                                branchId: branchId,
                                name: name,
                                currentStock: Double(currentStock.replacingOccurrences(of: ",", with: ".")) ?? 0,
                                unit: unit,
                                expiryDate: hasExpiry ? expiryDate : nil,
                                minimumStockWarning: Double(minimumStockWarning.replacingOccurrences(of: ",", with: ".")) ?? 0,
                                costPerUnit: Double(costPerUnit.replacingOccurrences(of: ",", with: ".")) ?? 0
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || currentStock.isEmpty || costPerUnit.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

