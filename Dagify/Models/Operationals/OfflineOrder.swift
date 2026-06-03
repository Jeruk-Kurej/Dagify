//
//  OfflineOrder.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftData

@Model
class OfflineOrderModel {

    // MARK: - Properties
    @Attribute(.unique) var id: String
    var orderData: Data  // Encoded 'Order' struct
    var timestamp: Date

    // MARK: - Initialization
    init(id: String = UUID().uuidString, orderData: Data, timestamp: Date) {
        self.id = id
        self.orderData = orderData
        self.timestamp = timestamp
    }
}
