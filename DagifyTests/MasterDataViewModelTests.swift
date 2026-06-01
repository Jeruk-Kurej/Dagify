import Foundation
import Testing

@testable import Dagify

@Suite("Master Data ViewModel Tests")
@MainActor
struct MasterDataViewModelTests {

    @Test("Fungsi: createIngredient() - Skenario Berhasil")
    func testCreateIngredientSuccess() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createIngredient(
            name: "Gula",
            currentStock: 10,
            unit: "kg",
            expiryDate: nil,
            minimumStockWarning: 2,
            costPerUnit: 15000
        )
        #expect(vm.isSuccess == true)
        #expect(vm.errorMessage == nil)
    }

    @Test("Fungsi: createIngredient() - Skenario Gagal (Nama Kosong)")
    func testCreateIngredientFail() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createIngredient(
            name: "",
            currentStock: 10,
            unit: "kg",
            expiryDate: nil,
            minimumStockWarning: 2,
            costPerUnit: 15000
        )
        #expect(vm.isSuccess == false)
        #expect(vm.errorMessage != nil)
    }

    @Test("Fungsi: createProduct() - Skenario Berhasil")
    func testCreateProductSuccess() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createProduct(name: "Kopi", price: 20000, recipe: [])
        #expect(vm.isSuccess == true)
    }

    @Test("Fungsi: createProduct() - Skenario Gagal (Harga Minus)")
    func testCreateProductFail() async {
        let mockRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockRepo)

        await vm.createProduct(name: "Kopi", price: -100, recipe: [])
        #expect(vm.isSuccess == false)
        #expect(vm.errorMessage == "Nama menu dan harga harus valid.")
    }
}
