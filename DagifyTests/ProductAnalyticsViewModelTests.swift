import Foundation
import Testing

@testable import Dagify

@Suite("Product Analytics ViewModel Tests")
@MainActor
struct ProductAnalyticsViewModelTests {

    @Test("Fungsi: loadAnalyticsData()")
    func testLoadAnalyticsData() async {
        let mockRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockRepo)
        mockRepo.dummyOrders = [
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [],
                totalAmount: 10000,
                timestamp: Date()
            )
        ]

        await vm.loadAnalyticsData(branchId: "B-1")
        #expect(vm.orders.count == 1)
    }

    @Test("Properti: productSalesCount, bestSellers, leastPopular")
    func testSalesSorting() async {
        let mockRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockRepo)

        let pLaris = Product(id: "1", name: "Ayam", price: 20000, recipe: [])
        let pSepi = Product(id: "2", name: "Tahu", price: 5000, recipe: [])

        mockRepo.dummyOrders = [
            Order(
                branchId: "B-1",
                customerId: nil,
                items: [
                    OrderItem(product: pLaris, quantity: 15),
                    OrderItem(product: pSepi, quantity: 2),
                ],
                totalAmount: 0,
                timestamp: Date()
            )
        ]

        await vm.loadAnalyticsData(branchId: "B-1")

        #expect(vm.productSalesCount["Ayam"] == 15)
        #expect(vm.bestSellers.first?.productName == "Ayam")
        #expect(vm.leastPopular.first?.productName == "Tahu")
    }

    @Test("Properti: mostProfitableProducts (Kalkulasi HPP)")
    func testMostProfitableProducts() async {
        let mockRepo = MockOperationalRepository()
        let vm = ProductAnalyticsViewModel(operationalProtocol: mockRepo)

        // Ingredient cost: 500
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

        // Product price: 25.000, butuh 20 unit (HPP = 10.000)
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

        // Profit margin: 25.000 - 10.000 = 15.000
        #expect(vm.mostProfitableProducts.first?.productName == "Kopi Aren")
        #expect(vm.mostProfitableProducts.first?.profitMargin == 15000)
    }
}
