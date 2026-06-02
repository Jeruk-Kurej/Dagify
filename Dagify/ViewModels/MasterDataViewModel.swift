import Foundation
import Observation

@MainActor
@Observable
class MasterDataViewModel {
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isSuccess: Bool = false
    
    var products: [Product] = []
    var availableIngredients: [Ingredient] = []
    var categories: [ProductCategory] = [] // ✅ STATE KATEGORI BARU
    
    private let operationalProtocol: OperationalProtocol
    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
    }
    
    func loadProducts(branchId: String) async {
        isLoading = true
        do { products = try await operationalProtocol.fetchProducts(for: branchId) }
        catch { errorMessage = "Gagal memuat daftar menu." }
        isLoading = false
    }
    
    func loadIngredients(branchId: String) async {
        do { availableIngredients = try await operationalProtocol.fetchIngredients(for: branchId) }
        catch { errorMessage = "Gagal memuat daftar bahan baku." }
    }
    
    // ✅ LOGIKA BARU: Muat Kategori (Buat nilai Default jika kosong)
    func loadCategories(branchId: String) async {
        do {
            let fetched = try await operationalProtocol.fetchCategories(for: branchId)
            if fetched.isEmpty {
                let defaultCats = ["Makanan Berat", "Minuman", "Lainnya"]
                for name in defaultCats {
                    _ = try await operationalProtocol.addCategory(ProductCategory(branchId: branchId, name: name))
                }
                categories = try await operationalProtocol.fetchCategories(for: branchId)
            } else {
                categories = fetched
            }
        } catch { errorMessage = "Gagal memuat kategori." }
    }
    
    func createCategory(branchId: String, name: String) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.addCategory(ProductCategory(branchId: branchId, name: name))
            await loadCategories(branchId: branchId)
        } catch { errorMessage = "Gagal menambah kategori." }
        isLoading = false
    }
    
    // ✅ VALIDASI SEBELUM MENGHAPUS KATEGORI
    func deleteCategory(categoryId: String, branchId: String) async {
        if products.contains(where: { $0.categoryId == categoryId }) {
            errorMessage = "Peringatan: Kategori ini sedang digunakan oleh menu F&B!"
            return
        }
        isLoading = true
        do {
            _ = try await operationalProtocol.deleteCategory(categoryId: categoryId)
            await loadCategories(branchId: branchId)
        } catch { errorMessage = "Gagal menghapus kategori." }
        isLoading = false
    }

    func createProduct(branchId: String, categoryId: String, name: String, price: Double, recipe: [RecipeItem], imageData: Data?) async {
        isLoading = true
        let newProduct = Product(branchId: branchId, categoryId: categoryId, name: name, price: price, recipe: recipe, imageData: imageData)
        do {
            _ = try await operationalProtocol.addProduct(newProduct)
            await loadProducts(branchId: branchId)
        } catch { errorMessage = "Gagal menyimpan menu baru." }
        isLoading = false
    }
    
    func updateProduct(product: Product) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.updateProduct(product)
            await loadProducts(branchId: product.branchId)
        } catch { errorMessage = "Gagal memperbarui menu." }
        isLoading = false
    }
    
    func deleteProduct(productId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.deleteProduct(productId: productId)
            await loadProducts(branchId: branchId)
        } catch { errorMessage = "Gagal menghapus menu." }
        isLoading = false
    }
}
