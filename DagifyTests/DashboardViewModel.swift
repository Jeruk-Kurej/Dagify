import Foundation
import Testing

@testable import Dagify

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {

    @Test("Skenario 1: Load Data Dasbor")
    func testLoadDashboardSummary() async {
        // Mock semua repository karena Dasbor adalah gabungan semua fitur
        let mockCash = MockCashflowRepository()
        let mockCRM = MockCRMRepository()
        let mockOp = MockOperationalRepository()

        let vm = DashboardViewModel(
            cashflowProtocol: mockCash,
            crmProtocol: mockCRM,
            operationalProtocol: mockOp
        )

        await vm.loadDashboardSummary(storeId: "S-1", branchId: "B-1")

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }
}
