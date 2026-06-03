import Foundation
import Testing
@testable import Dagify

@Suite("CRM ViewModel Tests")
@MainActor
struct CRMViewModelTests {

    @Test("Fungsi: loadCustomers() - Skenario Berhasil")
    func testLoadCustomers() async {
        let mockRepo = MockCRMRepository()
        let mockOp = MockOperationalRepository() // ✅ Tambahan mockStore
        let vm = CRMViewModel(crmProtocol: mockRepo, storeProtocol: mockOp)
        
        mockRepo.customers = [
            Customer(
                id: "1",
                storeId: "S-1",
                name: "Budi",
                phoneNumber: "081",
                totalSpent: 100000,
                visitHistory: []
            )
        ]
        await vm.loadCustomers(storeId: "S-1")
        #expect(vm.customers.count == 1)
        #expect(vm.errorMessage == nil)
    }

    @Test("Properti: loyalCustomerPercentage")
    func testLoyalCustomerPercentage() async {
        let mockRepo = MockCRMRepository()
        let mockOp = MockOperationalRepository()
        let vm = CRMViewModel(crmProtocol: mockRepo, storeProtocol: mockOp)
        
        let date = Date()
        let loyalCustomer = Customer(
            id: "1",
            name: "Budi",
            phoneNumber: "081",
            totalSpent: 100000,
            visitHistory: [date, date, date, date, date]
        )
        let newCustomer = Customer(
            id: "2",
            name: "Susi",
            phoneNumber: "082",
            totalSpent: 20000,
            visitHistory: [date]
        )
        mockRepo.customers = [loyalCustomer, newCustomer]
        await vm.loadCustomers(storeId: "S-1")
        #expect(vm.loyalCustomers.count == 1) // Diganti dari percentage untuk validasi loyalitas yang lebih presisi
    }

    @Test("Properti: busiestHours (Heatmap Jam Sibuk)")
    func testBusiestHours() async {
        let mockRepo = MockCRMRepository()
        let mockOp = MockOperationalRepository()
        let vm = CRMViewModel(crmProtocol: mockRepo, storeProtocol: mockOp)
        
        var components = DateComponents()
        components.hour = 14  // Jam 2 Siang
        let date2PM = Calendar.current.date(from: components)!
        let cust = Customer(
            id: "1",
            name: "Budi",
            phoneNumber: "081",
            totalSpent: 100000,
            visitHistory: [date2PM, date2PM, date2PM]
        )
        mockRepo.customers = [cust]
        await vm.loadCustomers(storeId: "S-1")
        #expect(vm.peakHoursData.first(where: { $0.label == "14:00" })?.count == 3, "Tercatat 3 kunjungan pada jam 14:00")
    }
}
