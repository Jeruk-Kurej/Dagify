//
//  MockCashflowRepository.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftData

@MainActor
class MockCashflowRepository: CashflowProtocol {
    var shouldThrowError = false
    func addRecord(_ record: FinancialRecord, context: ModelContext) async throws { if shouldThrowError { throw NSError() }; context.insert(record) }
    func fetchLocalRecords(branchId: String, context: ModelContext) throws -> [FinancialRecord] { return try context.fetch(FetchDescriptor<FinancialRecord>()) }
    func deleteRecord(_ record: FinancialRecord, context: ModelContext) async throws { context.delete(record) }
    func syncUnsyncedRecords(context: ModelContext) async throws {}
}
