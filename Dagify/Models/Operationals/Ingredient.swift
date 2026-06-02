//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Ingredient: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var branchId: String
    let name: String
    var currentStock: Double
    let unit: String
    let expiryDate: Date?
    let minimumStockWarning: Double
    let costPerUnit: Double
    
    init(id: String? = nil, branchId: String = "", name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double, costPerUnit: Double) {
        self.id = id
        self.branchId = branchId
        self.name = name
        self.currentStock = currentStock
        self.unit = unit
        self.expiryDate = expiryDate
        self.minimumStockWarning = minimumStockWarning
        self.costPerUnit = costPerUnit
    }
}
