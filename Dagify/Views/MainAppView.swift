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
    var authViewModel: AuthViewModel
    
    @State private var activeBranchId: String = ""
    @State private var selectedTab: AppMenu = .dashboard
    @State private var isInitializingApp: Bool = true
    @Environment(\.horizontalSizeClass) private var sizeClass
    
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
                if sizeClass == .regular {
                    NavigationSplitView {
                        List(selection: Binding(get: { selectedTab }, set: { if let new = $0 { selectedTab = new } })) {
                            ForEach(AppMenu.allCases) { menu in
                                NavigationLink(value: menu) {
                                    Label(menu.rawValue, systemImage: menu.icon)
                                }
                            }
                        }
                        .navigationTitle("Dagify")
                        .listStyle(.sidebar)
                    } detail: {
                        destinationView(for: selectedTab)
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
            CRMView(viewModel: CRMViewModel(crmProtocol: crmService, storeProtocol: operationalService), storeId: storeId)
        case .operational:
            OperationalView(operationalService: operationalService, cashflowService: cashflowService, crmService: crmService, storeId: storeId, branchId: activeBranchId)
                .id(activeBranchId)
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
