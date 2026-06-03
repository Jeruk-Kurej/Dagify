//
//  SyncManagerProtocol.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 30-05-2026.
//

import Foundation
import SwiftData

/// Defines operations for syncing offline data (SwiftData) with the cloud (Firebase).
protocol SyncManagerProtocol {
    func syncOfflineOrders(context: ModelContext, branchId: String) async
}
