import Foundation
import Testing

@testable import Dagify

@Suite("Inventory ViewModel Tests")
@MainActor
struct InventoryViewModelTests {

    @Test("Fungsi: loadIngredients() - Skenario Berhasil")
    func testLoadIngredientsSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", name: "Susu", currentStock: 10, unit: "L", minimumStockWarning: 5, costPerUnit: 15000)
        let i2 = Ingredient(id: "2", name: "Gula", currentStock: 2, unit: "Kg", minimumStockWarning: 5, costPerUnit: 12000)
        mockOpRepo.dummyIngredients = [i1, i2]

        await vm.loadIngredients(branchId: "B-1")

        #expect(vm.ingredients.count == 2)
        #expect(vm.lowStockCount == 1) // Gula is low stock
        #expect(vm.isLoading == false)
    }

    @Test("Fungsi: createIngredient() - Skenario Berhasil")
    func testCreateIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        await vm.createIngredient(branchId: "B-1", name: "Kopi", currentStock: 5, unit: "Kg", expiryDate: nil, minimumStockWarning: 2, costPerUnit: 50000)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyIngredients.count == 1)
        #expect(mockOpRepo.dummyIngredients.first?.name == "Kopi")
        #expect(mockCashRepo.dummyRecords.count == 1) // Should record expense
    }

    @Test("Fungsi: discardExpiredItem() - Skenario Berhasil")
    func testDiscardExpiredItemSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", name: "Susu", currentStock: 10, unit: "L", minimumStockWarning: 5, costPerUnit: 15000)
        mockOpRepo.dummyIngredients = [i1]

        await vm.discardExpiredItem(ingredient: i1, branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyIngredients.first?.currentStock == 0)
        #expect(mockCashRepo.dummyRecords.count == 1) // Expense for discarded item
    }

    @Test("Fungsi: updateIngredient() - Skenario Berhasil")
    func testUpdateIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        var i1 = Ingredient(id: "1", name: "Susu", currentStock: 10, unit: "L", minimumStockWarning: 5, costPerUnit: 15000)
        mockOpRepo.dummyIngredients = [i1]

        i1.currentStock = 20
        await vm.updateIngredient(ingredient: i1)

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyIngredients.first?.currentStock == 20)
    }

    @Test("Fungsi: deleteIngredient() - Skenario Berhasil")
    func testDeleteIngredientSuccess() async {
        let mockOpRepo = MockOperationalRepository()
        let mockCashRepo = MockCashflowRepository()
        let vm = InventoryViewModel(operationalProtocol: mockOpRepo, cashflowProtocol: mockCashRepo)

        let i1 = Ingredient(id: "1", name: "Susu", currentStock: 10, unit: "L", minimumStockWarning: 5, costPerUnit: 15000)
        mockOpRepo.dummyIngredients = [i1]

        await vm.deleteIngredient(ingredientId: "1", branchId: "B-1")

        #expect(vm.errorMessage == nil)
        #expect(mockOpRepo.dummyIngredients.isEmpty == true)
    }
}
