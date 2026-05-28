//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestoreSwift

struct Ingredient: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let name: String
    public var currentStock: Double
    public let unit: String
    public let expiryDate: Date?
    public let minimumStockWarning: Double
    
    public init(id: String? = nil, name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double) {
        self.id = id
        self.name = name
        self.currentStock = currentStock
        self.unit = unit
        self.expiryDate = expiryDate
        self.minimumStockWarning = minimumStockWarning
    }
}
