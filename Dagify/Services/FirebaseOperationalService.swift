//
//  FirebaseOperationalService.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class FirebaseOperationalService: OperationalRepository {
    private let db = Firestore.firestore()
    
    func submitOrder(_ order: Order) async throws -> Bool {
        let ref = db.collection("orders").document()
        try ref.setData(from: order)
        return true
    }
    
    func updateInventoryStock(for items: [OrderItem]) async throws -> Bool {
        let batch = db.batch()
        
        for item in items {
            for recipe in item.product.recipe {
                let ingRef = db.collection("ingredients").document(recipe.ingredientId)
                let deduction = Double(item.quantity) * recipe.quantityRequired
                
                batch.updateData(["currentStock": FieldValue.increment(-deduction)], forDocument: ingRef)
            }
        }
        
        try await batch.commit()
        return true
    }
}


