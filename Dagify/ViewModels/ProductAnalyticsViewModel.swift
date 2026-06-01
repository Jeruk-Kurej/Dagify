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
final class ProductAnalyticsViewModel {
    var isLoading: Bool = false
    var mostProfitableProducts: [(name: String, margin: Double)] = []
    var bestSellers: [(name: String, quantity: Int)] = []
    
    func loadAnalyticsData(branchId: String) async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000)
        mostProfitableProducts = [("Es Kopi Susu Aren", 12000), ("Americano", 10000), ("Teh Manis", 5000)].sorted { $0.margin > $1.margin }
        bestSellers = [("Es Kopi Susu Aren", 450), ("Teh Manis", 300), ("Americano", 120)].sorted { $0.quantity > $1.quantity }
        isLoading = false
    }
}

