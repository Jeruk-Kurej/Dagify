import Foundation
import SwiftData
import Testing

@testable import Dagify

@Suite("POS ViewModel Tests")
@MainActor
struct POSViewModelTests {

    @Test("Fungsi: loadProducts()")
    func testLoadProducts() async {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )
        mockRepo.dummyProducts = [
            Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        ]

        await vm.loadProducts(branchId: "B-1")
        #expect(vm.availableProducts.count == 1)
    }

    @Test("Fungsi: addToCart() & removeOrDecreaseFromCart()")
    func testCartOperations() {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )
        let p1 = Product(id: "1", name: "Kopi", price: 10000, recipe: [])

        vm.addToCart(product: p1)
        vm.addToCart(product: p1)  // qty = 2
        #expect(vm.cart.first?.quantity == 2)
        #expect(vm.subtotal == 20000)

        vm.removeOrDecreaseFromCart(product: p1)  // qty = 1
        #expect(vm.cart.first?.quantity == 1)

        vm.removeOrDecreaseFromCart(product: p1)  // qty = 0 (dihapus)
        #expect(vm.cart.isEmpty == true)
    }

    @Test("Fungsi: checkout() - Skenario Berhasil")
    func testCheckoutSuccess() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )
        vm.addToCart(
            product: Product(id: "1", name: "Kopi", price: 10000, recipe: [])
        )

        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        await vm.checkout(branchId: "B-1", context: ModelContext(container))

        #expect(vm.isCheckoutSuccess == true)
        #expect(vm.cart.isEmpty == true)
    }

    @Test("Fungsi: checkout() - Skenario Gagal (Keranjang Kosong)")
    func testCheckoutFailEmptyCart() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )

        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        await vm.checkout(branchId: "B-1", context: ModelContext(container))

        #expect(vm.isCheckoutSuccess == false)
        #expect(vm.errorMessage == "Keranjang masih kosong.")
    }
}
