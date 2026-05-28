//
//  Order.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Order: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let branchId: String
    public let customerId: String?
    public let items: [OrderItem]
    public let totalAmount: Double
    public let timestamp: Date
    
    public init(id: String? = nil, branchId: String, customerId: String?, items: [OrderItem], totalAmount: Double, timestamp: Date) {
        self.id = id
        self.branchId = branchId
        self.customerId = customerId
        self.items = items
        self.totalAmount = totalAmount
        self.timestamp = timestamp
    }
}
