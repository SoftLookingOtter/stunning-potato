//
//  NotificationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//  Updated by Robin Eliasson on 2026-05-26.
//  Updated by Sara Lindén on 2026-06-03.
//

import Foundation
import UserNotifications
import CoreLocation

final class NotificationService {

    private static let proximityRadiusMeters: CLLocationDistance = 200

    static let listenNowActionID = "listen-now"
    static let laterActionID = "later"
    static let proximityCategoryID = "proximity-memory"

    private var notificationsEnabled: Bool {
        UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
    }

    func requestNotificationPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { [weak self] granted, error in
                if let error {
                    print("Notification permission error: \(error.localizedDescription)")
                }

                if granted {
                    self?.registerNotificationCategories()
                }

                continuation.resume(returning: granted)
            }
        }
    }

    func registerNotificationCategories() {
        let listenNow = UNNotificationAction(
            identifier: Self.listenNowActionID,
            title: "Lyssna nu",
            options: [.foreground]
        )

        let later = UNNotificationAction(
            identifier: Self.laterActionID,
            title: "Senare",
            options: []
        )

        let proximityCategory = UNNotificationCategory(
            identifier: Self.proximityCategoryID,
            actions: [listenNow, later],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([proximityCategory])
    }

    func scheduleProximityNotification(for pin: EchoPin) {
        guard notificationsEnabled else {
            print("Notifications are disabled in app settings.")
            return
        }

        let region = CLCircularRegion(
            center: pin.coordinate,
            radius: Self.proximityRadiusMeters,
            identifier: pin.id.uuidString
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false

        let content = UNMutableNotificationContent()
        content.title = "Ett dolt minne är nära!"
        content.body = "Du är mindre än 200 meter från ett eko. Gå närmare för att låsa upp det."
        content.sound = .default
        content.categoryIdentifier = Self.proximityCategoryID

        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "proximity-\(pin.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule proximity notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleProximityNotifications(for pins: [EchoPin]) {
        guard notificationsEnabled else {
            print("Notifications are disabled in app settings.")
            return
        }

        pins.forEach { pin in
            scheduleProximityNotification(for: pin)
        }
    }
}
