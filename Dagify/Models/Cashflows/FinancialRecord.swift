//
//  FinancialRecord.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import FirebaseFirestore
import Foundation

struct FinancialRecord: Identifiable, Codable, Equatable {

    // MARK: - Properties
    @DocumentID public var id: String?
    var branchId: String

    var amount: Double
    var type: TransactionType
    var category: ExpenseCategory
    var timestamp: Date
    var notes: String

    // MARK: - Initialization
    init(
        id: String? = nil,
        branchId: String,
        amount: Double,
        type: TransactionType,
        category: ExpenseCategory,
        timestamp: Date,
        notes: String
    ) {
        self.id = id
        self.branchId = branchId
        self.amount = amount
        self.type = type
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
    }
}
