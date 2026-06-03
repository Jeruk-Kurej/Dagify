//
//  Store.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import FirebaseFirestore
import Foundation

struct Store: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var name: String
    var branches: [Branch]

    // MARK: - Initialization
    init(id: String? = nil, name: String, branches: [Branch] = []) {
        self.id = id
        self.name = name
        self.branches = branches
    }
}
