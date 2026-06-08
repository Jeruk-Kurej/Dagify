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

    @State private var activeSheet: CRMSheetType? = nil

    /// State to track the currently selected customer for detail view.
    @State private var selectedCustomer: Customer? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        Button(action: { activeSheet = .total }) {
                            FinancialBox(
                                title: "Total Pelanggan",
                                amount: Double(viewModel.customers.count),
                                color: Color(hex: "#00A3A3"),
                                icon: "person.3.fill",
                                isCurrency: false
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: { activeSheet = .loyal }) {
                            FinancialBox(
                                title: "Pelanggan Setia (Loyal)",
                                amount: Double(viewModel.loyalCustomers.count),
                                color: Color(hex: "#F59E0B"),
                                icon: "star.circle.fill",
                                isCurrency: false
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Grafik Jam Sibuk Kunjungan")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))

                        VStack {
                            if viewModel.peakHoursData.isEmpty {
                                Text("Belum ada data kunjungan yang cukup.")
                                    .foregroundColor(.gray).padding()
                            } else {
                                Chart(viewModel.peakHoursData) { item in
                                    BarMark(
                                        x: .value("Jam", item.label),
                                        y: .value("Total Kunjungan", item.count)
                                    )
                                    .foregroundStyle(
                                        Color(hex: "#00A3A3").gradient
                                    )
                                    .cornerRadius(4)
                                }
                                .frame(height: 200)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(
                            color: Color.black.opacity(0.04),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                    }.padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Direktori Pelanggan")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#111827"))

                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity).padding()
                        } else if viewModel.customers.isEmpty {
                            ContentUnavailableView(
                                "CRM Kosong",
                                systemImage:
                                    "person.crop.circle.badge.questionmark",
                                description: Text(
                                    "Catat nomor HP pelanggan di layar Kasir."
                                )
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.customers, id: \.id) {
                                    customer in

                                    /// Wrap the card in a button to make it interactive.
                                    Button(action: {
                                        selectedCustomer = customer
                                    }) {
                                        CustomerCardView(customer: customer)
                                    }
                                    .buttonStyle(PlainButtonStyle())  // Menghapus efek biru bawaan list/button

                                }
                            }
                        }
                    }.padding(.horizontal)
                }.padding(.vertical)
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color(hex: "#F9FAFB"))
            .navigationTitle("CRM")
            .onAppear {
                Task { await viewModel.loadCustomers(storeId: storeId) }
            }
            .refreshable { await viewModel.loadCustomers(storeId: storeId) }
            .popover(item: $activeSheet) { sheetType in
                CRMDashboardSheetView(
                    viewModel: viewModel,
                    sheetType: sheetType
                )
                .presentationDetents([.medium, .large])
            }
            /// Presents a pop-up sheet with customer details when a customer is selected.
            .sheet(item: $selectedCustomer) { customer in
                CustomerDetailSheetView(customer: customer)
                    .presentationDetents([.fraction(0.7), .large])  // Pop-up bisa 70% atau ditarik Full Screen
            }
        }
    }
}

#Preview {
    let mockCRM = MockCRMRepository()
    let mockOp = MockOperationalRepository()
    mockOp.dummyStore = Store(
        id: "S-1",
        name: "Dagify Test Store",
        branches: [Branch(id: "B-1", name: "Pusat", address: "")]
    )
    mockCRM.customers = [
        Customer(
            id: "1",
            storeId: "S-1",
            branchId: "B-1",
            name: "Budi",
            phoneNumber: "081",
            totalSpent: 100000,
            visitHistory: [Date()]
        ),
        Customer(
            id: "2",
            storeId: "S-1",
            branchId: "B-1",
            name: "Susi",
            phoneNumber: "082",
            totalSpent: 200000,
            visitHistory: [Date(), Date(), Date(), Date(), Date()]
        ),
    ]
    return CRMView(
        viewModel: CRMViewModel(crmProtocol: mockCRM, storeProtocol: mockOp),
        storeId: "S-1"
    )
}
