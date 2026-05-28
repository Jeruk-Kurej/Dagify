//
//  ProductAnalyticsViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("ProductAnalyticsViewModel Tests")
struct ProductAnalyticsViewModelTests {
    
    @Test @MainActor func testProfitabilityAndBestSeller() async throws {
        let mockRepo = MockOperationalRepository()
        
        mockRepo.dummyIngredients = [
            Ingredient(id: "I-1", name: "Kopi", currentStock: 1000, unit: "Gr", expiryDate: nil, minimumStockWarning: 100, costPerUnit: 500)
        ]
        
        let dummyCoffee = Product(id: "P-1", name: "Kopi Aren", price: 25000, recipe: [RecipeItem(ingredientId: "I-1", quantityRequired: 20)])
        
        let order = Order(branchId: "B-1", customerId: nil, items: [
            OrderItem(product: dummyCoffee, quantity: 5)
        ], totalAmount: 125000, timestamp: Date())
        
        mockRepo.dummyOrders = [order]
        
        let vm = ProductAnalyticsViewModel(repo: mockRepo)
        await vm.loadAnalyticsData(branchId: "B-1")
        
        #expect(vm.mostProfitableProducts.first?.productName == "Kopi Aren")
        #expect(vm.mostProfitableProducts.first?.profitMargin == 15000)
        
        #expect(vm.bestSellers.first?.productName == "Kopi Aren")
        #expect(vm.bestSellers.first?.quantitySold == 5)
    }
}
