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
    
    func scheduleExpiryAlert(for ingredient: Ingredient, branchName: String) {
        guard let expiryDate = ingredient.expiryDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Peringatan Kedaluwarsa!"
        content.body = "Bahan \(ingredient.name) di \(branchName) akan kedaluwarsa pada \(expiryDate.formatted(date: .abbreviated, time: .omitted)). Cek gudang sekarang!"
        content.sound = .default
        
        let alertDate = Calendar.current.date(byAdding: .day, value: -1, to: expiryDate) ?? expiryDate
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: alertDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let requestIdentifier = "expiry_\(ingredient.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Gagal menjadwalkan notifikasi expiry: \(error.localizedDescription)")
            }
        }
    }
}
