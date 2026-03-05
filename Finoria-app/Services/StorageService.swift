//
//  StorageService.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 12/02/2026.
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  🗑️ FICHIER OBSOLÈTE — À SUPPRIMER                                        ║
// ║                                                                            ║
// ║  L'ancien service de persistance UserDefaults est remplacé par SwiftData.  ║
// ║  Ce fichier est conservé temporairement car LegacyMigrationService         ║
// ║  utilise les mêmes clés UserDefaults pour la migration one-shot.           ║
// ║                                                                            ║
// ║  Supprimez ce fichier quand tous les utilisateurs ont migré vers           ║
// ║  la version SwiftData. Voir LegacyMigrationService.swift.                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation

/// @available(*, deprecated, message: "Remplacé par SwiftData via SwiftDataService + AccountsManager")
struct StorageService {
	
	static let schemaVersion = 1
	
	private let dataKey = "accounts_data_v2"
	private let selectedAccountKey = "lastSelectedAccountId"
	private let schemaVersionKey = "appSchemaVersion"
	
	struct AccountData: Codable {
		var account: LegacyAccountCodable
		var transactions: [LegacyTransactionCodable]
		var widgetShortcuts: [LegacyWidgetShortcutCodable]
		var recurringTransactions: [LegacyRecurringTransactionCodable]
	}
	
	// Types Codable legacy pour la compatibilité de décodage
	struct LegacyAccountCodable: Codable {
		let id: UUID
		var name: String
		var detail: String
		var style: AccountStyle
	}
	
	struct LegacyTransactionCodable: Codable {
		let id: UUID
		var amount: Double
		var comment: String
		var potentiel: Bool
		var date: Date?
		var category: TransactionCategory
		var recurringTransactionId: UUID?
	}
	
	struct LegacyWidgetShortcutCodable: Codable {
		let id: UUID
		let amount: Double
		let comment: String
		let type: TransactionType
		let category: TransactionCategory
	}
	
	struct LegacyRecurringTransactionCodable: Codable {
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
}
