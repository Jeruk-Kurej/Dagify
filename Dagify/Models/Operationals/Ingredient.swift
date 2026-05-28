//
//  Ingredient.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestoreSwift

struct Ingredient: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    var currentStock: Double
    let unit: String
    let expiryDate: Date?
}
