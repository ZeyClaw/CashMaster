//
//  TransactionManager.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  🗑️ FICHIER OBSOLÈTE — À SUPPRIMER                                        ║
// ║                                                                            ║
// ║  Cette classe est remplacée par les relations SwiftData :                  ║
// ║  Account.transactions, Account.widgetShortcuts, Account.recurringTransactions║
// ║                                                                            ║
// ║  Supprimez ce fichier quand tous les utilisateurs ont migré vers           ║
// ║  la version SwiftData. Voir LegacyMigrationService.swift.                 ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import Foundation

/// @available(*, deprecated, message: "Remplacé par les relations SwiftData sur Account")
class TransactionManager {
	let accountName: String
	var transactions: [Transaction] = []
	var widgetShortcuts: [WidgetShortcut] = []
	var recurringTransactions: [RecurringTransaction] = []
	
	init(accountName: String) {
		self.accountName = accountName
	}
}
