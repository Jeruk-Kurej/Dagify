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
    
     init() {}
    
     func login(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        let uid = authResult.user.uid
        
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard let user = try snapshot.data(as: User?.self) else {
            throw NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profil pengguna tidak ditemukan."])
        }
        return user
    }
    
    // FITUR BARU: Registrasi Kompleks (User + Store + Branch)
     func register(email: String, password: String, storeName: String, branchName: String) async throws -> User {
        // 1. Buat akun di Firebase Auth
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let uid = authResult.user.uid
        
        // Siapkan Batch untuk penulisan serentak
        let batch = db.batch()
        
        // 2. Siapkan dokumen Store baru
        let storeRef = db.collection("stores").document()
        let storeId = storeRef.documentID
        
        let newBranch = Branch(id: UUID().uuidString, name: branchName, address: "Belum diatur")
        let newStore = Store(id: storeId, name: storeName, branches: [newBranch])
        try batch.setData(from: newStore, forDocument: storeRef)
        
        // 3. Siapkan dokumen User yang terikat dengan Store tersebut
        let userRef = db.collection("users").document(uid)
        let newUser = User(id: uid, email: email, storeId: storeId)
        try batch.setData(from: newUser, forDocument: userRef)
        
        // 4. Eksekusi semua secara serentak
        try await batch.commit()
        
        return newUser
    }
    
     func logout() throws {
        try auth.signOut()
    }
}
