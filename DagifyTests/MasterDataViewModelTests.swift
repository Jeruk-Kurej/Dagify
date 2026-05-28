//
//  MasterDataViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("Master Data ViewModel Swift Tests")
struct MasterDataViewModelTests {
    
    @Test @MainActor func testCreateIngredientSuccessfully() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(repo: mockRepo)
        
        await vm.createIngredient(
            name: "Biji Kopi Arabica",
            currentStock: 5000,
            unit: "Gram",
            expiryDate: Date().addingTimeInterval(86400 * 30), // 30 Hari
            minimumStockWarning: 1000,
            costPerUnit: 50000
        )
        
        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
        #expect(mockRepo.dummyIngredients.count == 1)
        #expect(mockRepo.dummyIngredients.first?.name == "Biji Kopi Arabica")
    }
    
    @Test @MainActor func testCreateProductFailsWithEmptyName() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(repo: mockRepo)
        
        // Mencoba membuat produk tanpa nama (String kosong)
        await vm.createProduct(name: "", price: 25000, recipe: [])
        
        #expect(vm.isSuccess == false)
        #expect(vm.errorMessage == "Nama menu dan harga harus valid.")
        #expect(mockRepo.dummyProducts.isEmpty == true) // Memastikan tidak ada yang tersimpan ke database
    }
}
