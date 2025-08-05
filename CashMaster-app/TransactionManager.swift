//
//  TransactionManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//


// TransactionManager.swift
import Foundation

/// Une classe pour gérer les transactions d'un compte spécifique. (liste des transactions pour un compte)
class TransactionManager {
	/// Nom du compte associé à ce gestionnaire de transactions.
	let accountName: String
	/// Liste des transactions gérées par ce gestionnaire.
	private(set) var transactions: [Transaction] = []
	
	/// Initialise un nouveau gestionnaire de transactions pour un compte donné.
	/// - Parameter accountName: Le nom du compte.
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
	
	/// Calcule le total des transactions pour un mois et une année donnés.
	/// - Parameters:
	///   - month: Le mois pour lequel calculer le total (1-12).
	///   - year: L'année pour laquelle calculer le total.
	/// - Returns: Le montant total des transactions pour le mois et l'année spécifiés.
	func totalPourMois(_ month: Int, year: Int) -> Double {
		let calendar = Calendar.current
		return sommeTransactions(filtre: { transaction in
			guard !transaction.potentiel, let date = transaction.date else { return false }
			let comp = calendar.dateComponents([.year, .month], from: date)
			return comp.year == year && comp.month == month
		})
	}
	
	// MARK: - Privé
	private func sommeTransactions(filtre: (Transaction) -> Bool) -> Double {
		transactions.filter(filtre).map { $0.amount }.reduce(0, +)
	}
}
