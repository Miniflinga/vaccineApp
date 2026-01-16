//
//  vaccineAppApp.swift
//  vaccineApp
//
//  Created by hannali on 2026-01-03.
//

import SwiftUI
import UserNotifications

@main
struct vaccineAppApp: App {
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func requestNotificationPermission() {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
}
