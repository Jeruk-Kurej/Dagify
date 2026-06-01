//
//  OperationalView.swift
//  Dagify
//
//  Created by Mario Ruby Ariesusandi  on 01-06-2026.
//

import SwiftUI

struct OperationalView: View {
    let branchId: String; let storeId: String
    var operationalService: OperationalProtocol; var cashflowService: CashflowProtocol; var syncManager: SyncManagerProtocol; var networkMonitor: NetworkMonitor
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Kategori", selection: $selectedTab) { Text("Kasir").tag(0); Text("Gudang").tag(1); Text("Analitik").tag(2) }.pickerStyle(.segmented).padding().background(Color.themeBgSecondary)
                TabView(selection: $selectedTab) {
                    POSView(viewModel: POSViewModel(operationalProtocol: operationalService, networkMonitor: networkMonitor, syncManager: syncManager), crmViewModel: CRMViewModel(crmProtocol: FirebaseCRMService()), branchId: branchId, storeId: storeId).tag(0)
                    InventoryView(viewModel: InventoryViewModel(operationalProtocol: operationalService, cashflowProtocol: cashflowService), branchId: branchId).tag(1)
                    ProductAnalyticsView(viewModel: ProductAnalyticsViewModel(operationalProtocol: operationalService), branchId: branchId).tag(2)
                }.tabViewStyle(.page(indexDisplayMode: .never))
            }.navigationTitle("Operasional").navigationBarTitleDisplayMode(.inline).background(Color.themeBgMain)
        }
    }
}

#Preview {
    //OperationalView()
}
