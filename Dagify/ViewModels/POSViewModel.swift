//
//  POSViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Combine
import Foundation

@MainActor
class POSViewModel: ObservableObject {
    public var cart: [OrderItem] = []
    public var availableProducts: [Product] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var isCheckoutSuccess: Bool = false

    private let repo: OperationalRepository
    private let networkMonitor: NetworkMonitor

    public init(repo: OperationalRepository, networkMonitor: NetworkMonitor) {
        self.repo = repo
        self.networkMonitor = networkMonitor
    }

    public func loadProducts(branchId: String) async {
        isLoading = true
        do {
            availableProducts = try await repo.fetchProducts(for: branchId)
        } catch {
            errorMessage = "Gagal memuat daftar menu."
        }
        isLoading = false
    }

    public func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(OrderItem(product: product, quantity: 1))
        }
    }

    public func removeOrDecreaseFromCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if cart[index].quantity > 1 {
                cart[index].quantity -= 1
            } else {
                cart.remove(at: index)
            }
        }
    }

    public var subtotal: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    public func checkout(branchId: String, customerId: String? = nil) async {
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
            try await SyncManager.shared.handleCheckout(
                order: order,
                isConnected: networkMonitor.isConnected,
                firebaseRepo: repo
            )

            cart.removeAll()
            isCheckoutSuccess = true
            
        } catch {
            errorMessage = "Checkout gagal: \(error.localizedDescription)"
        }

        isLoading = false
    }

}
