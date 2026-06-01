import Foundation
import Testing

@testable import Dagify

@Suite("Inventory ViewModel Tests")
@MainActor
struct InventoryViewModelTests {

    @Test("Skenario 1: Filter Barang Low Stock & Expired")
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

        _ = try? await mockOp.addIngredient(
            Ingredient(
                id: "1",
                name: "Roti",
                currentStock: 2,
                unit: "pcs",
                expiryDate: pastDate,
                minimumStockWarning: 5,
                costPerUnit: 2000
            )
        )
        _ = try? await mockOp.addIngredient(
            Ingredient(
                id: "2",
                name: "Gula",
                currentStock: 50,
                unit: "kg",
                expiryDate: nil,
                minimumStockWarning: 10,
                costPerUnit: 10000
            )
        )

        await vm.loadIngredients(branchId: "B-1")

        #expect(vm.lowStockIngredients.count == 1)
        #expect(vm.expiredIngredients.count == 1)
        #expect(vm.expiredIngredients.first?.name == "Roti")
    }

    @Test("Skenario 2: Buang Barang Basi & Catat Kerugian Otomatis")
    func testDiscardExpiredItemRecordsLoss() async {
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
        let basi = Ingredient(
            id: "1",
            name: "Roti",
            currentStock: 5,
            unit: "pcs",
            expiryDate: pastDate,
            minimumStockWarning: 10,
            costPerUnit: 2000
        )

        await vm.discardExpiredItem(ingredient: basi, branchId: "B-1")

        #expect(vm.errorMessage == nil)

        // Menggunakan .records untuk mengecek array di MockCashflowRepository
        #expect(mockCash.records.first?.amount == 10000)
        #expect(
            mockCash.records.first?.notes == "Kerugian: Bahan Roti kedaluwarsa"
        )
    }
}
