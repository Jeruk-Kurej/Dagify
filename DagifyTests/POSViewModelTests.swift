import Foundation
import SwiftData
import Testing

@testable import Dagify

@Suite("POS ViewModel Tests")
@MainActor
struct POSViewModelTests {

    @Test("Skenario 1: Kalkulasi Tambah & Kurang Keranjang")
    func testCartCalculations() {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )

        let p1 = Product(id: "1", name: "Es Teh", price: 5000, recipe: [])

        vm.addToCart(product: p1)
        vm.addToCart(product: p1)

        #expect(vm.cart.first?.quantity == 2)
        #expect(vm.subtotal == 10000)

        vm.removeOrDecreaseFromCart(product: p1)
        #expect(vm.subtotal == 5000)
    }

    @Test("Skenario 2: Checkout Sukses Membersihkan Keranjang")
    func testCheckoutSuccess() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )

        let p1 = Product(id: "1", name: "Es Teh", price: 5000, recipe: [])
        vm.addToCart(product: p1)

        // Menggunakan nama model asli "OfflineOrderModel"
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        await vm.checkout(branchId: "B-1", context: context)

        #expect(vm.isCheckoutSuccess == true, "Flag success harus menyala")
        #expect(
            vm.cart.isEmpty == true,
            "Keranjang harus dikosongkan setelah bayar"
        )
        #expect(vm.errorMessage == nil)
    }

    @Test("Skenario 3: Checkout Gagal Karena Keranjang Kosong (Unhappy Path)")
    func testCheckoutFailEmptyCart() async throws {
        let mockRepo = MockOperationalRepository()
        let vm = POSViewModel(
            operationalProtocol: mockRepo,
            networkMonitor: NetworkMonitor(),
            syncManager: MockSyncManager()
        )

        // Menggunakan nama model asli "OfflineOrderModel"
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: OfflineOrderModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        await vm.checkout(branchId: "B-1", context: context)

        #expect(vm.isCheckoutSuccess == false)
        #expect(vm.errorMessage == "Keranjang masih kosong.")
    }
}
