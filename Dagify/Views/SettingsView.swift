//
//  SettingsView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct SettingsView: View {
    var authViewModel: AuthViewModel
    var operationalService: OperationalProtocol
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Toko & Gudang")) {
                    NavigationLink(destination: MasterDataView(viewModel: MasterDataViewModel(operationalProtocol: operationalService))) {
                        HStack {
                            Image(systemName: "cube.box.fill").foregroundColor(.themePrimary)
                            Text("Master Data & Resep")
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                            Text("Keluar Akun")
                        }
                    }
                }
            }
            .navigationTitle("Pengaturan")
            .listStyle(.insetGrouped)
            .background(Color.themeBgMain.edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview{
//    SettingsView()
}
