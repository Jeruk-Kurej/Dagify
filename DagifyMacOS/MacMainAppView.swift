//
//  MacMainAppView.swift
//  Dagify
//

import SwiftUI

struct MacMainAppView: View {
    let storeId: String
    var authViewModel: AuthViewModel
    
    @State private var activeBranchId: String = ""
    @State private var selectedIPadMenu: IPadMenu = .dashboard
    @State private var isInitializingApp: Bool = true
    @State private var isOperasionalExpanded: Bool = true
    
    private let operationalService = FirebaseOperationalService()
    private let cashflowService = FirebaseCashflowService()
    private let crmService = FirebaseCRMService()
    
    var body: some View {
        ZStack {
            if isInitializingApp {
                VStack(spacing: 16) {
                    Image("Dagify_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.bottom, 8)
                        
                    ProgressView().scaleEffect(1.5).tint(Color(hex: "#00A3A3"))
                    Text("Menyiapkan Ruang Kerja macOS...").font(.headline).foregroundColor(Color(hex: "#6B7280"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#F9FAFB").ignoresSafeArea())
                .transition(.opacity)
                
            } else {
                NavigationSplitView {
                    List(selection: Binding(get: { selectedIPadMenu }, set: { if let new = $0 { selectedIPadMenu = new } })) {
                        Section("Utama") {
                            NavigationLink(value: IPadMenu.dashboard) { Label(IPadMenu.dashboard.rawValue, systemImage: IPadMenu.dashboard.icon) }
                            NavigationLink(value: IPadMenu.cashflow) { Label(IPadMenu.cashflow.rawValue, systemImage: IPadMenu.cashflow.icon) }
                            NavigationLink(value: IPadMenu.crm) { Label(IPadMenu.crm.rawValue, systemImage: IPadMenu.crm.icon) }
                        }
                        
                        Section("Manajemen Operasional") {
                            NavigationLink(value: IPadMenu.pos) { Label(IPadMenu.pos.rawValue, systemImage: IPadMenu.pos.icon) }
                            NavigationLink(value: IPadMenu.masterData) { Label(IPadMenu.masterData.rawValue, systemImage: IPadMenu.masterData.icon) }
                            NavigationLink(value: IPadMenu.inventory) { Label(IPadMenu.inventory.rawValue, systemImage: IPadMenu.inventory.icon) }
                            NavigationLink(value: IPadMenu.analytics) { Label(IPadMenu.analytics.rawValue, systemImage: IPadMenu.analytics.icon) }
                        }
                        
                        Section("Sistem") {
                            NavigationLink(value: IPadMenu.settings) { Label(IPadMenu.settings.rawValue, systemImage: IPadMenu.settings.icon) }
                        }
                    }
                    .navigationTitle("Dagify macOS")
                    .listStyle(.sidebar)
                } detail: {
                    macDestinationView(for: selectedIPadMenu)
                }
                .tint(Color(hex: "#00A3A3"))
                .transition(.opacity)
            }
        }
        .task { await setupInitialBranch() }
    }
    
    @ViewBuilder
    private func macDestinationView(for menu: IPadMenu) -> some View {
        switch menu {
        case .dashboard:
            DashboardView(viewModel: DashboardViewModel(cashflowProtocol: cashflowService, crmProtocol: crmService, operationalProtocol: operationalService, storeProtocol: operationalService), storeId: storeId, branchId: activeBranchId)
                .id(activeBranchId)
        case .cashflow:
            CashflowView(viewModel: CashflowViewModel(cashProtocol: cashflowService), branchId: activeBranchId)
                .id(activeBranchId)
        case .crm:
            CRMView(viewModel: CRMViewModel(crmProtocol: crmService, storeProtocol: operationalService, operationalProtocol: operationalService), storeId: storeId)
        case .pos:
            POSView(
                viewModel: POSViewModel(
                    operationalProtocol: operationalService,
                    cashflowProtocol: cashflowService,
                    crmProtocol: crmService,
                    networkMonitor: NetworkMonitor(),
                    syncManager: SyncManager(
                        operationalProtocol: operationalService,
                        cashflowProtocol: cashflowService,
                        crmProtocol: crmService
                    )
                ),
                storeId: storeId, branchId: activeBranchId
            ).id(activeBranchId)
        case .masterData:
            MasterDataView(viewModel: MasterDataViewModel(operationalProtocol: operationalService), branchId: activeBranchId)
        case .inventory:
            InventoryView(viewModel: InventoryViewModel(operationalProtocol: operationalService, cashflowProtocol: cashflowService), branchId: activeBranchId)
        case .analytics:
            ProductAnalyticsView(viewModel: ProductAnalyticsViewModel(operationalProtocol: operationalService), branchId: activeBranchId)
        case .settings:
            SettingsView(authViewModel: authViewModel, storeProtocol: operationalService, storeId: storeId, activeBranchId: $activeBranchId)
        }
    }
    
    private func setupInitialBranch() async {
        do {
            let storeInfo = try await operationalService.fetchStore(storeId: storeId)
            if let firstBranch = storeInfo.branches.first { activeBranchId = firstBranch.id }
        } catch { print("Gagal memuat cabang utama.") }
        withAnimation(.easeOut(duration: 0.5)) { isInitializingApp = false }
    }
}
