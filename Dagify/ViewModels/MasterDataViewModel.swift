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
    
    // ✅ ARRAY UNTUK MENYIMPAN DAFTAR BAHAN BAKU DARI GUDANG
    var availableIngredients: [Ingredient] = []

    private let operationalProtocol: OperationalProtocol

    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }

    // ✅ FUNGSI TARIK DATA GUDANG
    func loadIngredients(branchId: String) async {
        do {
            availableIngredients = try await operationalProtocol.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat daftar bahan baku."
        }
    }

    func createProduct(branchId: String, name: String, price: Double, recipe: [RecipeItem]) async {
        guard !name.isEmpty, price >= 0 else {
            errorMessage = "Nama menu dan harga harus valid."
            return
        }
        isLoading = true
        errorMessage = nil
        isSuccess = false

        let newProduct = Product(branchId: branchId, name: name, price: price, recipe: recipe)

        do {
            _ = try await operationalProtocol.addProduct(newProduct)
            isSuccess = true
        } catch {
            errorMessage = "Gagal menyimpan menu baru."
        }
        isLoading = false
    }
}
