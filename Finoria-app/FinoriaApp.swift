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
	/// Non-nil si le conteneur SwiftData n'a pas pu être créé normalement.
	/// Contient un message descriptif affiché dans `DatabaseErrorView`.
	let initError: String?
	
	init() {
		// 1. Créer le conteneur SwiftData avec chaîne de fallback robuste
		//    Production → nettoyage + retry → in-memory → dernier recours minimal
		let result = Self.makeResilientContainer()
		self.modelContainer = result.container
		self.initError = result.error
		
		if let error = result.error {
			print("⚠️ Finoria démarré en mode dégradé : \(error)")
		}
		
		// 2. Migration one-shot depuis UserDefaults (ancien format JSON)
		//    Seulement si le conteneur est pleinement fonctionnel
		// ⚠️ À SUPPRIMER quand tous les utilisateurs sont migrés (voir LegacyMigrationService.swift)
		if result.error == nil {
			LegacyMigrationService.migrateIfNeeded(context: result.container.mainContext)
		}
		
		// 3. Créer l'orchestrateur principal
		let manager = AccountsManager(modelContext: result.container.mainContext)
		self._accountsManager = StateObject(wrappedValue: manager)
		
		// 4. Notifications
		NotificationManager.shared.requestNotificationPermission()
		NotificationManager.shared.scheduleWeeklyNotificationIfNeeded()
		NotificationManager.shared.listScheduledNotifications()
	}
	
	var body: some Scene {
		WindowGroup {
			if let error = initError {
				DatabaseErrorView(errorMessage: error)
			} else {
				ContentView(accountsManager: accountsManager)
			}
		}
		.modelContainer(modelContainer)
	}
	
	// MARK: - Création résiliente du conteneur
	
	/// Crée un `ModelContainer` avec une chaîne de fallback robuste.
	///
	/// Stratégie en 3 étapes (ne crash jamais) :
	/// 1. **Production** : on-disk + CloudKit (avec nettoyage et retry si échec)
	/// 2. **In-memory (schema explicite)** : pas de persistance, pas de CloudKit
	/// 3. **In-memory (config minimale)** : dernière tentative avec init simplifié
	///
	/// - Returns: Le conteneur créé et un message d'erreur optionnel pour l'UI
	private static func makeResilientContainer() -> (container: ModelContainer, error: String?) {
		
		// Tentative 1 : Conteneur production (on-disk + CloudKit)
		do {
			let container = try SwiftDataService.makeContainer()
			return (container, nil)
		} catch {
			print("❌ [Étape 1/3] Conteneur production échoué : \(error)")
		}
		
		// Tentative 2 : Conteneur en mémoire avec schema explicite
		do {
			let container = try SwiftDataService.makePreviewContainer()
			print("⚠️ [Étape 2/3] Fallback conteneur en mémoire (schema explicite)")
			return (
				container,
				"Base de données inaccessible.\nVos données ne seront pas sauvegardées.\nRedémarrez l'app ou réinstallez-la si le problème persiste."
			)
		} catch {
			print("❌ [Étape 2/3] Conteneur in-memory (schema explicite) échoué : \(error)")
		}
		
		// Tentative 3 : Conteneur en mémoire avec configuration minimale
		// Utilise l'initializer simplifié ModelContainer(for:configurations:) sans Schema séparé
		do {
			let container = try ModelContainer(
				for: Account.self, Transaction.self, WidgetShortcut.self, RecurringTransaction.self,
				configurations: ModelConfiguration(isStoredInMemoryOnly: true)
			)
			print("⚠️ [Étape 3/3] Fallback conteneur minimal en mémoire")
			return (
				container,
				"Erreur critique de base de données.\nRéinstallez l'application si le problème persiste."
			)
		} catch {
			print("❌ [Étape 3/3] Conteneur minimal échoué : \(error)")
			
			// Cas théoriquement impossible (in-memory + schema valide).
			// Si on arrive ici, un problème fondamental affecte les définitions @Model.
			fatalError("""
				💥 FATAL : Impossible de créer un ModelContainer (3 stratégies échouées).
				Dernière erreur : \(error)
				Action : Supprimer l'app et réinstaller depuis l'App Store.
				""")
		}
	}
}
