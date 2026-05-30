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

@Suite("POS ViewModel Tests")
@MainActor
struct POSViewModelTests {
    
    private func makeTestContext() -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Schema([]), configurations: [config])
        return container.mainContext
    }
    
    @Test("Test Fungsi loadProducts - Berhasil Mengambil Menu Cabang")
    func testLoadProducts() async {
        let mockOp = MockOperationalRepository()
        let vm = POSViewModel(operationalProtocol: mockOp, networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        
        mockOp.dummyProducts = [Product(id: "P1", name: "Matcha Latte", price: 22000, recipe: [])]
        await vm.loadProducts(branchId: "B1")
        
        #expect(vm.availableProducts.count == 1)
        #expect(vm.availableProducts.first?.name == "Matcha Latte")
    }
    
    @Test("Test Fungsi addToCart - Menambah Menu Baru ke Keranjang")
    func testAddToCartNewItem() {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        let product = Product(id: "P1", name: "Kopi Black", price: 12000, recipe: [])
        
        vm.addToCart(product: product)
        
        #expect(vm.cart.count == 1)
        #expect(vm.cart.first?.quantity == 1)
    }
    
    @Test("Test Fungsi addToCart - Menambah Kuantitas Jika Menu yang Sama Ditambahkan Lagi")
    func testAddToCartExistingItemIncrement() {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        let product = Product(id: "P1", name: "Kopi Black", price: 12000, recipe: [])
        
        vm.addToCart(product: product)
        vm.addToCart(product: product)
        
        #expect(vm.cart.count == 1)
        #expect(vm.cart.first?.quantity == 2)
    }
    
    @Test("Test Fungsi removeOrDecreaseFromCart - Mengurangi Kuantitas Item")
    func testRemoveOrDecreaseFromCartDecrement() {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        let product = Product(id: "P1", name: "Kopi Black", price: 12000, recipe: [])
        
        vm.addToCart(product: product)
        vm.addToCart(product: product)
        
        vm.removeOrDecreaseFromCart(product: product)
        
        #expect(vm.cart.first?.quantity == 1)
    }
    
    @Test("Test Fungsi removeOrDecreaseFromCart - Menghapus Item dari Keranjang Jika Kuantitas Habis")
    func testRemoveOrDecreaseFromCartRemoveCompletely() {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        let product = Product(id: "P1", name: "Kopi Black", price: 12000, recipe: [])
        
        vm.addToCart(product: product)
        vm.removeOrDecreaseFromCart(product: product)
        
        #expect(vm.cart.isEmpty == true)
    }
    
    @Test("Test Properti subtotal - Perhitungan Total Belanja Akurat")
    func testSubtotalCalculation() {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        let p1 = Product(id: "P1", name: "Roti", price: 10000, recipe: [])
        let p2 = Product(id: "P2", name: "Kopi", price: 15000, recipe: [])
        
        vm.addToCart(product: p1)
        vm.addToCart(product: p1)
        vm.addToCart(product: p2)
        
        #expect(vm.subtotal == 35000)
    }
    
    @Test("Test Fungsi checkout - Gagal Jika Keranjang Masuk Batas Kosong")
    func testCheckoutEmptyCartValidation() async {
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        
        await vm.checkout(branchId: "B1", customerId: nil, context: makeTestContext())
        
        #expect(vm.isCheckoutSuccess == false)
        #expect(vm.errorMessage == "Keranjang masih kosong.")
    }
    
    @Test("Test Fungsi checkout - Berhasil Checkout, Memicu Sync dan Mengosongkan Keranjang")
    func testCheckoutSuccess() async {
        let mockSync = MockSyncManager()
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: mockSync)
        let product = Product(id: "P1", name: "Kopi", price: 15000, recipe: [])
        
        vm.addToCart(product: product)
        await vm.checkout(branchId: "B1", customerId: "CUST-1", context: makeTestContext())
        
        #expect(mockSync.isCheckoutCalled == true)
        #expect(vm.isCheckoutSuccess == true)
        #expect(vm.cart.isEmpty == true)
    }
    
    @Test("Test Fungsi checkout - Menangani Error Jika SyncManager Mengalami Kegagalan")
    func testCheckoutFailureHandling() async {
        let mockSync = MockSyncManager()
        mockSync.shouldThrowError = true
        
        let vm = POSViewModel(operationalProtocol: MockOperationalRepository(), networkMonitor: NetworkMonitor(), syncManager: mockSync)
        let product = Product(id: "P1", name: "Kopi", price: 15000, recipe: [])
        
        vm.addToCart(product: product)
        await vm.checkout(branchId: "B1", customerId: nil, context: makeTestContext())
        
        #expect(vm.isCheckoutSuccess == false)
        #expect(vm.errorMessage?.contains("Checkout gagal:") == true)
        #expect(vm.cart.count == 1)
    }
}

