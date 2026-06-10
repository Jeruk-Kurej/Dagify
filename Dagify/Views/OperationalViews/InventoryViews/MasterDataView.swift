//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 08-06-2026.
//

import SwiftUI

enum MasterDataSheet: Identifiable {
    case manageCategories
    var id: String {
        switch self {
        case .manageCategories: return "categories"
        }
    }
}

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    @State private var activeSheet: MasterDataSheet? = nil
    @State private var selectedCategoryId: String? = nil
    @State private var navigateToAddProduct: Bool = false
    @State private var navigateToEditProduct: Product? = nil

    var body: some View {
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("Memuat daftar menu...")
            } else {
                VStack(spacing: 0) {
                    if !viewModel.categories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: { selectedCategoryId = nil }) {
                                    Text("Semua")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCategoryId == nil ? Color(hex: "#00A3A3") : Color.gray.opacity(0.1))
                                        .foregroundColor(selectedCategoryId == nil ? .white : .black)
                                        .clipShape(Capsule())
                                }
                                
                                ForEach(viewModel.categories) { cat in
                                    Button(action: { selectedCategoryId = cat.id }) {
                                        Text(cat.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategoryId == cat.id ? Color(hex: "#00A3A3") : Color.gray.opacity(0.1))
                                            .foregroundColor(selectedCategoryId == cat.id ? .white : .black)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                        .background(Color.white)
                        Divider()
                    }

                    if viewModel.products.isEmpty {
                        ContentUnavailableView(
                            "Menu Kosong",
                            systemImage: "takeoutbag.and.cup.and.straw",
                            description: Text("Silakan daftarkan menu F&B baru untuk Kasir.")
                        )
                    } else {
                        List {
                            let filteredProducts = selectedCategoryId == nil ? viewModel.products : viewModel.products.filter { $0.categoryId == selectedCategoryId }
                            
                            if filteredProducts.isEmpty {
                                ContentUnavailableView("Tidak ada menu", systemImage: "tray", description: Text("Belum ada menu di kategori ini."))
                            } else {
                                ForEach(filteredProducts) { product in
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
                                        Button { navigateToEditProduct = product } label: { Label("Edit Menu", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            if let id = product.id { Task { await viewModel.deleteProduct(productId: id, branchId: branchId) } }
                                        } label: { Label("Hapus Menu", systemImage: "trash") }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .frame(maxWidth: 800)
                        .frame(maxWidth: .infinity, alignment: .top)
                    }
                }
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
                    Button("Tambah Menu Baru", systemImage: "plus.app.fill") { navigateToAddProduct = true }
                    Button("Kelola Kategori", systemImage: "tag.fill") { activeSheet = .manageCategories }
                } label: {
                    Image(systemName: "ellipsis.circle").fontWeight(.bold).foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .onAppear { Task { await viewModel.loadProducts(branchId: branchId); await viewModel.loadIngredients(branchId: branchId); await viewModel.loadCategories(branchId: branchId) } }
        .refreshable { await viewModel.loadProducts(branchId: branchId) }
        .navigationDestination(isPresented: $navigateToAddProduct) {
            AddEditProductView(viewModel: viewModel, branchId: branchId, productToEdit: nil)
        }
        .navigationDestination(item: $navigateToEditProduct) { product in
            AddEditProductView(viewModel: viewModel, branchId: branchId, productToEdit: product)
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .manageCategories: CategoryManagerView(viewModel: viewModel, branchId: branchId)
            }
        }
    }
}


