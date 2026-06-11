//
//  MockAuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

enum MockAuthError: LocalizedError {
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Periksa kembali kredensial Anda."
        }
    }
}

class MockAuthRepository: AuthProtocol {

    // MARK: - Mock State
    var shouldThrowError = false
    var currentUser: User? = User(
        id: "U-1",
        email: "test@dagify.com",
        storeId: "S-1"
    )

    // MARK: - AuthProtocol Implementation

    func login(email: String, password: String) async throws -> User {
        if shouldThrowError {
            throw MockAuthError.invalidCredentials
        }
        return currentUser ?? User(id: "U-1", email: email, storeId: "S-1")
    }

    func register(
        email: String,
        password: String,
        storeName: String,
        branchName: String
    ) async throws -> User {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 400, userInfo: nil)
        }
        return User(id: "U-2", email: email, storeId: "S-2")
    }

    func logout() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 500, userInfo: nil)
        }
        currentUser = nil
    }

    func getCurrentUser() async throws -> User? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 500, userInfo: nil)
        }
        return currentUser
    }
}
