//
//  SwiftDataService.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/03/2026.
//

import Foundation
import SwiftData

/// Configuration du conteneur SwiftData pour Finoria.
///
/// Responsabilités :
/// - Créer et configurer le `ModelContainer` avec le schéma courant
/// - Fournir un conteneur en mémoire pour les Previews et tests
///
/// ## Synchronisation CloudKit (DÉSACTIVÉE)
/// CloudKit est désactivé pour le moment (cloudKitDatabase: .none).
/// Pour réactiver plus tard : changer `.none` en `.automatic`
enum SwiftDataService {
	
	// MARK: - Schema
	
	/// Liste des modèles SwiftData de l'application
	static let models: [any PersistentModel.Type] = [
		Account.self,
		Transaction.self,
		WidgetShortcut.self,
		RecurringTransaction.self
	]
	
	// MARK: - Production Container
	
	/// Crée le `ModelContainer` configuré pour l'application en production.
	///
	/// Les données sont persistées sur disque dans le répertoire par défaut de l'app.
	static func makeContainer() throws -> ModelContainer {
		let configuration = ModelConfiguration(
			isStoredInMemoryOnly: false,
			allowsSave: true,
			cloudKitDatabase: .none
		)
		
		return try ModelContainer(
			for: Account.self, Transaction.self, WidgetShortcut.self, RecurringTransaction.self,
			configurations: configuration
		)
	}
	
	// MARK: - Preview / Test Container
	
	/// Crée un `ModelContainer` en mémoire pour les Previews et les tests unitaires.
	///
	/// Les données ne sont jamais écrites sur disque.
	static func makePreviewContainer() throws -> ModelContainer {
		let configuration = ModelConfiguration(
			isStoredInMemoryOnly: true,
			allowsSave: true,
			cloudKitDatabase: .none
		)
		
		return try ModelContainer(
			for: Account.self, Transaction.self, WidgetShortcut.self, RecurringTransaction.self,
			configurations: configuration
		)
	}
}
