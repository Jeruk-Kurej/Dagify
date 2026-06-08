//
//  OrderItem.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
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
