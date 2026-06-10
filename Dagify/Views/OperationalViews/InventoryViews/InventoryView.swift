//
//  InventoryView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

enum InventorySheetType: Identifiable {
    case add
    case edit(Ingredient)
    case detail(Ingredient)
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let i): return "edit_\(i.id ?? UUID().uuidString)"
        case .detail(let i): return "detail_\(i.id ?? UUID().uuidString)"
        }
    }
}

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId: String
    
    @State private var activeSheet: InventorySheetType? = nil
    
    /// State to hold the item awaiting confirmation.
    @State private var ingredientToDiscard: Ingredient? = nil
    @State private var ingredientToDelete: Ingredient? = nil
    
    @ViewBuilder
    private func rowForIngredient(_ item: Ingredient, isExp: Bool, isLow: Bool) -> some View {
        IngredientRowView(
            ingredient: item,
            isExpired: isExp,
            isLowStock: isLow
        ) {
            ingredientToDiscard = item
        }
        .contentShape(Rectangle())
        .onTapGesture { activeSheet = .detail(item) }
        .contextMenu {
            Button { activeSheet = .edit(item) } label: { Label("Edit Bahan", systemImage: "pencil") }
            Button(role: .destructive) {
                ingredientToDelete = item
            } label: { Label("Hapus Bahan", systemImage: "trash") }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.ingredients.isEmpty {
                ProgressView("Memuat data gudang...")
            } else if viewModel.ingredients.isEmpty {
                ContentUnavailableView("Gudang Kosong", systemImage: "shippingbox", description: Text("Bahan baku belum ditambahkan."))
            } else {
                List {
                    /// Uses combined list for expired and low stock.
                    if !viewModel.attentionIngredients.isEmpty {
                        Section {
                            ForEach(viewModel.attentionIngredients, id: \.id) { item in
                                let isExp = viewModel.expiredIngredients.contains(item)
                                let isLow = viewModel.lowStockIngredients.contains(item)
                                
                                rowForIngredient(item, isExp: isExp, isLow: isLow)
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("PERHATIAN SEGERA").foregroundColor(Color(hex: "#EF4444")).fontWeight(.bold)
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) { Image(systemName: "trash.fill").foregroundColor(Color(hex: "#EF4444")); Text("Basi") }
                                    HStack(spacing: 4) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color(hex: "#F59E0B")); Text("Stok Minim") }
                                }
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .textCase(.none)
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.ingredients, id: \.id) { item in
                            // Tampilkan jika tidak ada di grup perhatian
                            if !viewModel.attentionIngredients.contains(item) {
                                rowForIngredient(item, isExp: false, isLow: false)
                            }
                        }
                    } header: { Text("STOK AMAN") }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .navigationTitle("Gudang")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { activeSheet = .add }) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .add:
                AddIngredientView(viewModel: viewModel, branchId: branchId)
            case .edit(let ingredient):
                AddIngredientView(viewModel: viewModel, branchId: branchId, ingredientToEdit: ingredient)
            case .detail(let ingredient):
                IngredientDetailView(ingredient: ingredient, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
            }
        }
        .onAppear { Task { await viewModel.loadIngredients(branchId: branchId) } }
        .refreshable { await viewModel.loadIngredients(branchId: branchId) }
        
        /// Confirmation alert for discarding expired stock.
        .alert("Buang Stok Basi?", isPresented: Binding<Bool>(
            get: { ingredientToDiscard != nil },
            set: { if !$0 { ingredientToDiscard = nil } }
        )) {
            Button("Batal", role: .cancel) { ingredientToDiscard = nil }
            Button("Ya, Buang", role: .destructive) {
                if let item = ingredientToDiscard {
                    Task { await viewModel.discardExpiredItem(ingredient: item, branchId: branchId) }
                }
            }
        } message: {
            if let item = ingredientToDiscard {
                Text("Apakah Anda yakin ingin membuang sisa '\(item.name)'? Stok akan diubah menjadi 0. Aksi ini tidak dapat dibatalkan.")
            }
        }
        
        .alert("Hapus Bahan Baku?", isPresented: Binding<Bool>(
            get: { ingredientToDelete != nil },
            set: { if !$0 { ingredientToDelete = nil } }
        )) {
            Button("Batal", role: .cancel) { ingredientToDelete = nil }
            Button("Hapus", role: .destructive) {
                if let id = ingredientToDelete?.id {
                    Task { await viewModel.deleteIngredient(ingredientId: id, branchId: branchId) }
                }
            }
        } message: {
            if let item = ingredientToDelete {
                Text("Apakah Anda yakin ingin menghapus '\(item.name)' secara permanen dari daftar gudang? Aksi ini tidak dapat dibatalkan.")
            }
        }
    }
}
