//
//  Branch.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct Branch: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let address: String
    
    public init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}
