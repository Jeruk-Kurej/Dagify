//
//  POSViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
class POSViewModel {
    var cart: [OrderItem] = []
    var availableProducts: [Product] = []
    var isLoading: Bool = false
    var isCheckoutSuccess: Bool = false

    var subtotal: Double { cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) } }
    var totalCartItems: Int { cart.reduce(0) { $0 + $1.quantity } }
    var isCartEmpty: Bool { cart.isEmpty }

    private let operationalProtocol: OperationalProtocol
    private let networkMonitor: NetworkMonitor
    private let syncManager: SyncManagerProtocol

    init(operationalProtocol: OperationalProtocol, networkMonitor: NetworkMonitor, syncManager: SyncManagerProtocol) {
        self.operationalProtocol = operationalProtocol; self.networkMonitor = networkMonitor; self.syncManager = syncManager
    }

    func loadProducts(branchId: String) async {
        isLoading = true
        availableProducts = (try? await operationalProtocol.fetchProducts(for: branchId)) ?? []
        isLoading = false
    }

    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) { cart[index].quantity += 1 }
        else { cart.append(OrderItem(product: product, quantity: 1)) }
    }

    func removeOrDecreaseFromCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if cart[index].quantity > 1 { cart[index].quantity -= 1 } else { cart.remove(at: index) }
        }
    }

    func checkout(branchId: String, customerId: String? = nil, context: ModelContext) async {
        guard !cart.isEmpty else { return }
        isLoading = true; isCheckoutSuccess = false
        let order = Order(branchId: branchId, customerId: customerId, items: cart, totalAmount: subtotal, timestamp: Date())
        _ = try? await syncManager.handleCheckout(order: order, isConnected: networkMonitor.isConnected, firebaseRepo: operationalProtocol, context: context)
        cart.removeAll(); isCheckoutSuccess = true; isLoading = false
    }
}
