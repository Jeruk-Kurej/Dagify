//
//  OrderItem.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct OrderItem: Codable, Equatable {
    public let product: Product
    public var quantity: Int
    
    public init(product: Product, quantity: Int) {
        self.product = product
        self.quantity = quantity
    }
}

