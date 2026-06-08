//
//  POSCheckoutSheetView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import SwiftData
import SwiftUI

struct POSCheckoutSheetView: View {
    @Bindable var viewModel: POSViewModel
    let storeId: String
    let branchId: String
    var context: ModelContext
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField(
                                "Nomor HP (Cth: 0812345...)",
                                text: $viewModel.customerPhone
                            )
                            .keyboardType(.phonePad)
                            .onChange(of: viewModel.customerPhone) {
                                oldValue,
                                newValue in
                                let filtered = newValue.filter {
                                    "0123456789".contains($0)
                                }
                                if filtered != newValue {
                                    viewModel.customerPhone = filtered
                                }
                            }

                            if !viewModel.suggestedCustomers.isEmpty {
                                Divider().padding(.vertical, 8)
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(
                                            viewModel.suggestedCustomers,
                                            id: \.id
                                        ) { cust in
                                            Button(action: {
                                                withAnimation {
                                                    viewModel.selectCustomer(
                                                        cust
                                                    )
                                                }
                                            }) {
                                                HStack {
                                                    Image(
                                                        systemName:
                                                            "magnifyingglass"
                                                    )
                                                    Text(cust.phoneNumber)
                                                        .fontWeight(.bold)
                                                    Text("- \(cust.name)")
                                                        .foregroundColor(.gray)
                                                    Spacer()
                                                }
                                            }
                                            .foregroundColor(
                                                Color(hex: "#00A3A3")
                                            )
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .frame(maxHeight: 120)
                            }
                        }

                        TextField(
                            "Nama Panggilan (Opsional)",
                            text: $viewModel.customerName
                        )
                    } header: {
                        Text("Identitas Pelanggan (CRM)")
                    } footer: {
                        Text(
                            "Isi No. HP agar sistem dapat melacak tingkat loyalitas dan preferensi pelanggan ini."
                        )
                    }

                    Section {
                        ForEach(viewModel.cart, id: \.product.id) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name).font(.body)
                                        .fontWeight(.semibold).foregroundColor(
                                            .themeTextPrimary
                                        )
                                    Text(item.product.price.toRupiah()).font(
                                        .subheadline
                                    ).foregroundColor(.themePrimary)
                                }
                                Spacer()
                                HStack(spacing: 12) {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.removeOrDecreaseFromCart(
                                                product: item.product
                                            )
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2).foregroundColor(
                                                .themeDestructive.opacity(0.8)
                                            )
                                    }
                                    Text("\(item.quantity)").font(.headline)
                                        .frame(width: 24, alignment: .center)
                                    Button(action: {
                                        withAnimation {
                                            viewModel.addToCart(
                                                product: item.product
                                            )
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2).foregroundColor(
                                                .themePrimary
                                            )
                                    }
                                }.buttonStyle(PlainButtonStyle())
                            }.padding(.vertical, 4)
                        }
                    } header: {
                        Text("Rincian Pesanan")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.themeBgMain)

                VStack(spacing: 16) {
                    HStack {
                        Text("Total Tagihan").font(.headline).foregroundColor(
                            .themeTextSecondary
                        )
                        Spacer()
                        Text(viewModel.subtotal.toRupiah()).font(.title2)
                            .fontWeight(.bold).foregroundColor(
                                .themeTextPrimary
                            )
                    }
                    Button(action: {
                        Task {
                            await viewModel.checkout(
                                storeId: storeId,
                                branchId: branchId,
                                context: context
                            )
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Konfirmasi & Bayar").fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding().background(Color.themePrimary)
                        .foregroundColor(.white).clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }.disabled(viewModel.isLoading)
                }.padding().background(Color.themeBgSecondary).shadow(
                    color: Color.black.opacity(0.05),
                    radius: 10,
                    x: 0,
                    y: -5
                )
            }
            .navigationTitle("Keranjang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { isPresented = false }
                }
            }
            .onChange(of: viewModel.cart.isEmpty) { oldValue, newValue in
                if newValue { isPresented = false }
            }
            .onAppear {
                Task {
                    await viewModel.loadCustomersForSuggestions(
                        storeId: storeId
                    )
                }
            }
            /// Alert when ingredient stock is empty during addition from pop-up.
            .alert(
                "Peringatan!",
                isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("Mengerti", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
