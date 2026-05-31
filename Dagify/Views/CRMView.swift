//
//  CRMView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 31/05/26.
//

import Charts
import SwiftUI

struct CRMView: View {
    var viewModel: CRMViewModel
    let storeId: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Retensi Pelanggan").font(.headline)
                        HStack {
                            Text(
                                String(
                                    format: "%.1f%%",
                                    viewModel.loyalCustomerPercentage
                                )
                            ).font(.system(size: 48, weight: .bold))
                                .foregroundColor(.themeSuccess)
                            Text("berbelanja lebih dari 5 kali.").font(
                                .subheadline
                            ).foregroundColor(.themeTextSecondary)
                        }
                    }.padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("Heatmap Jam Sibuk").font(.headline).padding(
                            .horizontal
                        )
                        if viewModel.sortedBusiestHours.isEmpty {
                            ContentUnavailableView(
                                "Belum Ada Data",
                                systemImage: "clock"
                            ).frame(height: 200)
                        } else {
                            Chart {
                                ForEach(viewModel.sortedBusiestHours, id: \.key)
                                { hour, count in
                                    BarMark(
                                        x: .value("Jam", "\(hour):00"),
                                        y: .value("Kunjungan", count)
                                    ).foregroundStyle(Color.themePrimary)
                                        .cornerRadius(4)
                                }
                            }.frame(height: 250).padding().background(
                                Color.themeBgSecondary
                            ).cornerRadius(12).padding(.horizontal)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Daftar Pelanggan").font(.headline).padding(
                            .horizontal
                        )
                        ForEach(viewModel.customers) { customer in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(customer.name).font(.body).bold()
                                    Text(customer.phoneNumber).font(.caption)
                                        .foregroundColor(.themeTextSecondary)
                                }
                                Spacer()
                                if customer.isLoyal {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.themeWarning)
                                }
                                Text(
                                    "Rp \(customer.totalSpent, specifier: "%.0f")"
                                ).font(.subheadline).bold().foregroundColor(
                                    .themePrimary
                                )
                            }.padding().background(Color.themeBgSecondary)
                                .cornerRadius(8).padding(.horizontal)
                        }
                    }
                }.padding(.vertical)
            }.navigationTitle("CRM").background(Color.themeBgMain).onAppear {
                Task { await viewModel.loadCustomers(storeId: storeId) }
            }
        }
    }
}
