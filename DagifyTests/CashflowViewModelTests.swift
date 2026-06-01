//
//  CashflowViewModelTests.swift
//  DagifyTests
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Testing
import Foundation
import SwiftData
@testable import Dagify

@MainActor
@Suite("Cashflow ViewModel Tests")
struct CashflowViewModelTests {
    
    @Test("Skenario 1: Tambah Pemasukan dan Hitung Saldo")
    func testAddIncomeAndCalculate() async throws {
        let context = try TestHelper.createInMemoryContext()
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(repository: mockRepo)
        
        await vm.addTransaction(amount: 1000000, type: .income, category: .none, notes: "Pendapatan A", branchId: "B1", context: context)
        vm.loadData(branchId: "B1", context: context)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(vm.records.count == 1, "Data pemasukan gagal disimpan")
        #expect(vm.totalIncome == 1000000, "Kalkulasi total pemasukan salah")
        #expect(vm.netProfit == 1000000, "Laba bersih harusnya sama dengan pemasukan jika tidak ada pengeluaran")
    }
    
    @Test("Skenario 2: Tambah Pengeluaran dan Potong Laba Bersih")
    func testAddExpenseAndDeductProfit() async throws {
        let context = try TestHelper.createInMemoryContext()
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(repository: mockRepo)
        
        await vm.addTransaction(amount: 1000000, type: .income, category: .none, notes: "Pendapatan A", branchId: "B1", context: context)
        await vm.addTransaction(amount: 300000, type: .expense, category: .operational, notes: "Listrik", branchId: "B1", context: context)
        
        vm.loadData(branchId: "B1", context: context)
        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(vm.totalExpense == 300000, "Kalkulasi total pengeluaran salah")
        #expect(vm.netProfit == 700000, "Pemotongan Laba Bersih (Income - Expense) tidak akurat!")
    }
    
    @Test("Skenario 3: Penghapusan Transaksi")
    func testDeleteTransaction() async throws {
        let context = try TestHelper.createInMemoryContext()
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(repository: mockRepo)
        
        await vm.addTransaction(amount: 50000, type: .income, category: .none, notes: "Test Hapus", branchId: "B1", context: context)
        vm.loadData(branchId: "B1", context: context)
        
        guard let recordToTrash = vm.records.first else { Issue.record("Data setup gagal"); return }
        
        await vm.deleteTransaction(recordToTrash, branchId: "B1", context: context)
        vm.loadData(branchId: "B1", context: context)
        
        #expect(vm.records.isEmpty == true, "Record gagal dihapus dari database")
    }
}
