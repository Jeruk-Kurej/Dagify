//
//  TestHelper.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 01/06/26.
//
@MainActor
enum TestHelper {
    /// Membuat database in-memory (RAM) yang akan langsung musnah setelah test selesai.
    /// Mencegah sampah data test masuk ke database Production.
    static func createInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: FinancialRecord.self,
            CustomerModel.self,
            IngredientModel.self,
            ProductModel.self,
            OrderModel.self,
            configurations: config
        )
        return ModelContext(container)
    }
}
