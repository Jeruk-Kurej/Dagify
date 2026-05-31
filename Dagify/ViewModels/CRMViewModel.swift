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

    // SRP FIX: ViewModel menyortir, bukan View
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
