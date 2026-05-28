//
//  ProductAnalyticsViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("ProductAnalyticsViewModel Swift Tests")
struct ProductAnalyticsViewModelTests {
    
    let dummyCoffee = Product(id: "P-1", name: "Kopi Gula Aren", price: 25000, recipe: [])
    let dummyTea = Product(id: "P-2", name: "Es Teh Manis", price: 10000, recipe: [])
    let dummyCroissant = Product(id: "P-3", name: "Croissant", price: 30000, recipe: [])
    
    @Test @MainActor func testBestSellerAndLeastPopularAnalytics() async throws {
        let mockRepo = MockOperationalRepository()
        
        // Skenario Transaksi:
        // Order 1: 5 Kopi, 1 Teh
        // Order 2: 3 Kopi, 2 Croissant
        // Total Terjual: Kopi (8), Croissant (2), Teh (1)
        let order1 = Order(branchId: "B-1", customerId: nil, items: [
            OrderItem(product: dummyCoffee, quantity: 5),
            OrderItem(product: dummyTea, quantity: 1)
        ], totalAmount: 135000, timestamp: Date())
        
        let order2 = Order(branchId: "B-1", customerId: nil, items: [
            OrderItem(product: dummyCoffee, quantity: 3),
            OrderItem(product: dummyCroissant, quantity: 2)
        ], totalAmount: 135000, timestamp: Date())
        
        mockRepo.dummyOrders = [order1, order2]
        
        let vm = ProductAnalyticsViewModel(repo: mockRepo)
        await vm.loadOrderHistory(branchId: "B-1")
        
        let bestSellers = vm.bestSellers
        let leastPopular = vm.leastPopular
        
        // Pengecekan Best-Seller (Peringkat 1 harus Kopi Gula Aren dengan 8 penjualan)
        #expect(bestSellers.first?.productName == "Kopi Gula Aren")
        #expect(bestSellers.first?.quantitySold == 8)
        
        // Pengecekan Least Popular (Peringkat terakhir/paling bawah di Least Popular harus Kopi, peringkat 1 nya Teh)
        #expect(leastPopular.first?.productName == "Es Teh Manis")
        #expect(leastPopular.first?.quantitySold == 1)
    }
}
