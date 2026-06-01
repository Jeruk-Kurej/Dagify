//
//  POSViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Testing
import Foundation

@testable import Dagify

@MainActor
struct POSViewModelTests {
    
    @Test("1. Kalkulasi Total Harga dan Jumlah Barang Keranjang")
    func testCartCalculations() {
        let mockOp = MockOperationalRepository()
        let viewModel = POSViewModel(operationalProtocol: mockOp, networkMonitor: NetworkMonitor(), syncManager: MockSyncManager())
        
        let product1 = Product(id: "P1", name: "Kopi", price: 20000, category: "Menu", isAvailable: true, recipe: [])
        let product2 = Product(id: "P2", name: "Teh", price: 15000, category: "Menu", isAvailable: true, recipe: [])
        
        viewModel.addToCart(product: product1)
        viewModel.addToCart(product: product1)
        viewModel.addToCart(product: product2)
        
        #expect(viewModel.totalCartItems == 3, "Kalkulasi jumlah barang di keranjang salah")
        #expect(viewModel.subtotal == 55000, "Kalkulasi subtotal (2x20k + 15k) salah")
        #expect(viewModel.isCartEmpty == false, "State keranjang kosong salah")
        
        viewModel.removeOrDecreaseFromCart(product: product1)
        #expect(viewModel.totalCartItems == 2, "Pengurangan item keranjang gagal")
    }
}
