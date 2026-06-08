//
//  NotificationService.swift
//  Dagify
//
//  Created by Bryan Carlie Lukito Setiawan on 28/05/26.
//

import Foundation
import UserNotifications

class NotificationService {

    // MARK: - Singleton Instance
    static let shared = NotificationService()
    private init() {}

    // MARK: - Authorization
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .badge, .sound,
        ]) { granted, error in
            if let error = error {
                print(
                    "Error meminta izin notifikasi: \(error.localizedDescription)"
                )
            }
        }
    }

    // MARK: - Scheduling Methods
    func scheduleExpiryWarning(for ingredient: Ingredient) {
        guard let expiryDate = ingredient.expiryDate else { return }

        // Memberi peringatan 3 hari sebelum basi
        let warningDate =
            Calendar.current.date(byAdding: .day, value: -3, to: expiryDate)
            ?? expiryDate
        if warningDate < Date() { return }  // Jangan jadwalkan di masa lalu

        let content = UNMutableNotificationContent()
        content.title = "Peringatan Kedaluwarsa!"
        content.body =
            "Bahan baku \(ingredient.name) akan segera basi pada \(expiryDate.formatted(date: .abbreviated, time: .omitted)). Harap cek gudang!"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour],
            from: warningDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        // Gunakan ID bahan sebagai identifier agar notifikasi dapat di-update/dibatalkan
        let request = UNNotificationRequest(
            identifier: "expiry_\(ingredient.id ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Gagal menjadwalkan notifikasi: \(error.localizedDescription)"
                )
            }
        }
    }

    func cancelExpiryWarning(for ingredientId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["expiry_\(ingredientId)"])
    }
}
