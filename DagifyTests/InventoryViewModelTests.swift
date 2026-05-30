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
    
    @Test("Test Fungsi loadIngredients - Berhasil Mengambil Data Bahan Baku")
    func testLoadIngredients() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        mockOp.dummyIngredients = [
            Ingredient(id: "1", name: "Biji Kopi", currentStock: 10, unit: "kg", expiryDate: nil, minimumStockWarning: 2, costPerUnit: 50000)
        ]
        
        await vm.loadIngredients(branchId: "BRANCH-A")
        
        #expect(vm.ingredients.count == 1)
        #expect(vm.ingredients.first?.name == "Biji Kopi")
    }
    
    @Test("Test Properti lowStockIngredients - Berhasil Mendeteksi Stok Menipis")
    func testLowStockIngredientsAlert() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let gula = Ingredient(name: "Gula", currentStock: 1, unit: "kg", expiryDate: nil, minimumStockWarning: 5, costPerUnit: 12000)
        mockOp.dummyIngredients = [gula]
        
        await vm.loadIngredients(branchId: "BRANCH-A")
        
        #expect(vm.lowStockIngredients.count == 1)
        #expect(vm.lowStockIngredients.first?.name == "Gula")
    }
    
    @Test("Test Properti expiredIngredients - Berhasil Mendeteksi Bahan Kedaluwarsa")
    func testExpiredIngredientsAlert() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let susuBasi = Ingredient(name: "Susu", currentStock: 5, unit: "L", expiryDate: Date().addingTimeInterval(-86400), minimumStockWarning: 2, costPerUnit: 15000)
        mockOp.dummyIngredients = [susuBasi]
        
        await vm.loadIngredients(branchId: "BRANCH-A")
        
        #expect(vm.expiredIngredients.count == 1)
        #expect(vm.expiredIngredients.first?.name == "Susu")
    }
    
    @Test("Test Fungsi discardExpiredItem - Berhasil Membuang Bahan & Mencatat Waste ke Cashflow")
    func testDiscardExpiredItem() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: mockCash)
        
        let ing = Ingredient(id: "I-BASI", name: "Susu UHT", currentStock: 2, unit: "L", expiryDate: Date().addingTimeInterval(-86400), minimumStockWarning: 2, costPerUnit: 15000)
        mockOp.dummyIngredients = [ing]
        
        await vm.loadIngredients(branchId: "BRANCH-A")
        await vm.discardExpiredItem(ingredient: ing, branchId: "BRANCH-A")
        
        let records = try? await mockCash.fetchRecords(for: "BRANCH-A")
        #expect(records?.count == 1)
        #expect(records?.first?.amount == 30000)
        #expect(records?.first?.category == .incidental)
    }
}

