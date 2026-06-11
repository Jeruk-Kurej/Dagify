//
//  InventoryViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Testing

@testable import Dagify

@Suite("Inventory ViewModel Tests")
@MainActor
struct InventoryViewModelTests {

    @Test("Fungsi: loadIngredients() - Skenario Berhasil")
    func testLoadIngredientsSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", branchId: "B-1", name: "Susu", unit: "L", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 10, costPerUnit: 15000)])
        let i2 = Ingredient(id: "2", branchId: "B-1", name: "Gula", unit: "Kg", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 2, costPerUnit: 12000)])
        mockOpRepo.ingredients = [i1, i2]

        await vm.loadIngredients(branchId: "B-1")

        #expect(vm.ingredients.count == 2)
        #expect(vm.lowStockIngredients.count == 1) // Gula is low stock
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: createIngredient() - Skenario Berhasil")
    func testCreateIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        await vm.createIngredient(branchId: "B-1", name: "Kopi", currentStock: 5, unit: "Kg", expiryDate: nil, minimumStockWarning: 2, costPerUnit: 50000)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.ingredients.count == 1)
        #expect(mockOpRepo.ingredients.first?.name == "Kopi")
        #expect(mockCashRepo.records.count == 1) // Should record expense
    }

    @Test("Fungsi: discardExpiredItem() - Skenario Berhasil")
    func testDiscardExpiredItemSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", branchId: "B-1", name: "Susu", unit: "L", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 10, costPerUnit: 15000)])
        mockOpRepo.ingredients = [i1]

        await vm.discardExpiredItem(ingredient: i1, branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.ingredients.first?.currentStock == 0)
    }

    @Test("Fungsi: updateIngredient() - Skenario Berhasil")
    func testUpdateIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        var i1 = Ingredient(id: "1", branchId: "B-1", name: "Susu", unit: "L", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 10, costPerUnit: 15000)])
        mockOpRepo.ingredients = [i1]

        i1.batches = [IngredientBatch(currentStock: 20, costPerUnit: 15000)]
        await vm.updateIngredient(ingredient: i1)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.ingredients.first?.currentStock == 20)
    }

    @Test("Fungsi: deleteIngredient() - Skenario Berhasil")
    func testDeleteIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", branchId: "B-1", name: "Susu", unit: "L", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 10, costPerUnit: 15000)])
        mockOpRepo.ingredients = [i1]

        await vm.deleteIngredient(ingredientId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.ingredients.isEmpty == true)
    }
}
