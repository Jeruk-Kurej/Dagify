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
    var name: String
    var currentStock: Double
    var unit: String
    var expiryDate: Date?
    var minimumStockWarning: Double
    var costPerUnit: Double
    
    var isExpired: Bool {
        guard let expiry = expiryDate else { return false }
        return expiry < Date()
    }
    
    var isLowStock: Bool {
        return currentStock <= minimumStockWarning
    }
}
