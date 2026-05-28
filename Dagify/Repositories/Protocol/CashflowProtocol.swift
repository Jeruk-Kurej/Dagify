//
//  CashflowRepository.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation

protocol CashflowProtocol {
    func addRecord(_ record: FinancialRecord) async throws -> Bool
    func fetchRecords(for branchId: String) async throws -> [FinancialRecord]
    func deleteRecord(id: String) async throws -> Bool
}
