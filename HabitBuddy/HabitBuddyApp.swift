//
//  HabitBuddyApp.swift
//  HabitBuddy
//
//  Created by Nitin ‘s on 08/11/24.
//

import SwiftUI
import UserNotifications

@main
struct HabitBuddyApp: App {
    init() {
            requestNotificationPermission()
        }

        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    private func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notifications permission granted.")
                } else {
                    print("Notifications permission denied.")
                }
            }
        }
}
