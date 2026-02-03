//
//  NotificationManager.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-16.
//

import Foundation
import UserNotifications

// MARK: - NotificationManager
/// Manages local notifications for vaccine renewals.
class NotificationManager {

    // Shared instance used throughout the app
    static let shared = NotificationManager()
    
    // MARK: Schedule reminder
    /// Schedules a notification on the vaccine's renewal date.
    func scheduleReminder(for vaccine: Vaccine) {
        
        // No renewal → no notification
        guard let renewalDate = vaccine.renewalDate else {
            removeReminder(for: vaccine)
            return
        }

        // Build of the notification
        let content = UNMutableNotificationContent()
        content.title = "Vaccinpåminnelse 💉"
        content.body = "\(vaccine.name) behöver förnyas"
        content.sound = .default

        // Trigger notification on renewal day
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
        // Register the notification in the system
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: Remove reminder
    /// Removes any pending notification for the given vaccine.
    /// Called when a vaccine is deleted or no longer needs renewal.
    func removeReminder(for vaccine: Vaccine) {
        UNUserNotificationCenter.current()
        .removePendingNotificationRequests(
            withIdentifiers: [vaccine.id.uuidString]
        )
    }
}
