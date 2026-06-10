//
//  MasterDataViewModelTests.swift
//  DagifyTests
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

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

        mockOpRepo.products = [Product(id: "1", branchId: "B-1", name: "Kopi", price: 10000, recipe: [])]
        mockOpRepo.ingredients = [Ingredient(id: "1", branchId: "B-1", name: "Susu", unit: "L", minimumStockWarning: 5, batches: [IngredientBatch(currentStock: 10, costPerUnit: 15000)])]
        mockOpRepo.categories = [ProductCategory(id: "1", branchId: "B-1", name: "Minuman")]

        await vm.loadProducts(branchId: "B-1")
        await vm.loadIngredients(branchId: "B-1")
        await vm.loadCategories(branchId: "B-1")

        #expect(vm.products.count == 1)
        #expect(vm.availableIngredients.count == 1)
        #expect(vm.categories.count == 1)
    }

    @Test("Fungsi: createCategory()")
    func testCreateCategory() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        await vm.createCategory(branchId: "B-1", name: "Makanan")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.categories.count == 1)
        #expect(mockOpRepo.categories.first?.name == "Makanan")
    }

    @Test("Fungsi: deleteCategory()")
    func testDeleteCategory() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.categories = [ProductCategory(id: "1", branchId: "B-1", name: "Minuman")]

        await vm.deleteCategory(categoryId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.categories.count == 3)
    }

    @Test("Fungsi: createProduct()")
    func testCreateProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        await vm.createProduct(branchId: "B-1", categoryId: "C-1", name: "Teh", price: 5000, recipe: [], newImageData: nil)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.products.count == 1)
        #expect(mockOpRepo.products.first?.name == "Teh")
    }

    @Test("Fungsi: updateProduct()")
    func testUpdateProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        var p = Product(id: "1", name: "Teh", price: 5000, recipe: [])
        mockOpRepo.products = [p]

        p.price = 7000
        await vm.updateProduct(product: p, newImageData: nil)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.products.first?.price == 7000)
    }

    @Test("Fungsi: deleteProduct()")
    func testDeleteProduct() async {
        let mockOpRepo = MockOperationalRepository()
        let vm = MasterDataViewModel(operationalProtocol: mockOpRepo)

        mockOpRepo.products = [Product(id: "1", name: "Teh", price: 5000, recipe: [])]

        await vm.deleteProduct(productId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.products.isEmpty == true)
    }
}
