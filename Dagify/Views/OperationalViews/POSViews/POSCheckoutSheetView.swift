import SwiftUI
import SwiftData

struct POSCheckoutSheetView: View {
    @Bindable var viewModel: POSViewModel
    let storeId: String // ✅ DITAMBAHKAN
    let branchId: String
    var context: ModelContext
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    // ✅ FORM CRM (PROFILING)
                    Section {
                        TextField("Nomor HP (Cth: 0812345...)", text: $viewModel.customerPhone)
                            .keyboardType(.phonePad)
                            .onChange(of: viewModel.customerPhone) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue { viewModel.customerPhone = filtered }
                            }
                        TextField("Nama Panggilan (Opsional)", text: $viewModel.customerName)
                    } header: { Text("Identitas Pelanggan (CRM)") }
                      footer: { Text("Isi No. HP agar sistem dapat melacak tingkat loyalitas dan preferensi pelanggan ini.") }

                    Section {
                        ForEach(viewModel.cart, id: \.product.id) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name).font(.body).fontWeight(.semibold).foregroundColor(.themeTextPrimary)
                                    Text(String(format: "Rp %.0f", item.product.price)).font(.subheadline).foregroundColor(.themePrimary)
                                }
                                Spacer()
                                HStack(spacing: 12) {
                                    Button(action: { withAnimation { viewModel.removeOrDecreaseFromCart(product: item.product) } }) {
                                        Image(systemName: "minus.circle.fill").font(.title2).foregroundColor(.themeDestructive.opacity(0.8))
                                    }
                                    Text("\(item.quantity)").font(.headline).frame(width: 24, alignment: .center)
                                    Button(action: { withAnimation { viewModel.addToCart(product: item.product) } }) {
                                        Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.themePrimary)
                                    }
                                }.buttonStyle(PlainButtonStyle())
                            }.padding(.vertical, 4)
                        }
                    } header: { Text("Rincian Pesanan") }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.themeBgMain)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Total Tagihan").font(.headline).foregroundColor(.themeTextSecondary)
                        Spacer()
                        Text(String(format: "Rp %.0f", viewModel.subtotal)).font(.title2).fontWeight(.bold).foregroundColor(.themeTextPrimary)
                    }
                    Button(action: {
                        Task {
                            await viewModel.checkout(storeId: storeId, branchId: branchId, context: context) // ✅ DIUPDATE
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Konfirmasi & Bayar").fontWeight(.bold) }
                            Spacer()
                        }
                        .padding().background(Color.themePrimary).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 16))
                    }.disabled(viewModel.isLoading)
                }.padding().background(Color.themeBgSecondary).shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
            .navigationTitle("Keranjang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { isPresented = false } } }
            .onChange(of: viewModel.cart.isEmpty) { oldValue, newValue in if newValue { isPresented = false } }
        }
    }
}
