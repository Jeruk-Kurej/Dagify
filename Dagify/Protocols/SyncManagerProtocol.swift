//
//  SyncManagerProtocol.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import Foundation
import SwiftData

/// Defines operations for syncing offline data (SwiftData) with the cloud (Firebase).
protocol SyncManagerProtocol {
    func syncOfflineOrders(context: ModelContext, branchId: String) async
}
