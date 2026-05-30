//
//  ProductAnalyticsViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@Suite("Product Analytics ViewModel Tests")
@MainActor
struct ProductAnalyticsViewModelTests {
    
    @Test("Test Fungsi loadAnalyticsData - Berhasil Memuat Data Penjualan")
    func testLoadAnalyticsData() async {
        let mockOp = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOp)
        
        await vm.loadAnalyticsData(branchId: "BRANCH-A")
        
        #expect(vm.orders != nil)
    }
    
    @Test("Test Properti mostProfitableProducts - Kalkulasi Margin Laba Bersih Berdasarkan HPP")
    func testMostProfitableProductsCalculation() async {
        let mockOp = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOp)
        
        let kopi = Ingredient(id: "I-KOPI", name: "Kopi", currentStock: 100, unit: "gr", expiryDate: nil, minimumStockWarning: 1, costPerUnit: 500)
        mockOp.dummyIngredients = [kopi]
        
        let espresso = Product(id: "P-ESP", name: "Espresso", price: 15000, recipe: [RecipeItem(ingredientId: "I-KOPI", quantityRequired: 10)])
        
        mockOp.dummyOrders = [
            Order(branchId: "BRANCH-A", customerId: nil, items: [OrderItem(product: espresso, quantity: 1)], totalAmount: 15000, timestamp: Date())
        ]
        
        await vm.loadAnalyticsData(branchId: "BRANCH-A")
        
        #expect(vm.mostProfitableProducts.first?.productName == "Espresso")
        #expect(vm.mostProfitableProducts.first?.profitMargin == 10000)
    }
    
    @Test("Test Properti bestSellers - Mengurutkan Produk dari yang Paling Banyak Terjual")
    func testBestSellersSorting() async {
        let mockOp = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOp)
        
        let p1 = Product(id: "P1", name: "Kopi Susu", price: 15000, recipe: [])
        let p2 = Product(id: "P2", name: "Teh Manis", price: 5000, recipe: [])
        
        mockOp.dummyOrders = [
            Order(branchId: "BRANCH-A", customerId: nil, items: [OrderItem(product: p1, quantity: 10)], totalAmount: 150000, timestamp: Date()),
            Order(branchId: "BRANCH-A", customerId: nil, items: [OrderItem(product: p2, quantity: 3)], totalAmount: 15000, timestamp: Date())
        ]
        
        await vm.loadAnalyticsData(branchId: "BRANCH-A")
        
        #expect(vm.bestSellers.first?.productName == "Kopi Susu")
        #expect(vm.bestSellers.first?.quantitySold == 10)
    }
    
    @Test("Test Properti leastPopular - Mengurutkan Produk dari yang Paling Sedikit Terjual")
    func testLeastPopularSorting() async {
        let mockOp = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockOp)
        
        let p1 = Product(id: "P1", name: "Kopi Susu", price: 15000, recipe: [])
        let p2 = Product(id: "P2", name: "Teh Manis", price: 5000, recipe: [])
        
        mockOp.dummyOrders = [
            Order(branchId: "BRANCH-A", customerId: nil, items: [OrderItem(product: p1, quantity: 10)], totalAmount: 150000, timestamp: Date()),
            Order(branchId: "BRANCH-A", customerId: nil, items: [OrderItem(product: p2, quantity: 3)], totalAmount: 15000, timestamp: Date())
        ]
        
        await vm.loadAnalyticsData(branchId: "BRANCH-A")
        
        #expect(vm.leastPopular.first?.productName == "Teh Manis")
        #expect(vm.leastPopular.first?.quantitySold == 3)
    }
}
