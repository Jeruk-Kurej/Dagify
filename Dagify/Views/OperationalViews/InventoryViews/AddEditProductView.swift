//
//  AddEditProductView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 02/06/26.
//

import SwiftUI

struct RecipeDraft: Identifiable {
    let id = UUID()
    var ingredient: Ingredient
    var qtyString: String
}

struct AddEditProductView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    var productToEdit: Product?
    
    @State private var productName = ""
    @State private var productPrice = ""
    @State private var recipeDrafts: [RecipeDraft] = []
    @State private var showIngredientPicker = false

    var isNameDuplicate: Bool {
        if let edit = productToEdit, edit.name.lowercased() == productName.lowercased() { return false }
        return viewModel.products.contains { $0.name.lowercased() == productName.lowercased() }
    }

    var isPriceDuplicate: Bool {
        guard let p = Double(productPrice.replacingOccurrences(of: ",", with: ".")) else { return false }
        if let edit = productToEdit, edit.price == p { return false }
        return viewModel.products.contains { $0.price == p }
    }
    
    // ✅ LOGIKA VALIDASI: Memastikan harga bukan huruf dan bernilai valid
    var isPriceValid: Bool {
        let clean = productPrice.replacingOccurrences(of: ",", with: ".")
        return Double(clean) != nil && (Double(clean) ?? 0) >= 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nama Produk").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                        TextField("Cth: Kopi Susu Aren", text: $productName)
                            .font(.body).foregroundColor(Color(hex: "#111827"))
                        
                        if isNameDuplicate {
                            Text("⚠️ Menu dengan nama ini sudah terdaftar!")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }.padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Harga Jual (Rp)").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                        TextField("Cth: 18000", text: $productPrice)
                            .keyboardType(.decimalPad)
                            .font(.body).foregroundColor(Color(hex: "#111827"))
                            // ✅ UX FIX: Membuang huruf asing secara otomatis
                            .onChange(of: productPrice) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    productPrice = filtered
                                }
                            }
                        
                        // ✅ PERINGATAN HARGA INVALID
                        if !productPrice.isEmpty && !isPriceValid {
                            Text("⚠️ Format harga tidak valid.")
                                .font(.caption2)
                                .foregroundColor(.red)
                        } else if isPriceDuplicate {
                            Text("💡 Info: Anda memiliki menu lain dengan harga ini.")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }.padding(.vertical, 4)
                } header: { Text("Informasi Menu Baru") }

                Section {
                    ForEach($recipeDrafts) { $draft in
                        HStack {
                            Text(draft.ingredient.name).font(.body)
                            Spacer()
                            TextField("Takaran", text: $draft.qtyString)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60).foregroundColor(Color(hex: "#00A3A3")).fontWeight(.bold)
                                // ✅ UX FIX: Membuang huruf asing di takaran resep juga
                                .onChange(of: draft.qtyString) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789.,".contains($0) }
                                    if filtered != newValue {
                                        draft.qtyString = filtered
                                    }
                                }
                            
                            Text(draft.ingredient.unit).font(.caption).foregroundColor(Color(hex: "#6B7280"))
                            
                            Button(action: { recipeDrafts.removeAll { $0.id == draft.id } }) {
                                Image(systemName: "minus.circle.fill").foregroundColor(.red)
                            }.padding(.leading, 8)
                        }
                    }
                    Button(action: { showIngredientPicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(recipeDrafts.isEmpty ? "Buat Resep Menu" : "Tambah Bahan Baku")
                        }.foregroundColor(Color(hex: "#00A3A3")).fontWeight(.semibold)
                    }
                } header: { Text("Resep Bahan Baku (Opsional)") }
                  footer: { Text("Bahan baku ini otomatis dipotong dari Gudang setiap menu terjual.") }
            }
            .navigationTitle(productToEdit == nil ? "Tambah Menu" : "Edit Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Batal") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") { saveProduct() }
                        // ✅ TOMBOL TERKUNCI jika nama kosong, harga kosong, HARGA INVALID, atau nama duplikat!
                        .disabled(productName.isEmpty || productPrice.isEmpty || !isPriceValid || viewModel.isLoading || isNameDuplicate)
                }
            }
            .onAppear(perform: loadExistingData)
            .sheet(isPresented: $showIngredientPicker) {
                NavigationStack {
                    List(viewModel.availableIngredients) { ingredient in
                        Button(action: {
                            if !recipeDrafts.contains(where: { $0.ingredient.id == ingredient.id }) {
                                recipeDrafts.append(RecipeDraft(ingredient: ingredient, qtyString: ""))
                            }
                            showIngredientPicker = false
                        }) {
                            HStack {
                                Text(ingredient.name).foregroundColor(Color(hex: "#111827")).fontWeight(.medium)
                                Spacer()
                                Text("Sisa: \(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)")
                                    .font(.caption).foregroundColor(Color(hex: "#6B7280"))
                            }
                        }
                    }
                    .navigationTitle("Pilih Bahan Baku").navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private func loadExistingData() {
        if let product = productToEdit {
            productName = product.name
            productPrice = String(format: "%.0f", product.price)
            recipeDrafts = product.recipe.compactMap { recipeItem in
                if let ingredient = viewModel.availableIngredients.first(where: { $0.id == recipeItem.ingredientId }) {
                    return RecipeDraft(ingredient: ingredient, qtyString: String(format: "%.1f", recipeItem.quantityRequired))
                }
                return nil
            }
        }
    }

    private func saveProduct() {
        let cleanPrice = productPrice.replacingOccurrences(of: ",", with: ".")
        guard let price = Double(cleanPrice) else { return }
        
        let finalRecipe = recipeDrafts.compactMap { draft -> RecipeItem? in
            guard let id = draft.ingredient.id,
                  let qty = Double(draft.qtyString.replacingOccurrences(of: ",", with: ".")),
                  qty > 0 else { return nil }
            return RecipeItem(ingredientId: id, quantityRequired: qty)
        }
        
        Task {
            if let edit = productToEdit {
                let updatedProduct = Product(id: edit.id, branchId: branchId, name: productName, price: price, recipe: finalRecipe)
                await viewModel.updateProduct(product: updatedProduct)
            } else {
                await viewModel.createProduct(branchId: branchId, name: productName, price: price, recipe: finalRecipe)
            }
            dismiss()
        }
    }
}
