//
//  RecipeItem.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct RecipeItem: Codable, Equatable {
    public let ingredientId: String
    public let quantityRequired: Double
    
    public init(ingredientId: String, quantityRequired: Double) {
        self.ingredientId = ingredientId
        self.quantityRequired = quantityRequired
    }
}
