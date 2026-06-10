//
//  MockOperationalRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

class MockOperationalRepository: OperationalProtocol, StoreProtocol {

    // MARK: - Mock State
    var shouldThrowError = false

    var dummyStore: Store = Store(
        id: "S-1",
        name: "Mock Store",
        branches: [Branch(id: "B-1", name: "Pusat", address: "Jl. Mock")]
    )
    var products: [Product] = []
    var ingredients: [Ingredient] = []
    var categories: [ProductCategory] = []
    var orders: [Order] = []

    // MARK: - StoreProtocol Implementation

    func fetchStore(storeId: String) async throws -> Store {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyStore
    }

    func updateStore(store: Store) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        self.dummyStore = store
        return true
    }

    func addBranch(storeId: String, branch: Branch) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        dummyStore.branches.append(branch)
        return true
    }

    // MARK: - OperationalProtocol: Products

    func fetchProducts(for branchId: String) async throws -> [Product] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return products.filter { $0.branchId == branchId }
    }

    func addProduct(_ product: Product) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        products.append(product)
        return true
    }

    func updateProduct(_ product: Product) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let idx = products.firstIndex(where: { $0.id == product.id }) {
            products[idx] = product
            return true
        }
        return false
    }

    func deleteProduct(productId: String) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        products.removeAll { $0.id == productId }
        return true
    }

    // MARK: - OperationalProtocol: Ingredients

    func fetchIngredients(for branchId: String) async throws -> [Ingredient] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return ingredients.filter { $0.branchId == branchId }
    }

    func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        ingredients.append(ingredient)
        return true
    }

    func updateIngredient(_ ingredient: Ingredient) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let idx = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[idx] = ingredient
            return true
        }
        return false
    }

    func deleteIngredient(ingredientId: String) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        ingredients.removeAll { $0.id == ingredientId }
        return true
    }

    func recordWaste(ingredientId: String, amountToDeduct: Double) async throws
        -> Bool
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        if let idx = ingredients.firstIndex(where: { $0.id == ingredientId }) {
            var amountLeft = amountToDeduct
            for i in 0..<ingredients[idx].batches.count {
                if amountLeft <= 0 { break }
                let available = ingredients[idx].batches[i].currentStock
                if available > 0 {
                    let deduction = min(available, amountLeft)
                    ingredients[idx].batches[i].currentStock -= deduction
                    amountLeft -= deduction
                }
            }
            return true
        }
        return false
    }

    // MARK: - OperationalProtocol: Categories

    func fetchCategories(for branchId: String) async throws -> [ProductCategory]
    {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return categories.filter { $0.branchId == branchId }
    }

    func addCategory(_ category: ProductCategory) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        categories.append(category)
        return true
    }

    func deleteCategory(categoryId: String) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        categories.removeAll { $0.id == categoryId }
        return true
    }

    // MARK: - OperationalProtocol: Orders

    func fetchOrders(for branchId: String) async throws -> [Order] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return orders.filter { $0.branchId == branchId }
    }

    func submitOrderAndUpdateInventory(order: Order) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        orders.append(order)
        return true
    }
}
