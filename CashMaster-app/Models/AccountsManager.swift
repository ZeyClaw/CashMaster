//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import Foundation

//  Central class for managing accounts and transactions.
//
//  IMPORTANT: All account/transaction modifications MUST go through
//  this class.
//  Why?
//  - It calls `objectWillChange.send()` after each update
//    so SwiftUI automatically refreshes the interface.
//  - If you modify a `Transaction` or `TransactionManager` directly without going through here,
//    the UI will not be notified and the display won't update.
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
		var recurringTransactions: [RecurringTransaction]
		
		// Rétrocompatibilité : si la clé n'existe pas dans les anciennes données
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

	// MARK: - Account Management
	
	func addAccount(_ account: Account) {
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
	
	func updateAccount(_ account: Account) {
		guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
		accounts[index] = account
		save()
		objectWillChange.send()
	}
	
	func resetAccount(_ account: Account) {
		transactionManagers[account.id]?.transactions.removeAll()
		save()
		objectWillChange.send()
	}
	
	func getAllAccounts() -> [Account] {
		accounts.sorted { $0.name < $1.name }
	}
	
	// MARK: - Transaction Management
	
	func addTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.add(transaction)
		save()
		objectWillChange.send()
	}
	
	func deleteTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.remove(transaction)
		save()
		objectWillChange.send()
	}
	
	func validateTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		let validatedTransaction = transaction.validated(at: Date())
		transactionManagers[accountId]?.update(validatedTransaction)
		save()
		objectWillChange.send()
	}
	
	func updateTransaction(_ transaction: Transaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.update(transaction)
		save()
		objectWillChange.send()
	}
	
	func transactions() -> [Transaction] {
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.transactions ?? []
	}
	
	// MARK: - Totals (delegated to CalculationService)
	
	func totalNonPotential(for account: Account) -> Double {
		let txs = transactionManagers[account.id]?.transactions ?? []
		return CalculationService.totalNonPotential(transactions: txs)
	}
	
	func totalPotential(for account: Account) -> Double {
		let txs = transactionManagers[account.id]?.transactions ?? []
		return CalculationService.totalPotential(transactions: txs)
	}
	
	// MARK: - Groupings (delegated to CalculationService)
	
	func availableYears() -> [Int] {
		CalculationService.availableYears(transactions: transactions())
	}
	
	func totalForYear(_ year: Int) -> Double {
		CalculationService.totalForYear(year, transactions: transactions())
	}
	
	func totalForMonth(_ month: Int, year: Int) -> Double {
		CalculationService.totalForMonth(month, year: year, transactions: transactions())
	}
	
	func monthlyChangePercentage() -> Double? {
		CalculationService.monthlyChangePercentage(transactions: transactions())
	}
	
	// MARK: - Filters (delegated to CalculationService)
	
	func potentialTransactions() -> [Transaction] {
		CalculationService.potentialTransactions(from: transactions())
	}
	
	func validatedTransactions(year: Int? = nil, month: Int? = nil) -> [Transaction] {
		CalculationService.validatedTransactions(from: transactions(), year: year, month: month)
	}
	
	// MARK: - Persistence
	
	/// Public save (for transaction modifications)
	func saveData() {
		save()
		objectWillChange.send()
	}
	
	private func save() {
		let dataArray = accounts.map { account in
			AccountData(
				account: account,
				transactions: transactionManagers[account.id]?.transactions ?? [],
				widgetShortcuts: transactionManagers[account.id]?.widgetShortcuts ?? [],
				recurringTransactions: transactionManagers[account.id]?.recurringTransactions ?? []
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
			manager.recurringTransactions = entry.recurringTransactions
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
	
	func updateWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let accountId = selectedAccountId,
			  let index = transactionManagers[accountId]?.widgetShortcuts.firstIndex(where: { $0.id == shortcut.id }) else { return }
		transactionManagers[accountId]?.widgetShortcuts[index] = shortcut
		save()
		objectWillChange.send()
	}
	
	// MARK: - CSV Export/Import (delegated to CSVService)
	
	/// Generates a CSV file containing all transactions from the selected account
	/// - Returns: Temporary URL of the generated CSV file, or nil if error
	func generateCSV() -> URL? {
		guard let account = selectedAccount else {
			print("❌ No account selected for export")
			return nil
		}
		return CSVService.generateCSV(transactions: transactions(), accountName: account.name)
	}
	
	/// Imports transactions from a CSV file
	/// - Parameter url: URL of the CSV file to import
	/// - Returns: Number of imported transactions
	func importCSV(from url: URL) -> Int {
		guard selectedAccountId != nil else {
			print("❌ No account selected")
			return 0
		}
		
		let importedTransactions = CSVService.importCSV(from: url)
		
		for transaction in importedTransactions {
			addTransaction(transaction)
		}
		
		return importedTransactions.count
	}
	
	// MARK: - Recurring Transactions
	
	func getRecurringTransactions() -> [RecurringTransaction] {
		guard let accountId = selectedAccountId else { return [] }
		return transactionManagers[accountId]?.recurringTransactions ?? []
	}
	
	func addRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let accountId = selectedAccountId else { return }
		transactionManagers[accountId]?.recurringTransactions.append(recurring)
		save()
		objectWillChange.send()
		// Générer immédiatement les transactions à venir
		processRecurringTransactions()
	}
	
	func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let accountId = selectedAccountId else { return }
		// Supprimer les transactions potentielles liées à cette récurrence
		transactionManagers[accountId]?.transactions.removeAll {
			$0.recurringTransactionId == recurring.id && $0.potentiel
		}
		// Supprimer la récurrence elle-même
		transactionManagers[accountId]?.recurringTransactions.removeAll { $0.id == recurring.id }
		save()
		objectWillChange.send()
	}
	
	func updateRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let accountId = selectedAccountId,
			  let index = transactionManagers[accountId]?.recurringTransactions.firstIndex(where: { $0.id == recurring.id }) else { return }
		// Supprimer les transactions potentielles liées à cette récurrence
		transactionManagers[accountId]?.transactions.removeAll {
			$0.recurringTransactionId == recurring.id && $0.potentiel
		}
		// Mettre à jour avec lastGeneratedDate remise à nil pour regénérer
		var updatedRecurring = recurring
		updatedRecurring.lastGeneratedDate = nil
		transactionManagers[accountId]?.recurringTransactions[index] = updatedRecurring
		save()
		objectWillChange.send()
		// Regénérer les transactions à venir
		processRecurringTransactions()
	}
	
	/// Génère automatiquement les transactions potentielles pour les récurrences à venir (< 1 mois)
	/// et valide celles dont la date est aujourd'hui ou passée.
	/// Appelé au lancement de l'app, après chaque ajout/modification de récurrence,
	/// et quand l'app revient au premier plan.
	func processRecurringTransactions() {
		let calendar = Calendar.current
		let now = Date()
		let startOfToday = calendar.startOfDay(for: now)
		
		for account in accounts {
			guard let manager = transactionManagers[account.id] else { continue }
			
			var updated = false
			
			for i in manager.recurringTransactions.indices {
				let recurring = manager.recurringTransactions[i]
				let pending = recurring.pendingTransactions()
				
				for entry in pending {
					// Vérifier qu'une transaction n'existe pas déjà pour cette date et récurrence
					let alreadyExists = manager.transactions.contains { tx in
						tx.recurringTransactionId == recurring.id &&
						tx.date != nil &&
						calendar.isDate(tx.date!, inSameDayAs: entry.date)
					}
					if !alreadyExists {
						manager.add(entry.transaction)
						updated = true
					}
				}
				
				// Mettre à jour la dernière date générée
				if let lastDate = pending.map({ $0.date }).max() {
					manager.recurringTransactions[i].lastGeneratedDate = lastDate
				}
			}
			
			// Valider les transactions potentielles dont la date prévue est passée
			for i in manager.transactions.indices {
				let tx = manager.transactions[i]
				if tx.potentiel, let date = tx.date, calendar.startOfDay(for: date) <= startOfToday {
					manager.transactions[i] = tx.validated(at: date)
					updated = true
				}
			}
			
			if updated {
				save()
				objectWillChange.send()
			}
		}
	}
}

