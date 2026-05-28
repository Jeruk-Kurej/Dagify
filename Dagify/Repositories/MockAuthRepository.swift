//
//  MockAuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

class MockAuthRepository: AuthRepository {
    public var shouldThrowError = false
    public var currentUser: User? = nil
    public var registeredStore: Store? = nil
    
    public init() {}
    
    public func login(email: String, password: String) async throws -> User {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 401) }
        currentUser = User(id: "U-1", email: email, storeId: "S-1")
        return currentUser!
    }
    
    public func register(email: String, password: String, storeName: String, branchName: String) async throws -> User {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 500) }
        
        let storeId = "S-\(UUID().uuidString)"
        registeredStore = Store(id: storeId, name: storeName, branches: [Branch(id: "B-1", name: branchName, address: "")])
        
        currentUser = User(id: "U-\(UUID().uuidString)", email: email, storeId: storeId)
        return currentUser!
    }
    
    public func logout() throws {
        currentUser = nil
    }
}
