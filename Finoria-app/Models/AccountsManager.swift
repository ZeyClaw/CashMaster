//
//  AccountsManager.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import Foundation

/// Orchestrateur central de l'application.
///
/// **Règle d'or** : Toute modification de données DOIT passer par cette classe.
///
/// Responsabilités :
/// - Maintenir l'état `@Published` pour SwiftUI
/// - Orchestrer les appels aux services spécialisés
/// - Garantir la persistance après chaque mutation
///
/// Délègue à :
/// - `StorageService` pour la persistance UserDefaults
/// - `RecurrenceEngine` pour le traitement des récurrences
/// - `CalculationService` pour les calculs financiers
/// - `CSVService` pour l'import/export CSV
class AccountsManager: ObservableObject {
	
	// MARK: - État publié (Single Source of Truth)
	
	@Published private(set) var accounts: [Account] = []
	@Published private(set) var transactionManagers: [UUID: TransactionManager] = [:]
	@Published var selectedAccountId: UUID? {
		didSet { storage.saveSelectedAccountId(selectedAccountId) }
	}
	
	/// Compte actuellement sélectionné (dérivé de selectedAccountId)
	var selectedAccount: Account? {
		accounts.first { $0.id == selectedAccountId }
	}
	
	// MARK: - Services
	
	private let storage = StorageService()
	
	// MARK: - Init
	
	init() {
		let loaded = storage.load()
		accounts = loaded.accounts
		transactionManagers = loaded.managers
		selectedAccountId = storage.loadSelectedAccountId()
	}
	
	// MARK: - Helpers internes
	
	/// Persiste l'état courant et notifie SwiftUI du changement
	private func persist() {
		storage.save(accounts: accounts, managers: transactionManagers)
		objectWillChange.send()
	}
	
	/// TransactionManager du compte actuellement sélectionné
	private var currentManager: TransactionManager? {
		guard let id = selectedAccountId else { return nil }
		return transactionManagers[id]
	}
	
	// MARK: - Gestion des comptes
	
	func addAccount(_ account: Account) {
		guard !accounts.contains(where: { $0.id == account.id }) else { return }
		accounts.append(account)
		transactionManagers[account.id] = TransactionManager(accountName: account.name)
		persist()
	}
	
	func deleteAccount(_ account: Account) {
		accounts.removeAll { $0.id == account.id }
		transactionManagers.removeValue(forKey: account.id)
		if accounts.isEmpty {
			selectedAccountId = nil
		} else if selectedAccountId == account.id {
			selectedAccountId = accounts.first?.id
		}
		persist()
	}
	
	func updateAccount(_ account: Account) {
		guard let index = accounts.firstIndex(where: { $0.id == account.id }) else { return }
		accounts[index] = account
		persist()
	}
	
	func resetAccount(_ account: Account) {
		transactionManagers[account.id]?.transactions.removeAll()
		persist()
	}
	
	func getAllAccounts() -> [Account] {
		accounts.sorted { $0.name < $1.name }
	}
	
	// MARK: - Gestion des transactions
	
	func addTransaction(_ transaction: Transaction) {
		currentManager?.add(transaction)
		persist()
	}
	
	func deleteTransaction(_ transaction: Transaction) {
		currentManager?.remove(transaction)
		persist()
	}
	
	func validateTransaction(_ transaction: Transaction) {
		currentManager?.update(transaction.validated(at: Date()))
		persist()
	}
	
	func updateTransaction(_ transaction: Transaction) {
		currentManager?.update(transaction)
		persist()
	}
	
	func transactions() -> [Transaction] {
		currentManager?.transactions ?? []
	}
	
	// MARK: - Calculs (délégués à CalculationService)
	
	func totalNonPotential(for account: Account) -> Double {
		CalculationService.totalNonPotential(transactions: transactionManagers[account.id]?.transactions ?? [])
	}
	
	func totalPotential(for account: Account) -> Double {
		CalculationService.totalPotential(transactions: transactionManagers[account.id]?.transactions ?? [])
	}
	
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
	
	// MARK: - Filtres (délégués à CalculationService)
	
	func potentialTransactions() -> [Transaction] {
		CalculationService.potentialTransactions(from: transactions())
	}
	
	func validatedTransactions(year: Int? = nil, month: Int? = nil) -> [Transaction] {
		CalculationService.validatedTransactions(from: transactions(), year: year, month: month)
	}
	
	// MARK: - Raccourcis (Widget Shortcuts)
	
	func getWidgetShortcuts() -> [WidgetShortcut] {
		currentManager?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		currentManager?.widgetShortcuts.append(shortcut)
		persist()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		currentManager?.widgetShortcuts.removeAll { $0.id == shortcut.id }
		persist()
	}
	
	func updateWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let index = currentManager?.widgetShortcuts.firstIndex(where: { $0.id == shortcut.id }) else { return }
		currentManager?.widgetShortcuts[index] = shortcut
		persist()
	}
	
	// MARK: - CSV (délégué à CSVService)
	
	func generateCSV() -> URL? {
		guard let account = selectedAccount else { return nil }
		return CSVService.generateCSV(transactions: transactions(), accountName: account.name)
	}
	
	func importCSV(from url: URL) -> Int {
		guard selectedAccountId != nil else { return 0 }
		let imported = CSVService.importCSV(from: url)
		for tx in imported {
			currentManager?.add(tx)
		}
		if !imported.isEmpty { persist() }
		return imported.count
	}
	
	// MARK: - Récurrences (délégué à RecurrenceEngine)
	
	func getRecurringTransactions() -> [RecurringTransaction] {
		currentManager?.recurringTransactions ?? []
	}
	
	func addRecurringTransaction(_ recurring: RecurringTransaction) {
		currentManager?.recurringTransactions.append(recurring)
		persist()
		processRecurringTransactions()
	}
	
	func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let manager = currentManager else { return }
		RecurrenceEngine.removePotentialTransactions(for: recurring.id, from: &manager.transactions)
		manager.recurringTransactions.removeAll { $0.id == recurring.id }
		persist()
	}
	
	func updateRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let manager = currentManager,
			  let index = manager.recurringTransactions.firstIndex(where: { $0.id == recurring.id }) else { return }
		RecurrenceEngine.removePotentialTransactions(for: recurring.id, from: &manager.transactions)
		var updated = recurring
		updated.lastGeneratedDate = nil
		manager.recurringTransactions[index] = updated
		persist()
		processRecurringTransactions()
	}
	
	func pauseRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let manager = currentManager,
			  let index = manager.recurringTransactions.firstIndex(where: { $0.id == recurring.id }) else { return }
		RecurrenceEngine.removePotentialTransactions(for: recurring.id, from: &manager.transactions)
		manager.recurringTransactions[index].isPaused = true
		persist()
	}
	
	func resumeRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let manager = currentManager,
			  let index = manager.recurringTransactions.firstIndex(where: { $0.id == recurring.id }) else { return }
		let calendar = Calendar.current
		let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
		manager.recurringTransactions[index].isPaused = false
		manager.recurringTransactions[index].lastGeneratedDate = yesterday
		persist()
		processRecurringTransactions()
	}
	
	/// Traite toutes les récurrences : génère les transactions à venir et valide celles du passé.
	/// Appelé au lancement, au retour au premier plan, et après ajout/modification de récurrence.
	func processRecurringTransactions() {
		if RecurrenceEngine.processAll(accounts: accounts, managers: transactionManagers) {
			persist()
		}
	}
	
	/// Sauvegarde publique pour besoins externes
	func saveData() {
		persist()
	}
}
