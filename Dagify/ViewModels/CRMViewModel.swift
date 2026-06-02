//
//  CRMViewModel.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import Observation

// Struktur Data untuk Grafik
struct TrafficData: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

@MainActor
@Observable
class CRMViewModel {
    var customers: [Customer] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var loyalCustomers: [Customer] { customers.filter { $0.isLoyal } }
    
    // ✅ FITUR C: SEGMENTASI WAKTU KUNJUNGAN (Jam Sibuk)
    var peakHoursData: [TrafficData] {
        var counts = [Int: Int]()
        let calendar = Calendar.current
        for customer in customers {
            for visit in customer.visitHistory {
                let hour = calendar.component(.hour, from: visit)
                counts[hour, default: 0] += 1
            }
        }
        // Urutkan dari jam 00 sampai 23
        return counts.keys.sorted().map { TrafficData(label: String(format: "%02d:00", $0), count: counts[$0]!) }
    }

    private let crmProtocol: CRMProtocol

    init(crmProtocol: CRMProtocol) { self.crmProtocol = crmProtocol }

    func loadCustomers(storeId: String) async {
        isLoading = true
        do { customers = try await crmProtocol.fetchCustomers(for: storeId) } catch { errorMessage = "Gagal memuat CRM." }
        isLoading = false
    }
}
