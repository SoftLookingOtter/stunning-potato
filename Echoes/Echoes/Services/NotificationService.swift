//
//  NotificationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//

import Foundation
import UserNotifications

final class NotificationService {

    func requestNotificationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in
                if let error {
                    print("Notification permission error: \(error.localizedDescription)")
                }

                continuation.resume(returning: granted)
            }
        }
    }
}
