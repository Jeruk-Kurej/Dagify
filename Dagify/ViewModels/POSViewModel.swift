//
//  POSViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation

@MainActor
@Observable
class POSViewModel {
    var cart: [OrderItem] = []
    var isLoading: Bool = false
    
    private let repo: OperationalRepository
    
    init(repo: OperationalRepository) {
        self.repo = repo
    }
    
    func addToCart(product: Product) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(OrderItem(product: product, quantity: 1))
        }
    }
    
    var subtotal: Double {
        cart.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    func checkout(branchId: String, customerId: String?) async {
        guard !cart.isEmpty else { return }
        isLoading = true
        
        let order = Order(
            branchId: branchId,
            customerId: customerId,
            items: cart,
            totalAmount: subtotal,
            timestamp: Date()
        )
        
        do {
            _ = try await repo.submitOrder(order)
            _ = try await repo.updateInventoryStock(for: cart)
            cart.removeAll()
        } catch {
            print("Checkout Gagal")
        }
        
        isLoading = false
    }
}
