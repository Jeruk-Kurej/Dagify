//
//  FirebaseCashflowService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import FirebaseFirestore
import Foundation

class FirebaseCashflowService: CashflowProtocol {

    // MARK: - Properties
    private let db = Firestore.firestore()
    private let collectionName = "financial_records"

    // MARK: - Initialization
    init() {}

    // MARK: - Create
    func addRecord(_ record: FinancialRecord) async throws -> Bool {
        let ref = db.collection(collectionName).document()
        try ref.setData(from: record)
        return true
    }

    // MARK: - Read
    func fetchRecords(for branchId: String) async throws -> [FinancialRecord] {
        let snapshot = try await db.collection(collectionName)
            .whereField("branchId", isEqualTo: branchId)
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap {
            try? $0.data(as: FinancialRecord.self)
        }
    }

    // MARK: - Update
    func updateRecord(_ record: FinancialRecord) async throws -> Bool {
        guard let id = record.id else { return false }
        try db.collection(collectionName).document(id).setData(from: record)
        return true
    }

    // MARK: - Delete
    func deleteRecord(id: String) async throws -> Bool {
        try await db.collection(collectionName).document(id).delete()
        return true
    }
}
