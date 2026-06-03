//
//  Order.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import FirebaseFirestore
import Foundation

struct Order: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var branchId: String
    var customerId: String?  // Opsional jika pelanggan umum

    var items: [OrderItem]
    var totalAmount: Double
    var timestamp: Date

    // MARK: - Initialization
    init(
        id: String? = nil,
        branchId: String,
        customerId: String? = nil,
        items: [OrderItem],
        totalAmount: Double,
        timestamp: Date
    ) {
        self.id = id
        self.branchId = branchId
        self.customerId = customerId
        self.items = items
        self.totalAmount = totalAmount
        self.timestamp = timestamp
    }
}
