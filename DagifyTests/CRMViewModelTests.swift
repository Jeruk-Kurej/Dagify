import Foundation
import Testing

@testable import Dagify

@Suite("CRM ViewModel Tests")
@MainActor
struct CRMViewModelTests {

    @Test("Fungsi: loadCustomers() - Skenario Berhasil")
    func testLoadCustomersSuccess() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(crmProtocol: mockCrmRepo, storeProtocol: mockStoreRepo)

        // Setup mock data
        let c1 = Customer(id: "1", name: "Budi", phone: "081", isLoyal: true, visitCount: 5)
        let c2 = Customer(id: "2", name: "Siti", phone: "082", isLoyal: false, visitCount: 2)
        mockCrmRepo.dummyCustomers = [c1, c2]

        await vm.loadCustomers(storeId: "S-1")

        #expect(vm.customers.count == 2)
        #expect(vm.customers.first?.name == "Budi")
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: loadCustomers() - Skenario Error")
    func testLoadCustomersFailure() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(crmProtocol: mockCrmRepo, storeProtocol: mockStoreRepo)

        mockCrmRepo.shouldThrowError = true

        await vm.loadCustomers(storeId: "S-1")

        #expect(vm.customers.isEmpty == true)
        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: getCustomerCount() - Skenario Filter")
    func testGetCustomerCount() async {
        let mockCrmRepo = MockCRMRepository()
        let mockStoreRepo = MockStoreRepository()
        let vm = CRMViewModel(crmProtocol: mockCrmRepo, storeProtocol: mockStoreRepo)

        let c1 = Customer(id: "1", name: "Budi", phone: "081", isLoyal: true, visitCount: 5)
        let c2 = Customer(id: "2", name: "Siti", phone: "082", isLoyal: false, visitCount: 2)
        let c3 = Customer(id: "3", name: "Agus", phone: "083", isLoyal: true, visitCount: 10)
        mockCrmRepo.dummyCustomers = [c1, c2, c3]

        await vm.loadCustomers(storeId: "S-1")

        let totalLoyal = vm.getCustomerCount(for: "S-1", isLoyalOnly: true)
        let totalSemua = vm.getCustomerCount(for: "S-1", isLoyalOnly: false)

        #expect(totalLoyal == 2)
        #expect(totalSemua == 3)
    }
}
