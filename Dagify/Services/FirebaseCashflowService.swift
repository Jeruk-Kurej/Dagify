//
//  FirebaseCashflowService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//
import Foundation
import FirebaseFirestore
import Network
import SwiftData

@MainActor
final class FirebaseCashflowService: CashflowProtocol {
    private let db = Firestore.firestore()
    private let monitor = NWPathMonitor()
    private var isOnline = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in self?.isOnline = (path.status == .satisfied) }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func addRecord(_ record: FinancialRecord, context: ModelContext) async throws {
        context.insert(record)
        try context.save()
        if isOnline {
            try await pushToFirebase(record)
            record.isSynced = true
            try context.save()
        }
    }
    
    func fetchLocalRecords(branchId: String, context: ModelContext) throws -> [FinancialRecord] {
        let predicate = #Predicate<FinancialRecord> { $0.branchId == branchId }
        let descriptor = FetchDescriptor<FinancialRecord>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func deleteRecord(_ record: FinancialRecord, context: ModelContext) async throws {
        let recordId = record.id
        context.delete(record)
        try context.save()
        if isOnline { try await db.collection("financial_records").document(recordId).delete() }
    }
    
    func syncUnsyncedRecords(context: ModelContext) async throws {
        guard isOnline else { return }
        let predicate = #Predicate<FinancialRecord> { $0.isSynced == false }
        let unsynced = try context.fetch(FetchDescriptor<FinancialRecord>(predicate: predicate))
        for record in unsynced {
            try await pushToFirebase(record)
            record.isSynced = true
        }
        try context.save()
    }
    
    private func pushToFirebase(_ record: FinancialRecord) async throws {
        let dto = FinancialRecordDTO(from: record)
        try db.collection("financial_records").document(record.id).setData(from: dto)
    }
}
