//
//  SyncManagerProtocol.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 30-05-2026.
//

import Foundation

protocol SyncManagerProtocol {
    func handleCheckout(order: Order, isConnected: Bool, firebaseRepo: OperationalRepository, context: ModelContext) async throws
}
