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
        let content = UNMutableNotificationContent()
        content.title = "Peringatan Kedaluwarsa!"
        content.body =
            "Bahan baku \(ingredient.name) akan segera basi pada \(expiryDate.formatted(date: .abbreviated, time: .omitted)). Harap cek gudang!"
        content.sound = .default

        let trigger: UNNotificationTrigger
        
        if warningDate < Date() {
            // Jika tanggal peringatan sudah lewat (barang diinput ketika umurnya tinggal < 3 hari)
            // Trigger notifikasi sekarang juga (delay 5 detik agar user sempat keluar aplikasi)
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        } else {
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: warningDate
            )
            trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
        }

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
