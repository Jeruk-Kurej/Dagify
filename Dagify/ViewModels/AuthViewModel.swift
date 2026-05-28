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
    public var currentUser: User? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    private let authRepo: AuthRepository

    public init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    public var isAuthenticated: Bool {
        return currentUser != nil
    }

    public func login(email: String, password: String) async {
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

    public func register(
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

    public func logout() {
        do {
            try authRepo.logout()
            currentUser = nil
        } catch {
            errorMessage = "Gagal logout."
        }
    }
}
