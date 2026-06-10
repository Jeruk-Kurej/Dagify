//
//  FirebaseOperationalService.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import FirebaseFirestore

class FirebaseOperationalService: OperationalProtocol, StoreProtocol {
    
    // MARK: - Properties
    private let db = Firestore.firestore()

    // MARK: - Initialization
    init() {}

    // MARK: - STORE & BRANCH OPERATIONS
    
    func fetchStore(storeId: String) async throws -> Store {
        let snapshot = try await db.collection("stores").document(storeId).getDocument()
        guard let store = try snapshot.data(as: Store?.self) else {
            throw NSError(
                domain: "Operational",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Toko tidak ditemukan."]
            )
        }
        return store
    }
    
    func updateStore(store: Store) async throws -> Bool {
        guard let id = store.id else { return false }
        try db.collection("stores").document(id).setData(from: store)
        return true
    }

    func addBranch(storeId: String, branch: Branch) async throws -> Bool {
        let storeRef = db.collection("stores").document(storeId)
        let branchData: [String: Any] = [
            "id": branch.id,
            "name": branch.name,
            "address": branch.address,
        ]
        try await storeRef.updateData([
            "branches": FieldValue.arrayUnion([branchData])
        ])
        return true
    }

    // MARK: - PRODUCT (MENU) OPERATIONS
    
    func fetchProducts(for branchId: String) async throws -> [Product] {
        let snapshot = try await db.collection("products").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { doc in
            var product = try? doc.data(as: Product.self)
            product?.id = doc.documentID
            return product
        }
    }
    
    func addProduct(_ product: Product) async throws -> Bool {
        let ref = db.collection("products").document()
        try ref.setData(from: product)
        return true
    }

    func updateProduct(_ product: Product) async throws -> Bool {
        guard let id = product.id else { return false }
        try db.collection("products").document(id).setData(from: product)
        return true
    }

    func deleteProduct(productId: String) async throws -> Bool {
        try await db.collection("products").document(productId).delete()
        return true
    }

    // MARK: - INGREDIENT (GUDANG) OPERATIONS
    
    func fetchIngredients(for branchId: String) async throws -> [Ingredient] {
        let snapshot = try await db.collection("ingredients").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Ingredient.self) }
    }
    
    func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        let ref = db.collection("ingredients").document()
        try ref.setData(from: ingredient)
        return true
    }

    func updateIngredient(_ ingredient: Ingredient) async throws -> Bool {
        guard let id = ingredient.id else { return false }
        try db.collection("ingredients").document(id).setData(from: ingredient)
        return true
    }

    func deleteIngredient(ingredientId: String) async throws -> Bool {
        try await db.collection("ingredients").document(ingredientId).delete()
        
        // Menghapus referensi bahan baku yang terhapus dari semua resep menu
        let productsSnapshot = try await db.collection("products").getDocuments()
        for doc in productsSnapshot.documents {
            if var product = try? doc.data(as: Product.self) {
                if product.recipe.contains(where: { $0.ingredientId == ingredientId }) {
                    product.recipe.removeAll(where: { $0.ingredientId == ingredientId })
                    try db.collection("products").document(doc.documentID).setData(from: product)
                }
            }
        }
        return true
    }

    func recordWaste(ingredientId: String, amountToDeduct: Double) async throws -> Bool {
        let ref = db.collection("ingredients").document(ingredientId)
        try await ref.updateData([
            "currentStock": FieldValue.increment(-amountToDeduct)
        ])
        return true
    }

    // MARK: - CATEGORY OPERATIONS
    
    func fetchCategories(for branchId: String) async throws -> [ProductCategory] {
        let snapshot = try await db.collection("categories").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: ProductCategory.self) }
    }

    func addCategory(_ category: ProductCategory) async throws -> Bool {
        let ref = db.collection("categories").document()
        try ref.setData(from: category)
        return true
    }

    func deleteCategory(categoryId: String) async throws -> Bool {
        try await db.collection("categories").document(categoryId).delete()
        return true
    }
    
    // MARK: - ORDER (TRANSAKSI) OPERATIONS
    
    func fetchOrders(for branchId: String) async throws -> [Order] {
        let snapshot = try await db.collection("orders").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Order.self) }
    }
    
    func submitOrderAndUpdateInventory(order: Order) async throws -> Bool {
        let orderRef = db.collection("orders").document()
        
        // Prepare required ingredient IDs
        var requiredIngredientIds = Set<String>()
        for item in order.items {
            for recipe in item.product.recipe {
                requiredIngredientIds.insert(recipe.ingredientId)
            }
        }
        
        let result = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            var ingredientsMap: [String: Ingredient] = [:]
            
            // 1. Read all required ingredients
            for id in requiredIngredientIds {
                let ref = self.db.collection("ingredients").document(id)
                do {
                    let doc = try transaction.getDocument(ref)
                    if let ingredient = try doc.data(as: Ingredient?.self) {
                        ingredientsMap[id] = ingredient
                    }
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
            }
            
            // 2. Perform deductions
            for item in order.items {
                for recipe in item.product.recipe {
                    guard var ingredient = ingredientsMap[recipe.ingredientId] else { continue }
                    var amountToDeduct = Double(item.quantity) * recipe.quantityRequired
                    
                    // Sort batches by expiryDate ascending (earliest first, nil last)
                    ingredient.batches.sort { 
                        if let d1 = $0.expiryDate, let d2 = $1.expiryDate { return d1 < d2 }
                        if $0.expiryDate != nil { return true }
                        if $1.expiryDate != nil { return false }
                        return $0.dateAdded < $1.dateAdded 
                    }
                    
                    // Deduct sequentially
                    for i in 0..<ingredient.batches.count {
                        if amountToDeduct <= 0 { break }
                        let available = ingredient.batches[i].currentStock
                        if available > 0 {
                            let deduction = min(available, amountToDeduct)
                            ingredient.batches[i].currentStock -= deduction
                            amountToDeduct -= deduction
                        }
                    }
                    
                    ingredientsMap[recipe.ingredientId] = ingredient
                }
            }
            
            // 3. Write back updated ingredients
            for (id, ingredient) in ingredientsMap {
                let ref = self.db.collection("ingredients").document(id)
                do {
                    try transaction.setData(from: ingredient, forDocument: ref)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
            }
            
            // 4. Write Order
            do {
                try transaction.setData(from: order, forDocument: orderRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            return true
        }
        
        if result == nil {
            throw NSError(domain: "FirebaseOperationalService", code: 500, userInfo: [NSLocalizedDescriptionKey: "Gagal menyimpan transaksi."])
        }
        
        return true
    }
}
