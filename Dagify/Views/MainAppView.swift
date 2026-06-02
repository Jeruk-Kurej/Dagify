//
//  MainAppView.swift
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

struct MainAppView: View {
    let storeId: String
    let branchId: String
    var authViewModel: AuthViewModel

    @State private var selectedTab: AppMenu = .dashboard

    // Inisialisasi Service Firebase
    private let operationalService = FirebaseOperationalService()
    private let cashflowService = FirebaseCashflowService()
    private let crmService = FirebaseCRMService()

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab(
                AppMenu.dashboard.rawValue,
                systemImage: AppMenu.dashboard.icon,
                value: .dashboard
            ) {
                DashboardView(
                    viewModel: DashboardViewModel(
                        cashflowProtocol: cashflowService,
                        crmProtocol: crmService,
                        operationalProtocol: operationalService
                    ),
                    storeId: storeId,
                    branchId: branchId
                )
            }

            Tab(
                AppMenu.cashflow.rawValue,
                systemImage: AppMenu.cashflow.icon,
                value: .cashflow
            ) {
                CashflowView(
                    viewModel: CashflowViewModel(cashProtocol: cashflowService),
                    branchId: branchId
                )
            }

            Tab(
                AppMenu.crm.rawValue,
                systemImage: AppMenu.crm.icon,
                value: .crm
            ) {
                CRMView(
                    viewModel: CRMViewModel(crmProtocol: crmService),
                    storeId: storeId
                )
            }

            Tab(
                AppMenu.operational.rawValue,
                systemImage: AppMenu.operational.icon,
                value: .operational
            ) {
                OperationalView(
                    operationalService: operationalService,
                    cashflowService: cashflowService,
                    branchId: branchId
                )
            }

            Tab(
                AppMenu.settings.rawValue,
                systemImage: AppMenu.settings.icon,
                value: .settings
            ) {
                SettingsView(
                    authViewModel: authViewModel,
                    storeId: storeId,
                    branchId: branchId
                )
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(Color(hex: "#00A3A3"))  // Warna Primary Dagify
    }
}
