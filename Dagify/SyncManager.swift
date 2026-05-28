//
//  SyncManager.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import SwiftData

@MainActor
class SyncManager {
    static let shared = SyncManager()
    
    private init() {}
    
    func handleCheckout(order: Order, isConnected: Bool, firebaseRepo: OperationalRepository, context: ModelContext) async throws {
        if isConnected {
            _ = try await firebaseRepo.submitOrderAndUpdateInventory(order: order)
            print("Online: Pesanan sukses masuk ke Firebase.")
        } else {
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(order) {
                let offlineOrder = OfflineOrderModel(
                    id: order.id ?? UUID().uuidString,
                    orderData: encodedData,
                    timestamp: Date()
                )
                
                context.insert(offlineOrder)
                try context.save()
                print("Offline: Pesanan aman tersimpan di SwiftData Lokal!")
            }
        }
    }
    
    func syncOfflineData(firebaseRepo: OperationalRepository, context: ModelContext) async {
        let descriptor = FetchDescriptor<OfflineOrderModel>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        guard let offlineOrders = try? context.fetch(descriptor), !offlineOrders.isEmpty else { return }
        
        print("Koneksi pulih! Memulai sinkronisasi \(offlineOrders.count) pesanan ke Firebase...")
        
        let decoder = JSONDecoder()
        
        for offlineOrder in offlineOrders {
            if let orderToSync = try? decoder.decode(Order.self, from: offlineOrder.orderData) {
                do {
                    _ = try await firebaseRepo.submitOrderAndUpdateInventory(order: orderToSync)
                    
                    context.delete(offlineOrder)
                } catch {
                    print("Gagal sinkronisasi order \(offlineOrder.id): \(error.localizedDescription)")
                }
            }
        }
        
        // Simpan penghapusan
        try? context.save()
        print("Sinkronisasi selesai!")
    }
}
