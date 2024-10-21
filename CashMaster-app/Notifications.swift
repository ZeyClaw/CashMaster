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
	
	// Fonction pour envoyer une notification hebdomadaire
	func scheduleWeeklyNotification() {
		let content = UNMutableNotificationContent()
		content.title = "Rappel - CashMaster"
		content.body = "As-tu acheté quelque chose cette semaine ?"
		content.sound = UNNotificationSound.default
		
		// Configuration du déclencheur basé sur le calendrier (par exemple, tous les dimanche à 20h00)
		var dateComponents = DateComponents()
		dateComponents.weekday = 1 // Dimanche (1 = dimanche, 2 = lundi, etc.)
		dateComponents.hour = 20   // À 20h00
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		
		// Créer la requête de notification avec un identifiant unique
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		
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
