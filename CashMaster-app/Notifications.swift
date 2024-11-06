//
//  Notifications.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 21/10/2024.
//

import SwiftUI
import UserNotifications

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
	
	// Fonction pour programmer une notification hebdomadaire si elle n'existe pas déjà
	func scheduleWeeklyNotificationIfNeeded() {
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			// Vérifie si une notification avec cet identifiant existe déjà
			let notificationExists = requests.contains { $0.identifier == self.notificationIdentifier }
			
			if !notificationExists {
				self.scheduleWeeklyNotification()
			} else {
				print("La notification hebdomadaire est déjà programmée.")
			}
		}
	}
	
	// Fonction pour envoyer une notification hebdomadaire
	private func scheduleWeeklyNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Rappel - CashMaster"
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
}
