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
    
    @State private var cashflowRepo = FirebaseCashflowService()
    @State private var crmRepo = FirebaseCRMService()
    @State private var operationalRepo = FirebaseOperationalService()
    
    var body: some View {
        TabView {
            
            // TAB 1: DASHBOARD
            DashboardView(
                viewModel: DashboardViewModel(),
                storeId: storeId,
                branchId: branchId
            )
            .tabItem { Label("Dashboard", systemImage: "squareshape.2x2.fill") }
            
            // TAB 2: CASHFLOW
            CashflowView(
                viewModel: CashflowViewModel(repository: cashflowRepo),
                branchId: branchId
            )
            .tabItem { Label("Arus Kas", systemImage: "chart.line.uptrend.xyaxis") }
            
            // TAB 3: CRM
            CRMView(
                viewModel: CRMViewModel(repository: crmRepo),
                storeId: storeId
            )
            .tabItem { Label("CRM", systemImage: "person.2.fill") }
            
            // TAB 4: OPERASIONAL
            OperationalView(
                branchId: branchId,
                storeId: storeId,
                posViewModel: POSViewModel(repository: operationalRepo),
                inventoryViewModel: InventoryViewModel(repository: operationalRepo),
                masterDataViewModel: MasterDataViewModel(repository: operationalRepo)
            )
            .tabItem { Label("Operasional", systemImage: "briefcase.fill") }
            
            // TAB 5: SETTINGS
            SettingsView(
                authViewModel: authViewModel,
                storeId: storeId,
                branchId: branchId
            )
            .tabItem { Label("Pengaturan", systemImage: "gearshape.fill") }
            
        }
        .tint(.dagifyPrimary)
        .onAppear {
            NotificationService.shared.requestPermission()
        }
    }
}
