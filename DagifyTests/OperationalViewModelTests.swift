//
//  OperationalViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Testing

@testable import Dagify

@Suite("POSViewModel Swift Tests")
struct POSViewModelTests {

    let dummyProduct = Product(
        id: "P-1",
        name: "Kopi Gula Aren",
        price: 25000,
        recipe: [RecipeItem(ingredientId: "ING-1", quantityRequired: 15.0)]
    )

    // a. Add to Cart & Decrease Cart
    @Test @MainActor func testCartManagement() async throws {
        let mockRepo = MockOperationalRepository()
        let networkMonitor = NetworkMonitor()
        let vm = POSViewModel(repo: mockRepo, networkMonitor: networkMonitor)

        vm.addToCart(product: dummyProduct)
        vm.addToCart(product: dummyProduct)
        #expect(vm.cart.count == 1)
        #expect(vm.cart[0].quantity == 2)
        #expect(vm.subtotal == 50000)

        vm.removeOrDecreaseFromCart(product: dummyProduct)
        #expect(vm.cart[0].quantity == 1)

        vm.removeOrDecreaseFromCart(product: dummyProduct)
        #expect(vm.cart.isEmpty)
        #expect(vm.subtotal == 0)
    }

    // b. Checkout Successfully -> Mengosongkan cart dan memanggil API (Batch Write)
    @Test @MainActor func testCheckoutSuccessfully() async throws {
        let mockRepo = MockOperationalRepository()
        let networkMonitor = NetworkMonitor()
        let vm = POSViewModel(repo: mockRepo, networkMonitor: networkMonitor)

        vm.addToCart(product: dummyProduct)

        await vm.checkout(branchId: "B-1")

        #expect(vm.cart.isEmpty == true)
        #expect(vm.isCheckoutSuccess == true)
        #expect(mockRepo.submitCallCount == 1)
    }
}

@Suite("InventoryViewModel Swift Tests")
struct InventoryViewModelTests {

    // Menguji Fitur Peringatan Low Stock & Kedaluwarsa
    @Test @MainActor func testInventoryWarnings() async throws {
        let mockRepo = MockOperationalRepository()

        // Setup Date: Kedaluwarsa Kemarin
        let yesterday = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Date()
        )!
        let nextMonth = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: Date()
        )!

        mockRepo.dummyIngredients = [
            // 1. Stok Aman, Belum Basi
            Ingredient(
                id: "I-1",
                name: "Gula",
                currentStock: 1000,
                unit: "Gr",
                expiryDate: nextMonth,
                minimumStockWarning: 200
            ),

            // 2. Stok Menipis (Low Stock), Belum Basi
            Ingredient(
                id: "I-2",
                name: "Susu",
                currentStock: 100,
                unit: "Ml",
                expiryDate: nextMonth,
                minimumStockWarning: 500
            ),

            // 3. Stok Aman, Tapi Basi (Expired)
            Ingredient(
                id: "I-3",
                name: "Roti",
                currentStock: 50,
                unit: "Pcs",
                expiryDate: yesterday,
                minimumStockWarning: 10
            ),
        ]

        let vm = InventoryViewModel(repo: mockRepo)
        await vm.loadIngredients(branchId: "B-1")

        // Validasi
        #expect(vm.ingredients.count == 3)
        #expect(vm.lowStockIngredients.count == 1)
        #expect(vm.lowStockIngredients.first?.name == "Susu")

        #expect(vm.expiredIngredients.count == 1)
        #expect(vm.expiredIngredients.first?.name == "Roti")
    }
}
