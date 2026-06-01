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
    let operationalProtocol: OperationalProtocol
    let cashflowProtocol: CashflowProtocol
    
    init(operationalProtocol: OperationalProtocol, cashflowProtocol: CashflowProtocol) {
        self.operationalProtocol = operationalProtocol; self.cashflowProtocol = cashflowProtocol
    }
    
    func loadIngredients(branchId: String) async {
        isLoading = true
        ingredients = (try? await operationalProtocol.fetchIngredients(for: branchId)) ?? []
        isLoading = false
    }
    
    func restockItem(ingredientId: String, addedAmount: Double, branchId: String) async {
        _ = try? await operationalProtocol.recordWaste(ingredientId: ingredientId, amountToDeduct: -addedAmount)
        await loadIngredients(branchId: branchId)
    }
    
    func discardItem(ingredient: Ingredient, branchId: String) async {
        _ = try? await operationalProtocol.recordWaste(ingredientId: ingredient.id ?? "", amountToDeduct: ingredient.currentStock)
        await loadIngredients(branchId: branchId)
    }
}

