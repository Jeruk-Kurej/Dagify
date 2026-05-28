//
//  OperationalRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

protocol OperationalRepository {
    func submitOrder(_ order: Order) async throws -> Bool
    func updateInventoryStock(for items: [OrderItem]) async throws -> Bool
}
