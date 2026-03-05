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
		let container: ModelContainer
		do {
			container = try SwiftDataService.makeContainer()
		} catch {
			fatalError("❌ Impossible de créer le ModelContainer : \(error)")
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
