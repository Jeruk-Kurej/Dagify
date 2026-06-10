//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import FirebaseFirestore
import Foundation

struct IngredientBatch: Identifiable, Codable, Equatable {
    var id: String
    var currentStock: Double
    var expiryDate: Date?
    var costPerUnit: Double
    var dateAdded: Date
    
    init(id: String = UUID().uuidString, currentStock: Double, expiryDate: Date? = nil, costPerUnit: Double, dateAdded: Date = Date()) {
        self.id = id
        self.currentStock = currentStock
        self.expiryDate = expiryDate
        self.costPerUnit = costPerUnit
        self.dateAdded = dateAdded
    }
}

struct Ingredient: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var branchId: String
    var name: String
    var unit: String
    var minimumStockWarning: Double
    var batches: [IngredientBatch]

    // MARK: - Computed Properties
    var currentStock: Double {
        batches.reduce(0) { $0 + $1.currentStock }
    }
    
    var expiryDate: Date? {
        batches.filter { $0.currentStock > 0 }.compactMap { $0.expiryDate }.min()
    }
    
    var costPerUnit: Double {
        guard !batches.isEmpty else { return 0 }
        let totalCost = batches.reduce(0) { $0 + ($1.currentStock * $1.costPerUnit) }
        let totalStock = currentStock
        return totalStock > 0 ? (totalCost / totalStock) : (batches.last?.costPerUnit ?? 0)
    }

    // MARK: - Initialization
    init(
        id: String? = nil,
        branchId: String,
        name: String,
        unit: String,
        minimumStockWarning: Double,
        batches: [IngredientBatch] = []
    ) {
        self.id = id
        self.branchId = branchId
        self.name = name
        self.unit = unit
        self.minimumStockWarning = minimumStockWarning
        self.batches = batches
    }
}
