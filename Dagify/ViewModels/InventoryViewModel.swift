//
//  InventoryViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation

@MainActor
@Observable
class InventoryViewModel {
    var ingredients: [Ingredient] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    /// Returns a list of expired ingredients that still have stock remaining.
    var expiredIngredients: [Ingredient] {
        let today = Date()
        return ingredients.filter { ingredient in
            guard let expiry = ingredient.expiryDate else { return false }
            return expiry < today && ingredient.currentStock > 0
        }
    }
    
    var lowStockIngredients: [Ingredient] {
        return ingredients.filter {
            $0.currentStock <= $0.minimumStockWarning
        }
    }
    
    /// Returns a list of ingredients that need attention (either expired or low stock).
    var attentionIngredients: [Ingredient] {
        let expiredIds = expiredIngredients.compactMap { $0.id }
        let lowStockIds = lowStockIngredients.compactMap { $0.id }
        let combinedIds = Set(expiredIds + lowStockIds)
        
        return ingredients.filter { combinedIds.contains($0.id ?? "") }
    }
    
    private let operationalProtocol: OperationalProtocol
    private let cashflowProtocol: CashflowProtocol
    
    init(operationalProtocol: OperationalProtocol, cashflowProtocol: CashflowProtocol) {
        self.operationalProtocol = operationalProtocol
        self.cashflowProtocol = cashflowProtocol
    }
    
    func loadIngredients(branchId: String) async {
        isLoading = true
        do {
            ingredients = try await operationalProtocol.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data gudang."
        }
        isLoading = false
    }
    
    func createIngredient(branchId: String, name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double, costPerUnit: Double) async {
        guard !name.isEmpty, currentStock >= 0 else {
            errorMessage = "Nama bahan baku tidak boleh kosong dan stok harus valid."
            return
        }
        isLoading = true
        
        /// Cek apakah tipe bahan baku dengan nama yang persis sama sudah ada
        if let existingIngredient = ingredients.first(where: { $0.name.lowercased() == name.lowercased() }) {
            /// Jika ada, catat sebagai model (batch) baru di dalam tipe bahan tersebut (Restock)
            await restockIngredient(
                ingredient: existingIngredient,
                addedStock: currentStock,
                costPerUnit: costPerUnit,
                expiryDate: expiryDate
            )
            return
        }
        
        let initialBatch = IngredientBatch(currentStock: currentStock, expiryDate: expiryDate, costPerUnit: costPerUnit)
        let newIngredient = Ingredient(
            branchId: branchId,
            name: name,
            unit: unit,
            minimumStockWarning: minimumStockWarning,
            batches: [initialBatch]
        )
        let totalCost = currentStock * costPerUnit
        
        do {
            _ = try await operationalProtocol.addIngredient(newIngredient)
            
            if totalCost > 0 {
                let expenseRecord = FinancialRecord(
                    id: UUID().uuidString,
                    branchId: branchId,
                    amount: totalCost,
                    type: .expense,
                    category: .cogs,
                    timestamp: Date(),
                    notes: "Beli Bahan: \(name)"
                )
                _ = try await cashflowProtocol.addRecord(expenseRecord)
            }
            
            // Jadwalkan notifikasi kadaluwarsa
            NotificationService.shared.scheduleExpiryWarning(for: newIngredient)
            
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal menyimpan bahan baku."
        }
        isLoading = false
    }
    
    func restockIngredient(ingredient: Ingredient, addedStock: Double, costPerUnit: Double, expiryDate: Date?) async {
        guard addedStock > 0 else { return }
        isLoading = true
        
        var updated = ingredient
        let newBatch = IngredientBatch(currentStock: addedStock, expiryDate: expiryDate, costPerUnit: costPerUnit)
        updated.batches.append(newBatch)
        
        let totalCost = addedStock * costPerUnit
        
        do {
            _ = try await operationalProtocol.updateIngredient(updated)
            
            if totalCost > 0 {
                let expenseRecord = FinancialRecord(
                    id: UUID().uuidString,
                    branchId: ingredient.branchId,
                    amount: totalCost,
                    type: .expense,
                    category: .cogs,
                    timestamp: Date(),
                    notes: "Refill Bahan: \(ingredient.name)"
                )
                _ = try await cashflowProtocol.addRecord(expenseRecord)
            }
            
            // Perbarui jadwal notifikasi dengan data terbaru
            NotificationService.shared.scheduleExpiryWarning(for: updated)
            
            await loadIngredients(branchId: ingredient.branchId)
        } catch {
            errorMessage = "Gagal menambah stok bahan baku."
        }
        isLoading = false
    }
    
    func discardExpiredItem(ingredient: Ingredient, branchId: String) async {
        guard let id = ingredient.id else { return }
        isLoading = true
        do {
            let today = Date()
            var updated = ingredient
            var totalDiscarded: Double = 0
            
            for i in 0..<updated.batches.count {
                if let exp = updated.batches[i].expiryDate, exp < today, updated.batches[i].currentStock > 0 {
                    totalDiscarded += updated.batches[i].currentStock
                    updated.batches[i].currentStock = 0
                }
            }
            
            if totalDiscarded > 0 {
                _ = try await operationalProtocol.recordWaste(ingredientId: id, amountToDeduct: totalDiscarded)
                _ = try await operationalProtocol.updateIngredient(updated)
                await loadIngredients(branchId: branchId)
            }
        } catch {
            errorMessage = "Gagal membuang stok basi."
        }
        isLoading = false
    }
    
    func updateIngredient(ingredient: Ingredient) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.updateIngredient(ingredient)
            await loadIngredients(branchId: ingredient.branchId)
        } catch {
            errorMessage = "Gagal memperbarui bahan baku."
        }
        isLoading = false
    }
    
    func deleteIngredient(ingredientId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.deleteIngredient(ingredientId: ingredientId)
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal menghapus bahan baku."
        }
        isLoading = false
    }
}
