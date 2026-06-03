import Foundation
import Testing

@testable import Dagify

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {

    @Test("Fungsi: loadDashboardSummary() - Skenario Berhasil")
    func testLoadDashboardSummarySuccess() async {
        let mockCashflowRepo = MockCashflowRepository()
        let mockCrmRepo = MockCRMRepository()
        let mockOpRepo = MockOperationalRepository()
        let mockStoreRepo = MockStoreRepository()
        
        let vm = DashboardViewModel(
            cashflowProtocol: mockCashflowRepo,
            crmProtocol: mockCrmRepo,
            operationalProtocol: mockOpRepo,
            storeProtocol: mockStoreRepo
        )

        // Setup mock data
        let r1 = FinancialRecord(id: "1", amount: 10000, type: .income, category: .sales, notes: "", date: Date())
        let r2 = FinancialRecord(id: "2", amount: 2000, type: .expense, category: .marketing, notes: "", date: Date())
        mockCashflowRepo.dummyRecords = [r1, r2]
        
        let c1 = Customer(id: "1", name: "Budi", phone: "081", isLoyal: true, visitCount: 5)
        mockCrmRepo.dummyCustomers = [c1]
        
        let p1 = Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        mockOpRepo.dummyProducts = [p1]

        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        
        // Income - Expense = 10000 - 2000 = 8000
        #expect(vm.summary.netProfit == 8000)
        #expect(vm.summary.totalCustomers == 1)
        #expect(vm.summary.totalTransactions == 1) // Assuming 1 income record
        #expect(vm.summary.topProducts.count == 1)
    }

    @Test("Fungsi: loadDashboardSummary() - Skenario Error")
    func testLoadDashboardSummaryFailure() async {
        let mockCashflowRepo = MockCashflowRepository()
        let mockCrmRepo = MockCRMRepository()
        let mockOpRepo = MockOperationalRepository()
        let mockStoreRepo = MockStoreRepository()
        
        let vm = DashboardViewModel(
            cashflowProtocol: mockCashflowRepo,
            crmProtocol: mockCrmRepo,
            operationalProtocol: mockOpRepo,
            storeProtocol: mockStoreRepo
        )

        mockCashflowRepo.shouldThrowError = true

        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.summary.netProfit == 0)
    }
}
