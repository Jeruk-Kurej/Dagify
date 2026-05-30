//
//  POSViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class POSViewModel {
    var cart: [OrderItem] = []
    var availableProducts: [Product] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCheckoutSuccess: Bool = false

    private let repo: OperationalRepository
    private let networkMonitor: NetworkMonitor
    private let syncManager: SyncManagerProtocol

    init(repo: OperationalRepository, networkMonitor: NetworkMonitor, syncManager: SyncManagerProtocol) {
        self.repo = repo
        self.networkMonitor = networkMonitor
        self.syncManager = syncManager
    }
    
    func loadProducts(branchId: String) async {
        isLoading = true
        do {
            availableProducts = try await repo.fetchProducts(for: branchId)
        } catch {
            errorMessage = "Gagal memuat daftar menu."
        }
        isLoading = false
    }
    
    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(OrderItem(product: product, quantity: 1))
        }
    }
    
    func removeOrDecreaseFromCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if cart[index].quantity > 1 {
                cart[index].quantity -= 1
            } else {
                cart.remove(at: index)
            }
        }
    }
    
    var subtotal: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    func checkout(branchId: String, customerId: String? = nil, context: ModelContext) async {
        guard !cart.isEmpty else {
            errorMessage = "Keranjang masih kosong."
            return
        }

        isLoading = true
        errorMessage = nil
        isCheckoutSuccess = false

        let order = Order(
            branchId: branchId,
            customerId: customerId,
            items: cart,
            totalAmount: subtotal,
            timestamp: Date()
        )

        do {
            try await syncManager.handleCheckout(
                order: order,
                isConnected: networkMonitor.isConnected,
                firebaseRepo: repo,
                context: context
            )
            
            cart.removeAll()
            isCheckoutSuccess = true
            
        } catch {
            errorMessage = "Checkout gagal: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
