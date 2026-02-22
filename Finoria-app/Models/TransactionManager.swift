//
//  TransactionManager.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//


// TransactionManager.swift
import Foundation

/// Une classe pour gérer les transactions d'un compte spécifique. (liste des transactions pour un compte)
//  Cette classe gère uniquement les transactions d'un compte précis.
//  Elle N'EST PAS observable directement par SwiftUI.
//  Toute modification doit passer par AccountsManager,
//  qui lui seul envoie les notifications de mise à jour.
class TransactionManager {
	/// Nom du compte associé à ce gestionnaire de transactions.
	let accountName: String
	/// Liste des transactions gérées par ce gestionnaire.
	var transactions: [Transaction] = []
	
	var widgetShortcuts: [WidgetShortcut] = []
	var recurringTransactions: [RecurringTransaction] = []
	
	init(accountName: String) {
		self.accountName = accountName
	}
	
	// MARK: - Basic Operations
	
	func add(_ transaction: Transaction) {
		transactions.append(transaction)
	}
	
	func remove(_ transaction: Transaction) {
		transactions.removeAll { $0.id == transaction.id }
	}
	
	/// Updates an existing transaction (search by ID)
	func update(_ transaction: Transaction) {
		if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
			transactions[index] = transaction
		}
	}
	
	// MARK: - Totals
	
	func totalNonPotential() -> Double {
		sumTransactions(filter: { !$0.potentiel })
	}
	
	func totalPotential() -> Double {
		sumTransactions(filter: { $0.potentiel })
	}
	
	// MARK: - Private
	
	private func sumTransactions(filter: (Transaction) -> Bool) -> Double {
		transactions.filter(filter).map { $0.amount }.reduce(0, +)
	}
}
