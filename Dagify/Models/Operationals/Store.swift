//
//  Store.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let name: String
    public let branches: [Branch]
    
    public init(id: String? = nil, name: String, branches: [Branch]) {
        self.id = id
        self.name = name
        self.branches = branches
    }
}
