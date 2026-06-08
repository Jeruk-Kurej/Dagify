//
//  MockStoreRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import Foundation

class MockStoreRepository: StoreProtocol {
    var shouldThrowError = false
    var dummyStore: Store = Store(
        id: "S-1",
        name: "Dagify Test Store",
        branches: []
    )

    func fetchStore(storeId: String) async throws -> Store {
        if shouldThrowError {
            throw NSError(
                domain: "MockStoreError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch store"]
            )
        }
        return dummyStore
    }

    func addBranch(storeId: String, branch: Branch) async throws -> Bool {
        if shouldThrowError {
            throw NSError(
                domain: "MockStoreError",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to add branch"]
            )
        }
        dummyStore.branches.append(branch)
        return true
    }
}
