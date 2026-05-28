//
//  ProductAnalyticsViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Testing

@testable import Dagify

@Suite("ProductAnalyticsViewModel Swift Tests")
struct ProductAnalyticsViewModelTests {

    // Perhatikan tambahan RecipeItem di sini untuk menghitung HPP
    let dummyCoffee = Product(
        id: "P-1",
        name: "Kopi Gula Aren",
        price: 25000,
        recipe: [RecipeItem(ingredientId: "I-1", quantityRequired: 20)]
    )
    let dummyTea = Product(
        id: "P-2",
        name: "Es Teh Manis",
        price: 10000,
        recipe: [RecipeItem(ingredientId: "I-2", quantityRequired: 10)]
    )

    @Test @MainActor func testProfitabilityAnalytics() async throws {
        let mockRepo = MockOperationalRepository()

        mockRepo.dummyIngredients = [
            Ingredient(
                id: "I-1",
                name: "Biji Kopi",
                currentStock: 1000,
                unit: "Gr",
                expiryDate: nil,
                minimumStockWarning: 100,
                costPerUnit: 500
            ),
            Ingredient(
                id: "I-2",
                name: "Teh",
                currentStock: 1000,
                unit: "Gr",
                expiryDate: nil,
                minimumStockWarning: 100,
                costPerUnit: 200
            ),
        ]

        let order1 = Order(
            branchId: "B-1",
            customerId: nil,
            items: [
                OrderItem(product: dummyCoffee, quantity: 1),
                OrderItem(product: dummyTea, quantity: 1),
            ],
            totalAmount: 35000,
            timestamp: Date()
        )

        mockRepo.dummyOrders = [order1]

        let vm = ProductAnalyticsViewModel(repo: mockRepo)

        await vm.loadAnalyticsData(branchId: "B-1")

        let profitableProducts = vm.mostProfitableProducts

        #expect(profitableProducts.count == 2)

        #expect(profitableProducts.first?.productName == "Kopi Gula Aren")
        #expect(profitableProducts.first?.profitMargin == 15000)

        #expect(profitableProducts.last?.productName == "Es Teh Manis")
        #expect(profitableProducts.last?.profitMargin == 8000)
    }
}
