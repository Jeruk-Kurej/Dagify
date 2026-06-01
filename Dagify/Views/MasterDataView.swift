//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    @State private var menuName = ""; @State private var menuPriceStr = ""
    
    var body: some View {
        Form {
            Section(header: Text("Informasi Menu")) {
                TextField("Nama Produk", text: $menuName)
                HStack { Text("Rp").foregroundColor(.gray); TextField("Harga Jual", text: $menuPriceStr).keyboardType(.numberPad) }
            }
            Section {
                Button(action: { Task { await viewModel.createProduct(name: menuName, priceString: menuPriceStr, storeId: "S-1") } }) {
                    Text("Simpan Database").bold().frame(maxWidth: .infinity)
                }.foregroundColor(.white).listRowBackground(menuName.isEmpty || menuPriceStr.isEmpty ? Color.themeBorder : Color.themePrimary).disabled(menuName.isEmpty || menuPriceStr.isEmpty)
            }
            if let err = viewModel.errorMessage { Section { Text(err).foregroundColor(.themeDestructive).font(.caption) } }
        }.navigationTitle("Master Data").alert("Berhasil", isPresented: $viewModel.isSuccess) { Button("OK") { menuName = ""; menuPriceStr = "" } }
    }
}

#Preview {
    //MasterDataView()
}
