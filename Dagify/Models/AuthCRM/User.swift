//
//  User.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let email: String
    let storeId: String  // 1 Akun = 1 Toko
}
