//
//  POSViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation
import SwiftData

@testable import Dagify

@Suite("POSViewModel Tests")
struct POSViewModelTests {
    
    let dummyProduct = Product(id: "P-1", name: "Kopi Gula Aren", price: 25000, recipe: [])
    
    @Test @MainActor func testCartManagement() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(repo: mockRepo, networkMonitor: NetworkMonitor(), crmRepo: MockCRMRepository())
        
        vm.addToCart(product: dummyProduct)
        #expect(vm.cart.count == 1)
        #expect(vm.subtotal == 25000)
        
        vm.removeOrDecreaseFromCart(product: dummyProduct)
        #expect(vm.cart.isEmpty == true)
        #expect(vm.subtotal == 0)
    }
    
    @Test @MainActor func testCheckoutSuccessfully() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(repo: mockRepo, networkMonitor: NetworkMonitor(), crmRepo: MockCRMRepository())
        
        vm.addToCart(product: dummyProduct)
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: OfflineOrder.self, configurations: config)
        let context = ModelContext(container)
        
        await vm.checkout(branchId: "B-1", context: context)
        
        #expect(vm.cart.isEmpty == true)
        #expect(vm.isCheckoutSuccess == true)
    }
}
