//
//  MockCashflowRepository.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation

class MockCashflowRepository: CashflowProtocol {

    // MARK: - Mock State
    var shouldThrowError = false
    var records: [FinancialRecord] = []

    // MARK: - CashflowProtocol Implementation

    func addRecord(_ record: FinancialRecord) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        records.append(record)
        return true
    }

    func fetchRecords(for branchId: String) async throws -> [FinancialRecord] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return records.filter { $0.branchId == branchId }
    }

    func deleteRecord(id: String) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        records.removeAll { $0.id == id }
        return true
    }

    func updateRecord(_ record: FinancialRecord) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            return true
        }
        return false
    }
}

