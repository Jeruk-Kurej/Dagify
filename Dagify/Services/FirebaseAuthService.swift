//
//  FirebaseAuthService.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

//
//  FirebaseAuthService.swift
//  Dagify
//
//  Standardized BaaS Implementation.
//  Handles Authentication using Firebase Auth and user records in Firestore.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseAuthService: AuthProtocol {

    // MARK: - Properties
    let auth = Auth.auth()
    let db = Firestore.firestore()

    // MARK: - Initialization
    init() {}

    // MARK: - Authentication Methods

    func login(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(
            withEmail: email,
            password: password
        )
        let snapshot = try await db.collection("users").document(
            authResult.user.uid
        ).getDocument()

        guard let user = try snapshot.data(as: User?.self) else {
            throw NSError(
                domain: "Auth",
                code: 404,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Data pengguna tidak ditemukan di database."
                ]
            )
        }
        return user
    }

    func register(
        email: String,
        password: String,
        storeName: String,
        branchName: String
    ) async throws -> User {
        let authResult = try await auth.createUser(
            withEmail: email,
            password: password
        )
        let uid = authResult.user.uid

        // Membuat entitas Store & Branch baru
        let storeId = UUID().uuidString
        let branchId = UUID().uuidString

        let initialBranch = Branch(
            id: branchId,
            name: branchName,
            address: "Alamat belum diatur"
        )
        let newStore = Store(
            id: storeId,
            name: storeName,
            branches: [initialBranch]
        )
        try db.collection("stores").document(storeId).setData(from: newStore)

        // Mendaftarkan User
        let newUser = User(id: uid, email: email, storeId: storeId)
        try db.collection("users").document(uid).setData(from: newUser)

        return newUser
    }

    func logout() throws {
        try auth.signOut()
    }

    func getCurrentUser() async throws -> User? {
        guard let currentUser = auth.currentUser else { return nil }
        let snapshot = try await db.collection("users").document(
            currentUser.uid
        ).getDocument()
        return try snapshot.data(as: User?.self)
    }
}
