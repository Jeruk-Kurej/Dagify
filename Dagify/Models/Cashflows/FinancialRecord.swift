//
//  FinancialRecord.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import FirebaseFirestore

struct FinancialRecord: Identifiable, Codable, Equatable {
    @DocumentID public var id: String?
    public let branchId: String
    public let amount: Double
    public let type: TransactionType
    public let category: ExpenseCategory
    public let timestamp: Date
    public let notes: String
    
    init(id: String? = nil, branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, timestamp: Date, notes: String) {
        self.id = id
        self.branchId = branchId
        self.amount = amount
        self.type = type
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
    }
}
