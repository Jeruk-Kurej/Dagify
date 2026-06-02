import SwiftUI

struct RecipeDraft: Identifiable {
    let id = UUID()
    var ingredient: Ingredient
    var qtyString: String
}

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String

    @State private var productName = ""
    @State private var productPrice = ""
    
    @State private var recipeDrafts: [RecipeDraft] = []
    @State private var showIngredientPicker = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Produk").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                    TextField("Cth: Kopi Susu Aren", text: $productName).font(.body)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Harga Jual (Rp)").font(.caption).foregroundColor(Color(hex: "#6B7280"))
                    TextField("Cth: 18000", text: $productPrice).keyboardType(.numberPad).font(.body)
                }
                .padding(.vertical, 4)
            } header: { Text("Informasi Menu Baru") }

            Section {
                ForEach($recipeDrafts) { $draft in
                    HStack {
                        Text(draft.ingredient.name)
                            .font(.body)
                            .foregroundColor(Color(hex: "#111827"))
                        Spacer()
                        TextField("Takaran", text: $draft.qtyString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .foregroundColor(Color(hex: "#00A3A3"))
                            .fontWeight(.bold)
                        Text(draft.ingredient.unit)
                            .font(.caption)
                            .foregroundColor(Color(hex: "#6B7280"))
                        
                        Button(action: {
                            recipeDrafts.removeAll { $0.id == draft.id }
                        }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(Color(hex: "#EF4444"))
                        }
                        .padding(.leading, 8)
                    }
                }
                
                Button(action: { showIngredientPicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(recipeDrafts.isEmpty ? "Buat Resep Menu" : "Tambah Bahan Baku")
                    }
                    .foregroundColor(Color(hex: "#00A3A3"))
                    .fontWeight(.semibold)
                }
            } header: {
                Text("Resep Bahan Baku (Opsional)")
            } footer: {
                Text("Bahan baku ini akan otomatis dipotong dari Gudang setiap kali menu ini terjual di Kasir (POS).")
            }

            Section {
                Button(action: saveProduct) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Simpan ke Database").fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .disabled(productName.isEmpty || productPrice.isEmpty || viewModel.isLoading)
                .listRowBackground((productName.isEmpty || productPrice.isEmpty) ? Color(hex: "#E5E7EB") : Color(hex: "#00A3A3"))
                .disabled(
                    productName.isEmpty || productPrice.isEmpty
                        || viewModel.isLoading
                )
                .listRowBackground(
                    (productName.isEmpty || productPrice.isEmpty)
                        ? Color(hex: "#E5E7EB")
                        : Color(hex: "#00A3A3")
                )
                .foregroundColor(.white)
            }

            if let err = viewModel.errorMessage {
                Section { Text(err).font(.footnote).foregroundColor(Color(hex: "#EF4444")) }.listRowBackground(Color.clear)
                Section {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#EF4444"))
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Tambah Menu")
        .listStyle(.insetGrouped)
        .background(Color(hex: "#F9FAFB").ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .onAppear {
            Task { await viewModel.loadIngredients(branchId: branchId) }
        }
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
                                .font(.caption)
                                .foregroundColor(Color(hex: "#6B7280"))
                        }
                    }
                }
                .navigationTitle("Pilih Bahan Baku")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Tutup") { showIngredientPicker = false }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Berhasil", isPresented: $viewModel.isSuccess) {
            Button("OK") {
                productName = ""
                productPrice = ""
                recipeDrafts.removeAll()
            }
        } message: { Text("Produk & Resep berhasil disimpan.") }
    }

    private func saveProduct() {
        guard let price = Double(productPrice) else { return }
        
        let finalRecipe = recipeDrafts.compactMap { draft -> RecipeItem? in
            guard let id = draft.ingredient.id,
                  let qty = Double(draft.qtyString.replacingOccurrences(of: ",", with: ".")),
                  qty > 0 else { return nil }
            return RecipeItem(ingredientId: id, quantityRequired: qty)
        }
        
        Task {
            await viewModel.createProduct(branchId: branchId, name: productName, price: price, recipe: finalRecipe)
            await viewModel.createProduct(
                branchId: branchId,
                name: productName,
                price: price,
                recipe: []
            )
        }
    }
}

#Preview {
    MasterDataView(viewModel: MasterDataViewModel(operationalProtocol: MockOperationalRepository()), branchId: "B-1")
    let previewViewModel: MasterDataViewModel = {
        let repo = MockOperationalRepository()
        return MasterDataViewModel(operationalProtocol: repo)
    }()

    NavigationStack {
        MasterDataView(viewModel: previewViewModel, branchId: "B-1")
    }
}
