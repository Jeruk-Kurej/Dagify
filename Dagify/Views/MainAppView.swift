//
//  MainView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

enum AppMenu: String, CaseIterable, Identifiable {
    case dashboard = "Dasbor"
    case pos = "Kasir (POS)"
    case inventory = "Gudang"
    case cashflow = "Arus Kas"
    case analytics = "Analitik Menu"
    case crm = "CRM"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "squareshape.2x2.fill"
        case .pos: return "cart.fill"
        case .inventory: return "shippingbox.fill"
        case .cashflow: return "chart.line.uptrend.xyaxis"
        case .analytics: return "chart.pie.fill"
        case .crm: return "person.2.fill"
        }
    }
}

struct MainAppView: View {
    let storeId: String
    let branchId: String
    var authViewModel: AuthViewModel
    
    @State private var selectedMenu: AppMenu? = .dashboard
    
    private let operationalService = FirebaseOperationalService()
    private let cashflowService = FirebaseCashflowService()
    private let crmService = FirebaseCRMService()
    
    var body: some View {
        NavigationSplitView {
            
            List(AppMenu.allCases, selection: $selectedMenu) { menu in
                NavigationLink(value: menu) {
                    Label(menu.rawValue, systemImage: menu.icon)
                }
            }
            .navigationTitle("Menu Dagify")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive, action: { authViewModel.logout() }) {
                        Label("Keluar Sistem", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.themeDestructive)
                    }
                }
            }
            
        } detail: {
            
            switch selectedMenu {
            case .dashboard:
                DashboardView(
                    viewModel: DashboardViewModel(cashflowProtocol: cashflowService, crmProtocol: crmService, operationalProtocol: operationalService),
                    storeId: storeId,
                    branchId: branchId
                )
            case .pos:
                POSView(
                    viewModel: POSViewModel(operationalProtocol: operationalService, networkMonitor: NetworkMonitor(), syncManager: SyncManager.shared as! SyncManagerProtocol),
                    branchId: branchId
                )
            case .inventory:
                InventoryView(
                    viewModel: InventoryViewModel(operationalProtocol: operationalService, cashflowProtocol: cashflowService),
                    branchId: branchId
                )
            case .cashflow:
                CashflowView(
                    viewModel: CashflowViewModel(cashProtocol: cashflowService),
                    branchId: branchId
                )
            case .analytics:
                ProductAnalyticsView(
                    viewModel: ProductAnalyticsViewModel(operationalProtocol: operationalService),
                    branchId: branchId
                )
            case .crm:
                CRMView(
                    viewModel: CRMViewModel(crmProtocol: crmService),
                    storeId: storeId
                )
            case .none:
                Text("Pilih menu dari bilah navigasi di sebelah kiri.")
                    .foregroundColor(.themeTextSecondary)
            }
        }
    }
}
