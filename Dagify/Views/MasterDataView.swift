//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    
    @State private var productName = ""
    @State private var productPrice = ""
    @State private var isShowingAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Informasi Menu Baru").foregroundColor(.themeTextPrimary)) {
                TextField("Nama Produk (Cth: Kopi Susu Aren)", text: $productName)
                    .foregroundColor(.themeTextPrimary)
                
                HStack {
                    Text("Rp").foregroundColor(.themeTextSecondary)
                    TextField("Harga Jual (Cth: 18000)", text: $productPrice)
                        .keyboardType(.numberPad)
                        .foregroundColor(.themeTextPrimary)
                }
            }
            
            Section(
                header: Text("Resep Bahan Baku").foregroundColor(.themeTextPrimary),
                footer: Text("Pilih bahan baku yang otomatis terpotong saat produk ini terjual.").foregroundColor(.themeTextSecondary)
            ) {
                Text("Fitur integrasi resep akan segera hadir.")
                    .italic()
                    .foregroundColor(.themeTextSecondary)
            }
            
            Section {
                Button(action: saveProduct) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Simpan Produk ke Database")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(productName.isEmpty || productPrice.isEmpty)
                .listRowBackground(productName.isEmpty || productPrice.isEmpty ? Color.themeBorder : Color.themePrimary)
                .foregroundColor(.white)
            }
            
            if let err = viewModel.errorMessage {
                Section {
                    Text(err).foregroundColor(.themeDestructive).font(.caption)
                }
            }
        }
        .navigationTitle("Tambah Master Data")
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
            await viewModel.createProduct(name: productName, price: price, recipe: [])
        }
    }
}

#Preview {
    //MasterDataView()
}
