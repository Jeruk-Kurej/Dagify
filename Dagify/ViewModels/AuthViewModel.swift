//
//  AuthViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Combine
import Foundation

@MainActor
class AuthViewModel: ObservableObject {
    var currentUser: User?
    var isLoading: Bool = false
    var error: String?

    private let authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func login(email: String, password: String) async {
        isLoading = true
        do {
            self.currentUser = try await authRepo.login(
                email: email,
                password: password
            )
        } catch {
            self.error = "Login gagal. Periksa kembali email dan password Anda."
        }
        isLoading = false
    }
}
