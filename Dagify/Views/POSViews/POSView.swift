import SwiftData
import SwiftUI

struct POSView: View {
    @Bindable var viewModel: POSViewModel
    @Environment(\.modelContext) private var context
    let branchId: String

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // --- AREA MENU GRID ---
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView("Menyiapkan mesin kasir...")
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if viewModel.availableProducts.isEmpty {
                        ContentUnavailableView(
                            "Menu Kosong",
                            systemImage: "square.grid.2x2",
                            description: Text(
                                "Silakan tambahkan menu di Master Data."
                            )
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.availableProducts) { product in
                                ProductCardView(product: product) {
                                    withAnimation(.spring) {
                                        viewModel.addToCart(product: product)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, viewModel.cart.isEmpty ? 20 : 100)  // Ruang untuk keranjang melayang
                    }
                }
                .background(Color.themeBgMain.ignoresSafeArea())

                // --- FLOATING CART BOTTOM BAR ---
                if !viewModel.cart.isEmpty {
                    VStack {
                        Button(action: {
                            // Eksekusi checkout langsung atau bisa buka Sheet Keranjang
                            Task {
                                await viewModel.checkout(
                                    branchId: branchId,
                                    context: context
                                )
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(
                                        "\(viewModel.cart.reduce(0){$0 + $1.quantity}) Item"
                                    )
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    Text(
                                        "Rp \(viewModel.subtotal, specifier: "%.0f")"
                                    )
                                    .font(.headline)
                                    .foregroundColor(.white)
                                }
                                Spacer()
                                HStack {
                                    Text("Bayar Sekarang")
                                        .fontWeight(.bold)
                                    Image(systemName: "creditcard.fill")
                                }
                                .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.themePrimary)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16,
                                    style: .continuous
                                )
                            )
                            .shadow(
                                color: Color.themePrimary.opacity(0.4),
                                radius: 10,
                                x: 0,
                                y: 5
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.themeBgMain.opacity(0), Color.themeBgMain,
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationTitle("Kasir (POS)")
            .onAppear {
                Task { await viewModel.loadProducts(branchId: branchId) }
            }
            .alert(
                "Transaksi Berhasil!",
                isPresented: $viewModel.isCheckoutSuccess
            ) {
                Button("OK", role: .cancel) {
                    viewModel.isCheckoutSuccess = false
                }
            } message: {
                Text(
                    "Pembayaran tercatat dan stok bahan baku terkait telah terpotong otomatis."
                )
            }
        }
    }
}

// MARK: - PREVIEW DENGAN DUMMY DATA LENGKAP
#Preview {
    let mockOp = MockOperationalRepository()
    let mockSync = MockSyncManager()
    let network = NetworkMonitor()

    // Suntik Dummy Products
    mockOp.dummyProducts = [
        Product(id: "1", name: "Es Kopi Susu Aren", price: 22000, recipe: []),
        Product(id: "2", name: "Americano Dingin", price: 18000, recipe: []),
        Product(id: "3", name: "Croissant Butter", price: 25000, recipe: []),
        Product(id: "4", name: "Matcha Latte", price: 28000, recipe: []),
    ]

    let vm = POSViewModel(
        operationalProtocol: mockOp,
        networkMonitor: network,
        syncManager: mockSync
    )

    // Inject SwiftData container bohongan untuk preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: OfflineOrderModel.self,
        configurations: config
    )

    return POSView(viewModel: vm, branchId: "B-1")
        .modelContainer(container)
}
