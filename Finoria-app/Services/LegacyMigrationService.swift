//
//  LegacyMigrationService.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/03/2026.
//

import Foundation
import SwiftData

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  ⚠️  SERVICE DE MIGRATION LEGACY — À SUPPRIMER APRÈS MIGRATION COMPLÈTE   ║
// ║                                                                            ║
// ║  Ce fichier lit les données JSON stockées dans UserDefaults (ancien        ║
// ║  format v2) et les injecte dans SwiftData au premier lancement.            ║
// ║                                                                            ║
// ║  QUAND SUPPRIMER :                                                         ║
// ║  - Quand TOUS les utilisateurs ont mis à jour vers la version SwiftData    ║
// ║  - Supprimer ce fichier entier (LegacyMigrationService.swift)              ║
// ║  - Supprimer StorageService.swift                                          ║
// ║  - Supprimer l'appel à migrateIfNeeded() dans FinoriaApp.swift             ║
// ║  - Supprimer TransactionManager.swift                                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

struct LegacyMigrationService {
	
	// MARK: - Clés UserDefaults (ancien format)
	
	private static let legacyDataKey = "accounts_data_v2"
	private static let legacySchemaVersionKey = "appSchemaVersion"
	private static let migrationCompletedKey = "swiftdata_migration_completed_v1"
	
	// MARK: - Types Legacy (copie des anciens structs Codable)
	
	/// Ces types reproduisent exactement le format JSON stocké dans UserDefaults
	/// par l'ancienne version de StorageService. Ils sont nécessaires pour décoder
	/// les données existantes et les convertir en modèles SwiftData.
	
	private struct LegacyAccountData: Codable {
		var account: LegacyAccount
		var transactions: [LegacyTransaction]
		var widgetShortcuts: [LegacyWidgetShortcut]
		var recurringTransactions: [LegacyRecurringTransaction]
	}
	
	private struct LegacyAccount: Codable {
		let id: UUID
		var name: String
		var detail: String
		var style: AccountStyle
	}
	
	private struct LegacyTransaction: Codable {
		let id: UUID
		var amount: Double
		var comment: String
		var potentiel: Bool
		var date: Date?
		var category: TransactionCategory
		var recurringTransactionId: UUID?
	}
	
	private struct LegacyWidgetShortcut: Codable {
		let id: UUID
		let amount: Double
		let comment: String
		let type: TransactionType
		let category: TransactionCategory
	}
	
	private struct LegacyRecurringTransaction: Codable {
		let id: UUID
		let amount: Double
		let comment: String
		let type: TransactionType
		let category: TransactionCategory
		let frequency: RecurrenceFrequency
		let startDate: Date
		var lastGeneratedDate: Date?
		var isPaused: Bool
	}
	
	// MARK: - Migration
	
	/// Migre les données UserDefaults vers SwiftData si ce n'est pas déjà fait.
	///
	/// Cette méthode est **idempotente** : elle ne s'exécute qu'une seule fois.
	/// Au premier lancement après mise à jour :
	/// 1. Lit les données JSON depuis UserDefaults
	/// 2. Crée les modèles SwiftData correspondants avec les mêmes UUIDs
	/// 3. Établit les relations (Account ↔ Transaction, etc.)
	/// 4. Sauvegarde dans SwiftData
	/// 5. Marque la migration comme terminée
	///
	/// - Parameter context: Le `ModelContext` dans lequel insérer les données
	static func migrateIfNeeded(context: ModelContext) {
		// Vérifier si la migration a déjà été effectuée
		guard !UserDefaults.standard.bool(forKey: migrationCompletedKey) else { return }
		
		// Lire les données legacy depuis UserDefaults
		guard let data = UserDefaults.standard.data(forKey: legacyDataKey),
			  let decoded = try? JSONDecoder().decode([LegacyAccountData].self, from: data) else {
			// Pas de données à migrer (nouveau utilisateur ou données corrompues)
			UserDefaults.standard.set(true, forKey: migrationCompletedKey)
			print("📦 Migration SwiftData : aucune donnée legacy à migrer")
			return
		}
		
		print("📦 Migration SwiftData : \(decoded.count) compte(s) à migrer...")
		
		for entry in decoded {
			// 1. Créer le compte SwiftData
			let account = Account(
				id: entry.account.id,
				name: entry.account.name,
				detail: entry.account.detail,
				style: entry.account.style
			)
			context.insert(account)
			
			// 2. Créer les récurrences (avant les transactions pour pouvoir les lier)
			var recurringMap: [UUID: RecurringTransaction] = [:]
			for old in entry.recurringTransactions {
				let recurring = RecurringTransaction(
					id: old.id,
					amount: old.amount,
					comment: old.comment,
					type: old.type,
					category: old.category,
					frequency: old.frequency,
					startDate: old.startDate,
					lastGeneratedDate: old.lastGeneratedDate,
					isPaused: old.isPaused
				)
				recurring.account = account
				context.insert(recurring)
				recurringMap[old.id] = recurring
			}
			
			// 3. Créer les transactions (avec lien vers récurrence source si applicable)
			for old in entry.transactions {
				let transaction = Transaction(
					id: old.id,
					amount: old.amount,
					comment: old.comment,
					potentiel: old.potentiel,
					date: old.date,
					category: old.category,
					sourceRecurringTransaction: old.recurringTransactionId.flatMap { recurringMap[$0] }
				)
				transaction.account = account
				context.insert(transaction)
			}
			
			// 4. Créer les raccourcis
			for old in entry.widgetShortcuts {
				let shortcut = WidgetShortcut(
					id: old.id,
					amount: old.amount,
					comment: old.comment,
					type: old.type,
					category: old.category
				)
				shortcut.account = account
				context.insert(shortcut)
			}
		}
		
		// 5. Sauvegarder dans SwiftData
		do {
			try context.save()
			print("✅ Migration SwiftData terminée avec succès")
		} catch {
			print("❌ Erreur lors de la migration SwiftData : \(error.localizedDescription)")
			return // Ne pas marquer comme terminée si la sauvegarde échoue
		}
		
		// 6. Marquer la migration comme terminée
		UserDefaults.standard.set(true, forKey: migrationCompletedKey)
		
		// ╔═══════════════════════════════════════════════════════════════════════╗
		// ║  🗑️ POST-MIGRATION — Nettoyage des données UserDefaults             ║
		// ║                                                                     ║
		// ║  Décommentez les lignes ci-dessous UNIQUEMENT quand TOUS les        ║
		// ║  utilisateurs ont migré vers la version SwiftData.                  ║
		// ║                                                                     ║
		// ║  Ensuite, supprimez entièrement :                                   ║
		// ║  • Ce fichier (LegacyMigrationService.swift)                        ║
		// ║  • StorageService.swift                                             ║
		// ║  • TransactionManager.swift                                         ║
		// ║  • L'appel LegacyMigrationService.migrateIfNeeded() dans           ║
		// ║    FinoriaApp.swift                                                 ║
		// ╚═══════════════════════════════════════════════════════════════════════╝
		//
		// UserDefaults.standard.removeObject(forKey: "accounts_data_v2")
		// UserDefaults.standard.removeObject(forKey: "appSchemaVersion")
	}
}
