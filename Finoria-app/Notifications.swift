//
//  Notifications.swift 
//
//  Created by Godefroy REYNAUD on 21/10/2024.
//

import SwiftUI
import UserNotifications

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
		// CloudKit gère automatiquement le token pour la synchronisation.
		// Pas besoin de l'envoyer manuellement à un serveur.
		let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
		print("✅ Enregistré pour les notifications push (token: \(token.prefix(8))...)")
	}
	
	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("❌ Échec inscription push: \(error.localizedDescription)")
	}
	
	func application(
		_ application: UIApplication,
		didReceiveRemoteNotification userInfo: [AnyHashable: Any],
		fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
	) {
		// CloudKit envoie des push silencieux pour notifier d'un changement de données.
		// SwiftData + CloudKit gèrent automatiquement le merge des données.
		print("📩 Push reçu — CloudKit synchronise les données...")
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
			if granted {
				print("Permission granted")
			} else {
				print("Permission denied")
			}
		}
	}
	
	func listScheduledNotifications() {
		let notificationCenter = UNUserNotificationCenter.current()
		
		notificationCenter.getPendingNotificationRequests { requests in
			if requests.isEmpty {
				print("Aucune notification programmée.")
			} else {
				print("Notifications programmées actuellement :")
				for request in requests {
					print("----------------------------")
					print("ID : \(request.identifier)")
					print("Titre : \(request.content.title)")
					print("Corps : \(request.content.body)")
					
					if let trigger = request.trigger as? UNCalendarNotificationTrigger {
						if let nextTriggerDate = trigger.nextTriggerDate() {
							let formatter = DateFormatter()
							formatter.dateStyle = .medium
							formatter.timeStyle = .short
							let dateString = formatter.string(from: nextTriggerDate)
							print("Prochaine date de déclenchement : \(dateString)")
						} else {
							print("Prochaine date de déclenchement : Inconnue")
						}
					} else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
						print("Intervalle en secondes : \(trigger.timeInterval)")
						print("Répète : \(trigger.repeats ? "Oui" : "Non")")
					} else {
						print("Type de déclencheur : Inconnu")
					}
				}
			}
		}
	}

	
	// Fonction pour programmer une notification hebdomadaire si elle n'existe pas déjà
	// Vérifie aussi que le contenu est à jour (ex: renommage de l'app)
	func scheduleWeeklyNotificationIfNeeded() {
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			if let existing = requests.first(where: { $0.identifier == self.notificationIdentifier }) {
				// Si le titre ne correspond plus (ex: ancien nom "Finoria"), on réinitialise
				if existing.content.title != "Rappel - Finoria" {
					print("Notification obsolète détectée, reprogrammation...")
					self.resetNotifications()
					self.scheduleWeeklyNotification()
				} else {
					print("La notification hebdomadaire est déjà programmée.")
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
				print("Erreur lors de l'envoi de la notification : \(error.localizedDescription)")
			} else {
				print("Notification hebdomadaire programmée avec succès.")
			}
		}
	}
	
	// Réinitialiser les notifications
	func resetNotifications() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		print("Toutes les notifications ont été réinitialisées.")
	}
	
}
