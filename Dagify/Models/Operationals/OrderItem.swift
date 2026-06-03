//
//  OrderItem.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct OrderItem: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
     var id: String
     var product: Product
     var quantity: Int
    
    // MARK: - Initialization
     init(id: String = UUID().uuidString, product: Product, quantity: Int) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
}
