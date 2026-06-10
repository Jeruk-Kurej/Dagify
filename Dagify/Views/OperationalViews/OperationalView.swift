//
//  OperationalView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

import SwiftUI

struct OperationalView: View {
    let operationalService: OperationalProtocol
    let cashflowService: CashflowProtocol
    let crmService: CRMProtocol
    let storeId: String
    let branchId: String


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pusat Operasional")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(Color(hex: "#111827"))
                        .padding(.horizontal).padding(.top, 8)

                    LazyVStack(spacing: 16) {
                        NavigationLink(
                            destination: POSView(
                                viewModel: POSViewModel(
                                    operationalProtocol: operationalService,
                                    cashflowProtocol: cashflowService,
                                    crmProtocol: crmService,
                                    networkMonitor: NetworkMonitor(),
                                    syncManager: SyncManager(
                                        operationalProtocol: operationalService
                                    )
                                ),
                                storeId: storeId,
                                branchId: branchId
                            )
                        ) {
                            OperationalMenuCard(
                                title: "Kasir (POS)",
                                description: "Lakukan transaksi penjualan dan catat pesanan pelanggan di cabang ini.",
                                icon: "cart.fill",
                                color: Color(hex: "#00A3A3")
                            )
                        }

                        NavigationLink(
                            destination: MasterDataView(
                                viewModel: MasterDataViewModel(
                                    operationalProtocol: operationalService
                                ),
                                branchId: branchId
                            )
                        ) {
                            OperationalMenuCard(
                                title: "Master Data",
                                description: "Kelola daftar menu F&B, harga, kategori, dan resep komposisi bahan.",
                                icon: "folder.fill.badge.plus",
                                color: Color(hex: "#4DBDBD")
                            )
                        }

                        NavigationLink(
                            destination: InventoryView(
                                viewModel: InventoryViewModel(
                                    operationalProtocol: operationalService,
                                    cashflowProtocol: cashflowService
                                ),
                                branchId: branchId
                            )
                        ) {
                            OperationalMenuCard(
                                title: "Gudang",
                                description: "Pantau stok bahan baku, catat barang masuk, dan kelola sisa inventaris.",
                                icon: "shippingbox.fill",
                                color: Color(hex: "#F59E0B")
                            )
                        }

                        NavigationLink(
                            destination: ProductAnalyticsView(
                                viewModel: ProductAnalyticsViewModel(
                                    operationalProtocol: operationalService
                                ),
                                branchId: branchId
                            )
                        ) {
                            OperationalMenuCard(
                                title: "Analitik Menu",
                                description: "Lihat tren penjualan menu mana yang paling laris dan disukai pelanggan.",
                                icon: "chart.pie.fill",
                                color: Color(hex: "#10B981")
                            )
                        }
                    }.padding(.horizontal)
                }.padding(.bottom, 24)
            }
            .background(Color(hex: "#F9FAFB").ignoresSafeArea())
            .navigationTitle("Operasional")
        }
    }
}

#Preview {
    OperationalView(
        operationalService: MockOperationalRepository(),
        cashflowService: MockCashflowRepository(),
        crmService: MockCRMRepository(),
        storeId: "S-1",
        branchId: "B-1"
    )
}
