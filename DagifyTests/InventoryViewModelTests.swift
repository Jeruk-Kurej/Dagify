//
//  InventoryViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("InventoryViewModel Tests")
struct InventoryViewModelTests {
    
    @Test @MainActor func testDiscardExpiredItem() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = InventoryViewModel(repo: mockRepo)
        
        let basiIngredient = Ingredient(id: "I-99", name: "Susu", currentStock: 2.0, unit: "Liter", expiryDate: Date(), minimumStockWarning: 5.0, costPerUnit: 15000)
        
        await vm.discardExpiredItem(ingredient: basiIngredient, branchId: "B-1")
        
        #expect(vm.errorMessage == nil)
        #expect(vm.isLoading == false)
    }
}
