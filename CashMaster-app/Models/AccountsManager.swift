//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

// AccountsManager.swift
import Foundation

//  Classe centrale de gestion des comptes et transactions.
//
//  Très important : toutes les modifications de comptes/transactions DOIVENT passer
//  par cette classe.
//  Pourquoi ?
//  - C’est elle qui appelle `objectWillChange.send()` après chaque mise à jour
//    afin que SwiftUI rafraîchisse automatiquement l’interface.
//  - Si tu modifies directement un `Transaction` ou un `TransactionManager` sans passer par ici,
//    l’UI ne sera pas informée et l’affichage ne se mettra pas à jour.
class AccountsManager: ObservableObject {
	/// Dictionnaire des gestionnaires de transactions, où les clés sont des noms de comptes et les valeurs sont des instances de TransactionManager correspondant à chaque compte (liste des transactions pour un compte).
	@Published private(set) var managers: [String: TransactionManager] = [:]
	@Published var selectedAccount: String? {
		didSet {
			UserDefaults.standard.set(selectedAccount, forKey: "lastSelectedAccount")
		}
	}

	private let saveKey = "accounts_data"
	
	init() { 
		load()
		selectedAccount = UserDefaults.standard.string(forKey: "lastSelectedAccount")
	}
	
	private struct AccountData: Codable {
		var transactions: [Transaction]
		var widgetShortcuts: [WidgetShortcut]
	}

	
	// MARK: - Gestion des comptes
	private func creerCompte(nom: String) {
		guard managers[nom] == nil else { return }
		managers[nom] = TransactionManager(accountName: nom)
		save()
		objectWillChange.send()
	}
	
	func ajouterCompte(_ nom: String) {
		creerCompte(nom: nom)
	}
	
	func deleteAccount(_ account: String) {
		managers.removeValue(forKey: account)
		save()
		if selectedAccount == account {
			selectedAccount = getAllAccounts().first
		}
		objectWillChange.send()
	}
	
	func getAllAccounts() -> [String] {
		Array(managers.keys).sorted()
	}
	
	// MARK: - Gestion des transactions
	func ajouterTransaction(_ transaction: Transaction) {
		guard let account = selectedAccount else { return }
		if managers[account] == nil { creerCompte(nom: account) }
		managers[account]?.ajouter(transaction)
		save()
		objectWillChange.send()
	}
	
	func supprimerTransaction(_ transaction: Transaction) {
		guard let account = selectedAccount else { return }
		managers[account]?.supprimer(transaction)
		save()
		objectWillChange.send()
	}
	
	func validerTransaction(_ transaction: Transaction) {
		transaction.valider(date: Date())
		save()
		objectWillChange.send()
	}
	
	func transactions() -> [Transaction] {
		guard let account = selectedAccount else { return [] }
		return managers[account]?.transactions ?? []
	}
	
	// MARK: - Totaux
	func totalNonPotentiel(for account: String) -> Double {
		managers[account]?.totalNonPotentiel() ?? 0
	}
	
	func totalPotentiel(for account: String) -> Double {
		managers[account]?.totalPotentiel() ?? 0
	}
	
	
	// MARK: - Persistance
	private func save() {
		if let data = try? JSONEncoder().encode(
			managers.mapValues { manager in
				AccountData(
					transactions: manager.transactions,
					widgetShortcuts: manager.widgetShortcuts
				)
			}
		)
 {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}
	
	private func load() {
		if let data = UserDefaults.standard.data(forKey: saveKey),
		   let decoded = try? JSONDecoder().decode([String: AccountData].self, from: data) {
			managers = decoded.mapValues { entry in
				let manager = TransactionManager(accountName: "Compte")
				manager.transactions = entry.transactions
				manager.widgetShortcuts = entry.widgetShortcuts
				return manager
			}
		}
	}
	
	// MARK: - Regroupements
	func anneesDisponibles() -> [Int] {
		let txs = transactions().filter { !$0.potentiel }
		let years = txs.compactMap { tx -> Int? in
			guard let d = tx.date else { return nil }
			return Calendar.current.component(.year, from: d)
		}
		return Array(Set(years)).sorted()
	}
	
	func totalPourAnnee(_ year: Int) -> Double {
		transactions()
			.filter { !$0.potentiel && Calendar.current.component(.year, from: $0.date ?? Date()) == year }
			.map { $0.amount }
			.reduce(0, +)
	}
	
	func totalPourMois(_ month: Int, year: Int) -> Double {
		transactions()
			.filter {
				guard !$0.potentiel, let date = $0.date else { return false }
				let comp = Calendar.current.dateComponents([.year, .month], from: date)
				return comp.year == year && comp.month == month
			}
			.map { $0.amount }
			.reduce(0, +)
	}
	
	// MARK: - Sélections utiles
	
	/// Retourne toutes les transactions validées (non potentielles)
	private func totalValidatedTransactions() -> [Transaction] {
		transactions().filter { !$0.potentiel }
	}
	
	/// Retourne toutes les transactions potentielles
	func potentialTransactions() -> [Transaction] {
		transactions().filter { $0.potentiel }
	}
	
	/// Retourne toutes les transactions validées d'une année et/ou d'un mois
	func validatedTransactions(year: Int? = nil, month: Int? = nil) -> [Transaction] {
		var txs = totalValidatedTransactions()
		if let year = year {
			txs = txs.filter { Calendar.current.component(.year, from: $0.date ?? Date()) == year }
		}
		if let month = month {
			txs = txs.filter { Calendar.current.component(.month, from: $0.date ?? Date()) == month }
		}
		return txs
	}
	
	
	// MARK: - Widgets
	func getWidgetShortcuts() -> [WidgetShortcut] {
		guard let account = selectedAccount else { return [] }
		return managers[account]?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let account = selectedAccount else { return }
		managers[account]?.widgetShortcuts.append(shortcut)
		save()
		objectWillChange.send()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let account = selectedAccount else { return }
		managers[account]?.widgetShortcuts.removeAll { $0.id == shortcut.id }
		save()
		objectWillChange.send()
	}


}

