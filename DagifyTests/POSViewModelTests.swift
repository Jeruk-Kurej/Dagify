import Foundation
import SwiftData
import Testing

@testable import Dagify

@Suite("POS ViewModel Tests")
@MainActor
struct POSViewModelTests {

    @Test("Fungsi: loadProducts()")
    func testLoadProducts() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockOpRepo,
            cashflowProtocol: MockCashflowRepository(),
            crmProtocol: MockCRMRepository(),
            networkMonitor: MockNetworkMonitor(),
            syncManager: MockSyncManager()
        )
        mockOpRepo.dummyProducts = [
            Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        ]

        await vm.loadProducts(branchId: "B-1")
        #expect(vm.availableProducts.count == 1)
    }

    @Test("Fungsi: loadCustomersForSuggestions() & selectCustomer()")
    func testCustomerSelection() async {
        let mockCrmRepo = MockCRMRepository()
        let vm = POSViewModel(
            operationalProtocol: MockOperationalRepository(),
            cashflowProtocol: MockCashflowRepository(),
            crmProtocol: mockCrmRepo,
            networkMonitor: MockNetworkMonitor(),
            syncManager: MockSyncManager()
        )
        
        let c1 = Customer(id: "1", name: "Budi", phone: "081", isLoyal: true, visitCount: 5)
        mockCrmRepo.dummyCustomers = [c1]
        
        await vm.loadCustomersForSuggestions(storeId: "S-1")
        #expect(vm.suggestedCustomers.count == 1)
        
        vm.selectCustomer(c1)
        #expect(vm.selectedCustomer?.name == "Budi")
        #expect(vm.customerSearchText == "Budi")
    }

    @Test("Fungsi: addToCart() & removeOrDecreaseFromCart() & getCartQuantity()")
    func testCartOperations() {
        let vm = POSViewModel(
            operationalProtocol: MockOperationalRepository(),
            cashflowProtocol: MockCashflowRepository(),
            crmProtocol: MockCRMRepository(),
            networkMonitor: MockNetworkMonitor(),
            syncManager: MockSyncManager()
        )
        let p1 = Product(id: "1", name: "Kopi", price: 10000, recipe: [])

        vm.addToCart(product: p1)
        vm.addToCart(product: p1)  // qty = 2
        #expect(vm.cart.first?.quantity == 2)
        #expect(vm.subtotal == 20000)
        #expect(vm.getCartQuantity(for: p1) == 2)

        vm.removeOrDecreaseFromCart(product: p1)  // qty = 1
        #expect(vm.cart.first?.quantity == 1)
        #expect(vm.getCartQuantity(for: p1) == 1)

        vm.removeOrDecreaseFromCart(product: p1)  // qty = 0 (dihapus)
        #expect(vm.cart.isEmpty == true)
        #expect(vm.getCartQuantity(for: p1) == 0)
    }

    @Test("Fungsi: checkout() - Skenario Berhasil")
    func testCheckoutSuccess() async throws {
        let mockCashRepo = MockCashflowRepository()
        let vm = POSViewModel(
            operationalProtocol: MockOperationalRepository(),
            cashflowProtocol: mockCashRepo,
            crmProtocol: MockCRMRepository(),
            networkMonitor: MockNetworkMonitor(),
            syncManager: MockSyncManager()
        )
        vm.addToCart(
            product: Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        )

        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        await vm.checkout(storeId: "S-1", branchId: "B-1", context: ModelContext(container))

        #expect(vm.isCheckoutSuccess == true)
        #expect(vm.cart.isEmpty == true)
        #expect(mockCashRepo.dummyRecords.count == 1) // Checkout should add income record
    }

    @Test("Fungsi: checkout() - Skenario Gagal (Keranjang Kosong)")
    func testCheckoutFailEmptyCart() async throws {
        let vm = POSViewModel(
            operationalProtocol: MockOperationalRepository(),
            cashflowProtocol: MockCashflowRepository(),
            crmProtocol: MockCRMRepository(),
            networkMonitor: MockNetworkMonitor(),
            syncManager: MockSyncManager()
        )

        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        await vm.checkout(storeId: "S-1", branchId: "B-1", context: ModelContext(container))

        #expect(vm.isCheckoutSuccess == false)
        #expect(vm.errorMessage == "Keranjang masih kosong.")
    }
}
