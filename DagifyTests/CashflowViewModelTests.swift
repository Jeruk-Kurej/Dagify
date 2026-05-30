//
//  CashflowViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
@testable import Dagify

@Suite("Cashflow ViewModel Tests")
@MainActor
struct CashflowViewModelTests {
    
    @Test("Test Load Records")
    func testLoadRecords() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        let record = FinancialRecord(branchId: "B1", amount: 50000, type: .income, category: .none, timestamp: Date(), notes: "Test")
        _ = try? await mockRepo.addRecord(record)
        
        await vm.loadRecords(branchId: "B1")
        
        #expect(vm.records.count == 1)
        #expect(vm.totalIncome == 50000)
    }
    
    @Test("Test Tambah Transaksi")
    func testAddTransaction() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        await vm.addTransaction(branchId: "B1", amount: 150000, type: .income, category: .none, notes: "Jual Kopi")
        
        #expect(vm.records.count == 1)
        #expect(vm.records.first?.amount == 150000)
    }
    
    @Test("Test Kalkulasi Laba Bersih & Total")
    func testAnalyticsComputations() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        await vm.addTransaction(branchId: "B1", amount: 200000, type: .income, category: .none, notes: "Pendapatan Hari ini")
        await vm.addTransaction(branchId: "B1", amount: 50000, type: .expense, category: .cogs, notes: "Beli Susu")
        
        #expect(vm.totalIncome == 200000)
        #expect(vm.totalExpense == 50000)
        #expect(vm.netProfit == 150000)
    }
}
