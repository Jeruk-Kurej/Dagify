//
//  AuthRepository.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func logout() throws
}
