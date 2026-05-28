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

    func login(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        let snapshot = try await db.collection("users").document(
            result.user.uid
        ).getDocument()

        guard let user = try snapshot.data(as: User?.self) else {
            throw NSError(
                domain: "Auth",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "User profile missing"]
            )
        }
        return user
    }
}
