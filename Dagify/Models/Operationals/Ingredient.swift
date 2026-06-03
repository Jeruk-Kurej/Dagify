//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Ingredient: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public var branchId: String
    // ✅ FIX: Semua 'let' diubah menjadi 'var' agar bisa diedit di Form
    public var name: String
    public var currentStock: Double
    public var unit: String
    public var expiryDate: Date?
    public var minimumStockWarning: Double
    public var costPerUnit: Double
    
    public init(id: String? = nil, branchId: String, name: String, currentStock: Double, unit: String, expiryDate: Date? = nil, minimumStockWarning: Double, costPerUnit: Double) {
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
