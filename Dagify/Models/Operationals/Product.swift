//
//  Product.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let name: String
    public let price: Double
    public let recipe: [RecipeItem]
    
    public init(id: String? = nil, name: String, price: Double, recipe: [RecipeItem]) {
        self.id = id
        self.name = name
        self.price = price
        self.recipe = recipe
    }
}
