import Foundation
import Testing

@testable import Dagify

@Suite("Product Analytics ViewModel Tests")
@MainActor
struct ProductAnalyticsViewModelTests {

    @Test("Skenario 1: Urutan Best Seller dan Paling Sepi")
    func testBestSellersSorting() async {
        let mockRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockRepo)

        let pLaris = Product(
            id: "1",
            name: "Ayam Goreng",
            price: 20000,
            recipe: []
        )
        let pSepi = Product(
            id: "2",
            name: "Tahu Walik",
            price: 5000,
            recipe: []
        )

        mockRepo.dummyOrders = [
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [OrderItem(product: pLaris, quantity: 15)],
                totalAmount: 300000,
                timestamp: Date()
            ),
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [OrderItem(product: pSepi, quantity: 2)],
                totalAmount: 10000,
                timestamp: Date()
            ),
        ]

        await vm.loadAnalyticsData(branchId: "B-1")

        #expect(vm.bestSellers.first?.productName == "Ayam Goreng")
        #expect(vm.leastPopular.first?.productName == "Tahu Walik")
    }

    @Test("Skenario 2: Perhitungan Profit Margin Berdasarkan HPP")
    func testMostProfitableProductsCalculation() async {
        let mockRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockRepo)

        // Modal Kopi Rp 500
        mockRepo.dummyIngredients = [
            Ingredient(
                id: "I-1",
                name: "Kopi",
                currentStock: 100,
                unit: "gr",
                expiryDate: nil,
                minimumStockWarning: 10,
                costPerUnit: 500
            )
        ]

        // Harga Jual Rp 25.000, butuh 20 unit (Modal total = Rp 10.000)
        let produk = Product(
            id: "P-1",
            name: "Kopi Aren",
            price: 25000,
            recipe: [RecipeItem(ingredientId: "I-1", quantityRequired: 20)]
        )

        mockRepo.dummyOrders = [
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [OrderItem(product: produk, quantity: 1)],
                totalAmount: 25000,
                timestamp: Date()
            )
        ]

        await vm.loadAnalyticsData(branchId: "B-1")

        // Ekspektasi Laba = 25.000 - 10.000 = 15.000
        #expect(vm.mostProfitableProducts.first?.productName == "Kopi Aren")
        #expect(
            vm.mostProfitableProducts.first?.profitMargin == 15000,
            "Kalkulasi HPP salah!"
        )
    }
}
