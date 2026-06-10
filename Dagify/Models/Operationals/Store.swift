//
//  Store.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Store: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var name: String
    var branches: [Branch]
    var loyaltyThreshold: Int

    // MARK: - Initialization
    init(id: String? = nil, name: String, branches: [Branch] = [], loyaltyThreshold: Int = 5) {
        self.id = id
        self.name = name
        self.branches = branches
        self.loyaltyThreshold = loyaltyThreshold
    }
}
