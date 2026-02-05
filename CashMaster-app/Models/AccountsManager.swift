//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import Foundation

//  Classe centrale de gestion des comptes et transactions.
//
//  Très important : toutes les modifications de comptes/transactions DOIVENT passer
//  par cette classe.
//  Pourquoi ?
//  - C'est elle qui appelle `objectWillChange.send()` après chaque mise à jour
//    afin que SwiftUI rafraîchisse automatiquement l'interface.
//  - Si tu modifies directement un `Transaction` ou un `TransactionManager` sans passer par ici,
//    l'UI ne sera pas informée et l'affichage ne se mettra pas à jour.
class AccountsManager: ObservableObject {
	
	// MARK: - Données publiées
	
	/// Liste des comptes
	@Published private(set) var accounts: [Account] = []
	
	/// Dictionnaire des gestionnaires de transactions, où les clés sont des IDs de comptes
	/// et les valeurs sont des instances de TransactionManager (liste des transactions pour un compte)
	@Published private(set) var transactionManagers: [UUID: TransactionManager] = [:]
	@Published var selectedAccountId: UUID? {
		didSet {
			if let id = selectedAccountId {
				UserDefaults.standard.set(id.uuidString, forKey: "lastSelectedAccountId")
			}
		}
	}
	
	var selectedAccount: Account? {
		accounts.first { $0.id == selectedAccountId }
	}

	private let saveKey = "accounts_data_v2"
	
	// MARK: - Init
	
	init() {
		load()
		if let idString = UserDefaults.standard.string(forKey: "lastSelectedAccountId"),
		   let id = UUID(uuidString: idString) {
			selectedAccountId = id
		}
	}
	
	// MARK: - Structure de sauvegarde
	
	private struct AccountData: Codable {
		var account: Account
		var transactions: [Transaction]
		var widgetShortcuts: [WidgetShortcut]
	}

	// MARK: - Gestion des comptes
	
	func ajouterCompte(_ account: Account) {
		guard !accounts.contains(where: { $0.id == account.id }) else { return }
		accounts.append(account)
		transactionManagers[account.id] = TransactionManager(accountName: account.name)
		save()
		objectWillChange.send()
	}
	
	func deleteAccount(_ account: Account) {
		accounts.removeAll { $0.id == account.id }
		transactionManagers.removeValue(forKey: account.id)
		save()
		if accounts.isEmpty {
			selectedAccountId = nil
		} else if selectedAccountId == account.id {
			selectedAccountId = accounts.first?.id
		}
		objectWillChange.send()
	}
	
	func getAllAccounts() -> [Account] {
		accounts.sorted { $0.name < $1.name }
	}
	
	// MARK: - Gestion des transactions
	
	func ajouterTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.ajouter(transaction)
		save()
		objectWillChange.send()
	}
	
	func supprimerTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.supprimer(transaction)
		save()
		objectWillChange.send()
	}
	
	func validerTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		let validatedTransaction = transaction.validated(at: Date())
		transactionManagers[accountId]?.mettreAJour(validatedTransaction)
		save()
		objectWillChange.send()
	}
	
	func mettreAJourTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.mettreAJour(transaction)
		save()
		objectWillChange.send()
	}
	
	func transactions() -> [Transaction] {
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.transactions ?? []
	}
	
	// MARK: - Totaux (délégués à CalculationService)
	
	func totalNonPotentiel(for account: Account) -> Double {
		let txs = transactionManagers[account.id]?.transactions ?? []
		return CalculationService.totalNonPotentiel(transactions: txs)
	}
	
	func totalPotentiel(for account: Account) -> Double {
		let txs = transactionManagers[account.id]?.transactions ?? []
		return CalculationService.totalPotentiel(transactions: txs)
	}
	
	// MARK: - Regroupements (délégués à CalculationService)
	
	func anneesDisponibles() -> [Int] {
		CalculationService.anneesDisponibles(transactions: transactions())
	}
	
	func totalPourAnnee(_ year: Int) -> Double {
		CalculationService.totalPourAnnee(year, transactions: transactions())
	}
	
	func totalPourMois(_ month: Int, year: Int) -> Double {
		CalculationService.totalPourMois(month, year: year, transactions: transactions())
	}
	
	func pourcentageChangementMois() -> Double? {
		CalculationService.pourcentageChangementMois(transactions: transactions())
	}
	
	// MARK: - Filtres (délégués à CalculationService)
	
	func potentialTransactions() -> [Transaction] {
		CalculationService.potentialTransactions(from: transactions())
	}
	
	func validatedTransactions(year: Int? = nil, month: Int? = nil) -> [Transaction] {
		CalculationService.validatedTransactions(from: transactions(), year: year, month: month)
	}
	
	// MARK: - Persistance
	
	/// Sauvegarde publique (pour les modifications de transaction)
	func sauvegarder() {
		save()
		objectWillChange.send()
	}
	
	private func save() {
		let dataArray = accounts.map { account in
			AccountData(
				account: account,
				transactions: transactionManagers[account.id]?.transactions ?? [],
				widgetShortcuts: transactionManagers[account.id]?.widgetShortcuts ?? []
			)
		}
		if let data = try? JSONEncoder().encode(dataArray) {
			UserDefaults.standard.set(data, forKey: saveKey)
		}
	}
	
	private func load() {
		guard let data = UserDefaults.standard.data(forKey: saveKey),
			  let decoded = try? JSONDecoder().decode([AccountData].self, from: data) else {
			return
		}
		
		var loadedAccounts: [Account] = []
		var loadedManagers: [UUID: TransactionManager] = [:]
		
		for entry in decoded {
			loadedAccounts.append(entry.account)
			let manager = TransactionManager(accountName: entry.account.name)
			manager.transactions = entry.transactions
			manager.widgetShortcuts = entry.widgetShortcuts
			loadedManagers[entry.account.id] = manager
		}
		
		accounts = loadedAccounts
		transactionManagers = loadedManagers
	}
	
	// MARK: - Widgets
	
	func getWidgetShortcuts() -> [WidgetShortcut] {
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.widgetShortcuts.append(shortcut)
		save()
		objectWillChange.send()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.widgetShortcuts.removeAll { $0.id == shortcut.id }
		save()
		objectWillChange.send()
	}
	
	// MARK: - Export/Import CSV (délégués à CSVService)
	
	/// Génère un fichier CSV contenant toutes les transactions du compte sélectionné
	/// - Returns: URL temporaire du fichier CSV généré, ou nil si erreur
	func generateCSV() -> URL? {
		guard let account = selectedAccount else {
			print("❌ Aucun compte sélectionné pour l'export")
			return nil
		}
		return CSVService.generateCSV(transactions: transactions(), accountName: account.name)
	}
	
	/// Importe des transactions depuis un fichier CSV
	/// - Parameter url: URL du fichier CSV à importer
	/// - Returns: Nombre de transactions importées
	func importCSV(from url: URL) -> Int {
		guard selectedAccountId != nil else {
			print("❌ Aucun compte sélectionné")
			return 0
		}
		
		let importedTransactions = CSVService.importCSV(from: url)
		
		for transaction in importedTransactions {
			ajouterTransaction(transaction)
		}
		
		return importedTransactions.count
	}
}

