//
//  User.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct User: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var email: String
    var storeId: String

    // MARK: - Initialization
    init(id: String? = nil, email: String, storeId: String) {
        self.id = id
        self.email = email
        self.storeId = storeId
    }
}
