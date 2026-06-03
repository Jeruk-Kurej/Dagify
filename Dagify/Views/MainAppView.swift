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
                TabView(selection: $selectedTab) {
                    DashboardView(viewModel: DashboardViewModel(cashflowProtocol: cashflowService, crmProtocol: crmService, operationalProtocol: operationalService, storeProtocol: operationalService), storeId: storeId, branchId: activeBranchId)
                    .id(activeBranchId).tabItem { Label(AppMenu.dashboard.rawValue, systemImage: AppMenu.dashboard.icon) }.tag(AppMenu.dashboard)
                    
                    CashflowView(viewModel: CashflowViewModel(cashProtocol: cashflowService), branchId: activeBranchId)
                    .id(activeBranchId).tabItem { Label(AppMenu.cashflow.rawValue, systemImage: AppMenu.cashflow.icon) }.tag(AppMenu.cashflow)
                    
                    CRMView(viewModel: CRMViewModel(crmProtocol: crmService, storeProtocol: operationalService), storeId: storeId)
                    .tabItem { Label(AppMenu.crm.rawValue, systemImage: AppMenu.crm.icon) }.tag(AppMenu.crm)
                    
                    OperationalView(operationalService: operationalService, cashflowService: cashflowService, crmService: crmService, storeId: storeId, branchId: activeBranchId)
                    .id(activeBranchId).tabItem { Label(AppMenu.operational.rawValue, systemImage: AppMenu.operational.icon) }.tag(AppMenu.operational)
                    
                    SettingsView(authViewModel: authViewModel, storeProtocol: operationalService, storeId: storeId, activeBranchId: $activeBranchId)
                    .tabItem { Label(AppMenu.settings.rawValue, systemImage: AppMenu.settings.icon) }.tag(AppMenu.settings)
                }
                .tint(Color(hex: "#00A3A3")).transition(.opacity)
            }
        }
        .task { await setupInitialBranch() }
    }
    
    private func setupInitialBranch() async {
        do {
            let storeInfo = try await operationalService.fetchStore(storeId: storeId)
            if let firstBranch = storeInfo.branches.first { activeBranchId = firstBranch.id }
        } catch { print("Gagal memuat cabang utama.") }
        withAnimation(.easeOut(duration: 0.5)) { isInitializingApp = false }
    }
}
