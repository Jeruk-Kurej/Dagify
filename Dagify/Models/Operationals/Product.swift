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
    var categoryId: String // ✅ DITAMBAHKAN: Relasi ke ProductCategory
    let name: String
    let price: Double
    let recipe: [RecipeItem]
    var imageData: Data?   // ✅ DITAMBAHKAN: Penyimpanan gambar opsional
    
    // Default value ditambahkan agar kompatibel dengan data yang sudah ada sebelumnya
    init(id: String? = nil, branchId: String = "", categoryId: String = "", name: String, price: Double, recipe: [RecipeItem], imageData: Data? = nil) {
        self.id = id
        self.branchId = branchId
        self.categoryId = categoryId
        self.name = name
        self.price = price
        self.recipe = recipe
        self.imageData = imageData
    }
}
