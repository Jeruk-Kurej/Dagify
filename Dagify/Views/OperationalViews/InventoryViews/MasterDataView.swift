import SwiftUI

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    
    @State private var showForm = false
    @State private var productToEdit: Product? = nil

    var body: some View {
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Memuat daftar menu...")
            } else if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "Menu Kosong",
                    systemImage: "takeoutbag.and.cup.and.straw",
                    description: Text("Silakan daftarkan menu F&B baru untuk Kasir.")
                )
            } else {
                List {
                    ForEach(viewModel.products) { product in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#111827"))
                                Text(String(format: "Rp %.0f", product.price))
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#00A3A3"))
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Text("\(product.recipe.count) Bahan")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#E5E7EB"))
                                .foregroundColor(Color(hex: "#6B7280"))
                                .clipShape(Capsule())
                        }
                        .contentShape(Rectangle()) // Memastikan seluruh area baris bisa dideteksi gesturnya
                        // ✅ UX HIG MODERN: Hold (Long Press) untuk memunculkan Context Menu
                        .contextMenu {
                            Button {
                                productToEdit = product
                                showForm = true
                            } label: {
                                Label("Edit Menu", systemImage: "pencil")
                            }
                            
                            // Tombol dengan role .destructive akan otomatis berwarna merah di iOS
                            Button(role: .destructive) {
                                if let id = product.id {
                                    Task {
                                        await viewModel.deleteProduct(productId: id, branchId: branchId)
                                    }
                                }
                            } label: {
                                Label("Hapus Menu", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Master Data")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    productToEdit = nil // Pastikan form kosong untuk mode Tambah Baru
                    showForm = true
                }) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadProducts(branchId: branchId)
                await viewModel.loadIngredients(branchId: branchId) // Siapkan data gudang untuk resep
            }
        }
        .refreshable {
            await viewModel.loadProducts(branchId: branchId)
        }
        .sheet(isPresented: $showForm) {
            AddEditProductView(
                viewModel: viewModel,
                branchId: branchId,
                productToEdit: productToEdit
            )
        }
    }
}

#Preview {
    let previewViewModel: MasterDataViewModel = {
        let repo = MockOperationalRepository()
        return MasterDataViewModel(operationalProtocol: repo)
    }()
    NavigationStack {
        MasterDataView(viewModel: previewViewModel, branchId: "B-1")
    }
}
