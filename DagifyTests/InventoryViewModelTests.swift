//
//  InventoryViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@MainActor
struct InventoryViewModelTests {
    
    @Test("1. Logika Restock dan Validasi Kadaluwarsa")
    func testRestockAndExpiry() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let viewModel = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let ing = Ingredient(id: "I1", name: "Susu", currentStock: 10, unit: "L", expiryDate: pastDate, minimumStockWarning: 5, costPerUnit: 15000)
        
        _ = try? await mockOp.addIngredient(ing, branchId: "B-1")
        await viewModel.loadIngredients(branchId: "B-1")
        
        let fetchedIng = viewModel.ingredients.first!
        #expect(fetchedIng.isExpired == true, "Validasi kadaluwarsa (Model) gagal")
        #expect(fetchedIng.isLowStock == false, "Validasi stok menipis (Model) gagal")
        
        await viewModel.discardItem(ingredient: fetchedIng, branchId: "B-1")
        await viewModel.loadIngredients(branchId: "B-1")
        #expect(viewModel.ingredients.first!.currentStock == 0, "Fungsi pembuangan stok basi gagal")
    }
}
