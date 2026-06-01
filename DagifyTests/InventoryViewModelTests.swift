import Foundation
import Testing

@testable import Dagify

@Suite("Inventory ViewModel Tests")
@MainActor
struct InventoryViewModelTests {

    @Test("Fungsi: loadIngredients() - Skenario Berhasil")
    func testLoadIngredients() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(
            operationalProtocol: mockOp,
            cashflowProtocol: mockCash
        )

        mockOp.dummyIngredients = [
            Ingredient(
                id: "1",
                name: "Roti",
                currentStock: 2,
                unit: "pcs",
                expiryDate: nil,
                minimumStockWarning: 5,
                costPerUnit: 2000
            )
        ]

        await vm.loadIngredients(branchId: "B-1")
        #expect(vm.ingredients.count == 1)
    }

    @Test("Properti: lowStockIngredients & expiredIngredients")
    func testLowStockAndExpiredFilters() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(
            operationalProtocol: mockOp,
            cashflowProtocol: mockCash
        )

        let pastDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Date()
        )

        mockOp.dummyIngredients = [
            Ingredient(
                id: "1",
                name: "Roti",
                currentStock: 2,
                unit: "pcs",
                expiryDate: pastDate,
                minimumStockWarning: 5,
                costPerUnit: 2000
            ),  // Basi & Menipis
            Ingredient(
                id: "2",
                name: "Gula",
                currentStock: 50,
                unit: "kg",
                expiryDate: nil,
                minimumStockWarning: 10,
                costPerUnit: 10000
            ),  // Normal
        ]

        await vm.loadIngredients(branchId: "B-1")
        #expect(vm.lowStockIngredients.count == 1)
        #expect(vm.expiredIngredients.count == 1)
    }

    @Test("Fungsi: discardExpiredItem() - Skenario Mencatat Kerugian")
    func testDiscardExpiredItemRecordsLoss() async {
        let mockOp = MockOperationalRepository()
        let mockCash = MockCashflowRepository()
        let vm = InventoryViewModel(
            operationalProtocol: mockOp,
            cashflowProtocol: mockCash
        )

        let basi = Ingredient(
            id: "1",
            name: "Roti",
            currentStock: 5,
            unit: "pcs",
            expiryDate: Date(),
            minimumStockWarning: 10,
            costPerUnit: 2000
        )  // Loss 10.000

        await vm.discardExpiredItem(ingredient: basi, branchId: "B-1")

        #expect(
            mockCash.records.count == 1,
            "Data kerugian harus masuk ke Cashflow"
        )
        #expect(mockCash.records.first?.amount == 10000)
    }
}
