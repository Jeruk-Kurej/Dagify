//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import FirebaseFirestore
import Foundation

struct Ingredient: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var branchId: String

    var name: String
    var currentStock: Double
    var unit: String
    var expiryDate: Date?
    var minimumStockWarning: Double
    var costPerUnit: Double

    // MARK: - Initialization
    init(
        id: String? = nil,
        branchId: String,
        name: String,
        currentStock: Double,
        unit: String,
        expiryDate: Date? = nil,
        minimumStockWarning: Double,
        costPerUnit: Double
    ) {
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
