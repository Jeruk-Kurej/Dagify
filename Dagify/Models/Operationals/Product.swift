//
//  Product.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    let price: Double
    let recipe: [RecipeItem]
    
    init(id: String? = nil, name: String, price: Double, recipe: [RecipeItem]) {
        self.id = id
        self.name = name
        self.price = price
        self.recipe = recipe
    }
}
