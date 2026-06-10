//
//  AuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

/// Defines operations for Business Store and Branch structural data.
protocol StoreProtocol {
    func fetchStore(storeId: String) async throws -> Store
    func addBranch(storeId: String, branch: Branch) async throws -> Bool
    func updateStore(store: Store) async throws -> Bool
}
