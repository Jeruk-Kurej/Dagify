import SwiftUI

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    let branchId: String // ✅ DITAMBAHKAN: Untuk mengetahui kita sedang di cabang mana

    @State private var productName = ""
    @State private var productPrice = ""

    var body: some View {
        // NavigationStack dihapus agar tidak terjadi double-navigation-bar
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Produk")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#6B7280"))
                    TextField("Cth: Kopi Susu Aren", text: $productName)
                        .font(.body)
                        .foregroundColor(Color(hex: "#111827"))
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Harga Jual (Rp)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#6B7280"))
                    TextField("Cth: 18000", text: $productPrice)
                        .keyboardType(.numberPad)
                        .font(.body)
                        .foregroundColor(Color(hex: "#111827"))
                }
                .padding(.vertical, 4)
            } header: {
                Text("Informasi Menu Baru")
            }

            Section {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(Color(hex: "#00A3A3"))
                    Text(
                        "Fitur integrasi resep & bahan baku otomatis akan segera hadir."
                    )
                    .font(.footnote)
                    .foregroundColor(Color(hex: "#6B7280"))
                }
                .padding(.vertical, 8)
            } header: {
                Text("Resep Bahan Baku")
            }

            Section {
                Button(action: saveProduct) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Simpan ke Database")
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .disabled(
                    productName.isEmpty || productPrice.isEmpty
                        || viewModel.isLoading
                )
                .listRowBackground(
                    (productName.isEmpty || productPrice.isEmpty)
                        ? Color(hex: "#E5E7EB")  // Disabled Color
                        : Color(hex: "#00A3A3")  // Primary Color
                )
                .foregroundColor(.white)
            }

            if let err = viewModel.errorMessage {
                Section {
                    Text(err)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#EF4444"))  // Destructive
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Tambah Menu")
        .listStyle(.insetGrouped)
        .background(Color(hex: "#F9FAFB").ignoresSafeArea())  // Main BG
        .scrollContentBackground(.hidden)
        .alert("Berhasil", isPresented: $viewModel.isSuccess) {
            Button("OK") {
                productName = ""
                productPrice = ""
            }
        } message: {
            Text("Produk berhasil ditambahkan ke menu Kasir.")
        }
    }

    private func saveProduct() {
        guard let price = Double(productPrice) else { return }
        Task {
            // ✅ DITAMBAHKAN: Mengirim branchId ke ViewModel
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
    let previewViewModel: MasterDataViewModel = {
        let repo = MockOperationalRepository()
        return MasterDataViewModel(operationalProtocol: repo)
    }()

    NavigationStack {
        // ✅ DITAMBAHKAN: Kirim Dummy branchId
        MasterDataView(viewModel: previewViewModel, branchId: "B-1")
    }
}

#Preview {
    let previewViewModel: MasterDataViewModel = {
        let repo = MockOperationalRepository()
        return MasterDataViewModel(operationalProtocol: repo)
    }()

    NavigationStack {
        MasterDataView(viewModel: previewViewModel)
    }
}
