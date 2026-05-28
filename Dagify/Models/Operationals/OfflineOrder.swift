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
    @Attribute(.unique) var id: String
    var orderData: Data
    var timestamp: Date
    
    init(id: String, orderData: Data, timestamp: Date) {
        self.id = id
        self.orderData = orderData
        self.timestamp = timestamp
    }
}
