//
//  CashflowRepository.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import SwiftData

protocol CashflowProtocol {
    func addRecord(_ record: FinancialRecord, context: ModelContext) async throws
    func fetchLocalRecords(branchId: String, context: ModelContext) throws -> [FinancialRecord]
    func deleteRecord(_ record: FinancialRecord, context: ModelContext) async throws
    func syncUnsyncedRecords(context: ModelContext) async throws
}
