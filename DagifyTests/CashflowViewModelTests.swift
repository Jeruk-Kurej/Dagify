import Foundation
import Testing

@testable import Dagify

@Suite("Cashflow ViewModel Tests")
@MainActor
struct CashflowViewModelTests {

    @Test("Fungsi: previousMonth() dan nextMonth()")
    func testMonthNavigation() {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)
        
        let initialMonth = vm.currentMonthYear
        
        vm.previousMonth()
        let previousMonth = vm.currentMonthYear
        #expect(initialMonth != previousMonth)
        
        vm.nextMonth()
        let nextMonth = vm.currentMonthYear
        #expect(initialMonth == nextMonth)
    }

    @Test("Fungsi: loadRecords() - Skenario Berhasil")
    func testLoadRecordsSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)

        let r1 = FinancialRecord(id: "1", amount: 10000, type: .income, category: .sales, notes: "", date: Date())
        let r2 = FinancialRecord(id: "2", amount: 5000, type: .expense, category: .rawMaterials, notes: "", date: Date())
        mockRepo.dummyRecords = [r1, r2]

        await vm.loadRecords(branchId: "B-1")

        #expect(vm.financialRecords.count == 2)
        #expect(vm.totalIncome == 10000)
        #expect(vm.totalExpense == 5000)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: loadRecords() - Skenario Error")
    func testLoadRecordsFailure() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)
        mockRepo.shouldThrowError = true

        await vm.loadRecords(branchId: "B-1")

        #expect(vm.financialRecords.isEmpty == true)
        #expect(vm.errorMessage != nil)
    }

    @Test("Fungsi: addTransaction() - Skenario Berhasil")
    func testAddTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)

        await vm.addTransaction(branchId: "B-1", amount: 20000, type: .income, category: .sales, notes: "Laris", date: Date())

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.dummyRecords.count == 1)
        #expect(mockRepo.dummyRecords.first?.amount == 20000)
    }

    @Test("Fungsi: updateTransaction() - Skenario Berhasil")
    func testUpdateTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)
        
        var record = FinancialRecord(id: "1", amount: 10000, type: .income, category: .sales, notes: "", date: Date())
        mockRepo.dummyRecords = [record]
        
        record.amount = 50000
        await vm.updateTransaction(record)

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.dummyRecords.first?.amount == 50000)
    }

    @Test("Fungsi: deleteTransaction() - Skenario Berhasil")
    func testDeleteTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashflowProtocol: mockRepo)
        
        let record = FinancialRecord(id: "1", amount: 10000, type: .income, category: .sales, notes: "", date: Date())
        mockRepo.dummyRecords = [record]
        
        await vm.deleteTransaction(recordId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockRepo.dummyRecords.isEmpty == true)
    }
}
