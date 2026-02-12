//
//  StorageService.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 12/02/2026.
//

import Foundation

/// Service responsable de la persistance des données dans UserDefaults.
/// Encapsule toute la logique de stockage dans un service testable et indépendant.
///
/// Principe : AccountsManager délègue ici toute la sérialisation/désérialisation.
/// Ce service ne connaît ni SwiftUI ni l'état de l'application.
struct StorageService {
	
	private let saveKey = "accounts_data_v2"
	private let selectedAccountKey = "lastSelectedAccountId"
	
	// MARK: - Structure de sauvegarde
	
	/// Format de persistance : un tableau de AccountData encodé en JSON dans UserDefaults.
	struct AccountData: Codable {
		var account: Account
		var transactions: [Transaction]
		var widgetShortcuts: [WidgetShortcut]
		var recurringTransactions: [RecurringTransaction]
		
		// Rétrocompatibilité : recurringTransactions absent dans les anciennes données
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			account = try container.decode(Account.self, forKey: .account)
			transactions = try container.decode([Transaction].self, forKey: .transactions)
			widgetShortcuts = try container.decode([WidgetShortcut].self, forKey: .widgetShortcuts)
			recurringTransactions = try container.decodeIfPresent([RecurringTransaction].self, forKey: .recurringTransactions) ?? []
		}
		
		init(account: Account, transactions: [Transaction], widgetShortcuts: [WidgetShortcut], recurringTransactions: [RecurringTransaction]) {
			self.account = account
			self.transactions = transactions
			self.widgetShortcuts = widgetShortcuts
			self.recurringTransactions = recurringTransactions
		}
	}
	
	// MARK: - Sauvegarde / Chargement des comptes
	
	/// Persiste l'ensemble des comptes et leurs données associées
	func save(accounts: [Account], managers: [UUID: TransactionManager]) {
		let dataArray = accounts.map { account in
			AccountData(
				account: account,
				transactions: managers[account.id]?.transactions ?? [],
				widgetShortcuts: managers[account.id]?.widgetShortcuts ?? [],
				recurringTransactions: managers[account.id]?.recurringTransactions ?? []
			)
		}
		if let data = try? JSONEncoder().encode(dataArray) {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}
	
	/// Charge tous les comptes et reconstruit les TransactionManagers
	func load() -> (accounts: [Account], managers: [UUID: TransactionManager]) {
		guard let data = UserDefaults.standard.data(forKey: saveKey),
			  let decoded = try? JSONDecoder().decode([AccountData].self, from: data) else {
			return ([], [:])
		}
		
		var accounts: [Account] = []
		var managers: [UUID: TransactionManager] = [:]
		
		for entry in decoded {
			accounts.append(entry.account)
			let manager = TransactionManager(accountName: entry.account.name)
			manager.transactions = entry.transactions
			manager.widgetShortcuts = entry.widgetShortcuts
			manager.recurringTransactions = entry.recurringTransactions
			managers[entry.account.id] = manager
		}
		
		return (accounts, managers)
	}
	
	// MARK: - Compte sélectionné
	
	/// Persiste l'ID du compte actuellement sélectionné
	func saveSelectedAccountId(_ id: UUID?) {
		if let id = id {
			UserDefaults.standard.set(id.uuidString, forKey: selectedAccountKey)
		} else {
			UserDefaults.standard.removeObject(forKey: selectedAccountKey)
		}
	}
	
	/// Charge l'ID du dernier compte sélectionné
	func loadSelectedAccountId() -> UUID? {
		guard let idString = UserDefaults.standard.string(forKey: selectedAccountKey) else { return nil }
		return UUID(uuidString: idString)
	}
}
