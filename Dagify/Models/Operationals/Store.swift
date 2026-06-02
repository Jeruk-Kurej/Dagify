//
//  Store.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    var branches: [Branch]
    
    init(id: String? = nil, name: String, branches: [Branch]) {
        self.id = id
        self.name = name
        self.branches = branches
    }
}
