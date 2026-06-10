//
//  MainView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

enum AppMenu: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Dasbor"
    case cashflow = "Arus Kas"
    case crm = "CRM"
    case operational = "Operasional"
    case settings = "Pengaturan"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .cashflow: return "chart.line.uptrend.xyaxis"
        case .crm: return "person.2.fill"
        case .operational: return "briefcase.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

enum IPadMenu: String, Hashable, Identifiable {
    case dashboard = "Dasbor"
    case cashflow = "Arus Kas"
    case crm = "CRM"
    case pos = "Kasir (POS)"
    case masterData = "Master Data"
    case inventory = "Gudang"
    case analytics = "Analitik Menu"
    case settings = "Pengaturan"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .cashflow: return "chart.line.uptrend.xyaxis"
        case .crm: return "person.2.fill"
        case .pos: return "cart.fill"
        case .masterData: return "folder.fill.badge.plus"
        case .inventory: return "shippingbox.fill"
        case .analytics: return "chart.pie.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainAppView: View {
    let storeId: String
    var authViewModel: AuthViewModel
    
    @State private var activeBranchId: String = ""
    @State private var selectedTab: AppMenu = .dashboard
    @State private var selectedIPadMenu: IPadMenu = .dashboard
    @State private var isInitializingApp: Bool = true
    @State private var isOperasionalExpanded: Bool = true
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isMacOS: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp
    }
    
    private let operationalService = FirebaseOperationalService()
    private let cashflowService = FirebaseCashflowService()
    private let crmService = FirebaseCRMService()
    
    init(storeId: String, authViewModel: AuthViewModel) {
        self.storeId = storeId
        self.authViewModel = authViewModel
    }

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
                    Text("Menyiapkan Ruang Kerja...").font(.headline).foregroundColor(Color(hex: "#6B7280"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#F9FAFB").ignoresSafeArea())
                .transition(.opacity)
                
            } else {
                if isMacOS {
                    MacMainAppView(storeId: storeId, authViewModel: authViewModel)
                } else if sizeClass == .regular {
                    NavigationSplitView {
                        List(selection: Binding(get: { selectedIPadMenu }, set: { if let new = $0 { selectedIPadMenu = new } })) {
                            NavigationLink(value: IPadMenu.dashboard) { Label(IPadMenu.dashboard.rawValue, systemImage: IPadMenu.dashboard.icon) }
                            NavigationLink(value: IPadMenu.cashflow) { Label(IPadMenu.cashflow.rawValue, systemImage: IPadMenu.cashflow.icon) }
                            NavigationLink(value: IPadMenu.crm) { Label(IPadMenu.crm.rawValue, systemImage: IPadMenu.crm.icon) }
                            
                            DisclosureGroup(isExpanded: $isOperasionalExpanded) {
                                NavigationLink(value: IPadMenu.pos) { Label(IPadMenu.pos.rawValue, systemImage: IPadMenu.pos.icon) }
                                NavigationLink(value: IPadMenu.masterData) { Label(IPadMenu.masterData.rawValue, systemImage: IPadMenu.masterData.icon) }
                                NavigationLink(value: IPadMenu.inventory) { Label(IPadMenu.inventory.rawValue, systemImage: IPadMenu.inventory.icon) }
                                NavigationLink(value: IPadMenu.analytics) { Label(IPadMenu.analytics.rawValue, systemImage: IPadMenu.analytics.icon) }
                            } label: {
                                Label("Operasional", systemImage: "briefcase.fill")
                            }
                            
                            NavigationLink(value: IPadMenu.settings) { Label(IPadMenu.settings.rawValue, systemImage: IPadMenu.settings.icon) }
                        }
                        .navigationTitle("Dagify")
                        .listStyle(.sidebar)
                    } detail: {
                        ipadDestinationView(for: selectedIPadMenu)
                    }
                    .tint(Color(hex: "#00A3A3"))
                    .transition(.opacity)
                } else {
                    TabView(selection: $selectedTab) {
                        ForEach(AppMenu.allCases) { menu in
                            destinationView(for: menu)
                                .tabItem { Label(menu.rawValue, systemImage: menu.icon) }
                                .tag(menu)
                        }
                    }
                    .tint(Color(hex: "#00A3A3"))
                    .transition(.opacity)
                }
            }
        }
        .task { await setupInitialBranch() }
        .onAppear { NotificationService.shared.requestAuthorization() }
    }
    
    @ViewBuilder
    private func destinationView(for menu: AppMenu) -> some View {
        switch menu {
        case .dashboard:
            DashboardView(viewModel: DashboardViewModel(cashflowProtocol: cashflowService, crmProtocol: crmService, operationalProtocol: operationalService, storeProtocol: operationalService), storeId: storeId, branchId: activeBranchId)
                .id(activeBranchId)
        case .cashflow:
            CashflowView(viewModel: CashflowViewModel(cashProtocol: cashflowService), branchId: activeBranchId)
                .id(activeBranchId)
        case .crm:
            CRMView(viewModel: CRMViewModel(crmProtocol: crmService, storeProtocol: operationalService, operationalProtocol: operationalService), storeId: storeId)
        case .operational:
            OperationalView(operationalService: operationalService, cashflowService: cashflowService, crmService: crmService, storeId: storeId, branchId: activeBranchId)
                .id(activeBranchId)
        case .settings:
            SettingsView(authViewModel: authViewModel, storeProtocol: operationalService, storeId: storeId, activeBranchId: $activeBranchId)
        }
    }
    
    @ViewBuilder
    private func ipadDestinationView(for menu: IPadMenu) -> some View {
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
                viewModel: POSViewModel(operationalProtocol: operationalService, cashflowProtocol: cashflowService, crmProtocol: crmService, networkMonitor: NetworkMonitor(), syncManager: SyncManager(operationalProtocol: operationalService)),
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

#Preview {
    MainAppView(
        storeId: "S-1",
        authViewModel: AuthViewModel(authProtocol: MockAuthRepository())
    )
}

