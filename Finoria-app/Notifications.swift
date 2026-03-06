//
//  Notifications.swift 
//
//  Created by Godefroy REYNAUD on 21/10/2024.
//

import SwiftUI
import UserNotifications
import os.log

// MARK: - Logger

private let notifLogger = Logger(
	subsystem: Bundle.main.bundleIdentifier ?? "com.finoria",
	category: "Notifications"
)

// MARK: - AppDelegate (Remote Notifications + CloudKit)

/// AppDelegate nécessaire pour gérer les notifications push distantes.
///
/// CloudKit utilise les push silencieux pour déclencher la synchronisation entre appareils.
/// L'inscription via `registerForRemoteNotifications()` est requise pour que cela fonctionne.
///
/// Depuis le CloudKit Dashboard (https://icloud.developer.apple.com), vous pouvez aussi
/// envoyer des push visibles à tous les utilisateurs via les Subscriptions CloudKit.
class AppDelegate: NSObject, UIApplicationDelegate {
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		// Inscription aux notifications distantes (push silencieux CloudKit + push visibles)
		application.registerForRemoteNotifications()
		return true
	}
	
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		notifLogger.info("Enregistré pour les notifications push (token: \(token.prefix(8))...)")
	}
	
	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		notifLogger.warning("Échec inscription push: \(error.localizedDescription)")
	}
	
	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable: Any],
		fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
	) {
		// CloudKit envoie des push silencieux pour notifier d'un changement de données.
		// SwiftData + CloudKit gèrent automatiquement le merge des données.
		notifLogger.info("Push reçu — CloudKit synchronise les données")
		completionHandler(.newData)
	}
}

// MARK: - NotificationManager (Notifications Locales)

struct NotificationManager {
	static let shared = NotificationManager()
	private let notificationIdentifier = "WeeklyNotification"  // Identifiant fixe pour éviter les duplications
	
	func requestNotificationPermission() {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
			if let error = error {
				notifLogger.error("Erreur autorisation notifications: \(error.localizedDescription)")
			} else {
				notifLogger.info("Permission notifications: \(granted ? "accordée" : "refusée")")
			}
		}
	}
	
	func listScheduledNotifications() {
		let notificationCenter = UNUserNotificationCenter.current()
		
		notificationCenter.getPendingNotificationRequests { requests in
			if requests.isEmpty {
				notifLogger.info("Aucune notification programmée.")
			} else {
				for request in requests {
					notifLogger.info("Notification: \(request.identifier) - \(request.content.title)")
				}
			}
		}
	}

	
	// Fonction pour programmer une notification hebdomadaire si elle n'existe pas déjà
	// Vérifie aussi que le contenu est à jour (ex: renommage de l'app)
	func scheduleWeeklyNotificationIfNeeded() {
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			if let existing = requests.first(where: { $0.identifier == self.notificationIdentifier }) {
				if existing.content.title != "Rappel - Finoria" {
					notifLogger.info("Notification obsolète détectée, reprogrammation...")
					self.resetNotifications()
					self.scheduleWeeklyNotification()
				} else {
					notifLogger.info("Notification hebdomadaire déjà programmée.")
				}
			} else {
				self.scheduleWeeklyNotification()
			}
		}
	}
	
	// Fonction pour envoyer une notification hebdomadaire
	private func scheduleWeeklyNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Rappel - Finoria"
		content.body = "As-tu acheté quelque chose cette semaine ?"
		content.sound = UNNotificationSound.default
		
		// Configuration du déclencheur basé sur le calendrier (par exemple, tous les dimanche à 20h00)
		var dateComponents = DateComponents()
		dateComponents.weekday = 1 // Dimanche (1 = dimanche, 2 = lundi, etc.)
		dateComponents.hour = 20   // À 20h00
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		
		// Utiliser un identifiant fixe pour cette requête
		let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
		
		// Ajouter la requête au centre de notifications
		UNUserNotificationCenter.current().add(request) { error in
			if let error = error {
				notifLogger.error("Erreur programmation notification: \(error.localizedDescription)")
			} else {
				notifLogger.info("Notification hebdomadaire programmée avec succès.")
			}
		}
	}
	
	// Réinitialiser les notifications
	func resetNotifications() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		notifLogger.info("Toutes les notifications ont été réinitialisées.")
	}
	
}
