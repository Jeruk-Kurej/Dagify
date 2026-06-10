//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

enum MasterDataSheet: Identifiable {
    case add
    case edit(Product)
    case manageCategories
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let product): return product.id ?? UUID().uuidString
        case .manageCategories: return "categories"
        }
    }
}

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
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
                        HStack(spacing: 16) {
                            if let urlStr = product.imageUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color(hex: "#E5E7EB")
                                }
                                .frame(width: 50, height: 50).clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "cup.and.saucer.fill").resizable().scaledToFit().frame(width: 25, height: 25).foregroundColor(.gray).frame(width: 50, height: 50).background(Color(hex: "#E5E7EB")).clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name).font(.headline).foregroundColor(Color(hex: "#111827"))
                                Text(product.price.toRupiah()).font(.subheadline).foregroundColor(Color(hex: "#00A3A3")).fontWeight(.bold)
                            }
                            Spacer()
                            Text("\(product.recipe.count) Bahan").font(.caption).padding(.horizontal, 8).padding(.vertical, 4).background(Color(hex: "#E5E7EB")).foregroundColor(Color(hex: "#6B7280")).clipShape(Capsule())
                        }
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button { activeSheet = .edit(product) } label: { Label("Edit Menu", systemImage: "pencil") }
                            Button(role: .destructive) {
                                if let id = product.id { Task { await viewModel.deleteProduct(productId: id, branchId: branchId) } }
                            } label: { Label("Hapus Menu", systemImage: "trash") }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity, alignment: .top)
                .overlay(alignment: .bottom) {
                    if let err = viewModel.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Master Data")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Tambah Menu Baru", systemImage: "plus.app.fill") { activeSheet = .add }
                    Button("Kelola Kategori", systemImage: "tag.fill") { activeSheet = .manageCategories }
                } label: {
                    Image(systemName: "ellipsis.circle").fontWeight(.bold).foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .onAppear { Task { await viewModel.loadProducts(branchId: branchId); await viewModel.loadIngredients(branchId: branchId); await viewModel.loadCategories(branchId: branchId) } }
        .refreshable { await viewModel.loadProducts(branchId: branchId) }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .add: AddEditProductView(viewModel: viewModel, branchId: branchId, productToEdit: nil)
            case .edit(let product): AddEditProductView(viewModel: viewModel, branchId: branchId, productToEdit: product)
            case .manageCategories: CategoryManagerView(viewModel: viewModel, branchId: branchId)
            }
        }
    }
}


