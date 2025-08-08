//
//  TransactionManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//


// TransactionManager.swift
import Foundation

/// Une classe pour gérer les transactions d'un compte spécifique. (liste des transactions pour un compte)
//  Cette classe gère uniquement les transactions d’un compte précis.
//  Elle N’EST PAS observable directement par SwiftUI.
//  Toute modification doit passer par AccountsManager,
//  qui lui seul envoie les notifications de mise à jour.
class TransactionManager {
	/// Nom du compte associé à ce gestionnaire de transactions.
	let accountName: String
	/// Liste des transactions gérées par ce gestionnaire.
	var transactions: [Transaction] = []
	
	var widgetShortcuts: [WidgetShortcut] = []
	
	init(accountName: String) {
		self.accountName = accountName
	}
	
	// MARK: - Gestion basique
	func ajouter(_ transaction: Transaction) {
		transactions.append(transaction)
	}
	
	func supprimer(_ transaction: Transaction) {
		transactions.removeAll { $0.id == transaction.id }
	}
	
	// MARK: - Totaux
	func totalNonPotentiel() -> Double {
		sommeTransactions(filtre: { !$0.potentiel })
	}
	
	func totalPotentiel() -> Double {
		sommeTransactions(filtre: { $0.potentiel })
	}
	
	// MARK: - Widgets
	
	private let widgetKey = "widget_shortcuts"
	
	func addWidgetShortcut(_ shortcut: WidgetShortcut) {
		widgetShortcuts.append(shortcut)
	}
	
	func removeWidgetShortcut(_ shortcut: WidgetShortcut) {
		widgetShortcuts.removeAll { $0 == shortcut }
	}
	
	private func saveWidgets() {
		if let data = try? JSONEncoder().encode(widgetShortcuts) {
			UserDefaults.standard.set(data, forKey: widgetKey)
		}
	}
	
	private func loadWidgets() {
		if let data = UserDefaults.standard.data(forKey: widgetKey),
		   let decoded = try? JSONDecoder().decode([WidgetShortcut].self, from: data) {
			widgetShortcuts = decoded
		}
	}
	
	
	// MARK: - Privé
	private func sommeTransactions(filtre: (Transaction) -> Bool) -> Double {
		transactions.filter(filtre).map { $0.amount }.reduce(0, +)
	}
}

