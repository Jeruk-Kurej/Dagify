import Foundation
import Observation

@MainActor
@Observable
class InventoryViewModel {
    var ingredients: [Ingredient] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    /// Returns a list of expired ingredients that still have stock remaining.
    var expiredIngredients: [Ingredient] {
        let today = Date()
        return ingredients.filter { ingredient in
            guard let expiry = ingredient.expiryDate else { return false }
            return expiry < today && ingredient.currentStock > 0
        }
    }
    
    var lowStockIngredients: [Ingredient] {
        return ingredients.filter {
            $0.currentStock <= $0.minimumStockWarning
        }
    }
    
    /// Returns a list of ingredients that need attention (either expired or low stock).
    var attentionIngredients: [Ingredient] {
        let expiredIds = expiredIngredients.compactMap { $0.id }
        let lowStockIds = lowStockIngredients.compactMap { $0.id }
        let combinedIds = Set(expiredIds + lowStockIds)
        
        return ingredients.filter { combinedIds.contains($0.id ?? "") }
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
    
    func createIngredient(branchId: String, name: String, currentStock: Double, unit: String, expiryDate: Date?, minimumStockWarning: Double, costPerUnit: Double) async {
        guard !name.isEmpty, currentStock >= 0 else {
            errorMessage = "Nama bahan baku tidak boleh kosong dan stok harus valid."
            return
        }
        isLoading = true
        
        let newIngredient = Ingredient(branchId: branchId, name: name, currentStock: currentStock, unit: unit, expiryDate: expiryDate, minimumStockWarning: minimumStockWarning, costPerUnit: costPerUnit)
        let totalCost = currentStock * costPerUnit
        
        do {
            _ = try await operationalProtocol.addIngredient(newIngredient)
            
            if totalCost > 0 {
                let expenseRecord = FinancialRecord(
                    id: UUID().uuidString,
                    branchId: branchId,
                    amount: totalCost,
                    type: .expense,
                    category: .cogs,
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
    
    func discardExpiredItem(ingredient: Ingredient, branchId: String) async {
        guard let id = ingredient.id else { return }
        isLoading = true
        do {
            // Catat kerugian secara sistem
            _ = try await operationalProtocol.recordWaste(ingredientId: id, amountToDeduct: ingredient.currentStock)
            
            /// Resets current stock to 0 and removes the expiry date after discarding.
            var updated = ingredient
            updated.currentStock = 0
            updated.expiryDate = nil
            _ = try await operationalProtocol.updateIngredient(updated)
            
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal membuang stok basi."
        }
        isLoading = false
    }
    
    func updateIngredient(ingredient: Ingredient) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.updateIngredient(ingredient)
            await loadIngredients(branchId: ingredient.branchId)
        } catch {
            errorMessage = "Gagal memperbarui bahan baku."
        }
        isLoading = false
    }
    
    func deleteIngredient(ingredientId: String, branchId: String) async {
        isLoading = true
        do {
            _ = try await operationalProtocol.deleteIngredient(ingredientId: ingredientId)
            await loadIngredients(branchId: branchId)
        } catch {
            errorMessage = "Gagal menghapus bahan baku."
        }
        isLoading = false
    }
}
