import Foundation
import UserNotifications

protocol LocalNotificationsServiceProtocol {
    func registerForLatestUpdatesIfPossible()
}

/// Обрабатывает разрешения на локальные уведомления
final class LocalNotificationsService: NSObject, UNUserNotificationCenterDelegate, LocalNotificationsServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    private let latestUpdatesRequestId = "latestUpdatesDaily19"
    private let updatesCategoryId = "updates"
    private let openUpdatesActionId = "openUpdates"

    func registerForLatestUpdatesIfPossible() {
        registerUpdatesCategory()

        center.requestAuthorization(options: [.sound, .badge, .alert]) { [weak self] granted, _ in
            guard granted, let self = self else { return }

            self.center.delegate = self

            let content = UNMutableNotificationContent()
            content.body = L10n.tr("notifications.latest_updates.body")
            content.sound = .default
            content.badge = 1
            content.categoryIdentifier = self.updatesCategoryId

            var dateComponents = DateComponents()
            dateComponents.hour = 19
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            self.center.removePendingNotificationRequests(withIdentifiers: [self.latestUpdatesRequestId])

            let request = UNNotificationRequest(
                identifier: self.latestUpdatesRequestId,
                content: content,
                trigger: trigger
            )

            self.center.add(request, withCompletionHandler: nil)
        }
    }

    func registerUpdatesCategory() {
        let action = UNNotificationAction(
            identifier: openUpdatesActionId,
            title: L10n.tr("notifications.latest_updates.open_action"),
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: updatesCategoryId,
            actions: [action],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([category])
    }
}

extension LocalNotificationsService {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.content.categoryIdentifier == updatesCategoryId,
           response.actionIdentifier == openUpdatesActionId {
            // Entry point for the "updates" action. Here we keep lightweight analytics/logging only.
            print(L10n.tr("notifications.latest_updates.action_triggered_log"))
        }

        completionHandler()
    }
}
