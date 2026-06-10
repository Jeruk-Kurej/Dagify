//
//  IngredientBatch.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

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
