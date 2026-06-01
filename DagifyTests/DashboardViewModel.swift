import Foundation
import Testing

@testable import Dagify

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {

    @Test("Fungsi: loadDashboardSummary() & Semua Kalkulasi Hari Ini")
    func testLoadDashboardSummary() async {
        let mockCash = MockCashflowRepository()
        let mockCRM = MockCRMRepository()
        let mockOp = MockOperationalRepository()
        let vm = DashboardViewModel(
            cashflowProtocol: mockCash,
            crmProtocol: mockCRM,
            operationalProtocol: mockOp
        )

        // 1. Setup Cashflow Hari Ini
        mockCash.records = [
            FinancialRecord(
                branchId: "B-1",
                amount: 100000,
                type: .income,
                category: .none,
                timestamp: Date(),
                notes: ""
            ),
            FinancialRecord(
                branchId: "B-1",
                amount: 20000,
                type: .expense,
                category: .none,
                timestamp: Date(),
                notes: ""
            ),
        ]

        // 2. Setup CRM (1 Loyal)
        mockCRM.customers = [
            Customer(
                id: "1",
                name: "A",
                phoneNumber: "1",
                totalSpent: 0,
                visitHistory: [Date(), Date(), Date(), Date(), Date()]
            )
        ]

        // 3. Setup Inventory (1 Low Stock)
        mockOp.dummyIngredients = [
            Ingredient(
                id: "1",
                name: "Susu",
                currentStock: 1,
                unit: "L",
                expiryDate: nil,
                minimumStockWarning: 5,
                costPerUnit: 10
            )
        ]

        // Eksekusi
        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        // Validasi SEMUA variabel dasbor
        #expect(vm.todayRevenue == 100000)
        #expect(vm.todayExpense == 20000)
        #expect(vm.todayNetProfit == 80000)
        #expect(vm.totalLoyalCustomers == 1)
        #expect(vm.lowStockAlertsCount == 1)
        #expect(vm.isLoading == false)
    }
}
