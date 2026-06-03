//
//  Product.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
    @DocumentID public var id: String?
     var branchId: String
     var categoryId: String
    
     var name: String
     var price: Double
     var recipe: [RecipeItem]
     var imageUrl: String?
    
    // MARK: - Initialization
     init(
        id: String? = nil,
        branchId: String = "",
        categoryId: String = "",
        name: String,
        price: Double,
        recipe: [RecipeItem],
        imageUrl: String? = nil
    ) {
        self.id = id
        self.branchId = branchId
        self.categoryId = categoryId
        self.name = name
        self.price = price
        self.recipe = recipe
        self.imageUrl = imageUrl
    }
}
