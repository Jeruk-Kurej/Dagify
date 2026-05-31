//
//  POSView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct POSView: View {
    var viewModel: POSViewModel
    @Environment(\.modelContext) private var context
    let branchId: String
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Menyiapkan mesin kasir...").frame(maxHeight: .infinity)
            } else {
                List(viewModel.availableProducts) { product in
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name).font(.headline).foregroundColor(.themeTextPrimary)
                            Text("Rp \(product.price, specifier: "%.0f")").font(.subheadline).foregroundColor(.themeTextSecondary)
                        }
                        Spacer()
                        
                        if let itemInCart = viewModel.cart.first(where: { $0.product.id == product.id }) {
                            HStack(spacing: 12) {
                                Button(action: { viewModel.removeOrDecreaseFromCart(product: product) }) {
                                    Image(systemName: "minus.circle.fill").font(.title3).foregroundColor(.themeDestructive)
                                }
                                Text("\(itemInCart.quantity)").font(.headline).foregroundColor(.themeTextPrimary).frame(width: 24, alignment: .center)
                                Button(action: { viewModel.addToCart(product: product) }) {
                                    Image(systemName: "plus.circle.fill").font(.title3).foregroundColor(.themePrimary)
                                }
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button(action: { viewModel.addToCart(product: product) }) {
                                Label("Tambah", systemImage: "cart.badge.plus")
                                    .font(.subheadline).bold().padding(.vertical, 6).padding(.horizontal, 12)
                                    .background(Color.themePrimary.opacity(0.1)).foregroundColor(.themePrimary).cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            
            VStack(spacing: 16) {
                Divider()
                HStack {
                    Text("Total (\(viewModel.cart.reduce(0){$0 + $1.quantity}) Item)").font(.body).foregroundColor(.themeTextSecondary)
                    Spacer()
                    Text("Rp \(viewModel.subtotal, specifier: "%.0f")").font(.title2).bold().foregroundColor(.themeTextPrimary)
                }
                
                Button(action: { Task { await viewModel.checkout(branchId: branchId, context: context) } }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("Selesaikan Transaksi (Checkout)").bold()
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(viewModel.cart.isEmpty ? Color.themeBorder : Color.themePrimary)
                    .foregroundColor(.white).cornerRadius(12)
                }
                .disabled(viewModel.cart.isEmpty)
            }
            .padding().background(Color.themeBgSecondary)
        }
        .navigationTitle("Kasir (POS)")
        .onAppear { Task { await viewModel.loadProducts(branchId: branchId) } }
        .alert("Status Transaksi", isPresented: .constant(viewModel.isCheckoutSuccess)) {
            Button("Tutup", role: .cancel) { viewModel.isCheckoutSuccess = false }
        } message: { Text("Pembayaran berhasil, stok terkait telah terpotong otomatis.") }
    }
}

#Preview {
    //POSView()
}
