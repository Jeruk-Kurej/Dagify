//
//  ProductAnalyticsViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation

@MainActor
@Observable
class ProductAnalyticsViewModel {
    var products: [Product] = []
    var isLoading: Bool = false
    
    let operationalProtocol: OperationalProtocol
    
    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }
    
    var mostProfitableProducts: [Product] {
        return products.sorted { $0.price > $1.price }
    }
    
    func loadProducts(branchId: String) async {
        isLoading = true
        products = (try? await operationalProtocol.fetchProducts(for: branchId)) ?? []
        isLoading = false
    }
}
