//
//  POSView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct POSView: View {
    var viewModel: POSViewModel
    var crmViewModel: CRMViewModel
    let branchId: String
    let storeId: String
    @State private var showCheckoutSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading { ProgressView("Menyiapkan Kasir...").frame(maxHeight: .infinity) }
            else if viewModel.availableProducts.isEmpty { ContentUnavailableView("Tidak Ada Menu", systemImage: "cup.and.saucer") }
            else {
                List(viewModel.availableProducts) { product in
                    HStack {
                        VStack(alignment: .leading) { Text(product.name).font(.headline); Text("Rp \(product.price, specifier: "%.0f")").font(.subheadline) }
                        Spacer()
                        if let itemInCart = viewModel.cart.first(where: { $0.product.id == product.id }) {
                            HStack {
                                Button(action: { viewModel.removeOrDecreaseFromCart(product: product) }) { Image(systemName: "minus.circle.fill").foregroundColor(.themeDestructive) }
                                Text("\(itemInCart.quantity)").font(.headline).frame(width: 24)
                                Button(action: { viewModel.addToCart(product: product) }) { Image(systemName: "plus.circle.fill").foregroundColor(.themePrimary) }
                            }.buttonStyle(.plain)
                        } else {
                            Button(action: { viewModel.addToCart(product: product) }) { Label("Tambah", systemImage: "cart.badge.plus").padding(6).background(Color.themePrimary.opacity(0.1)).foregroundColor(.themePrimary).cornerRadius(8) }.buttonStyle(.plain)
                        }
                    }
                }.listStyle(.plain)
            }
            
            VStack(spacing: 16) {
                Divider()
                HStack { Text("Total (\(viewModel.totalCartItems) Item)").foregroundColor(.gray); Spacer(); Text("Rp \(viewModel.subtotal, specifier: "%.0f")").font(.title2).bold() }
                Button(action: { showCheckoutSheet = true }) {
                    HStack { Image(systemName: "creditcard.fill"); Text("Lanjutkan ke Pembayaran").bold() }.frame(maxWidth: .infinity).padding().background(viewModel.isCartEmpty ? Color.themeBorder : Color.themePrimary).foregroundColor(.white).cornerRadius(12)
                }.disabled(viewModel.isCartEmpty)
            }.padding().background(Color.themeBgSecondary)
        }
        .navigationTitle("Kasir").onAppear { Task { await viewModel.loadProducts(branchId: branchId) } }
        .sheet(isPresented: $showCheckoutSheet) { CheckoutSheetView(posVM: viewModel, crmVM: crmViewModel, storeId: storeId, branchId: branchId) }
        .alert("Sukses", isPresented: $viewModel.isCheckoutSuccess) { Button("OK", role: .cancel) { viewModel.isCheckoutSuccess = false } }
    }
}

#Preview {
    //POSView()
}
