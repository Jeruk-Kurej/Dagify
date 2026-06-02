import SwiftUI

struct OperationalView: View {
    let operationalService: OperationalProtocol
    let cashflowService: CashflowProtocol
    let crmService: CRMProtocol // ✅ DITAMBAHKAN
    let storeId: String         // ✅ DITAMBAHKAN
    let branchId: String
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pusat Operasional").font(.title2).fontWeight(.bold).foregroundColor(Color(hex: "#111827")).padding(.horizontal).padding(.top, 8)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        NavigationLink(destination: POSView(
                            viewModel: POSViewModel(
                                operationalProtocol: operationalService,
                                cashflowProtocol: cashflowService,
                                crmProtocol: crmService, // ✅ KABEL DISAMBUNGKAN
                                networkMonitor: NetworkMonitor(),
                                syncManager: SyncManager.shared
                            ),
                            storeId: storeId, // ✅ DITAMBAHKAN
                            branchId: branchId
                        )) {
                            OperationalMenuCard(title: "Kasir (POS)", icon: "cart.fill", color: Color(hex: "#00A3A3"))
                        }
                        
                        NavigationLink(destination: MasterDataView(viewModel: MasterDataViewModel(operationalProtocol: operationalService), branchId: branchId)) {
                            OperationalMenuCard(title: "Master Data", icon: "folder.fill.badge.plus", color: Color(hex: "#4DBDBD"))
                        }
                        
                        NavigationLink(destination: InventoryView(viewModel: InventoryViewModel(operationalProtocol: operationalService, cashflowProtocol: cashflowService), branchId: branchId)) {
                            OperationalMenuCard(title: "Gudang", icon: "shippingbox.fill", color: Color(hex: "#F59E0B"))
                        }
                        
                        NavigationLink(destination: ProductAnalyticsView(viewModel: ProductAnalyticsViewModel(operationalProtocol: operationalService), branchId: branchId)) {
                            OperationalMenuCard(title: "Analitik Menu", icon: "chart.pie.fill", color: Color(hex: "#10B981"))
                        }
                    }.padding(.horizontal)
                }.padding(.bottom, 24)
            }
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())
            .navigationTitle("Operasional")
        }
    }
}
// Sub-komponen Kartu Menu
struct OperationalMenuCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#111827"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(Color(hex: "#FFFFFF"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    OperationalView(
        operationalService: MockOperationalRepository(),
        cashflowService: MockCashflowRepository(),
        crmService: MockCRMRepository(), // ✅ DITAMBAHKAN
        storeId: "S-1",                  // ✅ DITAMBAHKAN
        branchId: "B-1"
    )
}
