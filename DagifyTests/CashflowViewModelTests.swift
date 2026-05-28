//
//  CashflowViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation

@testable import Dagify

@Suite("CashflowViewModel Tests")
struct CashflowViewModelTests {
    
    @Test @MainActor func testAddIncomeAndExpense() async throws {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(repo: mockRepo)
        
        await vm.addTransaction(amount: 100000, type: .income, notes: "Modal Awal")
        await vm.addTransaction(amount: 20000, type: .expense, notes: "Beli Sapu")
        
        #expect(vm.errorMessage == nil)
    }
}
