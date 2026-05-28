//
//  User.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct User: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let email: String
    public let storeId: String
    
    public init(id: String? = nil, email: String, storeId: String) {
        self.id = id
        self.email = email
        self.storeId = storeId
    }
}
