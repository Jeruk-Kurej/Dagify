//
//  MockOperationalRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

class MockOperationalRepository: OperationalRepository, StoreRepository {
    public var shouldThrowError = false
    public var dummyProducts: [Product] = []
    public var dummyIngredients: [Ingredient] = []
    public var dummyOrders: [Order] = []
    public var submitCallCount = 0
    
    public init() {}
    
    public func fetchOrders(for branchId: String) async throws -> [Order] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyOrders.filter { $0.branchId == branchId }
    }
    
    public func fetchStore(storeId: String) async throws -> Store {
        if shouldThrowError { throw NSError(domain: "MockError", code: 404) }
        return Store(id: storeId, name: "Dagify Test Store", branches: [Branch(id: "B-1", name: "Pusat", address: "Surabaya")])
    }
    
    public func fetchProducts(for branchId: String) async throws -> [Product] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyProducts
    }
    
    public func fetchIngredients(for branchId: String) async throws -> [Ingredient] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        return dummyIngredients
    }
    
    public func submitOrderAndUpdateInventory(order: Order) async throws -> Bool {
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
    
    public func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        if shouldThrowError { throw NSError(domain: "MockError", code: 500) }
        var newIngredient = ingredient
        if newIngredient.id == nil { newIngredient.id = UUID().uuidString }
        dummyIngredients.append(newIngredient)
        return true
    }
}
