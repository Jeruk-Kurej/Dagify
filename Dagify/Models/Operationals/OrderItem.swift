//
//  OrderItem.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct OrderItem: Codable, Equatable {
    let product: Product
    var quantity: Int
}
