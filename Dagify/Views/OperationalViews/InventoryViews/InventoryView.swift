import SwiftUI

// ✅ ENUM UNTUK POP-UP SHEET GUDANG
enum InventorySheetType: Identifiable {
    case add
    case edit(Ingredient)
    case detail(Ingredient)
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let i): return "edit_\(i.id ?? UUID().uuidString)"
        case .detail(let i): return "detail_\(i.id ?? UUID().uuidString)"
        }
    }
}

struct InventoryView: View {
    var viewModel: InventoryViewModel
    let branchId: String
    
    @State private var activeSheet: InventorySheetType? = nil
    
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
                                .contentShape(Rectangle())
                                .onTapGesture { activeSheet = .detail(item) } // KLIK: MUNCUL DETAIL
                                .contextMenu {                                // TAHAN (HOLD): MUNCUL EDIT & HAPUS
                                    Button { activeSheet = .edit(item) } label: { Label("Edit Bahan", systemImage: "pencil") }
                                    Button(role: .destructive) {
                                        if let id = item.id { Task { await viewModel.deleteIngredient(ingredientId: id, branchId: branchId) } }
                                    } label: { Label("Hapus Bahan", systemImage: "trash") }
                                }
                            }
                            ForEach(viewModel.lowStockIngredients, id: \.id) { item in
                                IngredientRowView(ingredient: item, isLowStock: true)
                                    .contentShape(Rectangle())
                                    .onTapGesture { activeSheet = .detail(item) }
                                    .contextMenu {
                                        Button { activeSheet = .edit(item) } label: { Label("Edit Bahan", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            if let id = item.id { Task { await viewModel.deleteIngredient(ingredientId: id, branchId: branchId) } }
                                        } label: { Label("Hapus Bahan", systemImage: "trash") }
                                    }
                            }
                        } header: {
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
                                    .contentShape(Rectangle())
                                    .onTapGesture { activeSheet = .detail(item) }
                                    .contextMenu {
                                        Button { activeSheet = .edit(item) } label: { Label("Edit Bahan", systemImage: "pencil") }
                                        Button(role: .destructive) {
                                            if let id = item.id { Task { await viewModel.deleteIngredient(ingredientId: id, branchId: branchId) } }
                                        } label: { Label("Hapus Bahan", systemImage: "trash") }
                                    }
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
                Button(action: { activeSheet = .add }) {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#00A3A3"))
                }
            }
        }
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .add:
                AddIngredientView(viewModel: viewModel, branchId: branchId)
            case .edit(let ingredient):
                AddIngredientView(viewModel: viewModel, branchId: branchId, ingredientToEdit: ingredient)
            case .detail(let ingredient):
                IngredientDetailView(ingredient: ingredient)
                    .presentationDetents([.medium, .large]) // Memungkinkan pop-up setengah layar
            }
        }
        .onAppear { Task { await viewModel.loadIngredients(branchId: branchId) } }
        .refreshable { await viewModel.loadIngredients(branchId: branchId) }
    }
}

// ✅ TAMPILAN DETAIL BAHAN BAKU (BARU)
struct IngredientDetailView: View {
    var ingredient: Ingredient
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informasi Utama")) {
                    LabeledContent("Nama Bahan", value: ingredient.name)
                    LabeledContent("Stok Gudang", value: "\(String(format: "%.1f", ingredient.currentStock)) \(ingredient.unit)")
                    LabeledContent("Harga Satuan", value: ingredient.costPerUnit.toRupiah())
                    LabeledContent("Estimasi Aset", value: (ingredient.currentStock * ingredient.costPerUnit).toRupiah())
                        .fontWeight(.bold)
                }
                Section(header: Text("Peringatan & Batas Waktu")) {
                    LabeledContent("Batas Stok Minim", value: "\(String(format: "%.1f", ingredient.minimumStockWarning)) \(ingredient.unit)")
                        .foregroundColor(.orange)
                    
                    if let expiry = ingredient.expiryDate {
                        LabeledContent("Tgl Kedaluwarsa", value: expiry.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(expiry < Date() ? .red : .primary)
                    } else {
                        LabeledContent("Tgl Kedaluwarsa", value: "Tidak Ada Batas")
                    }
                }
            }
            .navigationTitle("Detail Bahan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}
