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
    var orders: [Order] = []
    var ingredients: [Ingredient] = []

    var isLoading: Bool = false
    var errorMessage: String? = nil

    var productSalesCount: [String: Int] {
        var salesDict: [String: Int] = [:]
        for order in orders {
            for item in order.items {
                salesDict[item.product.name, default: 0] += item.quantity
            }
        }
        return salesDict
    }

    var bestSellers: [(productName: String, quantitySold: Int)] {
        return
            productSalesCount
            .map { (productName: $0.key, quantitySold: $0.value) }
            .sorted { $0.quantitySold > $1.quantitySold }
    }

    var leastPopular: [(productName: String, quantitySold: Int)] {
        return
            productSalesCount
            .map { (productName: $0.key, quantitySold: $0.value) }
            .sorted { $0.quantitySold < $1.quantitySold }
    }

    private let operationalProtocol: OperationalProtocol

    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }

    func loadAnalyticsData(branchId: String) async {
        isLoading = true
        do {
            async let fetchOrders = operationalProtocol.fetchOrders(
                for: branchId
            )
            async let fetchIngredients = operationalProtocol.fetchIngredients(
                for: branchId
            )

            self.orders = try await fetchOrders
            self.ingredients = try await fetchIngredients
        } catch {
            errorMessage = "Gagal memuat data analitik."
        }
        isLoading = false
    }

    var mostProfitableProducts: [(productName: String, profitMargin: Double)] {
        let ingredientCostMap = Dictionary(
            uniqueKeysWithValues: ingredients.compactMap {
                ($0.id ?? "", $0.costPerUnit)
            }
        )

        var profitMap: [String: Double] = [:]

        let allSoldProducts = orders.flatMap { $0.items.map { $0.product } }
        let uniqueProducts = Array(Set(allSoldProducts.map { $0.id }))

        for product in allSoldProducts {
            guard let productId = product.id, profitMap[productId] == nil else {
                continue
            }

            var totalCogs: Double = 0
            for recipeItem in product.recipe {
                let costPerUnit =
                    ingredientCostMap[recipeItem.ingredientId] ?? 0
                totalCogs += (costPerUnit * recipeItem.quantityRequired)
            }

            let profitMargin = product.price - totalCogs
            profitMap[productId] = profitMargin
        }

        return
            allSoldProducts
            .filter { profitMap[$0.id ?? ""] != nil }
            .reduce(into: [Product]()) { unique, product in
                if !unique.contains(where: { $0.id == product.id }) {
                    unique.append(product)
                }
            }
            .map {
                (
                    productName: $0.name,
                    profitMargin: profitMap[$0.id ?? ""] ?? 0
                )
            }
            .sorted { $0.profitMargin > $1.profitMargin }
    }
}
