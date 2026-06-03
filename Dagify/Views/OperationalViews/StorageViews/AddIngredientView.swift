import SwiftUI

struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: InventoryViewModel
    let branchId: String
    
    /// Optional identifier for edit mode.
    var ingredientToEdit: Ingredient? = nil
    
    @State private var name = ""
    @State private var currentStock = ""
    @State private var unit = "Kg"
    @State private var minimumStockWarning = ""
    @State private var costPerUnit = ""
    @State private var hasExpiry = false
    @State private var expiryDate = Date()
    
    let units = ["Kg", "Gram", "Liter", "Ml", "Pcs", "Box", "Cup"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informasi Utama") {
                    TextField("Nama Bahan (Cth: Biji Kopi Arabica)", text: $name)
                    HStack {
                        TextField("Stok Saat Ini", text: $currentStock).keyboardType(.decimalPad)
                        Picker("Satuan", selection: $unit) {
                            ForEach(units, id: \.self) { Text($0) }
                        }.pickerStyle(.menu)
                    }
                }
                
                Section("Harga Modal & Peringatan") {
                    TextField("Harga Modal per Satuan (Rp)", text: $costPerUnit).keyboardType(.decimalPad)
                    TextField("Batas Peringatan Stok Tipis", text: $minimumStockWarning).keyboardType(.decimalPad)
                }
                
                Section("Kedaluwarsa (Opsional)") {
                    Toggle("Ada Batas Kedaluwarsa?", isOn: $hasExpiry)
                        .tint(Color(hex: "#00A3A3"))
                    if hasExpiry {
                        DatePicker("Tanggal Basi", selection: $expiryDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle(ingredientToEdit == nil ? "Tambah Bahan Baku" : "Edit Bahan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        Task {
                            let parsedStock = Double(currentStock.replacingOccurrences(of: ",", with: ".")) ?? 0
                            let parsedWarning = Double(minimumStockWarning.replacingOccurrences(of: ",", with: ".")) ?? 0
                            let parsedCost = Double(costPerUnit.replacingOccurrences(of: ",", with: ".")) ?? 0
                            let finalExpiry = hasExpiry ? expiryDate : nil
                            
                            if let edit = ingredientToEdit {
                                // Mode EDIT
                                var updated = edit
                                updated.name = name
                                updated.currentStock = parsedStock
                                updated.unit = unit
                                updated.minimumStockWarning = parsedWarning
                                updated.costPerUnit = parsedCost
                                updated.expiryDate = finalExpiry
                                await viewModel.updateIngredient(ingredient: updated)
                            } else {
                                // Mode TAMBAH BARU
                                await viewModel.createIngredient(
                                    branchId: branchId,
                                    name: name,
                                    currentStock: parsedStock,
                                    unit: unit,
                                    expiryDate: finalExpiry,
                                    minimumStockWarning: parsedWarning,
                                    costPerUnit: parsedCost
                                )
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || currentStock.isEmpty || costPerUnit.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                /// Populate data if edit mode is active.
                if let edit = ingredientToEdit {
                    name = edit.name
                    currentStock = String(format: "%.1f", edit.currentStock)
                    unit = edit.unit
                    minimumStockWarning = String(format: "%.1f", edit.minimumStockWarning)
                    costPerUnit = String(format: "%.0f", edit.costPerUnit)
                    if let expiry = edit.expiryDate {
                        hasExpiry = true
                        expiryDate = expiry
                    }
                }
            }
        }
    }
}

#Preview {
    AddIngredientView(viewModel: InventoryViewModel(operationalProtocol: MockOperationalRepository(), cashflowProtocol: MockCashflowRepository()), branchId: "B-1")
}
