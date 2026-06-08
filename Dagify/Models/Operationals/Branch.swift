//
//  Branch.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct Branch: Identifiable, Codable, Equatable {

    // MARK: - Properties
    var id: String
    var name: String
    var address: String

    // MARK: - Initialization
    init(id: String = UUID().uuidString, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}
