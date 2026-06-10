//
//  CustomerDetailSheetView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 08/06/26.
//

import SwiftUI

struct CustomerDetailSheetView: View {
    var customer: Customer
    @Bindable var viewModel: CRMViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var customerOrders: [Order] = []
    @State private var isLoadingOrders = true
    @State private var showLoyaltyTooltip = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Informasi Pelanggan")) {
                    LabeledContent("Nama", value: customer.name)
                    LabeledContent("No. Handphone", value: customer.phoneNumber)
                    LabeledContent(
                        "Total Pembelanjaan",
                        value: customer.totalSpent.toRupiah()
                    )
                    LabeledContent {
                        Text(customer.isLoyal(threshold: viewModel.loyaltyThreshold) ? "Pelanggan Setia (Loyal)" : "Reguler")
                            .onLongPressGesture {
                                showLoyaltyTooltip = true
                            }
                            .popover(isPresented: $showLoyaltyTooltip) {
                                Text("Pelanggan disebut loyal jika sudah berbelanja minimal \(viewModel.loyaltyThreshold) kali.")
                                    .padding()
                                    .presentationCompactAdaptation(.popover)
                            }
                    } label: {
                        Text("Status")
                    }
                }

                Section(header: Text("Riwayat Transaksi & Kunjungan")) {
                    if isLoadingOrders {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if customerOrders.isEmpty {
                        Text("Belum ada riwayat belanja.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(customerOrders) { order in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                Color(hex: "#00A3A3").opacity(0.15)
                                            )
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "bag.fill")
                                            .foregroundColor(Color(hex: "#00A3A3"))
                                            .font(.title3)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Transaksi Kasir")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(hex: "#111827"))

                                        Text(
                                            order.timestamp.formatted(
                                                date: .complete,
                                                time: .shortened
                                            )
                                        )
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#6B7280"))
                                    }
                                    Spacer()
                                    Text(order.totalAmount.toRupiah())
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#00A3A3"))
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(order.items) { item in
                                        HStack {
                                            Text("\(item.quantity)x \(item.product.name)")
                                                .font(.caption)
                                                .foregroundColor(Color(hex: "#374151"))
                                            Spacer()
                                            Text((Double(item.quantity) * item.product.price).toRupiah())
                                                .font(.caption)
                                                .foregroundColor(Color(hex: "#6B7280"))
                                        }
                                    }
                                }
                                .padding(.leading, 60)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(hex: "#F9FAFB"))
            .navigationTitle("Detail Riwayat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") { dismiss() }
                }
            }
            .task {
                if let id = customer.id {
                    customerOrders = await viewModel.fetchCustomerOrders(customerId: id)
                }
                isLoadingOrders = false
            }
        }
    }
}

#Preview {
    CustomerDetailSheetView(
        customer: Customer(
            id: "1",
            storeId: "S-1",
            branchId: "B-1",
            name: "Budi",
            phoneNumber: "081234567890",
            totalSpent: 150000,
            visitHistory: [Date(), Date().addingTimeInterval(-86400)]
        ),
        viewModel: CRMViewModel(crmProtocol: MockCRMRepository(), storeProtocol: MockOperationalRepository(), operationalProtocol: MockOperationalRepository())
    )
}
