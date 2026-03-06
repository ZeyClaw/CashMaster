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
	
	/// AppDelegate pour gérer les notifications push (CloudKit + push visibles)
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	/// Conteneur SwiftData partagé pour toute l'application
	let modelContainer: ModelContainer
	
	/// Gestionnaire des comptes (source de vérité)
	@StateObject private var accountsManager: AccountsManager
	
	init() {
		// 1. Créer le conteneur SwiftData (CloudKit activé)
		// Note : makeContainer() avec .automatic ne crash quasiment jamais.
		// Si CloudKit est indisponible (pas de compte iCloud, simulateur, etc.),
		// SwiftData fonctionne en local et synchronise plus tard quand c'est possible.
		// Le diagnostic CloudKit est fait dans ContentView via CloudKitService.
		let container: ModelContainer
		do {
			container = try SwiftDataService.makeContainer()
			print("✅ ModelContainer créé (CloudKit .automatic)")
		} catch {
			// Ce cas est très rare (corruption de base, migration impossible, etc.)
			print("❌ Erreur création ModelContainer avec CloudKit: \(error)")
			print("❌ Détail: \(error.localizedDescription)")
			// Fallback : conteneur SUR DISQUE sans CloudKit (données conservées !)
			do {
				container = try SwiftDataService.makeFallbackContainer()
				print("⚠️ Fallback: conteneur local sans CloudKit (données sur disque)")
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
