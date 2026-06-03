import SwiftData
import SwiftUI

struct POSView: View {
    @Bindable var viewModel: POSViewModel
    @Environment(\.modelContext) private var context
    let storeId: String
    let branchId: String
    
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
                            ProductCardView(
                                product: product,
                                quantity: viewModel.getCartQuantity(for: product),
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
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())

            if !viewModel.cart.isEmpty {
                VStack {
                    Button(action: {
                        showCheckoutSheet = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(viewModel.cart.reduce(0){$0 + $1.quantity}) Item")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(viewModel.subtotal.toRupiah())
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            HStack {
                                Text("Bayar Sekarang").fontWeight(.bold)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "#00A3A3"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(hex: "#00A3A3").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    .frame(maxWidth: 600)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#F9FAFB").opacity(0),
                            Color(hex: "#F9FAFB")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
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
        /// Alert when ingredient stock is empty.
        .alert("Peringatan!", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Mengerti", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .popover(isPresented: $showCheckoutSheet) {
            POSCheckoutSheetView(
                viewModel: viewModel,
                storeId: storeId,
                branchId: branchId,
                context: context,
                isPresented: $showCheckoutSheet
            )
            .presentationDetents([.fraction(0.85), .large])
        }
    }
}

