//
//  CashflowViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("CashflowViewModel Swift Tests")
struct CashflowViewModelTests {
    
    // a. Load Records Successfully -> Menghitung total Income, Expense, dan Net Profit dengan benar
    @Test @MainActor func testLoadRecordsAndCalculations() async throws {
        let mockRepo = MockCashflowRepository()
        let testDate = Date()
        
        mockRepo.records = [
            FinancialRecord(id: "1", branchId: "B-1", amount: 500000, type: .income, category: .none, timestamp: testDate, notes: "Sales Harian"),
            FinancialRecord(id: "2", branchId: "B-1", amount: 150000, type: .expense, category: .cogs, timestamp: testDate, notes: "Beli Biji Kopi"),
            FinancialRecord(id: "3", branchId: "B-1", amount: 50000, type: .expense, category: .incidental, timestamp: testDate, notes: "Benerin Pipa Bocor")
        ]
        
        let vm = CashflowViewModel(repository: mockRepo)
        
        await vm.loadRecords(branchId: "B-1")
        
        #expect(vm.records.count == 3)
        #expect(vm.totalIncome == 500000)
        #expect(vm.totalExpense == 200000)
        #expect(vm.netProfit == 300000)
        #expect(vm.errorMessage == nil)
    }
    
    // b. Add Transaction -> Data langsung masuk dan perhitungan berubah otomatis
    @Test @MainActor func testAddTransactionSuccessfully() async throws {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(repository: mockRepo)
        
        #expect(vm.records.isEmpty)
        
        await vm.addTransaction(branchId: "B-2", amount: 100000, type: .expense, category: .operational, notes: "Bayar Listrik")
        
        #expect(mockRepo.records.count == 1)
        #expect(vm.records.count == 1)
        #expect(vm.totalExpense == 100000)
        #expect(vm.netProfit == -100000)
    }
    
    // c. Delete Transaction -> Mengurangi record yang ada
    @Test @MainActor func testDeleteTransaction() async throws {
        let mockRepo = MockCashflowRepository()
        let testRecord = FinancialRecord(id: "REC-1", branchId: "B-1", amount: 50000, type: .income, category: .none, timestamp: Date(), notes: "Test")
        mockRepo.records = [testRecord]
        
        let vm = CashflowViewModel(repository: mockRepo)
        await vm.loadRecords(branchId: "B-1")
        #expect(vm.records.count == 1)
        
        await vm.deleteTransaction(recordId: "REC-1", branchId: "B-1")
        
        #expect(vm.records.isEmpty)
        #expect(mockRepo.records.isEmpty)
    }
    
    // d. Load Records Error -> ViewModel menangkap error dan mengosongkan data
    @Test @MainActor func testLoadRecordsFails() async throws {
        let mockRepo = MockCashflowRepository()
        mockRepo.shouldThrowError = true
        
        let vm = CashflowViewModel(repository: mockRepo)
        await vm.loadRecords(branchId: "B-1")
        
        #expect(vm.errorMessage != nil)
        #expect(vm.records.isEmpty)
    }
}
