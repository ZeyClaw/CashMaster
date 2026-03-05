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
	let modelContainer: ModelContainer
	@StateObject private var accountsManager: AccountsManager
	
	init() {
		// 1. Créer le conteneur SwiftData
		//    Stratégie : production → suppression store corrompu + retry → in-memory (dernier recours)
		let container: ModelContainer
		do {
			container = try SwiftDataService.makeContainer()
		} catch {
			print("❌ Échec total du ModelContainer production : \(error)")
			print("⚠️ Fallback sur un conteneur en mémoire (données non persistées)")
			do {
				container = try SwiftDataService.makePreviewContainer()
			} catch {
				// Situation quasi-impossible — dernier filet de sécurité
				print("❌ Échec du conteneur en mémoire : \(error)")
				container = try! ModelContainer(for: Account.self, Transaction.self, WidgetShortcut.self, RecurringTransaction.self)
			}
		}
		self.modelContainer = container
		
		// 2. Migration one-shot depuis UserDefaults (ancien format JSON)
		// ⚠️ À SUPPRIMER quand tous les utilisateurs sont migrés (voir LegacyMigrationService.swift)
		LegacyMigrationService.migrateIfNeeded(context: container.mainContext)
		
		// 3. Créer l'orchestrateur principal
		let manager = AccountsManager(modelContext: container.mainContext)
		self._accountsManager = StateObject(wrappedValue: manager)
		
		// 4. Notifications
		NotificationManager.shared.requestNotificationPermission()
		NotificationManager.shared.scheduleWeeklyNotificationIfNeeded()
		NotificationManager.shared.listScheduledNotifications()
	}
	
    var body: some Scene {
        WindowGroup {
            ContentView(accountsManager: accountsManager)
        }
		.modelContainer(modelContainer)
    }
}
