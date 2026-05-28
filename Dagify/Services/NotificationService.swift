//
//  NotificationService.swift
//  Dagify
//
//  Created by Hanzelius Kwan on 28/05/26.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Gagal meminta izin notifikasi: \(error)")
            return false
        }
    }
    
    func scheduleLowStockAlert(for ingredient: Ingredient, branchName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Peringatan Stok Menipis!"
        content.body = "Stok \(ingredient.name) di cabang \(branchName) sisa \(ingredient.currentStock) \(ingredient.unit). Segera lakukan restock!"
        content.sound = .default
        
        let requestIdentifier = "low_stock_\(ingredient.id ?? UUID().uuidString)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Gagal menjadwalkan notifikasi: \(error.localizedDescription)")
            }
        }
    }
}
