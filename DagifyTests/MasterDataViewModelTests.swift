import Foundation
import Testing

@testable import Dagify

@Suite("Master Data ViewModel Tests")
@MainActor
struct MasterDataViewModelTests {

    @Test("Skenario 1: Tambah Menu Produk Baru Sukses")
    func testCreateProductSuccess() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createProduct(name: "Kopi Susu", price: 20000, recipe: [])

        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Skenario 2: Tambah Produk Gagal - Harga Minus (Unhappy Path)")
    func testCreateProductFailNegativePrice() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        // Menguji input harga minus
        await vm.createProduct(name: "Kopi Susu", price: -5000, recipe: [])

        #expect(vm.isSuccess == false)
        #expect(
            vm.errorMessage == "Nama menu dan harga harus valid.",
            "Validasi harga minus gagal!"
        )
    }

    @Test("Skenario 3: Tambah Bahan Baku Gagal - Nama Kosong (Unhappy Path)")
    func testCreateIngredientFailEmptyName() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createIngredient(
            name: "",
            currentStock: 100,
            unit: "kg",
            expiryDate: nil,
            minimumStockWarning: 10,
            costPerUnit: 5000
        )

        #expect(vm.isSuccess == false)
        #expect(
            vm.errorMessage
                == "Nama bahan baku tidak boleh kosong dan stok harus valid."
        )
    }
}
