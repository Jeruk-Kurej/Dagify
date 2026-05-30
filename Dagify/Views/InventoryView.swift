//
//  InventoryView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId = "B-1"
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Menghitung sisa pasokan...").frame(maxHeight: .infinity)
            } else if viewModel.ingredients.isEmpty {
                ContentUnavailableView("Gudang Kosong", systemImage: "shippingbox", description: Text("Bahan baku belum diinput."))
            } else {
                List(viewModel.ingredients) { ingredient in
                    HStack(spacing: 16) {
                        Image(systemName: "shippingbox.fill")
                            .font(.title2).foregroundColor(.themeTextSecondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name).font(.headline).foregroundColor(.themeTextPrimary)
                            Text("Stok Aktif: \(ingredient.currentStock, specifier: "%.1f") \(ingredient.unit)").font(.subheadline).foregroundColor(.themeTextSecondary)
                        }
                        Spacer()
                        
                        if let expiry = ingredient.expiryDate, expiry < Date() {
                            VStack(alignment: .trailing, spacing: 4) {
                                Image(systemName: "xmark.octagon.fill").foregroundColor(.themeDestructive)
                                Text("Basi").font(.caption2).foregroundColor(.themeDestructive)
                            }
                        } else if ingredient.currentStock <= ingredient.minimumStockWarning {
                            VStack(alignment: .trailing, spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.themeWarning)
                                Text("Stok Menipis").font(.caption2).foregroundColor(.themeWarning)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if let expiry = ingredient.expiryDate, expiry < Date() {
                            Button(role: .destructive) {
                                Task { await viewModel.discardExpiredItem(ingredient: ingredient, branchId: branchId) }
                            } label: { Label("Buang Waste", systemImage: "trash.fill") }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Gudang Inventaris")
        .onAppear { Task { await viewModel.loadIngredients(branchId: branchId) } }
    }
}
#Preview {
    //InventoryView()
}
