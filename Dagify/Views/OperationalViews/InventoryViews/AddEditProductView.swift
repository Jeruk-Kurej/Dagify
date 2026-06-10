//
//  AddEditProductView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI
import PhotosUI

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
    @State private var isSaving = false
    
    @State private var selectedCategoryId: String = ""
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil // Untuk gambar lokal yang baru dipilih

    var isNameDuplicate: Bool {
        if let edit = productToEdit, edit.name.lowercased() == productName.lowercased() { return false }
        return viewModel.products.contains { $0.name.lowercased() == productName.lowercased() }
    }

    var isPriceDuplicate: Bool {
        guard let p = Double(productPrice.replacingOccurrences(of: ",", with: ".")) else { return false }
        if let edit = productToEdit, edit.price == p { return false }
        return viewModel.products.contains { $0.price == p }
    }
    
    var isPriceValid: Bool {
        let clean = productPrice.replacingOccurrences(of: ",", with: ".")
        return (Double(clean) ?? 0) > 0
    }
    
    var priceValidationMessage: String? {
        if productPrice.isEmpty { return "Harga jual wajib diisi." }
        let clean = productPrice.replacingOccurrences(of: ",", with: ".")
        if Double(clean) == nil { return "Format harga tidak valid." }
        else if let val = Double(clean), val <= 0 { return "Harga jual harus lebih dari 0." }
        return nil
    }
    
    var isRecipeValid: Bool {
        for draft in recipeDrafts {
            let clean = draft.qtyString.replacingOccurrences(of: ",", with: ".")
            if let val = Double(clean), val > 0 { continue } else { return false }
        }
        return true
    }

    var body: some View {
        Group {
            Form {
                Section("Media & Pengelompokan") {
                    HStack {
                        Spacer()
                        
                        /// Image display logic (Local, Internet, or Default)
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            // Tampilkan gambar baru yang di-pick dari galeri lokal
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 120, height: 120).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(radius: 3)
                        } else if let urlString = productToEdit?.imageUrl, let url = URL(string: urlString) {
                            // Tampilkan gambar dari Cloudinary menggunakan AsyncImage
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFill()
                                } else if phase.error != nil {
                                    Image(systemName: "photo.fill").foregroundColor(.gray)
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 120, height: 120).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(radius: 3)
                        } else {
                            Image(systemName: "cup.and.saucer.fill").resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.gray).frame(width: 120, height: 120).background(Color(hex: "#F3F4F6")).clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Spacer()
                    }
                    
                    PhotosPicker(selection: $selectedImageItem, matching: .images, photoLibrary: .shared()) {
                        Text("Ganti Gambar Menu").frame(maxWidth: .infinity).foregroundColor(Color(hex: "#00A3A3"))
                    }
                    .onChange(of: selectedImageItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImageData = uiImage.jpegData(compressionQuality: 0.5)
                            }
                        }
                    }
                    
                    Picker("Pilih Kategori", selection: $selectedCategoryId) {
                        if viewModel.categories.isEmpty { Text("Memuat...").tag("") }
                        else { ForEach(viewModel.categories) { cat in Text(cat.name).tag(cat.id ?? "") } }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nama Produk").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                        TextField("Cth: Kopi Susu Aren", text: $productName).font(.body).foregroundColor(Color(hex: "#111827"))
                        if isNameDuplicate { Text("⚠️ Menu dengan nama ini sudah terdaftar!").font(.caption2).foregroundColor(.red) }
                    }.padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Harga Jual (Rp)").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                        TextField("Cth: 18000", text: $productPrice).keyboardType(.decimalPad).font(.body).foregroundColor(Color(hex: "#111827"))
                            .onChange(of: productPrice) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue { productPrice = filtered }
                            }
                        if let msg = priceValidationMessage { Text(msg).font(.caption2).foregroundColor(.red) }
                        else if isPriceDuplicate { Text("💡 Info: Anda memiliki menu lain dengan harga ini.").font(.caption2).foregroundColor(.orange) }
                    }.padding(.vertical, 4)
                } header: { Text("Informasi Menu Baru") }

                Section {
                    ForEach($recipeDrafts) { $draft in
                        HStack {
                            Text(draft.ingredient.name).font(.body)
                            Spacer()
                            TextField("Takaran", text: $draft.qtyString).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80).foregroundColor(Color(hex: "#00A3A3")).fontWeight(.bold)
                                .onChange(of: draft.qtyString) { oldValue, newValue in
                                    let filtered = newValue.filter { "0123456789.,".contains($0) }
                                    if filtered != newValue { draft.qtyString = filtered }
                                }
                            Text(draft.ingredient.unit).font(.caption).foregroundColor(Color(hex: "#6B7280"))
                            Image(systemName: "minus.circle.fill").foregroundColor(.red).font(.title3).padding(.leading, 8).contentShape(Rectangle())
                                .onTapGesture { recipeDrafts.removeAll { $0.id == draft.id } }
                        }
                        let cleanQty = draft.qtyString.replacingOccurrences(of: ",", with: ".")
                        if !draft.qtyString.isEmpty && (Double(cleanQty) ?? 0) <= 0 { Text("Takaran harus lebih dari 0").font(.caption2).foregroundColor(.red) }
                    }
                    Button(action: { showIngredientPicker = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(recipeDrafts.isEmpty ? "Buat Resep Menu" : "Tambah Bahan Baku")
                        }.foregroundColor(Color(hex: "#00A3A3")).fontWeight(.semibold)
                    }
                } header: { Text("Resep Bahan Baku (Opsional)") }
                  footer: {
                      VStack(alignment: .leading, spacing: 4) {
                          Text("Bahan baku ini otomatis dipotong dari Gudang setiap menu terjual.")
                          if !isRecipeValid && !recipeDrafts.isEmpty { Text("⚠️ Masih ada takaran bahan baku yang kosong/tidak valid.").foregroundColor(.red).fontWeight(.semibold) }
                      }
                  }
            }
            .frame(maxWidth: 500)
            .navigationTitle(productToEdit == nil ? "Tambah Menu" : "Edit Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        if viewModel.isLoading { return }
                        saveProduct()
                    }
                    .disabled(productName.isEmpty || !isPriceValid || viewModel.isLoading || isNameDuplicate || !isRecipeValid || isSaving || selectedCategoryId.isEmpty)
                }
            }
            .onAppear(perform: loadExistingData)
            .sheet(isPresented: $showIngredientPicker) {
                NavigationStack {
                    Group {
                        if viewModel.availableIngredients.isEmpty {
                            ContentUnavailableView("Belum ada bahan baku", systemImage: "shippingbox", description: Text("Silakan tambahkan bahan baku di tab Gudang terlebih dahulu."))
                        } else {
                            List(viewModel.availableIngredients) { ingredient in
                                Button(action: {
                                    if !recipeDrafts.contains(where: { $0.ingredient.id == ingredient.id }) { recipeDrafts.append(RecipeDraft(ingredient: ingredient, qtyString: "")) }
                                    showIngredientPicker = false
                                }) {
                                    HStack {
                                        Text(ingredient.name).foregroundColor(Color(hex: "#111827")).fontWeight(.medium)
                                        Spacer()
                                        Text("Sisa: \(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("Pilih Bahan Baku").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { showIngredientPicker = false } } }
                }.presentationDetents([.medium, .large])
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Mengunggah Aset...").padding().background(Color.white).cornerRadius(12)
                    }
                }
            }
        }
    }

    private func loadExistingData() {
        if let product = productToEdit {
            productName = product.name
            productPrice = String(format: "%.0f", product.price)
            selectedCategoryId = product.categoryId
            selectedImageData = nil
            
            recipeDrafts = product.recipe.compactMap { recipeItem -> RecipeDraft? in
                if let ingredient = viewModel.availableIngredients.first(where: { $0.id == recipeItem.ingredientId }) {
                    return RecipeDraft(ingredient: ingredient, qtyString: String(format: "%.1f", recipeItem.quantityRequired))
                }
                return nil
            }
        } else {
            selectedCategoryId = viewModel.categories.first?.id ?? ""
        }
    }

    private func saveProduct() {
        guard !isSaving else { return }
        let cleanPrice = productPrice.replacingOccurrences(of: ",", with: ".")
        guard let price = Double(cleanPrice) else { return }
        
        let finalRecipe = recipeDrafts.compactMap { draft -> RecipeItem? in
            guard let id = draft.ingredient.id, let qty = Double(draft.qtyString.replacingOccurrences(of: ",", with: ".")), qty > 0 else { return nil }
            return RecipeItem(ingredientId: id, quantityRequired: qty)
        }
        
        isSaving = true
        Task {
            if let edit = productToEdit {
                let updatedProduct = Product(id: edit.id, branchId: branchId, categoryId: selectedCategoryId, name: productName, price: price, recipe: finalRecipe, imageUrl: edit.imageUrl)
                await viewModel.updateProduct(product: updatedProduct, newImageData: selectedImageData)
            } else {
                await viewModel.createProduct(branchId: branchId, categoryId: selectedCategoryId, name: productName, price: price, recipe: finalRecipe, newImageData: selectedImageData)
            }
            isSaving = false
            dismiss()
        }
}

}

#Preview {
    AddEditProductView(viewModel: MasterDataViewModel(operationalProtocol: MockOperationalRepository()), branchId: "B-1")
}
