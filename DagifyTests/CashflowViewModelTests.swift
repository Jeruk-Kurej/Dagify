import Foundation
import Testing

@testable import Dagify

@Suite("Cashflow ViewModel Tests")
@MainActor
struct CashflowViewModelTests {

    @Test("Fungsi: loadRecords() - Skenario Berhasil")
    func testLoadRecordsSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        mockRepo.records = [
            FinancialRecord(
                branchId: "B-1",
                amount: 10000,
                type: .income,
                category: .none,
                timestamp: Date(),
                notes: "Test"
            )
        ]

        await vm.loadRecords(branchId: "B-1")
        #expect(vm.records.count == 1)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: addTransaction() - Skenario Berhasil")
    func testAddTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)

        await vm.addTransaction(
            branchId: "B-1",
            amount: 50000,
            type: .income,
            category: .none,
            notes: "Jual"
        )
        #expect(vm.records.count == 1)
        #expect(vm.records.first?.amount == 50000)
    }

    @Test("Fungsi: deleteTransaction() - Skenario Berhasil")
    func testDeleteTransactionSuccess() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        let record = FinancialRecord(
            id: "REC-1",
            branchId: "B-1",
            amount: 10000,
            type: .income,
            category: .none,
            timestamp: Date(),
            notes: ""
        )
        mockRepo.records = [record]

        await vm.deleteTransaction(recordId: "REC-1", branchId: "B-1")
        #expect(vm.records.isEmpty == true)
    }

    @Test("Properti: Perhitungan Income, Expense, NetProfit")
    func testFinancialCalculations() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)
        mockRepo.records = [
            FinancialRecord(
                branchId: "B-1",
                amount: 100000,
                type: .income,
                category: .none,
                timestamp: Date(),
                notes: "Laris"
            ),
            FinancialRecord(
                branchId: "B-1",
                amount: 20000,
                type: .expense,
                category: .operational,
                timestamp: Date(),
                notes: "Listrik"
            ),
        ]

        await vm.loadRecords(branchId: "B-1")
        #expect(vm.totalIncome == 100000)
        #expect(vm.totalExpense == 20000)
        #expect(vm.netProfit == 80000)
    }

    @Test("Properti: groupedRecordsByMonth")
    func testGroupedRecordsByMonth() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date1 = formatter.date(from: "2026-05-10")!
        let date2 = formatter.date(from: "2026-06-15")!

        mockRepo.records = [
            FinancialRecord(
                branchId: "B-1",
                amount: 100,
                type: .income,
                category: .none,
                timestamp: date1,
                notes: "Mei"
            ),
            FinancialRecord(
                branchId: "B-1",
                amount: 200,
                type: .income,
                category: .none,
                timestamp: date2,
                notes: "Juni"
            ),
        ]

        await vm.loadRecords(branchId: "B-1")
        #expect(
            vm.groupedRecordsByMonth.keys.count == 2,
            "Harus terbagi menjadi 2 bulan berbeda"
        )
    }
}
