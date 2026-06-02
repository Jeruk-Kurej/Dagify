//
//  ProductCategory.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import Foundation
import FirebaseFirestore

struct ProductCategory: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var branchId: String
    var name: String
    
    init(id: String? = nil, branchId: String = "", name: String) {
        self.id = id
        self.branchId = branchId
        self.name = name
    }
}
