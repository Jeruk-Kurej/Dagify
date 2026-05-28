//
//  MockAuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

class MockAuthRepository: AuthRepository {
    var dummyUser = User(
        id: "U-1",
        email: "bcarlielukito@student.ciputra.ac.id",
        storeId: "S-1"
    )

    func login(email: String, password: String) async throws -> User {
        return dummyUser
    }
}
