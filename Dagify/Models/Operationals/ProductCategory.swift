//
//  ProductCategory.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import FirebaseFirestore
import Foundation

struct ProductCategory: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var branchId: String
    var name: String

    // MARK: - Initialization
    init(id: String? = nil, branchId: String, name: String) {
        self.id = id
        self.branchId = branchId
        self.name = name
    }
}
