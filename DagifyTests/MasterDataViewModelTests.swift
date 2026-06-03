import Foundation
import Testing

@testable import Dagify

@Suite("MasterData ViewModel Tests")
@MainActor
struct MasterDataViewModelTests {

    @Test("Fungsi: loadProducts(), loadIngredients(), loadCategories()")
    func testLoadData() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.dummyProducts = [Product(id: "1", name: "Kopi", price: 10000, recipe: [])]
        mockOpRepo.dummyIngredients = [Ingredient(id: "1", name: "Susu", currentStock: 10, unit: "L", minimumStockWarning: 5, costPerUnit: 15000)]
        mockOpRepo.dummyCategories = [ProductCategory(id: "1", name: "Minuman")]

        await vm.loadProducts(branchId: "B-1")
        await vm.loadIngredients(branchId: "B-1")
        await vm.loadCategories(branchId: "B-1")

        #expect(vm.products.count == 1)
        #expect(vm.ingredients.count == 1)
        #expect(vm.categories.count == 1)
    }

    @Test("Fungsi: createCategory()")
    func testCreateCategory() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        await vm.createCategory(branchId: "B-1", name: "Makanan")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyCategories.count == 1)
        #expect(mockOpRepo.dummyCategories.first?.name == "Makanan")
    }

    @Test("Fungsi: deleteCategory()")
    func testDeleteCategory() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.dummyCategories = [ProductCategory(id: "1", name: "Minuman")]

        await vm.deleteCategory(categoryId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyCategories.isEmpty == true)
    }

    @Test("Fungsi: createProduct()")
    func testCreateProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        await vm.createProduct(branchId: "B-1", categoryId: "C-1", name: "Teh", price: 5000, recipe: [], newImageData: nil)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyProducts.count == 1)
        #expect(mockOpRepo.dummyProducts.first?.name == "Teh")
    }

    @Test("Fungsi: updateProduct()")
    func testUpdateProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        var p = Product(id: "1", name: "Teh", price: 5000, recipe: [])
        mockOpRepo.dummyProducts = [p]

        p.price = 7000
        await vm.updateProduct(product: p, newImageData: nil)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyProducts.first?.price == 7000)
    }

    @Test("Fungsi: deleteProduct()")
    func testDeleteProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.dummyProducts = [Product(id: "1", name: "Teh", price: 5000, recipe: [])]

        await vm.deleteProduct(productId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyProducts.isEmpty == true)
    }
}
