//
//  StoreRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

protocol StoreProtocol {
    func fetchStore(storeId: String) async throws -> Store
}
