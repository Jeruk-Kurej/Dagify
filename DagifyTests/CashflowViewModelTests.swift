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
    @Test("Test Fungsi deleteTransaction - Menghapus Riwayat")
        func testDeleteTransaction() async {
            let mockRepo = MockCashflowRepository()
            let vm = CashflowViewModel(cashProtocol: mockRepo)
            
            let record = FinancialRecord(id: "REC-1", branchId: "B1", amount: 50000, type: .income, category: .none, timestamp: Date(), notes: "Test")
            _ = try? await mockRepo.addRecord(record)
            
            await vm.loadRecords(branchId: "B1")
            #expect(vm.records.count == 1)
            
            await vm.deleteTransaction(recordId: "REC-1", branchId: "B1")
            #expect(vm.records.isEmpty == true)
        }

        @Test("Test Properti groupedRecordsByMonth - Mengelompokkan Data per Bulan")
        func testGroupedRecordsByMonth() async {
            let mockRepo = MockCashflowRepository()
            let vm = CashflowViewModel(cashProtocol: mockRepo)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let r1 = FinancialRecord(branchId: "B1", amount: 100, type: .income, category: .none, timestamp: formatter.date(from: "2026-05-10")!, notes: "Mei")
            let r2 = FinancialRecord(branchId: "B1", amount: 200, type: .income, category: .none, timestamp: formatter.date(from: "2026-06-15")!, notes: "Juni")
            
            _ = try? await mockRepo.addRecord(r1)
            _ = try? await mockRepo.addRecord(r2)
            
            await vm.loadRecords(branchId: "B1")
            
            let grouped = vm.groupedRecordsByMonth
            #expect(grouped.keys.count == 2) 
        }
}
