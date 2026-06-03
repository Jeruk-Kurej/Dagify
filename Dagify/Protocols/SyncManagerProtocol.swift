//
//  SyncManagerProtocol.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 30-05-2026.
//

import Foundation
import SwiftData

protocol SyncManagerProtocol {
    func handleCheckout(order: Order, isConnected: Bool, firebaseRepo: OperationalProtocol, context: ModelContext) async throws
}
