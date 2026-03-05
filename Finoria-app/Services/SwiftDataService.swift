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
/// ## Activer la synchronisation CloudKit
/// 1. Ajouter la capability **CloudKit** dans Xcode ➜ Signing & Capabilities
/// 2. Créer un container CloudKit (ex: `iCloud.com.votreapp.finoria`)
/// 3. Dans `makeContainer()`, décommenter `cloudKitDatabase: .automatic`
/// 4. Tester sur un **appareil physique** (CloudKit ne fonctionne pas en simulateur)
///
/// ## Gérer les futures versions du schéma (Schema Migration)
///
/// SwiftData gère automatiquement les **migrations légères** :
/// - Ajouter une propriété avec une valeur par défaut → aucune action requise
/// - Exemple : `var newField: String = ""`
///
/// Pour des **migrations complexes** (renommage, suppression, transformation) :
///
/// ```
/// // Étape 1 : Copier les modèles ACTUELS dans un enum versionné
/// enum FinoriaSchemaV1: VersionedSchema {
///     static var versionIdentifier = Schema.Version(1, 0, 0)
///     static var models: [any PersistentModel.Type] = [...]
///     @Model final class Account { /* propriétés V1 */ }
///     @Model final class Transaction { /* propriétés V1 */ }
/// }
///
/// // Étape 2 : Modifier les modèles principaux (Account.swift, etc.) = V2
///
/// // Étape 3 : Créer le plan de migration
/// enum FinoriaMigrationPlan: SchemaMigrationPlan {
///     static var schemas: [any VersionedSchema.Type] = [
///         FinoriaSchemaV1.self, FinoriaSchemaV2.self
///     ]
///     static var stages: [MigrationStage] = [
///         .lightweight(fromVersion: FinoriaSchemaV1.self, toVersion: FinoriaSchemaV2.self)
///     ]
/// }
///
/// // Étape 4 : Passer le plan au conteneur
/// ModelContainer(for: schema, migrationPlan: FinoriaMigrationPlan.self, configurations: [...])
/// ```
enum SwiftDataService {
	
	// MARK: - Production Container
	
	/// Crée le `ModelContainer` configuré pour l'application en production.
	///
	/// Les données sont persistées sur disque dans le répertoire par défaut de l'app.
	/// Pour activer CloudKit, décommenter la ligne `cloudKitDatabase:` ci-dessous.
	static func makeContainer() throws -> ModelContainer {
		let schema = Schema([
			Account.self,
			Transaction.self,
			WidgetShortcut.self,
			RecurringTransaction.self
		])
		
		let configuration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false,
			cloudKitDatabase: .automatic
		)
		
		return try ModelContainer(for: schema, configurations: [configuration])
	}
	
	// MARK: - Preview / Test Container
	
	/// Crée un `ModelContainer` en mémoire pour les Previews et les tests unitaires.
	///
	/// Les données ne sont jamais écrites sur disque.
	static func makePreviewContainer() throws -> ModelContainer {
		let schema = Schema([
			Account.self,
			Transaction.self,
			WidgetShortcut.self,
			RecurringTransaction.self
		])
		
		let configuration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: true
		)
		
		return try ModelContainer(for: schema, configurations: [configuration])
	}
}
