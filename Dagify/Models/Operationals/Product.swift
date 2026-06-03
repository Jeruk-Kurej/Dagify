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
    var branchId: String
    var categoryId: String
    let name: String
    let price: Double
    let recipe: [RecipeItem]
    var imageUrl: String?   // ✅ DIUBAH: Sekarang hanya menyimpan Tautan (URL) Gambar
    
    init(id: String? = nil, branchId: String = "", categoryId: String = "", name: String, price: Double, recipe: [RecipeItem], imageUrl: String? = nil) {
        self.id = id
        self.branchId = branchId
        self.categoryId = categoryId
        self.name = name
        self.price = price
        self.recipe = recipe
        self.imageUrl = imageUrl
    }
}
