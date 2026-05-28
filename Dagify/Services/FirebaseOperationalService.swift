//
//  FirebaseOperationalService.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

class FirebaseOperationalService: OperationalRepository, StoreRepository {
    private let db = Firestore.firestore()
    
    public init() {}
    
    public func fetchOrders(for branchId: String) async throws -> [Order] {
        let snapshot = try await db.collection("orders")
            .whereField("branchId", isEqualTo: branchId)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Order.self) }
    }
    
    public func fetchStore(storeId: String) async throws -> Store {
        let snapshot = try await db.collection("stores").document(storeId).getDocument()
        guard let store = try snapshot.data(as: Store?.self) else {
            throw NSError(domain: "Operational", code: 404, userInfo: [NSLocalizedDescriptionKey: "Toko tidak ditemukan."])
        }
        return store
    }
    
    public func fetchProducts(for branchId: String) async throws -> [Product] {
        let snapshot = try await db.collection("products")
            .whereField("branchId", isEqualTo: branchId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Product.self) }
    }
    
    public func fetchIngredients(for branchId: String) async throws -> [Ingredient] {
        let snapshot = try await db.collection("ingredients")
            .whereField("branchId", isEqualTo: branchId)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Ingredient.self) }
    }
    
    public func submitOrderAndUpdateInventory(order: Order) async throws -> Bool {
        let batch = db.batch()
        
        let orderRef = db.collection("orders").document()
        try batch.setData(from: order, forDocument: orderRef)
        
        for item in order.items {
            for recipe in item.product.recipe {
                let ingredientRef = db.collection("ingredients").document(recipe.ingredientId)
                
                let totalDeduction = Double(item.quantity) * recipe.quantityRequired
                
                batch.updateData([
                    "currentStock": FieldValue.increment(-totalDeduction)
                ], forDocument: ingredientRef)
            }
        }
        
        try await batch.commit()
        return true
    }
    
    public func addProduct(_ product: Product) async throws -> Bool {
        let ref = db.collection("products").document()
        try ref.setData(from: product)
        return true
    }
    
    public func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        let ref = db.collection("ingredients").document()
        try ref.setData(from: ingredient)
        return true
    }
}
