import Foundation
import Testing

@testable import Dagify

@Suite("Cashflow ViewModel Tests")
@MainActor
struct CashflowViewModelTests {

    @Test("Fungsi: previousMonth() dan nextMonth()")
    func testMonthNavigation() {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        let initialMonth = vm.currentMonthString
        
        vm.previousMonth()
        let previousMonth = vm.currentMonthString
        #expect(initialMonth != previousMonth)
        
        vm.nextMonth()
        let nextMonth = vm.currentMonthString
        #expect(initialMonth == nextMonth)
    }

    @Test("Fungsi: loadRecords() - Skenario Berhasil")
    func testLoadRecordsSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)

        let r1 = FinancialRecord(id: "1", branchId: "B-1", amount: 10000, type: .income, category: .none, timestamp: Date(), notes: "")
        let r2 = FinancialRecord(id: "2", branchId: "B-1", amount: 5000, type: .expense, category: .cogs, timestamp: Date(), notes: "")
        mockRepo.records = [r1, r2]

        await vm.loadRecords(branchId: "B-1")

        #expect(vm.records.count == 2)
        #expect(vm.totalIncome == 10000)
        #expect(vm.totalExpense == 5000)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: loadRecords() - Skenario Error")
    func testLoadRecordsFailure() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        mockRepo.shouldThrowError = true

        await vm.loadRecords(branchId: "B-1")

        #expect(vm.records.isEmpty == true)
        #expect(vm.errorMessage != nil)
    }

    @Test("Fungsi: addTransaction() - Skenario Berhasil")
    func testAddTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)

        await vm.addTransaction(branchId: "B-1", amount: 20000, type: .income, category: .none, notes: "Laris", date: Date())

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.records.count == 1)
        #expect(mockRepo.records.first?.amount == 20000)
    }

    @Test("Fungsi: updateTransaction() - Skenario Berhasil")
    func testUpdateTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        var record = FinancialRecord(id: "1", branchId: "B-1", amount: 10000, type: .income, category: .none, timestamp: Date(), notes: "")
        mockRepo.records = [record]
        
        record.amount = 50000
        await vm.updateTransaction(record)

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.records.first?.amount == 50000)
    }

    @Test("Fungsi: deleteTransaction() - Skenario Berhasil")
    func testDeleteTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        
        let record = FinancialRecord(id: "1", branchId: "B-1", amount: 10000, type: .income, category: .none, timestamp: Date(), notes: "")
        mockRepo.records = [record]
        
        await vm.deleteTransaction(recordId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.records.isEmpty == true)
    }
}
