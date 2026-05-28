//
//  SyncManager.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation

class SyncManager {
    public static let shared = SyncManager()

    // Antrean lokal (Offline Queue) untuk pesanan yang gagal terkirim karena offline
    private var offlineOrdersQueue: [Order] = []

    private init() {}

    // Fungsi ini dipanggil oleh POSViewModel Mario saat Checkout
    public func handleCheckout(
        order: Order,
        isConnected: Bool,
        firebaseRepo: OperationalRepository
    ) async throws {
        if isConnected {
            // Jika Online: Langsung hajar ke Firebase
            _ = try await firebaseRepo.submitOrderAndUpdateInventory(
                order: order
            )
        } else {
            // Jika Offline: Simpan ke memori lokal / SwiftData
            offlineOrdersQueue.append(order)
            print(
                "Internet mati! Pesanan disimpan secara lokal (Offline Mode)."
            )
            // Notifikasi sukses palsu agar UI kasir tetap jalan dengan mulus
        }
    }

    // Fungsi ini dipanggil secara otomatis saat NetworkMonitor mendeteksi koneksi kembali
    public func syncOfflineData(firebaseRepo: OperationalRepository) async {
        guard !offlineOrdersQueue.isEmpty else { return }
        print(
            "Koneksi pulih! Memulai sinkronisasi \(offlineOrdersQueue.count) pesanan..."
        )

        for order in offlineOrdersQueue {
            do {
                _ = try await firebaseRepo.submitOrderAndUpdateInventory(
                    order: order
                )
                // Jika sukses terkirim, hapus dari antrean lokal
                offlineOrdersQueue.removeAll { $0.id == order.id }
            } catch {
                print("Gagal sinkronisasi order \(order.id ?? ""): \(error)")
            }
        }
    }
}
