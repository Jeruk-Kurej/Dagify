//
//  FinancialRecord.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftData
import FirebaseFirestore

@Model
final class FinancialRecord {
    @Attribute(.unique) var id: String
    var branchId: String
    var amount: Double
    var typeRaw: String
    var categoryRaw: String
    var timestamp: Date
    var notes: String
    var isSynced: Bool
    
    init(id: String = UUID().uuidString, branchId: String, amount: Double, type: TransactionType, category: ExpenseCategory, timestamp: Date = Date(), notes: String, isSynced: Bool = false) {
        self.id = id
        self.branchId = branchId
        self.amount = amount
        self.typeRaw = type.rawValue
        self.categoryRaw = category.rawValue
        self.timestamp = timestamp
        self.notes = notes
        self.isSynced = isSynced
    }
    
    @Transient var type: TransactionType { TransactionType(rawValue: typeRaw) ?? .expense }
    @Transient var category: ExpenseCategory { ExpenseCategory(rawValue: categoryRaw) ?? .none }
}

struct FinancialRecordDTO: Codable {
    @DocumentID var id: String?
    let branchId: String
    let amount: Double
    let typeRaw: String
    let categoryRaw: String
    let timestamp: Date
    let notes: String
    
    init(from model: FinancialRecord) {
        self.id = model.id
        self.branchId = model.branchId
        self.amount = model.amount
        self.typeRaw = model.typeRaw
        self.categoryRaw = model.categoryRaw
        self.timestamp = model.timestamp
        self.notes = model.notes
    }
}
