//
//  MockCashflowRepository.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation

class MockCashflowRepository: CashflowRepository {
    var records: [FinancialRecord] = []
    var shouldThrowError = false
    
    init() {}
    
    func addRecord(_ record: FinancialRecord) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        
        var newRecord = record
        if newRecord.id == nil {
            newRecord.id = UUID().uuidString
        }
        records.append(newRecord)
        return true
    }
    
    func fetchRecords(for branchId: String) async throws -> [FinancialRecord] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 404) }
        
        return records
            .filter { $0.branchId == branchId }
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func deleteRecord(id: String) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        records.removeAll { $0.id == id }
        return true
    }
}
