//
//  InventoryView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId: String
    @State private var itemToRestock: Ingredient?; @State private var restockInput = ""
    
    var body: some View {
        Group {
            if viewModel.isLoading { ProgressView() }
            else if viewModel.ingredients.isEmpty { ContentUnavailableView("Gudang Kosong", systemImage: "shippingbox") }
            else {
                List(viewModel.ingredients) { ingredient in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(ingredient.name).font(.headline)
                            Text("Stok: \(ingredient.currentStock, specifier: "%.1f") \(ingredient.unit)").font(.subheadline).foregroundColor(.themeTextSecondary)
                        }
                        Spacer()
                        
                        if ingredient.isExpired { Image(systemName: "xmark.octagon.fill").foregroundColor(.themeDestructive) }
                        else if ingredient.isLowStock { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.themeWarning) }
                        else { Button("Restock") { itemToRestock = ingredient }.buttonStyle(.bordered) }
                    }.swipeActions {
                        if ingredient.isExpired { Button(role: .destructive) { Task { await viewModel.discardItem(ingredient: ingredient, branchId: branchId) } } label: { Label("Waste", systemImage: "trash") } }
                    }
                }.listStyle(.plain)
            }
        }
        .onAppear { Task { await viewModel.loadIngredients(branchId: branchId) } }
        .alert("Restock Bahan", isPresented: Binding(get: { itemToRestock != nil }, set: { if !$0 { itemToRestock = nil; restockInput = "" } })) {
            TextField("Jumlah Tambahan Masuk", text: $restockInput).keyboardType(.decimalPad)
            Button("Batal", role: .cancel) { itemToRestock = nil }
            Button("Simpan") {
                if let item = itemToRestock, let qty = Double(restockInput.replacingOccurrences(of: ",", with: ".")) { Task { await viewModel.restockItem(ingredientId: item.id ?? "", addedAmount: qty, branchId: branchId) } }
                itemToRestock = nil; restockInput = ""
            }
        }
    }
}


#Preview {
    //InventoryView()
}
