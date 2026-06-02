import SwiftUI

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId: String

    var body: some View {
        // ✅ NavigationStack dihapus
        ZStack {
            Color(hex: "#F9FAFB").ignoresSafeArea()

            if viewModel.isLoading && viewModel.ingredients.isEmpty {
                ProgressView("Memuat data gudang...")
            } else if viewModel.ingredients.isEmpty {
                ContentUnavailableView(
                    "Gudang Kosong",
                    systemImage: "shippingbox",
                    description: Text("Bahan baku belum ditambahkan.")
                )
            } else {
                List {
                    if !viewModel.lowStockIngredients.isEmpty
                        || !viewModel.expiredIngredients.isEmpty
                    {
                        Section {
                            ForEach(viewModel.expiredIngredients, id: \.id) {
                                item in
                                IngredientRowView(
                                    ingredient: item,
                                    isExpired: true
                                ) {
                                    Task {
                                        await viewModel.discardExpiredItem(
                                            ingredient: item,
                                            branchId: branchId
                                        )
                                    }
                                }
                            }
                            ForEach(viewModel.lowStockIngredients, id: \.id) {
                                item in
                                IngredientRowView(
                                    ingredient: item,
                                    isLowStock: true
                                )
                            }
                        } header: {
                            Text("PERHATIAN SEGERA").foregroundColor(
                                Color(hex: "#EF4444")
                            ).fontWeight(.bold)
                        }
                    }

                    Section {
                        ForEach(viewModel.ingredients, id: \.id) { item in
                            if !viewModel.lowStockIngredients.contains(where: {
                                $0.id == item.id
                            })
                                && !viewModel.expiredIngredients.contains(
                                    where: { $0.id == item.id })
                            {
                                IngredientRowView(ingredient: item)
                            }
                        }
                    } header: {
                        Text("STOK AMAN")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Gudang")
        .onAppear {
            Task { await viewModel.loadIngredients(branchId: branchId) }
        }
        .refreshable { await viewModel.loadIngredients(branchId: branchId) }
    }
}

#Preview {
    let previewViewModel: InventoryViewModel = {
        let mockOp = MockOperationalRepository()
        let pastDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Date()
        )
        mockOp.dummyIngredients = [
            Ingredient(
                id: "1",
                name: "Gula Aren",
                currentStock: 50,
                unit: "Kg",
                expiryDate: nil,
                minimumStockWarning: 10,
                costPerUnit: 20000
            ),
            Ingredient(
                id: "3",
                name: "Roti",
                currentStock: 10,
                unit: "Pcs",
                expiryDate: pastDate,
                minimumStockWarning: 20,
                costPerUnit: 5000
            ),
        ]
        return InventoryViewModel(
            operationalProtocol: mockOp,
            cashflowProtocol: MockCashflowRepository()
        )
    }()

    NavigationStack {
        InventoryView(viewModel: previewViewModel, branchId: "B-1")
    }
}
