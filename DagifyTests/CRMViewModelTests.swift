import Testing
import Foundation
@testable import Dagify

@Suite("CRM ViewModel Tests")
@MainActor
struct CRMViewModelTests {
    
    @Test("Skenario 1: Kalkulasi Persentase Pelanggan Loyal")
    func testLoyalCustomerPercentage() async {
        let mockRepo = MockCRMRepository()
        let vm = CRMViewModel(crmProtocol: mockRepo)
        
        let date = Date()
        // Menggunakan nama model asli "Customer", nilai 100k diganti 100000, visitHistory menggunakan array Date
        let loyalCustomer = Customer(id: "1", name: "Budi", phoneNumber: "081", totalSpent: 100000, visitHistory: [date, date, date, date, date])
        let newCustomer = Customer(id: "2", name: "Susi", phoneNumber: "082", totalSpent: 20000, visitHistory: [date])
        
        _ = try? await mockRepo.addCustomer(loyalCustomer)
        _ = try? await mockRepo.addCustomer(newCustomer)
        
        // Asumsi fungsi memuat pelanggan berdasarkan storeId
        await vm.loadCustomers(storeId: "S-1")
        
        #expect(vm.loyalCustomerPercentage == 50.0, "Persentase 1 dari 2 orang harusnya 50%")
    }
}
