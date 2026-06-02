import FirebaseFirestore
import Foundation

class FirebaseOperationalService: OperationalProtocol, StoreProtocol {
    private let db = Firestore.firestore()

    init() {}

    func fetchOrders(for branchId: String) async throws -> [Order] {
        let snapshot = try await db.collection("orders").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Order.self) }
    }

    func fetchStore(storeId: String) async throws -> Store {
        let snapshot = try await db.collection("stores").document(storeId)
            .getDocument()
        guard let store = try snapshot.data(as: Store?.self) else {
            throw NSError(
                domain: "Operational",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Toko tidak ditemukan."]
            )
        }
        return store
    }

    // ✅ FUNGSI BARU: Simpan Cabang Baru ke Firebase Array
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

    func fetchProducts(for branchId: String) async throws -> [Product] {
        let snapshot = try await db.collection("products").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Product.self) }
    }

    func fetchIngredients(for branchId: String) async throws -> [Ingredient] {
        let snapshot = try await db.collection("ingredients").whereField(
            "branchId",
            isEqualTo: branchId
        ).getDocuments()
        return snapshot.documents.compactMap {
            try? $0.data(as: Ingredient.self)
        }
    }

    func submitOrderAndUpdateInventory(order: Order) async throws -> Bool {
        let batch = db.batch()
        let orderRef = db.collection("orders").document()
        try batch.setData(from: order, forDocument: orderRef)

        for item in order.items {
            for recipe in item.product.recipe {
                let ingredientRef = db.collection("ingredients").document(
                    recipe.ingredientId
                )
                let totalDeduction =
                    Double(item.quantity) * recipe.quantityRequired
                batch.updateData(
                    ["currentStock": FieldValue.increment(-totalDeduction)],
                    forDocument: ingredientRef
                )
            }
        }
        try await batch.commit()
        return true
    }

    func addProduct(_ product: Product) async throws -> Bool {
        let ref = db.collection("products").document()
        try ref.setData(from: product)
        return true
    }

    // ✅ FUNGSI BARU: Update Menu F&B
    func updateProduct(_ product: Product) async throws -> Bool {
        guard let id = product.id else { return false }
        try db.collection("products").document(id).setData(from: product)
        return true
    }

    // ✅ FUNGSI BARU: Hapus Menu F&B
    func deleteProduct(productId: String) async throws -> Bool {
        try await db.collection("products").document(productId).delete()
        return true
    }

    func addIngredient(_ ingredient: Ingredient) async throws -> Bool {
        let ref = db.collection("ingredients").document()
        try ref.setData(from: ingredient)
        return true
    }

    func recordWaste(ingredientId: String, amountToDeduct: Double) async throws
        -> Bool
    {
        let ref = db.collection("ingredients").document(ingredientId)
        try await ref.updateData([
            "currentStock": FieldValue.increment(-amountToDeduct)
        ])
        return true
    }
}
