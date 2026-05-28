//
//  InventoryViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Combine
import Foundation

@MainActor
class InventoryViewModel: ObservableObject {
     var ingredients: [Ingredient] = []
     var isLoading: Bool = false
     var errorMessage: String? = nil
    
    private let repo: OperationalRepository
    
     init(repo: OperationalRepository) {
        self.repo = repo
    }
    
     var lowStockIngredients: [Ingredient] {
        ingredients.filter { $0.currentStock <= $0.minimumStockWarning }
    }
    
     var expiredIngredients: [Ingredient] {
        let today = Date()
        return ingredients.filter { ingredient in
            guard let expiry = ingredient.expiryDate else { return false }
            return expiry < today
        }
    }
    
    func loadIngredients(branchId: String) async {
        isLoading = true
        do {
            ingredients = try await repo.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data gudang."
        }
        isLoading = false
    }
    
    func discardExpiredItem(ingredient: Ingredient, branchId: String) async {
        guard let id = ingredient.id else { return }
        
        isLoading = true
        do {
            _ = try await repo.recordWaste(ingredientId: id, amountToDeduct: ingredient.currentStock)
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal membuang stok basi."
        }
        isLoading = false
    }
}
