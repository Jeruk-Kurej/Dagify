//
//  MockSyncManager.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 30/05/26.
//

import Foundation
import SwiftData

class MockSyncManager: SyncManagerProtocol {

    // MARK: - Mock State
    var didSync = false

    // MARK: - SyncManagerProtocol Implementation

    func syncOfflineOrders(context: ModelContext, branchId: String) async {
        // Hanya simulasi bahwa method ini terpanggil tanpa error
        didSync = true
    }
}
