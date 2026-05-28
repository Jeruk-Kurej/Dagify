//
//  MockOperationalRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

class MockOperationalRepository: OperationalRepository {
    var submitCallCount = 0
    func submitOrder(_ order: Order) async throws -> Bool {
        submitCallCount += 1
        return true
    }
    func updateInventoryStock(for items: [OrderItem]) async throws -> Bool {
        return true
    }
}
