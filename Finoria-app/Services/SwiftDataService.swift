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
/// ## Synchronisation CloudKit (ACTIVE)
/// La synchronisation iCloud est activée via `cloudKitDatabase: .automatic`.
/// Container CloudKit : `iCloud.com.godefroyinformatique.GDF-app`
///
/// Prérequis vérifiés :
/// - ✅ Capability CloudKit dans Signing & Capabilities
/// - ✅ Container CloudKit déclaré dans les entitlements (Debug + Release)
/// - ✅ `cloudKitDatabase: .automatic` configuré dans `makeContainer()`
/// - ✅ Aucun `@Attribute(.unique)` sur les modèles (incompatible avec CloudKit)
/// - ⚠️ Tester sur un **appareil physique** (CloudKit ne fonctionne pas en simulateur)
///
/// **Important** : CloudKit ne supporte PAS `@Attribute(.unique)`.
/// L'unicité des UUID est garantie par génération côté client (`UUID()` dans les `init`).
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
	/// CloudKit est activé pour la synchronisation iCloud entre appareils.
	///
	/// Stratégie de résilience :
	/// 1. Tente de créer/ouvrir le store normalement
	/// 2. Si échec (schéma incompatible, base corrompue…), supprime le store et retente
	/// 3. En dernier recours, l'appelant peut fallback sur un conteneur en mémoire
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
		
		do {
			return try ModelContainer(for: schema, configurations: [configuration])
		} catch {
			print("⚠️ Échec création ModelContainer : \(error)")
			print("⚠️ Suppression du store corrompu et nouvelle tentative…")
			
			// Supprimer le store existant (potentiellement corrompu ou incompatible)
			deleteExistingStore()
			
			// Retenter avec un store vierge
			return try ModelContainer(for: schema, configurations: [configuration])
		}
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
	
	// MARK: - Store Cleanup
	
	/// Supprime les fichiers du store SwiftData existant sur disque.
	///
	/// Utilisé en cas de base de données corrompue ou d'incompatibilité de schéma
	/// pour permettre une recréation propre du conteneur.
	///
	/// Supprime tous les fichiers dont le nom commence par `default.store`
	/// (inclut `-wal`, `-shm`, et autres métadonnées éventuelles).
	private static func deleteExistingStore() {
		let fileManager = FileManager.default
		guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			print("⚠️ Impossible de localiser le répertoire Application Support")
			return
		}
		
		do {
			let contents = try fileManager.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil)
			var deletedCount = 0
			for fileURL in contents where fileURL.lastPathComponent.hasPrefix("default.store") {
				try fileManager.removeItem(at: fileURL)
				print("🗑️ Supprimé : \(fileURL.lastPathComponent)")
				deletedCount += 1
			}
			if deletedCount == 0 {
				print("ℹ️ Aucun fichier default.store trouvé dans Application Support")
			}
		} catch {
			print("❌ Erreur lors du nettoyage du store : \(error)")
		}
	}
}
