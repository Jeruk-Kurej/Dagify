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
    var branchId: String // ✅ DITAMBAHKAN: Identitas Cabang
    let name: String
    let price: Double
    let recipe: [RecipeItem]
    
    init(id: String? = nil, branchId: String = "", name: String, price: Double, recipe: [RecipeItem]) {
        self.id = id
        self.branchId = branchId // ✅ Disimpan
        self.name = name
        self.price = price
        self.recipe = recipe
    }
}
