//
//  FirebaseCashflowService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import FirebaseFirestore

class FirebaseCashflowService: CashflowRepository {
    let db = Firestore.firestore()
    let collectionName = "financial_records"
    
    init() {}
    
    func addRecord(_ record: FinancialRecord) async throws -> Bool {
        let ref = db.collection(collectionName).document()
        try ref.setData(from: record)
        return true
    }
    
    func fetchRecords(for branchId: String) async throws -> [FinancialRecord] {
        let snapshot = try await db.collection(collectionName)
            .whereField("branchId", isEqualTo: branchId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: FinancialRecord.self) }
    }
    
    func deleteRecord(id: String) async throws -> Bool {
        try await db.collection(collectionName).document(id).delete()
        return true
    }
}
