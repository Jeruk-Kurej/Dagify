//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct MasterDataView: View {
    @Bindable var viewModel: MasterDataViewModel
    
    let storeId: String
    let branchId: String

    @State private var menuName = ""; @State private var menuPriceStr = ""
    @State private var ingName = ""; @State private var ingStockStr = ""; @State private var ingUnit = "kg"; @State private var ingCostStr = ""
    
    var body: some View {
        Form {
            Section(header: Text("Informasi Menu Baru")) {
                TextField("Nama Produk", text: $menuName)
                HStack { Text("Rp").foregroundColor(.themeTextSecondary); TextField("Harga Jual", text: $menuPriceStr).keyboardType(.numberPad) }
                Button(action: { Task { await viewModel.createProduct(name: menuName, priceString: menuPriceStr, storeId: storeId) } }) { Text("Simpan Menu").bold().frame(maxWidth: .infinity) }
                .foregroundColor(.white).listRowBackground(menuName.isEmpty || menuPriceStr.isEmpty ? Color.themeBorder : Color.themePrimary).disabled(menuName.isEmpty || menuPriceStr.isEmpty)
            }
            
            Section(header: Text("Informasi Bahan Baku Baru")) {
                TextField("Nama Bahan", text: $ingName)
                HStack { TextField("Stok Awal", text: $ingStockStr).keyboardType(.decimalPad); Divider(); TextField("Unit", text: $ingUnit) }
                HStack { Text("Rp").foregroundColor(.gray); TextField("Harga Modal", text: $ingCostStr).keyboardType(.numberPad) }
                Button(action: { Task { await viewModel.createIngredient(name: ingName, stockStr: ingStockStr, unit: ingUnit, costStr: ingCostStr, branchId: branchId) } }) { Text("Simpan ke Gudang").bold().frame(maxWidth: .infinity) }
                .foregroundColor(.white).listRowBackground(ingName.isEmpty || ingStockStr.isEmpty || ingCostStr.isEmpty ? Color.themeBorder : Color.themePrimary).disabled(ingName.isEmpty || ingStockStr.isEmpty || ingCostStr.isEmpty)
            }
            
            if let err = viewModel.errorMessage { Section { Text(err).foregroundColor(.themeDestructive).font(.caption) } }
        }.navigationTitle("Master Data").alert("Penyimpanan Berhasil!", isPresented: $viewModel.isSuccess) {
            Button("OK") { menuName = ""; menuPriceStr = ""; ingName = ""; ingStockStr = ""; ingCostStr = "" }
        }
    }
}

#Preview {
    //MasterDataView()
}
