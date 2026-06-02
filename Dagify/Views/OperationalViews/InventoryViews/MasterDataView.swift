import SwiftUI

// ✅ WRAPPER SOLID: Memastikan SwiftUI tidak bingung saat melempar data ke layar Pop-up
struct ProductEditWrapper: Identifiable {
    let id = UUID()
    let product: Product
}

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    
    // ✅ DIPISAH: Pintu masuk untuk Tambah dan Edit tidak lagi menggunakan variabel yang sama
    @State private var showAddForm = false
    @State private var productToEdit: ProductEditWrapper? = nil

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
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button {
                                // ✅ Menggunakan Wrapper agar data dijamin masuk ke Pop-up
                                productToEdit = ProductEditWrapper(product: product)
                            } label: {
                                Label("Edit Menu", systemImage: "pencil")
                            }
                            
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
                    showAddForm = true // ✅ Membuka pintu khusus Tambah
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
                await viewModel.loadIngredients(branchId: branchId)
            }
        }
        .refreshable {
            await viewModel.loadProducts(branchId: branchId)
        }
        // ✅ SHEET 1: KHUSUS UNTUK TAMBAH BARU
        .sheet(isPresented: $showAddForm) {
            AddEditProductView(
                viewModel: viewModel,
                branchId: branchId,
                productToEdit: nil
            )
        }
        // ✅ SHEET 2: KHUSUS UNTUK EDIT (Sistem akan membuat ulang UI dengan data yang benar)
        .sheet(item: $productToEdit) { wrapper in
            AddEditProductView(
                viewModel: viewModel,
                branchId: branchId,
                productToEdit: wrapper.product
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
