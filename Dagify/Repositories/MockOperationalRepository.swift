import Foundation

class MockOperationalRepository: OperationalProtocol, StoreProtocol {
    public var shouldThrowError = false
    public var dummyProducts: [Product] = []
    public var dummyIngredients: [Ingredient] = []
    public var dummyOrders: [Order] = []
    public var submitCallCount = 0

    // ✅ Menggunakan properti variabel untuk simulasi store
    public var dummyStore = Store(
        id: "S-1",
        name: "Dagify Test Store",
        branches: [Branch(id: "B-1", name: "Pusat", address: "Surabaya")]
    )

    public init() {}

    public func fetchStore(storeId: String) async throws -> Store {
        if shouldThrowError { throw NSError(domain: "MockError", code: 404) }
        return dummyStore
    }

    // ✅ FUNGSI BARU: Tambah cabang untuk simulasi Preview
    public func addBranch(storeId: String, branch: Branch) async throws -> Bool
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        var updatedBranches = dummyStore.branches
        updatedBranches.append(branch)
        dummyStore = Store(
            id: dummyStore.id,
            name: dummyStore.name,
            branches: updatedBranches
        )
        return true
    }

    public func fetchOrders(for branchId: String) async throws -> [Order] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyOrders.filter { $0.branchId == branchId }
    }

    public func fetchProducts(for branchId: String) async throws -> [Product] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyProducts
    }

    public func fetchIngredients(for branchId: String) async throws
        -> [Ingredient]
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyIngredients
    }

    public func submitOrderAndUpdateInventory(order: Order) async throws -> Bool
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        submitCallCount += 1
        return true
    }

    public func addProduct(_ product: Product) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        var newProduct = product
        if newProduct.id == nil { newProduct.id = UUID().uuidString }
        dummyProducts.append(newProduct)
        return true
    }

    // ✅ FUNGSI BARU UNTUK PREVIEW
    public func updateProduct(_ product: Product) async throws -> Bool {
        if let index = dummyProducts.firstIndex(where: { $0.id == product.id })
        {
            dummyProducts[index] = product
            return true
        }
        return false
    }

    public func deleteProduct(productId: String) async throws -> Bool {
        dummyProducts.removeAll(where: { $0.id == productId })
        return true
    }

    public func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        var newIngredient = ingredient
        if newIngredient.id == nil { newIngredient.id = UUID().uuidString }
        dummyIngredients.append(newIngredient)
        return true
    }

    public func recordWaste(ingredientId: String, amountToDeduct: Double)
        async throws -> Bool
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let index = dummyIngredients.firstIndex(where: {
            $0.id == ingredientId
        }) {
            dummyIngredients[index].currentStock -= amountToDeduct
            return true
        }
        return false
    }
}
