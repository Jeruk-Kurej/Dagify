//
//  CRMViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Observation

@MainActor
@Observable
class CRMViewModel {
    var customers: [Customer] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    var loyalCustomerPercentage: Double {
        guard !customers.isEmpty else { return 0 }
        let loyalCount = customers.filter { $0.isLoyal }.count
        return (Double(loyalCount) / Double(customers.count)) * 100
    }

    var busiestHours: [Int: Int] {
        var hourFrequencies: [Int: Int] = [:]
        let calendar = Calendar.current

        for customer in customers {
            for visit in customer.visitHistory {
                let hour = calendar.component(.hour, from: visit)
                hourFrequencies[hour, default: 0] += 1
            }
        }
        return hourFrequencies
    }
    
    private let crmProtocol: CRMProtocol

    init(crmProtocol: CRMProtocol) {
        self.crmProtocol = crmProtocol
    }

    func loadCustomers(storeId: String) async {
        isLoading = true
        do {
            customers = try await crmProtocol.fetchCustomers(for: storeId)
        } catch {
            errorMessage = "Gagal memuat data pelanggan."
        }
        isLoading = false
    }

}
