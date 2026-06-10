//
//  CRMDashboardSheetView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 03/06/26.
//

import SwiftUI

// MARK: - CRM Dashboard Sheet View
struct CRMDashboardSheetView: View {
    // MARK: - Properties
    var viewModel: CRMViewModel
    var sheetType: CRMSheetType

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // Kalkulasi pelanggan lama yang dibuat sebelum fitur multi-cabang rilis
                let unknownCount = viewModel.customers.filter {
                    $0.branchId == nil || $0.branchId == ""
                }.count
                let unknownLoyalCount = viewModel.customers.filter {
                    ($0.branchId == nil || $0.branchId == "") && $0.isLoyal(threshold: viewModel.loyaltyThreshold)
                }.count

                Section(header: Text("Rincian per Cabang")) {
                    ForEach(viewModel.storeBranches, id: \.id) { branch in
                        HStack {
                            Text(branch.name)
                                .font(.body)
                                .foregroundColor(Color(hex: "#111827"))
                            Spacer()
                            Text(
                                "\(viewModel.getCustomerCount(for: branch.id, isLoyalOnly: sheetType == .loyal)) Orang"
                            )
                            .font(.headline)
                            .foregroundColor(
                                sheetType == .total
                                    ? Color(hex: "#00A3A3")
                                    : Color(hex: "#F59E0B")
                            )
                        }
                    }

                    // Tampilkan peninggalan data lama jika ada
                    if sheetType == .total
                        ? (unknownCount > 0) : (unknownLoyalCount > 0)
                    {
                        HStack {
                            Text("Tidak Diketahui (Data Lama)")
                                .font(.body)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(
                                "\(sheetType == .total ? unknownCount : unknownLoyalCount) Orang"
                            )
                            .font(.headline)
                            .foregroundColor(.gray)
                        }
                    }
                }
                
                if sheetType == .loyal {
                    Section {
                        Text("💡 Info: Pengunjung loyal adalah pengunjung yang telah datang sebanyak \(viewModel.loyaltyThreshold) kali atau lebih.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .navigationTitle(
                sheetType == .total ? "Total Pelanggan" : "Pelanggan Setia"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let mockCRM = MockCRMRepository()
    let mockOp = MockOperationalRepository()
    let vm = CRMViewModel(crmProtocol: mockCRM, storeProtocol: mockOp, operationalProtocol: mockOp)
    CRMDashboardSheetView(viewModel: vm, sheetType: .total)
}
