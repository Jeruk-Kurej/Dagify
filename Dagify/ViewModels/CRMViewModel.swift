//
//  CRMViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Charts
import Foundation
import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
class CRMViewModel {
    var customers: [Customer] = []
    var isLoading: Bool = false
    let crmProtocol: CRMProtocol

    init(crmProtocol: CRMProtocol) { self.crmProtocol = crmProtocol }

    var loyalCustomerPercentage: Double {
        guard !customers.isEmpty else { return 0.0 }
        return
            (Double(customers.filter { $0.isLoyal }.count)
            / Double(customers.count)) * 100
    }

    var sortedBusiestHours: [(key: Int, value: Int)] {
        var hoursCount: [Int: Int] = [:]
        let calendar = Calendar.current
        for customer in customers {
            for visit in customer.visitHistory {
                hoursCount[
                    calendar.component(.hour, from: visit),
                    default: 0
                ] += 1
            }
        }
        return hoursCount.sorted(by: { $0.key < $1.key })
    }

    func loadCustomers(storeId: String) async {
        customers = (try? await crmProtocol.fetchCustomers(for: storeId)) ?? []
    }

    func processCustomerForCheckout(
        name: String,
        phone: String,
        spent: Double,
        storeId: String
    ) async -> String? {
        await loadCustomers(storeId: storeId)
        if let existingCust = customers.first(where: {
            $0.phoneNumber == phone && !phone.isEmpty
        }) {
            _ = try? await crmProtocol.recordNewVisit(
                customerId: existingCust.id ?? "",
                spent: spent,
                date: Date()
            )
            return existingCust.id
        } else {
            let newCustomer = Customer(
                id: nil,
                name: name,
                phoneNumber: phone,
                totalSpent: spent,
                visitHistory: [Date()]
            )
            _ = try? await crmProtocol.addCustomer(newCustomer)
            return nil
        }
    }
}

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
                            Text("berbelanja > 5 kali.").font(.subheadline)
                                .foregroundColor(.themeTextSecondary)
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

struct CheckoutSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var posVM: POSViewModel
    var crmVM: CRMViewModel
    let storeId: String
    let branchId: String

    @State private var customerName = ""
    @State private var customerPhone = ""
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Identitas Pelanggan (CRM)")) {
                    TextField("Nama Pelanggan", text: $customerName)
                    TextField("No HP (Opsional)", text: $customerPhone)
                        .keyboardType(.numberPad)
                }
                Section {
                    Button(action: executePayment) {
                        HStack {
                            Spacer()
                            if isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Text(
                                    "Bayar: Rp \(posVM.subtotal, specifier: "%.0f")"
                                ).bold()
                            }
                            Spacer()
                        }
                    }.foregroundColor(.white).listRowBackground(
                        customerName.isEmpty || isProcessing
                            ? Color.themeTextSecondary : Color.themeSuccess
                    ).disabled(customerName.isEmpty || isProcessing)
                }
            }.navigationTitle("Pembayaran").toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
        }
    }

    private func executePayment() {
        isProcessing = true
        Task {
            let customerId = await crmVM.processCustomerForCheckout(
                name: customerName,
                phone: customerPhone,
                spent: posVM.subtotal,
                storeId: storeId
            )
            await posVM.checkout(
                branchId: branchId,
                customerId: customerId,
                context: context
            )
            isProcessing = false
            dismiss()
        }
    }
}
