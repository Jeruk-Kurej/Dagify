//
//  CheckoutSheetView.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 01/06/26.
//

import SwiftData
import SwiftUI

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
