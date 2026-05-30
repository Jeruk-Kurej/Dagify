//
//  Branch.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

struct Branch: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let address: String
    
    init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }
}
