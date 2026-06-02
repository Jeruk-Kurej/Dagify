import SwiftUI

// ✅ ENUM UNTUK SHEET NAVIGATION YANG SOLID (Mengatasi Bug SwiftUI)
enum MasterDataSheet: Identifiable {
    case add
    case edit(Product)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let product): return product.id ?? UUID().uuidString
        }
    }
}

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    
    // ✅ Menggabungkan Add dan Edit ke dalam 1 variabel State agar SwiftUI tidak bingung
    @State private var activeSheet: MasterDataSheet? = nil

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
                                // ✅ Panggil mode Edit
                                activeSheet = .edit(product)
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
                    activeSheet = .add // ✅ Panggil mode Add
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
        // ✅ SATU SHEET UNTUK SEMUA: Mencegah bug salah memanggil pop-up edit/tambah
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .add:
                AddEditProductView(
                    viewModel: viewModel,
                    branchId: branchId,
                    productToEdit: nil
                )
            case .edit(let product):
                AddEditProductView(
                    viewModel: viewModel,
                    branchId: branchId,
                    productToEdit: product
                )
            }
        }
    }
}
