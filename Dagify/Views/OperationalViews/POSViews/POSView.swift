import SwiftData
import SwiftUI

struct POSView: View {
    @Bindable var viewModel: POSViewModel
    @Environment(\.modelContext) private var context
    let branchId: String
    
    // ✅ STATE BARU: Mengontrol kemunculan pop up keranjang
    @State private var showCheckoutSheet = false

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("Menyiapkan mesin kasir...")
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if viewModel.availableProducts.isEmpty {
                    ContentUnavailableView(
                        "Menu Kosong",
                        systemImage: "square.grid.2x2",
                        description: Text("Silakan tambahkan menu di Master Data.")
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.availableProducts) { product in
                            // ✅ AMBIL KUANTITAS DARI KERANJANG SECARA REAL-TIME
                            let quantity = viewModel.cart.first(where: { $0.product.id == product.id })?.quantity ?? 0
                            
                            ProductCardView(
                                product: product,
                                quantity: quantity,
                                onAdd: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.addToCart(product: product)
                                    }
                                },
                                onDecrease: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.removeOrDecreaseFromCart(product: product)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .padding(.bottom, viewModel.cart.isEmpty ? 20 : 100)
                }
            }
            .background(Color.themeBgMain.ignoresSafeArea())

            // --- FLOATING CART BOTTOM BAR ---
            if !viewModel.cart.isEmpty {
                VStack {
                    Button(action: {
                        // ✅ TAMPILKAN POP UP (SHEET) ALIH-ALIH LANGSUNG CHECKOUT
                        showCheckoutSheet = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(viewModel.cart.reduce(0){$0 + $1.quantity}) Item")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Rp \(viewModel.subtotal, specifier: "%.0f")")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            HStack {
                                Text("Bayar Sekarang").fontWeight(.bold)
                                Image(systemName: "chevron.right") // ✅ Panah visualisasi buka pop-up
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.themePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.themePrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.themeBgMain.opacity(0),
                            Color.themeBgMain,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                // Animasi muncul dari bawah
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Kasir (POS)")
        .onAppear {
            Task { await viewModel.loadProducts(branchId: branchId) }
        }
        .alert("Transaksi Berhasil!", isPresented: $viewModel.isCheckoutSuccess) {
            Button("OK", role: .cancel) { viewModel.isCheckoutSuccess = false }
        } message: {
            Text("Pembayaran tercatat dan stok bahan baku terkait telah terpotong otomatis.")
        }
        // ✅ PASANG SHEET POP-UP DI SINI
        .sheet(isPresented: $showCheckoutSheet) {
            POSCheckoutSheetView(
                viewModel: viewModel,
                branchId: branchId,
                context: context,
                isPresented: $showCheckoutSheet
            )
            .presentationDetents([.fraction(0.85), .large]) // Sheet bergaya menutupi 85% layar
        }
    }
}

// ... (Scroll ke paling bawah, cari bagian #Preview dan ganti isinya dengan ini) ...

//#Preview {
//    let mockOp = MockOperationalRepository()
//    let mockCash = MockCashflowRepository() // ✅ DITAMBAHKAN
//    let mockSync = MockSyncManager()
//    let network = NetworkMonitor()
//
//    mockOp.dummyProducts = [
//        Product(id: "1", branchId: "B-1", name: "Es Kopi Susu Aren", price: 22000, recipe: []),
//        Product(id: "2", branchId: "B-1", name: "Americano Dingin", price: 18000, recipe: [])
//    ]
//
//    let vm = POSViewModel(
//        operationalProtocol: mockOp,
//        cashflowProtocol: mockCash, 
//        networkMonitor: network,
//        syncManager: mockSync
//    )
//    
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: OfflineOrderModel.self, configurations: config)
//
//    NavigationStack {
//        POSView(viewModel: vm, branchId: "B-1")
//            .modelContainer(container)
//    }
//}
