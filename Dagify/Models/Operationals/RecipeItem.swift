//
//  RecipeItem.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct RecipeItem: Codable, Equatable {

    // MARK: - Properties
    var ingredientId: String
    var quantityRequired: Double

    // MARK: - Initialization
    init(ingredientId: String, quantityRequired: Double) {
        self.ingredientId = ingredientId
        self.quantityRequired = quantityRequired
    }
}
