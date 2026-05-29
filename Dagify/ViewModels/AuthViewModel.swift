//
//  AuthViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
class AuthViewModel{
     var currentUser: User? = nil
     var isLoading: Bool = false
     var errorMessage: String? = nil

    private let authRepo: AuthRepository

     init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

     var isAuthenticated: Bool {
        return currentUser != nil
    }

     func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await authRepo.login(
                email: email,
                password: password
            )
        } catch {
            errorMessage = "Gagal login: Periksa kembali kredensial Anda."
        }

        isLoading = false
    }

     func register(
        email: String,
        password: String,
        storeName: String,
        branchName: String
    ) async {
        guard !email.isEmpty, !password.isEmpty, !storeName.isEmpty else {
            errorMessage = "Semua kolom pendaftaran wajib diisi."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            currentUser = try await authRepo.register(
                email: email,
                password: password,
                storeName: storeName,
                branchName: branchName
            )
        } catch {
            errorMessage = "Gagal mendaftar: \(error.localizedDescription)"
        }

        isLoading = false
    }

     func logout() {
        do {
            try authRepo.logout()
            currentUser = nil
        } catch {
            errorMessage = "Gagal logout."
        }
    }
}
