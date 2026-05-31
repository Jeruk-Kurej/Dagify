//
//  MainView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

struct MainAppView: View {
    let storeId: String
    let branchId: String
    var authViewModel: AuthViewModel
    
    let operationalService = FirebaseOperationalService()
    let cashflowService = FirebaseCashflowService()
    let crmService = FirebaseCRMService()
    let syncManager = SyncManager.shared
    let networkMonitor = NetworkMonitor()
    
    var body: some View {
        TabView {
            DashboardView(viewModel: DashboardViewModel(cashflowProtocol: cashflowService, crmProtocol: crmService, operationalProtocol: operationalService), storeId: storeId, branchId: branchId)
                .tabItem { Label("Dashboard", systemImage: "squareshape.2x2.fill") }
            
            CashflowView(viewModel: CashflowViewModel(cashProtocol: cashflowService), branchId: branchId)
                .tabItem { Label("Cashflow", systemImage: "chart.line.uptrend.xyaxis") }
            
            CRMView(viewModel: CRMViewModel(crmProtocol: crmService), storeId: storeId)
                .tabItem { Label("CRM", systemImage: "person.2.fill") }
            
            OperationalView(branchId: branchId, storeId: storeId, operationalService: operationalService, cashflowService: cashflowService, syncManager: syncManager, networkMonitor: networkMonitor)
                .tabItem { Label("Operational", systemImage: "briefcase.fill") }
            
            SettingsView(authViewModel: authViewModel, operationalService: operationalService)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}
