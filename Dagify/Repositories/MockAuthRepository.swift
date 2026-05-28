//
//  MockAuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

public class MockAuthRepository: AuthRepository {
    public var shouldThrowError = false
    public var currentUser: User? = User(
        id: "U-1",
        email: "bcarlielukito@student.ciputra.ac.id",
        storeId: "S-1"
    )

    public init() {}

    public func login(email: String, password: String) async throws -> User {
        if shouldThrowError { throw NSError(domain: "MockAuth", code: 401) }
        return currentUser!
    }

    public func logout() throws {
        currentUser = nil
    }
}
