//
//  Product.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Product: Identifiable, Codable, Equatable, Hashable {

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
