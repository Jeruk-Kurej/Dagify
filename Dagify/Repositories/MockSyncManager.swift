//
//  MockSyncManager.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 30-05-2026.
//

import Foundation
import SwiftData

class MockSyncManager: SyncManagerProtocol {
    var isCheckoutCalled = false
    var shouldThrowError = false
    
    func handleCheckout(order: Order, isConnected: Bool, firebaseRepo: OperationalProtocol, context: ModelContext) async throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        isCheckoutCalled = true
    }
}

class MockNetworkMonitor {
    var isConnected: Bool = true
}
