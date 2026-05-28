//
//  MasterDataViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Combine
import Foundation

@MainActor
class MasterDataViewModel: ObservableObject {
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var isSuccess: Bool = false
    
    private let repo: OperationalRepository
    
    public init(repo: OperationalRepository) {
        self.repo = repo
    }
    
    public func createIngredient(name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double) async {
        guard !name.isEmpty, currentStock >= 0 else {
            errorMessage = "Nama bahan baku tidak boleh kosong dan stok harus valid."
            return
        }
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        let newIngredient = Ingredient(
            name: name,
            currentStock: currentStock,
            unit: unit,
            expiryDate: expiryDate,
            minimumStockWarning: minimumStockWarning
        )
        
        do {
            _ = try await repo.addIngredient(newIngredient)
            isSuccess = true
        } catch {
            errorMessage = "Gagal menyimpan bahan baku: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    public func createProduct(name: String, price: Double, recipe: [RecipeItem]) async {
        guard !name.isEmpty, price >= 0 else {
            errorMessage = "Nama menu dan harga harus valid."
            return
        }
        
        isLoading = true
        errorMessage = nil
        isSuccess = false
        
        let newProduct = Product(
            name: name,
            price: price,
            recipe: recipe
        )
        
        do {
            _ = try await repo.addProduct(newProduct)
            isSuccess = true
        } catch {
            errorMessage = "Gagal menyimpan menu baru: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
