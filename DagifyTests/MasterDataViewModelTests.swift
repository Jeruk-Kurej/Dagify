//
//  MasterDataViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("MasterDataViewModel Tests")
struct MasterDataViewModelTests {
    
    @Test @MainActor func testCreateIngredientSuccessfully() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(repo: mockRepo)
        
        await vm.createIngredient(name: "Biji Kopi", currentStock: 5000, unit: "Gram", expiryDate: nil, minimumStockWarning: 1000)
        
        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
    }
    
    @Test @MainActor func testCreateProductFailsWithEmptyName() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(repo: mockRepo)
        
        await vm.createProduct(name: "", price: 25000, recipe: [])
        
        #expect(vm.isSuccess == false)
        #expect(vm.errorMessage != nil)
    }
}
