//
//  NotificationService.swift
//  Echoes
//
//  Updated by Sara Lindén on 2026-05-22.
//  Updated by Robin Eliasson on 2026-05-26
//

import Foundation
import UserNotifications
import CoreLocation

final class NotificationService {

    private static let proximityRadiusMeters: CLLocationDistance = 200

    static let listenNowActionID = "listen-now"
    static let laterActionID = "later"
    static let proximityCategoryID = "proximity-memory"

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

        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
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
        cancelAllProximityNotifications()
        pins.forEach { scheduleProximityNotification(for: $0) }
    }

    func cancelAllProximityNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let proximityIDs = requests
                .map { $0.identifier }
                .filter { $0.hasPrefix("proximity-") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: proximityIDs)
        }
    }
}
