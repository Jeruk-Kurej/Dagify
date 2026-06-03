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
    public var branchId: String
    // ✅ FIX: Semua 'let' diubah menjadi 'var' agar bisa diedit di Form
    public var amount: Double
    public var type: TransactionType
    public var category: ExpenseCategory
    public var timestamp: Date
    public var notes: String
    
    public init(id: String? = nil, branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, timestamp: Date, notes: String) {
        self.id = id
        self.branchId = branchId
        self.amount = amount
        self.type = type
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
    }
}
