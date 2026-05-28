//
//  ProductAnalyticsViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Combine

@MainActor
class ProductAnalyticsViewModel {
    public var orders: [Order] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let repo: OperationalRepository
    
    public init(repo: OperationalRepository) {
        self.repo = repo
    }
    
    public func loadOrderHistory(branchId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            orders = try await repo.fetchOrders(for: branchId)
        } catch {
            errorMessage = "Gagal memuat riwayat pesanan."
        }
        isLoading = false
    }
    
    private var productSalesCount: [String: Int] {
        var salesDict: [String: Int] = [:]
        
        for order in orders {
            for item in order.items {
                salesDict[item.product.name, default: 0] += item.quantity
            }
        }
        return salesDict
    }
    
    public var bestSellers: [(productName: String, quantitySold: Int)] {
        return productSalesCount
            .map { (productName: $0.key, quantitySold: $0.value) }
            .sorted { $0.quantitySold > $1.quantitySold }
    }
    
    public var leastPopular: [(productName: String, quantitySold: Int)] {
        return productSalesCount
            .map { (productName: $0.key, quantitySold: $0.value) }
            .sorted { $0.quantitySold < $1.quantitySold }
    }
}
