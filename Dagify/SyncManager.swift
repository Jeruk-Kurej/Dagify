//
//  SyncManager.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import SwiftData

class SyncManager: SyncManagerProtocol {

    // MARK: - Properties
    let operationalProtocol: OperationalProtocol
    let cashflowProtocol: CashflowProtocol
    let crmProtocol: CRMProtocol

    // MARK: - Initialization
    init(operationalProtocol: OperationalProtocol, cashflowProtocol: CashflowProtocol, crmProtocol: CRMProtocol) {
        self.operationalProtocol = operationalProtocol
        self.cashflowProtocol = cashflowProtocol
        self.crmProtocol = crmProtocol
    }

    // MARK: - Synchronization Methods
    func syncOfflineOrders(context: ModelContext, branchId: String) async {
        do {
            let descriptor = FetchDescriptor<OfflineOrderModel>()
            let offlineOrders = try context.fetch(descriptor)

            guard !offlineOrders.isEmpty else { return }
            print(
                "Memulai sinkronisasi \(offlineOrders.count) transaksi offline ke Cloud..."
            )

            let decoder = JSONDecoder()
            for offlineRecord in offlineOrders {
                if let order = try? decoder.decode(
                    Order.self,
                    from: offlineRecord.orderData
                ) {
                    do {
                        _ =
                            try await operationalProtocol
                            .submitOrderAndUpdateInventory(order: order)
                            
                        let incomeRecord = FinancialRecord(
                            id: UUID().uuidString,
                            branchId: order.branchId,
                            amount: order.totalAmount,
                            type: .income,
                            category: .none,
                            timestamp: order.timestamp,
                            notes: "POS Offline Sync"
                        )
                        _ = try await cashflowProtocol.addRecord(incomeRecord)
                        
                        // Bug Fix: Restore CRM loyal status
                        if let cid = order.customerId, !cid.isEmpty {
                            _ = try await crmProtocol.recordNewVisit(customerId: cid, spent: order.totalAmount, date: order.timestamp)
                        }

                        // Jika berhasil dikirim, hapus dari database lokal
                        context.delete(offlineRecord)
                    } catch {
                        print(
                            "Gagal sinkronisasi pesanan \(order.id ?? "Unknown")"
                        )
                    }
                }
            }
            try context.save()
            print("Sinkronisasi Selesai.")
        } catch {
            print("Gagal membaca data offline: \(error.localizedDescription)")
        }
    }
}
