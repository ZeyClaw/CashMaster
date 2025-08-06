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
	
	
	// MARK: - Privé
	private func sommeTransactions(filtre: (Transaction) -> Bool) -> Double {
		transactions.filter(filtre).map { $0.amount }.reduce(0, +)
	}
}

