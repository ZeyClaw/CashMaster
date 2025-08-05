//
//  AccountsManager.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

// AccountsManager.swift
import Foundation

/// Une classe pour gérer plusieurs comptes et leurs transactions.
class AccountsManager {
	/// Dictionnaire des gestionnaires de transactions, où les clés sont des noms de comptes et les valeurs sont des instances de TransactionManager correspondant à chaque compte (liste des transactions pour un compte).
	private var managers: [String: TransactionManager] = [:]
	
	// MARK: - Gestion des comptes
	/// Crée un nouveau compte avec un nom donné, s'il n'existe pas déjà.
	/// - Parameter nom: Le nom du compte à créer.
	private func creerCompte(nom: String) {
		guard managers[nom] == nil else { return }
		managers[nom] = TransactionManager(accountName: nom)
	}
	
	// MARK: - Gestion des transactions
	/// Ajoute une transaction à un compte spécifié.
	/// - Parameters:
	///   - transaction: La transaction à ajouter.
	///   - account: Le nom du compte auquel ajouter la transaction.
	func ajouterTransaction(_ transaction: Transaction, to account: String) {
		if managers[account] == nil {
			creerCompte(nom: account)
		}
		managers[account]?.ajouter(transaction)
	}
	
	/// Supprime une transaction d'un compte spécifié.
	/// - Parameters:
	///   - transaction: La transaction à supprimer.
	///   - account: Le nom du compte duquel supprimer la transaction.
	func supprimerTransaction(_ transaction: Transaction, from account: String) {
		managers[account]?.supprimer(transaction)
	}
	
	// MARK: - Totaux
	func totalNonPotentiel(for account: String) -> Double {
		managers[account]?.totalNonPotentiel() ?? 0
	}
	
	func totalPotentiel(for account: String) -> Double {
		managers[account]?.totalPotentiel() ?? 0
	}
	
	/// Calcule le total des transactions pour un mois et une année donnés pour un compte spécifié.
	/// - Parameters:
	///   - month: Le mois pour lequel calculer le total (1-12).
	///   - year: L'année pour laquelle calculer le total.
	///   - account: Le nom du compte pour lequel calculer le total.
	/// - Returns: Le montant total des transactions pour le mois et l'année spécifiés pour le compte donné.
	func totalPourMois(_ month: Int, year: Int, account: String) -> Double {
		managers[account]?.totalPourMois(month, year: year) ?? 0
	}
}
