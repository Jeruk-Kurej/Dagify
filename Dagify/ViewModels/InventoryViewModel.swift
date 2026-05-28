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
    public var ingredients: [Ingredient] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let repo: OperationalRepository
    
    public init(repo: OperationalRepository) {
        self.repo = repo
    }
    
    public func loadIngredients(branchId: String) async {
        isLoading = true
        do {
            ingredients = try await repo.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data gudang."
        }
        isLoading = false
    }
    
    public var lowStockIngredients: [Ingredient] {
        ingredients.filter { $0.currentStock <= $0.minimumStockWarning }
    }
    
    public var expiredIngredients: [Ingredient] {
        let today = Date()
        return ingredients.filter { ingredient in
            guard let expiry = ingredient.expiryDate else { return false }
            return expiry < today
        }
    }
}
