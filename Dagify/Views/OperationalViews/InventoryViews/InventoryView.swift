import SwiftUI

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId: String
    
    @State private var showAddIngredient = false
    
    var body: some View {
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.ingredients.isEmpty {
                ProgressView("Memuat data gudang...")
            } else if viewModel.ingredients.isEmpty {
                ContentUnavailableView("Gudang Kosong", systemImage: "shippingbox", description: Text("Bahan baku belum ditambahkan."))
            } else {
                List {
                    if !viewModel.lowStockIngredients.isEmpty || !viewModel.expiredIngredients.isEmpty {
                        Section {
                            ForEach(viewModel.expiredIngredients, id: \.id) { item in
                                IngredientRowView(ingredient: item, isExpired: true) {
                                    Task { await viewModel.discardExpiredItem(ingredient: item, branchId: branchId) }
                                }
                            }
                            ForEach(viewModel.lowStockIngredients, id: \.id) { item in
                                IngredientRowView(ingredient: item, isLowStock: true)
                            }
                        } header: {
                            // ✅ UX FIX: Tambahan Legenda Ikon agar User Paham
                            VStack(alignment: .leading, spacing: 6) {
                                Text("PERHATIAN SEGERA").foregroundColor(Color(hex: "#EF4444")).fontWeight(.bold)
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) { Image(systemName: "trash.fill").foregroundColor(Color(hex: "#EF4444")); Text("Basi (Dapat Dibuang)") }
                                    HStack(spacing: 4) { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color(hex: "#F59E0B")); Text("Stok Minim") }
                                }
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .textCase(.none)
                            }
                        }
                    }
                    
                    Section {
                        ForEach(viewModel.ingredients, id: \.id) { item in
                            if !viewModel.lowStockIngredients.contains(where: { $0.id == item.id }) &&
                               !viewModel.expiredIngredients.contains(where: { $0.id == item.id }) {
                                IngredientRowView(ingredient: item)
                            }
                        }
                    } header: { Text("STOK AMAN") }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Gudang")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddIngredient = true }) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .sheet(isPresented: $showAddIngredient) {
            AddIngredientView(viewModel: viewModel, branchId: branchId)
        }
        .onAppear { Task { await viewModel.loadIngredients(branchId: branchId) } }
        .refreshable { await viewModel.loadIngredients(branchId: branchId) }
    }
}

#Preview {
    let previewViewModel: InventoryViewModel = {
        let mockOp = MockOperationalRepository()
        return InventoryViewModel(operationalProtocol: mockOp, cashflowProtocol: MockCashflowRepository())
    }()
    NavigationStack {
        InventoryView(viewModel: previewViewModel, branchId: "B-1")
    }
}
