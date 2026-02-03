//
//  vaccineAppApp.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-03.
//

import SwiftUI
import UserNotifications

// MARK: - App entry point
/// Main entry point for the app.
/// Sets up the root view and requests notification permission on launch.
@main
struct vaccineAppApp: App {
    
    // MARK: - App initialisation
    /// Called once when the app launches.
    init() {
        requestNotificationPermission()
    }
    
    // MARK: - Scene configuration
    /// Defines the main window and root view of the app.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // MARK: - Notifications
    /// Requests permission to show alerts, sounds and badges.
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}
