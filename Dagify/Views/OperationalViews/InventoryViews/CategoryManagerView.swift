import SwiftUI

struct CategoryManagerView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String
    @Environment(\.dismiss) private var dismiss
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Tambah Kategori Baru") {
                    HStack {
                        TextField("Ketik nama kategori...", text: $newCategoryName)
                        Button("Tambah") {
                            Task {
                                await viewModel.createCategory(branchId: branchId, name: newCategoryName)
                                newCategoryName = ""
                            }
                        }.disabled(newCategoryName.isEmpty || viewModel.isLoading)
                    }
                }
                Section("Daftar Kategori") {
                    ForEach(viewModel.categories) { cat in
                        Text(cat.name)
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task { await viewModel.deleteCategory(categoryId: cat.id ?? "", branchId: branchId) }
                                } label: { Label("Hapus", systemImage: "trash") }
                            }
                    }
                }
            }
            .navigationTitle("Kelola Kategori")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { dismiss() } } }
            .overlay(alignment: .bottom) {
                if let err = viewModel.errorMessage {
                    Text(err).font(.caption).foregroundColor(.white).padding().background(Color.red).cornerRadius(10).padding(.bottom, 20)
                }
            }
        }
    }
}

#Preview {
    let mockViewModel = MasterDataViewModel(operationalProtocol: MockOperationalRepository())
    return CategoryManagerView(viewModel: mockViewModel, branchId: "B-1")
}
