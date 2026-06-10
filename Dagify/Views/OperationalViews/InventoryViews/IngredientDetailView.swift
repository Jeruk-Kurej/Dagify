//
//  IngredientDetailView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

import SwiftUI

struct IngredientDetailView: View {
    var ingredient: Ingredient
    var viewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingRestock = false
    @State private var restockAmount = ""
    @State private var restockCost = ""
    @State private var hasExpiry = false
    @State private var restockExpiry = Date()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informasi Utama")) {
                    LabeledContent("Nama Bahan", value: ingredient.name)
                    LabeledContent("Total Stok", value: "\(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)")
                        .fontWeight(.bold)
                    LabeledContent("Harga Rata-rata", value: ingredient.costPerUnit.toRupiah())
                    LabeledContent("Batas Peringatan", value: "\(String(format: "%.1f", ingredient.minimumStockWarning)) \(ingredient.unit)")
                }
                
                Section(header: Text("Riwayat Stok (Batches)")) {
                    let activeBatches = ingredient.batches.filter { $0.currentStock > 0 }
                    if activeBatches.isEmpty {
                        Text("Tidak ada stok tersedia.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(activeBatches.sorted(by: { ($0.expiryDate ?? Date.distantFuture) < ($1.expiryDate ?? Date.distantFuture) })) { batch in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("\(String(format: "%.1f", batch.currentStock)) \(ingredient.unit)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(batch.costPerUnit.toRupiah())
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let expiry = batch.expiryDate {
                                    Text("Basi: \(expiry.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(expiry < Date() ? .red : .orange)
                                } else {
                                    Text("Tidak ada batas basi")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Masuk: \(batch.dateAdded.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Button(action: { isShowingRestock = true }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                        Text("Tambah Stok (Refill)")
                        Spacer()
                    }
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Detail Bahan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
            .sheet(isPresented: $isShowingRestock) {
                NavigationStack {
                    Form {
                        Section("Jumlah & Harga") {
                            HStack {
                                TextField("Stok Ditambahkan", text: $restockAmount).keyboardType(.decimalPad)
                                Text(ingredient.unit)
                            }
                            TextField("Harga per Satuan (Rp)", text: $restockCost).keyboardType(.decimalPad)
                        }
                        Section("Kedaluwarsa") {
                            Toggle("Ada Batas Kedaluwarsa?", isOn: $hasExpiry)
                                .tint(Color(hex: "#00A3A3"))
                            if hasExpiry {
                                DatePicker("Tanggal Basi", selection: $restockExpiry, displayedComponents: .date)
                            }
                        }
                    }
                    .navigationTitle("Refill Stok")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Batal") { isShowingRestock = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Simpan") {
                                Task {
                                    let amount = Double(restockAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
                                    let cost = Double(restockCost.replacingOccurrences(of: ",", with: ".")) ?? 0
                                    let expiry = hasExpiry ? restockExpiry : nil
                                    await viewModel.restockIngredient(ingredient: ingredient, addedStock: amount, costPerUnit: cost, expiryDate: expiry)
                                    isShowingRestock = false
                                }
                            }
                            .disabled(restockAmount.isEmpty || restockCost.isEmpty || viewModel.isLoading)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

