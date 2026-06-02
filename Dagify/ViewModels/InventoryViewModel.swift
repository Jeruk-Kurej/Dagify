import Foundation
import Observation

@MainActor
@Observable
class InventoryViewModel {
    var ingredients: [Ingredient] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var lowStockIngredients: [Ingredient] {
        ingredients.filter { $0.currentStock <= $0.minimumStockWarning }
    }

    var expiredIngredients: [Ingredient] {
        let today = Date()
        return ingredients.filter { ingredient in
            guard let expiry = ingredient.expiryDate else { return false }
            return expiry < today
        }
    }

    private let operationalProtocol: OperationalProtocol
    private let cashflowProtocol: CashflowProtocol

    init(operationalProtocol: OperationalProtocol, cashflowProtocol: CashflowProtocol) {
        self.operationalProtocol = operationalProtocol
        self.cashflowProtocol = cashflowProtocol
    }

    func loadIngredients(branchId: String) async {
        isLoading = true
        do {
            ingredients = try await operationalProtocol.fetchIngredients(for: branchId)
        } catch {
            errorMessage = "Gagal memuat data gudang."
        }
        isLoading = false
    }

    // ✅ FITUR BARU: Otomatis mencatat pengeluaran ke Arus Kas saat beli bahan baku
    func createIngredient(branchId: String, name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double, costPerUnit: Double) async {
        guard !name.isEmpty, currentStock >= 0 else {
            errorMessage = "Nama bahan baku tidak boleh kosong dan stok harus valid."
            return
        }
        isLoading = true
        
        let newIngredient = Ingredient(branchId: branchId, name: name, currentStock: currentStock, unit: unit, expiryDate: expiryDate, minimumStockWarning: minimumStockWarning, costPerUnit: costPerUnit)
        
        // 1. Hitung total modal yang dikeluarkan
        let totalCost = currentStock * costPerUnit
        
        do {
            // 2. Simpan ke Gudang
            _ = try await operationalProtocol.addIngredient(newIngredient)
            
            // 3. Langsung potong uang Kas secara otomatis!
            if totalCost > 0 {
                let expenseRecord = FinancialRecord(
                    id: UUID().uuidString,
                    branchId: branchId,
                    amount: totalCost,
                    type: .expense,
                    category: .cogs, // Kategori Harga Pokok Penjualan
                    timestamp: Date(),
                    notes: "Beli Bahan: \(name)"
                )
                _ = try await cashflowProtocol.addRecord(expenseRecord)
            }
            
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal menyimpan bahan baku."
        }
        isLoading = false
    }

    // ✅ FIX BUG: Buang stok basi HANYA memotong kuantitas fisik, TIDAK mengurangi Kas lagi.
    func discardExpiredItem(ingredient: Ingredient, branchId: String) async {
        guard let id = ingredient.id else { return }
        isLoading = true
        do {
            // Murni hanya memotong stok dari Database Firebase, tidak menyentuh Cashflow
            _ = try await operationalProtocol.recordWaste(ingredientId: id, amountToDeduct: ingredient.currentStock)
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal membuang stok basi."
        }
        isLoading = false
    }
}
