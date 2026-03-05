//
//  FinoriaApp.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 03/10/2024.
//

import SwiftUI
import SwiftData

@main
struct FinoriaApp: App {
	
	/// Conteneur SwiftData partagé pour toute l'application
	let modelContainer: ModelContainer
	
	/// Gestionnaire des comptes (source de vérité)
	@StateObject private var accountsManager: AccountsManager
	
	init() {
		// 1. Créer le conteneur SwiftData
		let container: ModelContainer
		do {
			container = try SwiftDataService.makeContainer()
		} catch {
			print("❌ Erreur création ModelContainer: \(error)")
			// Fallback vers conteneur en mémoire
			do {
				container = try SwiftDataService.makePreviewContainer()
				print("⚠️ Utilisation d'un conteneur en mémoire (données non persistées)")
			} catch {
				fatalError("Impossible de créer le ModelContainer: \(error)")
			}
		}
		self.modelContainer = container
		
		// 2. Créer l'AccountsManager avec le contexte du conteneur
		let manager = AccountsManager(modelContext: container.mainContext)
		_accountsManager = StateObject(wrappedValue: manager)
		
		// 3. Notifications
		NotificationManager.shared.requestNotificationPermission()
		NotificationManager.shared.scheduleWeeklyNotificationIfNeeded()
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView(accountsManager: accountsManager)
		}
		.modelContainer(modelContainer)
	}
}
