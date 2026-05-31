//
//  CRMView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import SwiftUI

struct CRMView: View {
    var viewModel: CRMViewModel
    let storeId = "S-1"

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Banner Retensi Pelanggan
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tingkat Retensi Loyalitas").font(.subheadline)
                        .foregroundColor(.themeTextSecondary)
                    Text(
                        String(
                            format: "%.1f%%",
                            viewModel.loyalCustomerPercentage
                        )
                    ).font(.largeTitle).bold().foregroundColor(.themeHighlight)
                }
                Spacer()
                Image(systemName: "person.3.sequence.fill").font(.largeTitle)
                    .foregroundColor(.themePrimary.opacity(0.3))
            }
            .padding(24).background(Color.themeBgSecondary)
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(.themeBorder),
                alignment: .bottom
            )

            // MARK: - Daftar Pelanggan
            if viewModel.isLoading {
                ProgressView("Memuat data pelanggan...").frame(
                    maxHeight: .infinity
                )
            } else if viewModel.customers.isEmpty {
                ContentUnavailableView(
                    "Belum Ada Pelanggan",
                    systemImage: "person.crop.circle.badge.questionmark"
                )
            } else {
                List(viewModel.customers) { customer in
                    HStack(spacing: 16) {
                        Circle().fill(Color.themePrimary.opacity(0.12)).frame(
                            width: 44,
                            height: 44
                        )
                        .overlay(
                            Text(String(customer.name.prefix(1))).font(
                                .headline
                            ).bold().foregroundColor(.themePrimary)
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(customer.name).font(.headline).foregroundColor(
                                .themeTextPrimary
                            )
                            Text(
                                "Total Kontribusi: Rp \(customer.totalSpent, specifier: "%.0f")"
                            ).font(.caption).foregroundColor(
                                .themeTextSecondary
                            )
                        }
                        Spacer()

                        // Indikator Loyalitas
                        if customer.isLoyal {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").foregroundColor(
                                    .themeWarning
                                )
                                Text("Loyal").font(.caption2).bold()
                                    .foregroundColor(.themeWarning)
                            }
                            .padding(.vertical, 4).padding(.horizontal, 8)
                            .background(Color.themeWarning.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Manajemen CRM")
        .onAppear { Task { await viewModel.loadCustomers(storeId: storeId) } }
    }
}
