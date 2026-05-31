//
//  MasterDataViewModel.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 28-05-2026.
//

import Foundation
import Observation

@MainActor
@Observable
class MasterDataViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isSuccess: Bool = false

    private let operationalProtocol: OperationalProtocol

    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }

    func createIngredient(
        name: String,
        currentStock: Double,
        unit: String,
        expiryDate: Date?,
        minimumStockWarning: Double,
        costPerUnit: Double
    ) async {
        guard !name.isEmpty, currentStock >= 0 else {
            errorMessage =
                "Nama bahan baku tidak boleh kosong dan stok harus valid."
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
            minimumStockWarning: minimumStockWarning,
            costPerUnit: costPerUnit
        )

        do {
            _ = try await operationalProtocol.addIngredient(newIngredient)
            isSuccess = true
        } catch {
            errorMessage =
                "Gagal menyimpan bahan baku: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func createProduct(name: String, price: Double, recipe: [RecipeItem]) async
    {
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
            _ = try await operationalProtocol.addProduct(newProduct)
            isSuccess = true
        } catch {
            errorMessage =
                "Gagal menyimpan menu baru: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
