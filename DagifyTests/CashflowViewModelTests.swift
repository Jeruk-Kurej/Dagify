import Foundation
import Testing

@testable import Dagify

@Suite("Cashflow ViewModel Tests")
@MainActor
struct CashflowViewModelTests {

    @Test("Skenario 1: Kalkulasi Total Income, Expense, dan Net Profit")
    func testFinancialCalculations() async {
        let mockRepo = MockCashflowRepository()
        let vm = CashflowViewModel(cashProtocol: mockRepo)

        // Menggunakan "records" (bukan dummyRecords), dan kategori .none & .operational
        mockRepo.records = [
            FinancialRecord(
                branchId: "B-1",
                amount: 500000,
                type: .income,
                category: .none,
                timestamp: Date(),
                notes: "Laris"
            ),
            FinancialRecord(
                branchId: "B-1",
                amount: 150000,
                type: .expense,
                category: .operational,
                timestamp: Date(),
                notes: "Listrik"
            ),
        ]

        await vm.loadRecords(branchId: "B-1")

        #expect(vm.totalIncome == 500000)
        #expect(vm.totalExpense == 150000)
        #expect(
            vm.netProfit == 350000,
            "Laba bersih (Income - Expense) tidak akurat!"
        )
    }
}
