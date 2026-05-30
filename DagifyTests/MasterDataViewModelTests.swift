//
//  MasterDataViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("Master Data ViewModel Tests")
@MainActor
struct MasterDataViewModelTests {
    
    @Test("Test Fungsi createIngredient - Berhasil Menyimpan Bahan Baku Baru")
    func testCreateIngredientSuccess() async {
        let mockOp = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOp)
        
        await vm.createIngredient(name: "Sirup Vanila", currentStock: 10, unit: "Botol", expiryDate: nil, minimumStockWarning: 2, costPerUnit: 40000)
        
        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
        #expect(mockOp.dummyIngredients.count == 1)
    }
    
    @Test("Test Fungsi createIngredient - Gagal Jika Form Input Tidak Valid")
    func testCreateIngredientValidationError() async {
        let mockOp = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOp)
        
        await vm.createIngredient(name: "", currentStock: -5, unit: "Pcs", expiryDate: nil, minimumStockWarning: 1, costPerUnit: 10)
        
        #expect(vm.isSuccess == false)
        #expect(vm.errorMessage != nil)
    }
    
    @Test("Test Fungsi createProduct - Berhasil Membuat Menu Baru Beserta Resepnya")
    func testCreateProductSuccess() async {
        let mockOp = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOp)
        
        let resepItem = RecipeItem(ingredientId: "ING-01", quantityRequired: 15)
        await vm.createProduct(name: "Caramel Latte", price: 28000, recipe: [resepItem])
        
        #expect(vm.isSuccess == true)
        #expect(mockOp.dummyProducts.count == 1)
        #expect(mockOp.dummyProducts.first?.name == "Caramel Latte")
    }
}
