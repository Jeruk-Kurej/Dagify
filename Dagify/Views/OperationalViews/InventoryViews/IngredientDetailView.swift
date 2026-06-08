//
//  IngredientDetailView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

// MARK: - Ingredient Detail View
struct IngredientDetailView: View {
    // MARK: - Properties
    var ingredient: Ingredient
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Primary Info Section
                Section(header: Text("Informasi Utama")) {
                    LabeledContent("Nama Bahan", value: ingredient.name)
                    LabeledContent("Stok Gudang", value: "\(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)")
                    LabeledContent("Harga Satuan", value: ingredient.costPerUnit.toRupiah())
                    LabeledContent("Estimasi Aset", value: (ingredient.currentStock * ingredient.costPerUnit).toRupiah())
                        .fontWeight(.bold)
                }
                
                // MARK: - Warning & Limits Section
                Section(header: Text("Peringatan & Batas Waktu")) {
                    LabeledContent("Batas Stok Minim", value: "\(String(format: "%.1f", ingredient.minimumStockWarning)) \(ingredient.unit)")
                        .foregroundColor(.orange)
                    
                    if let expiry = ingredient.expiryDate {
                        LabeledContent("Tgl Kedaluwarsa", value: expiry.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(expiry < Date() ? .red : .primary)
                    } else {
                        LabeledContent("Tgl Kedaluwarsa", value: "Tidak Ada Batas")
                    }
                }
            }
            .navigationTitle("Detail Bahan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    IngredientDetailView(ingredient: Ingredient(branchId: "B-1", name: "Biji Kopi", currentStock: 5.0, unit: "Kg", minimumStockWarning: 2.0, costPerUnit: 150000))
}
