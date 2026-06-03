//
//  SyncManager.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

//
//  SyncManager.swift
//  Dagify
//
//  Handles background synchronization between local SwiftData (Offline)
//  and Firestore (Online).
//

import Foundation
import SwiftData

class SyncManager: SyncManagerProtocol {

    // MARK: - Properties
    let operationalProtocol: OperationalProtocol

    // MARK: - Initialization
    init(operationalProtocol: OperationalProtocol) {
        self.operationalProtocol = operationalProtocol
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
