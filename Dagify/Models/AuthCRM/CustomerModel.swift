//
//  Customer.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct Customer: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public var storeId: String // ✅ DITAMBAHKAN: Agar selaras dengan pencarian Firebase
    public let name: String
    public let phoneNumber: String
    public var totalSpent: Double
    public var visitHistory: [Date]
    
    public init(id: String? = nil, storeId: String, name: String, phoneNumber: String, totalSpent: Double, visitHistory: [Date]) {
        self.id = id
        self.storeId = storeId
        self.name = name
        self.phoneNumber = phoneNumber
        self.totalSpent = totalSpent
        self.visitHistory = visitHistory
    }
    
    public var isLoyal: Bool {
        return visitHistory.count >= 5
    }
}
