//
//  NotificationService.swift
//  IosProject1
//
//  Wraps UNUserNotificationCenter so the app schedules exactly one daily
//  "Daily Challenge" notification at the user's chosen time.
//
//  Callers:
//      let granted = await NotificationService.shared.requestPermission()
//      NotificationService.shared.scheduleDailyChallenge(at: date)
//      NotificationService.shared.cancelDailyChallenge()
//

import Foundation
import UserNotifications

final class NotificationService {

    /// Singleton — no need for more than one instance, and the OS notification
    /// center is itself a singleton internally.
    static let shared = NotificationService()

    /// Fixed identifier for the daily notification. Scheduling with the same
    /// identifier *replaces* the previous request, so we never end up with
    /// duplicate notifications when the user changes the time.
    private let dailyIdentifier = "playhub.dailyChallenge"

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    /// Prompts for permission to show notifications. Returns whether the
    /// user granted access. Safe to call multiple times — iOS only shows
    /// the dialog the first time; subsequent calls return the stored answer.
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    /// Async lookup of the current permission state. Used by Settings on
    /// appear to show the correct toggle position without prompting.
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Scheduling

    /// Schedules the daily challenge to repeat every day at the given time.
    /// Replaces any previously scheduled instance so the user can freely
    /// change the time from Settings without leaking old triggers.
    /// - Parameter date: any Date whose hour/minute components describe the
    ///                   desired time of day.
    func scheduleDailyChallenge(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "PlayHub Daily Challenge"
        content.body = "A fresh challenge is waiting. Beat your best score!"
        content.sound = .default

        // Pull hour/minute from the user's chosen date. Using DateComponents
        // (not a raw TimeInterval) is what makes the trigger *repeat daily*.
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: dailyIdentifier,
            content: content,
            trigger: trigger
        )

        // Fire-and-forget — a scheduling failure isn't worth crashing over.
        // If it fails, the toggle in Settings simply won't produce alerts.
        center.add(request) { _ in }
    }

    /// Cancels any scheduled daily challenge. Called when the user turns
    /// the toggle off in Settings.
    func cancelDailyChallenge() {
        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier])
    }
}
