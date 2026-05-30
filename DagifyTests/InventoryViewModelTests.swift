//
//  InventoryViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("Inventory ViewModel Tests")
@MainActor
struct InventoryViewModelTests {
    
    @Test("Test Deteksi Stok Menipis & Kadaluwarsa")
    func testStockAlerts() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let ing1 = Ingredient(name: "Gula", currentStock: 1, unit: "kg", expiryDate: Date().addingTimeInterval(86400), minimumStockWarning: 5, costPerUnit: 10000)
        let ing2 = Ingredient(name: "Susu", currentStock: 10, unit: "L", expiryDate: Date().addingTimeInterval(-86400), minimumStockWarning: 2, costPerUnit: 15000)
        
        mockOp.dummyIngredients = [ing1, ing2]
        await vm.loadIngredients(branchId: "B1")
        
        #expect(vm.lowStockIngredients.contains { $0.name == "Gula" } == true)
        #expect(vm.expiredIngredients.contains { $0.name == "Susu" } == true)
    }
    
    @Test("Test Buang Bahan Basi (Waste to Cashflow)")
    func testDiscardExpiredItem() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let ing = Ingredient(id: "I-1", name: "Susu Basi", currentStock: 2, unit: "L", expiryDate: Date().addingTimeInterval(-86400), minimumStockWarning: 5, costPerUnit: 10000)
        mockOp.dummyIngredients = [ing]
        
        await vm.loadIngredients(branchId: "B1")
        await vm.discardExpiredItem(ingredient: ing, branchId: "B1")
        
        let cashflowRecords = try? await mockCash.fetchRecords(for: "B1")
        #expect(cashflowRecords?.count == 1)
        #expect(cashflowRecords?.first?.amount == 20000)
    }
}
