//
//  MainAppView.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 31/05/26.
//

import SwiftUI

enum AppMenu: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Dasbor"
    case pos = "Kasir (POS)"
    case masterData = "Master Data"  // ✅ DITAMBAHKAN
    case inventory = "Gudang"
    case cashflow = "Arus Kas"
    case analytics = "Analitik Menu"
    case crm = "CRM"
    case settings = "Pengaturan"  // ✅ DITAMBAHKAN

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        // ✅ DIPERBAIKI: Nama SF Symbol yang benar untuk Dashboard
        case .dashboard: return "square.grid.2x2.fill"
        case .pos: return "cart.fill"
        case .masterData: return "folder.fill.badge.plus"
        case .inventory: return "shippingbox.fill"
        case .cashflow: return "chart.line.uptrend.xyaxis"
        case .analytics: return "chart.pie.fill"
        case .crm: return "person.2.fill"
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
                AppMenu.pos.rawValue,
                systemImage: AppMenu.pos.icon,
                value: .pos
            ) {
                POSView(
                    viewModel: POSViewModel(
                        operationalProtocol: operationalService,
                        networkMonitor: NetworkMonitor(),
                        syncManager: SyncManager.shared
                    ),
                    branchId: branchId
                )
            }

            // ✅ DITAMBAHKAN: Tab Master Data agar kamu bisa mengisi menu
            Tab(
                AppMenu.masterData.rawValue,
                systemImage: AppMenu.masterData.icon,
                value: .masterData
            ) {
                MasterDataView(
                    viewModel: MasterDataViewModel(
                        operationalProtocol: operationalService
                    )
                )
            }

            Tab(
                AppMenu.inventory.rawValue,
                systemImage: AppMenu.inventory.icon,
                value: .inventory
            ) {
                InventoryView(
                    viewModel: InventoryViewModel(
                        operationalProtocol: operationalService,
                        cashflowProtocol: cashflowService
                    ),
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
                AppMenu.analytics.rawValue,
                systemImage: AppMenu.analytics.icon,
                value: .analytics
            ) {
                ProductAnalyticsView(
                    viewModel: ProductAnalyticsViewModel(
                        operationalProtocol: operationalService
                    ),
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

            // ✅ DITAMBAHKAN: Tab Pengaturan untuk Logout
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
    }
}
