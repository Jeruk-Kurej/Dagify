//
//  CRMViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Observation

struct TrafficData: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

/// Enum to identify which CRM sheet is currently presented.
enum CRMSheetType: Identifiable {
    case total
    case loyal
    var id: String {
        switch self {
        case .total: return "total"
        case .loyal: return "loyal"
        }
    }
}

@MainActor
@Observable
class CRMViewModel {
    var customers: [Customer] = []
    /// The list of branches associated with the current store.
    var storeBranches: [Branch] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var loyalCustomers: [Customer] { customers.filter { $0.isLoyal } }

    var peakHoursData: [TrafficData] {
        var counts = [Int: Int]()
        let calendar = Calendar.current
        for customer in customers {
            for visit in customer.visitHistory {
                let hour = calendar.component(.hour, from: visit)
                counts[hour, default: 0] += 1
            }
        }
        return counts.keys.sorted().map {
            TrafficData(
                label: String(format: "%02d:00", $0),
                count: counts[$0]!
            )
        }
    }

    private let crmProtocol: CRMProtocol
    /// Protocol dependency for accessing store data.
    private let storeProtocol: StoreProtocol

    init(crmProtocol: CRMProtocol, storeProtocol: StoreProtocol) {
        self.crmProtocol = crmProtocol
        self.storeProtocol = storeProtocol
    }

    func loadCustomers(storeId: String) async {
        isLoading = true
        do {
            // Ambil data pelanggan dan cabang secara pararel
            async let fetchCusts = crmProtocol.fetchCustomers(for: storeId)
            async let fetchStore = storeProtocol.fetchStore(storeId: storeId)

            self.customers = try await fetchCusts
            if let store = try? await fetchStore {
                self.storeBranches = store.branches
            }
        } catch {
            errorMessage = "Gagal memuat CRM."
        }
        isLoading = false
    }

    /// Calculates the number of customers for a specific branch.
    func getCustomerCount(for branchId: String, isLoyalOnly: Bool) -> Int {
        let branchCustomers = customers.filter { $0.branchId == branchId }
        if isLoyalOnly {
            return branchCustomers.filter { $0.isLoyal }.count
        }
        return branchCustomers.count
    }
}
