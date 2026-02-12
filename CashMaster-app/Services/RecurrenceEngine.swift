//
//  RecurrenceEngine.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 12/02/2026.
//

import Foundation

/// Moteur de traitement des transactions récurrentes.
///
/// Responsabilités :
/// - Générer les transactions potentielles à venir (< 1 mois)
/// - Auto-valider les transactions dont la date est passée
/// - Nettoyer les transactions potentielles lors de suppression/modification de récurrence
///
/// Ce service est **pur** : il opère directement sur les TransactionManagers (référence)
/// mais ne gère aucune persistance. C'est AccountsManager qui persiste après appel.
struct RecurrenceEngine {
	
	// MARK: - Traitement global
	
	/// Traite toutes les récurrences de tous les comptes.
	/// Génère les transactions futures et valide automatiquement celles dont la date est passée.
	///
	/// - Parameters:
	///   - accounts: Liste de tous les comptes
	///   - managers: Dictionnaire des TransactionManagers par compte
	/// - Returns: `true` si des modifications ont été effectuées
	@discardableResult
	static func processAll(
		accounts: [Account],
		managers: [UUID: TransactionManager]
	) -> Bool {
		let calendar = Calendar.current
		let now = Date()
		let startOfToday = calendar.startOfDay(for: now)
		var anyChange = false
		
		for account in accounts {
			guard let manager = managers[account.id] else { continue }
			
			// 1. Générer les transactions potentielles depuis les récurrences actives
			for i in manager.recurringTransactions.indices {
				let recurring = manager.recurringTransactions[i]
				guard !recurring.isPaused else { continue }
				
				let pending = recurring.pendingTransactions()
				
				for entry in pending {
					let alreadyExists = manager.transactions.contains { tx in
						tx.recurringTransactionId == recurring.id &&
						tx.date != nil &&
						calendar.isDate(tx.date!, inSameDayAs: entry.date)
					}
					if !alreadyExists {
						manager.add(entry.transaction)
						anyChange = true
					}
				}
				
				// Mettre à jour la dernière date générée
				if let lastDate = pending.map({ $0.date }).max() {
					manager.recurringTransactions[i].lastGeneratedDate = lastDate
				}
			}
			
			// 2. Auto-valider les transactions potentielles dont la date prévue est passée
			for i in manager.transactions.indices {
				let tx = manager.transactions[i]
				if tx.potentiel, let date = tx.date, calendar.startOfDay(for: date) <= startOfToday {
					manager.transactions[i] = tx.validated(at: date)
					anyChange = true
				}
			}
		}
		
		return anyChange
	}
	
	// MARK: - Nettoyage
	
	/// Supprime toutes les transactions potentielles liées à une récurrence donnée.
	/// Utilisé lors de la suppression, modification ou mise en pause d'une récurrence.
	static func removePotentialTransactions(for recurringId: UUID, from transactions: inout [Transaction]) {
		transactions.removeAll { $0.recurringTransactionId == recurringId && $0.potentiel }
	}
}
