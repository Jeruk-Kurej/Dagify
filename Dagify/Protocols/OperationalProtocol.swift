//
//  OperationalRepository.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation

protocol OperationalProtocol {
    func fetchProducts(for branchId: String) async throws -> [Product]
    func fetchIngredients(for branchId: String) async throws -> [Ingredient]
    func submitOrderAndUpdateInventory(order: Order) async throws -> Bool
    func fetchOrders(for branchId: String) async throws -> [Order]
    
    func addProduct(_ product: Product) async throws -> Bool
    func updateProduct(_ product: Product) async throws -> Bool
    func deleteProduct(productId: String) async throws -> Bool
    
    func addIngredient(_ ingredient: Ingredient) async throws -> Bool
    func updateIngredient(_ ingredient: Ingredient) async throws -> Bool // ✅ BARU
    func deleteIngredient(ingredientId: String) async throws -> Bool    // ✅ BARU
    func recordWaste(ingredientId: String, amountToDeduct: Double) async throws -> Bool
    
    func fetchCategories(for branchId: String) async throws -> [ProductCategory]
    func addCategory(_ category: ProductCategory) async throws -> Bool
    func deleteCategory(categoryId: String) async throws -> Bool
}
