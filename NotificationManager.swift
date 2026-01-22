//
//  NotificationManager.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-16.
//

import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    func scheduleReminder(for vaccine: Vaccine) {
        
        // Ingen förnyelse → ingen notis
        guard let renewalDate = vaccine.renewalDate else {
            removeReminder(for: vaccine)
            return
        }

        // Notis på förnyelsedagen
        let content = UNMutableNotificationContent()
        content.title = "Vaccinpåminnelse 💉"
        content.body = "\(vaccine.name) behöver förnyas"
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: renewalDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        let identifier = vaccine.id.uuidString

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func removeReminder(for vaccine: Vaccine) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [vaccine.id.uuidString]
            )
    }
}
