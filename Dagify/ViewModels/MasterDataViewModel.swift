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
    
    // ✅ STATE BARU: Menyimpan daftar menu yang sudah ada
    var products: [Product] = []
    var availableIngredients: [Ingredient] = []

    private let operationalProtocol: OperationalProtocol

    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }

    // ✅ FUNGSI BARU: Tarik Daftar Menu
    func loadProducts(branchId: String) async {
        isLoading = true
        do {
            products = try await operationalProtocol.fetchProducts(for: branchId)
        } catch {
            errorMessage = "Gagal memuat daftar menu."
        }
        isLoading = false
    }

    func loadIngredients(branchId: String) async {
        do {
            availableIngredients = try await operationalProtocol.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat daftar bahan baku."
        }
    }

    func createProduct(branchId: String, name: String, price: Double, recipe: [RecipeItem]) async {
        isLoading = true
        let newProduct = Product(branchId: branchId, name: name, price: price, recipe: recipe)
        do {
            _ = try await operationalProtocol.addProduct(newProduct)
            await loadProducts(branchId: branchId) // Refresh List
        } catch {
            errorMessage = "Gagal menyimpan menu baru."
        }
        isLoading = false
    }

    // ✅ FUNGSI BARU: Perbarui Menu
    func updateProduct(product: Product) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.updateProduct(product)
            await loadProducts(branchId: product.branchId) // Refresh List
        } catch {
            errorMessage = "Gagal memperbarui menu."
        }
        isLoading = false
    }

    // ✅ FUNGSI BARU: Hapus Menu
    func deleteProduct(productId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.deleteProduct(productId: productId)
            await loadProducts(branchId: branchId) // Refresh List
        } catch {
            errorMessage = "Gagal menghapus menu."
        }
        isLoading = false
    }
}
