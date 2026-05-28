//
//  FirebaseAuthService.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseAuthService: AuthRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    public init() {}

    public func login(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(
            withEmail: email,
            password: password
        )
        let uid = authResult.user.uid

        let snapshot = try await db.collection("users").document(uid)
            .getDocument()
        guard let user = try snapshot.data(as: User?.self) else {
            throw NSError(
                domain: "AuthError",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Profil pengguna tidak ditemukan."
                ]
            )
        }
        return user
    }

    public func logout() throws {
        try auth.signOut()
    }
}
