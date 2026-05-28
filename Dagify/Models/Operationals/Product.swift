//
//  Product.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestoreSwift

struct Product: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    let price: Double
    let recipe: [RecipeItem]
}

struct OrderItem: Codable, Equatable {
    let product: Product
    var quantity: Int
}

struct Order: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let branchId: String
    let customerId: String?
    let items: [OrderItem]
    let totalAmount: Double
    let timestamp: Date
}
