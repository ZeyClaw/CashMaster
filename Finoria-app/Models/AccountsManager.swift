//
//  AccountsManager.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import Foundation
import SwiftData

/// Orchestrateur central de l'application.
///
/// **Règle d'or** : Toute modification de données DOIT passer par cette classe.
///
/// Responsabilités :
/// - Maintenir l'état observable pour SwiftUI
/// - Orchestrer les appels aux services spécialisés
/// - Garantir la persistance SwiftData après chaque mutation
///
/// Délègue à :
/// - `SwiftData ModelContext` pour la persistance
/// - `RecurrenceEngine` pour le traitement des récurrences
/// - `CalculationService` pour les calculs financiers
/// - `CSVService` pour l'import/export CSV
class AccountsManager: ObservableObject {
	
	// MARK: - Dependencies
	
	let modelContext: ModelContext
	
	// MARK: - État publié (Single Source of Truth)
	
	@Published private(set) var accounts: [Account] = []
	@Published var selectedAccountId: UUID? {
		didSet { saveSelectedAccountId() }
	}
	
	/// Compte actuellement sélectionné (dérivé de selectedAccountId)
	var selectedAccount: Account? {
		accounts.first { $0.id == selectedAccountId }
	}
	
	// MARK: - Init
	
	init(modelContext: ModelContext) {
		self.modelContext = modelContext
		fetchAccounts()
		selectedAccountId = loadSelectedAccountId()
	}
	
	// MARK: - Preview Helper
	
	/// Crée un AccountsManager avec un conteneur en mémoire pour les Previews
	@MainActor
	static var preview: AccountsManager {
		do {
			let container = try SwiftDataService.makePreviewContainer()
			return AccountsManager(modelContext: container.mainContext)
		} catch {
			fatalError("Failed to create preview container: \(error)")
		}
	}
	
	// MARK: - Persistance interne
	
	/// Sauvegarde le contexte SwiftData et rafraîchit la liste des comptes
	private func persist() {
		try? modelContext.save()
		fetchAccounts()
	}
	
	/// Recharge la liste des comptes depuis SwiftData et valide la sélection
	private func fetchAccounts() {
		let descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.name)])
		accounts = (try? modelContext.fetch(descriptor)) ?? []
		
		// Vérifier que le compte sélectionné existe toujours
		if let id = selectedAccountId, !accounts.contains(where: { $0.id == id }) {
			// Le compte a été supprimé (ex: sync CloudKit) → réinitialiser
			selectedAccountId = accounts.first?.id
		}
	}
	
	// MARK: - Persistance du compte sélectionné (UserDefaults — préférence UI)
	
	private func saveSelectedAccountId() {
		if let id = selectedAccountId {
			UserDefaults.standard.set(id.uuidString, forKey: "lastSelectedAccountId")
		} else {
			UserDefaults.standard.removeObject(forKey: "lastSelectedAccountId")
		}
	}
	
	private func loadSelectedAccountId() -> UUID? {
		guard let idString = UserDefaults.standard.string(forKey: "lastSelectedAccountId") else { return nil }
		return UUID(uuidString: idString)
	}
	
	// MARK: - Gestion des comptes
	
	func addAccount(_ account: Account) {
		modelContext.insert(account)
		persist()
	}
	
	func deleteAccount(_ account: Account) {
		let wasSelected = selectedAccountId == account.id
		modelContext.delete(account) // cascade : supprime transactions, raccourcis, récurrences
		persist()
		
		if accounts.isEmpty {
			selectedAccountId = nil
		} else if wasSelected {
			selectedAccountId = accounts.first?.id
		}
	}
	
	func updateAccount(_ account: Account, name: String, detail: String, style: AccountStyle) {
		account.name = name
		account.detail = detail
		account.style = style
		persist()
	}
	
	func resetAccount(_ account: Account) {
		for transaction in account.transactions {
			modelContext.delete(transaction)
		}
		for shortcut in account.widgetShortcuts {
			modelContext.delete(shortcut)
		}
		for recurring in account.recurringTransactions {
			modelContext.delete(recurring)
		}
		persist()
	}
	
	func getAllAccounts() -> [Account] {
		accounts
	}
	
	// MARK: - Gestion des transactions
	
	func addTransaction(_ transaction: Transaction) {
		guard let account = selectedAccount else { return }
		transaction.account = account
		modelContext.insert(transaction)
		persist()
	}
	
	func deleteTransaction(_ transaction: Transaction) {
		modelContext.delete(transaction)
		persist()
	}
	
	func validateTransaction(_ transaction: Transaction) {
		transaction.validate(at: Date())
		persist()
	}
	
	func updateTransaction(
		_ transaction: Transaction,
		amount: Double,
		comment: String,
		potentiel: Bool,
		date: Date?,
		category: TransactionCategory
	) {
		transaction.amount = amount
		transaction.comment = comment
		transaction.potentiel = potentiel
		transaction.date = date
		transaction.category = category
		persist()
	}
	
	func transactions() -> [Transaction] {
		selectedAccount?.transactions ?? []
	}
	
	// MARK: - Calculs (délégués à CalculationService)
	
	func totalNonPotential(for account: Account) -> Double {
		CalculationService.totalNonPotential(transactions: account.transactions)
	}
	
	func totalPotential(for account: Account) -> Double {
		CalculationService.totalPotential(transactions: account.transactions)
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
		selectedAccount?.widgetShortcuts ?? []
	}
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		guard let account = selectedAccount else { return }
		shortcut.account = account
		modelContext.insert(shortcut)
		persist()
	}
	
	func deleteWidgetShortcut(_ shortcut: WidgetShortcut) {
		modelContext.delete(shortcut)
		persist()
	}
	
	func updateWidgetShortcut(
		_ shortcut: WidgetShortcut,
		amount: Double,
		comment: String,
		type: TransactionType,
		category: TransactionCategory
	) {
		shortcut.amount = amount
		shortcut.comment = comment
		shortcut.type = type
		shortcut.category = category
		persist()
	}
	
	// MARK: - CSV (délégué à CSVService)
	
	func generateCSV() -> URL? {
		guard let account = selectedAccount else { return nil }
		return CSVService.generateCSV(transactions: account.transactions, accountName: account.name)
	}
	
	func importCSV(from url: URL) -> Int {
		guard let account = selectedAccount else { return 0 }
		let imported = CSVService.importCSV(from: url)
		for tx in imported {
			tx.account = account
			modelContext.insert(tx)
		}
		if !imported.isEmpty { persist() }
		return imported.count
	}
	
	// MARK: - Récurrences (délégué à RecurrenceEngine)
	
	func getRecurringTransactions() -> [RecurringTransaction] {
		selectedAccount?.recurringTransactions ?? []
	}
	
	func addRecurringTransaction(_ recurring: RecurringTransaction) {
		guard let account = selectedAccount else { return }
		recurring.account = account
		modelContext.insert(recurring)
		persist()
		processRecurringTransactions()
	}
	
	func deleteRecurringTransaction(_ recurring: RecurringTransaction) {
		RecurrenceEngine.removePotentialTransactions(for: recurring, context: modelContext)
		modelContext.delete(recurring)
		persist()
	}
	
	func updateRecurringTransaction(
		_ recurring: RecurringTransaction,
		amount: Double,
		comment: String,
		type: TransactionType,
		category: TransactionCategory,
		frequency: RecurrenceFrequency,
		startDate: Date
	) {
		RecurrenceEngine.removePotentialTransactions(for: recurring, context: modelContext)
		recurring.amount = amount
		recurring.comment = comment
		recurring.type = type
		recurring.category = category
		recurring.frequency = frequency
		recurring.startDate = startDate
		recurring.lastGeneratedDate = nil
		persist()
		processRecurringTransactions()
	}
	
	func pauseRecurringTransaction(_ recurring: RecurringTransaction) {
		RecurrenceEngine.removePotentialTransactions(for: recurring, context: modelContext)
		recurring.isPaused = true
		persist()
	}
	
	func resumeRecurringTransaction(_ recurring: RecurringTransaction) {
		let calendar = Calendar.current
		let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
		recurring.isPaused = false
		recurring.lastGeneratedDate = yesterday
		persist()
		processRecurringTransactions()
	}
	
	/// Traite toutes les récurrences : génère les transactions à venir et valide celles du passé.
	/// Appelé au lancement, au retour au premier plan, et après ajout/modification de récurrence.
	func processRecurringTransactions() {
		if RecurrenceEngine.processAll(accounts: accounts, context: modelContext) {
			persist()
		}
	}
	
	/// Sauvegarde publique pour besoins externes
	func saveData() {
		persist()
	}
	
	/// Rafraîchit les données depuis le store SwiftData.
	/// Appelé quand l'app revient au premier plan pour récupérer les changements CloudKit.
	func refreshFromStore() {
		fetchAccounts()
	}
}
