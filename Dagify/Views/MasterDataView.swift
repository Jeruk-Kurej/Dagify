//
//  MasterDataView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 31-05-2026.
//

import SwiftUI

struct MasterDataView: View {
    @State private var viewModel = MasterDataViewModel(operationalProtocol: FirebaseOperationalService())
    
    @State private var ingredientName = ""
    @State private var selectedUnit = "gram"
    @State private var currentStock: Double = 0
    @State private var costPrice: Double = 0
    @State private var alertThreshold: Double = 0
    
    let units = ["gram", "ml", "pcs", "pack", "kg", "liter"]
    
    var body: some View {
        Form {
            Section(header: Text("Identitas Bahan Baku")) {
                TextField("Nama Bahan Baku (Misal: Gula Aren)", text: $ingredientName)
                
                Picker("Satuan Ukuran", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { Text($0) }
                }
            }
            
            Section(header: Text("Parameter Nilai & Batas Stok")) {
                HStack {
                    Text("Jumlah Stok Awal")
                    Spacer()
                    TextField("0", value: $currentStock, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Biaya HPP per Satuan (Rp)")
                    Spacer()
                    TextField("0", value: $costPrice, format: .number).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Batas Peringatan Minimum")
                    Spacer()
                    TextField("0", value: $alertThreshold, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            }
            
            if let error = viewModel.errorMessage {
                Section { Text(error).font(.caption).foregroundColor(.themeDestructive) }
            }
            
            Section {
                Button(action: {
                    Task {
                        await viewModel.createIngredient(name: ingredientName, currentStock: currentStock, unit: selectedUnit, expiryDate: nil, minimumStockWarning: alertThreshold, costPerUnit: costPrice)
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading { ProgressView().tint(.white) }
                        else { Text("Daftarkan ke Sistem Gudang").bold() }
                        Spacer()
                    }
                }
                .disabled(ingredientName.isEmpty || viewModel.isLoading)
                .foregroundColor(.white)
                .listRowBackground(ingredientName.isEmpty ? Color.themeBorder : Color.themePrimary)
            }
        }
        .navigationTitle("Input Master Data")
        .alert("Pemberitahuan", isPresented: $viewModel.isSuccess) {
            Button("OK", role: .cancel) {
                ingredientName = ""
                currentStock = 0
                costPrice = 0
                alertThreshold = 0
            }
        } message: { Text("Data material baru berhasil diunggah.") }
    }
}
#Preview {
    //MasterDataView()
}
