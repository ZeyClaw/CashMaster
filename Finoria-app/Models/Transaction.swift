//
//  Transaction.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

import Foundation


enum TransactionType: String, CaseIterable, Codable, Identifiable {
	case income = "+"
	case expense = "-"
	
	var id: String { self.rawValue }
	
	var label: String {
		switch self {
		case .income: return "Revenu"
		case .expense: return "Dépense"
		}
	}
}


/// Structure immuable représentant une transaction financière.
///
/// **Potentielle** (`potentiel = true`) : planifiée, sans date ou avec date future.
/// **Validée** (`potentiel = false`) : confirmée, avec date.
///
/// Modifications via `validated(at:)` ou `modified(...)` uniquement (retournent une nouvelle instance).
struct Transaction: Identifiable, Codable, Equatable {
	let id: UUID
	var amount: Double
	var comment: String
	var potentiel: Bool
	var date: Date?
	var category: TransactionCategory
	var recurringTransactionId: UUID?
	
	/// Initialise une nouvelle transaction.
	/// - Parameters:
	///   - id: Identifiant unique (généré automatiquement si non fourni)
	///   - amount: Le montant de la transaction.
	///   - comment: Un commentaire associé à la transaction.
	///   - potentiel: Indique si la transaction est potentielle (par défaut, `true`).
	///   - date: Date de la transaction, `nil` si la transaction est potentielle.
	///   - category: Catégorie de la transaction (défaut: `.other`).
	///   - recurringTransactionId: ID de la récurrence source (optionnel).
	init(
		id: UUID = UUID(),
		amount: Double,
		comment: String,
		potentiel: Bool = true,
		date: Date? = nil,
		category: TransactionCategory = .other,
		recurringTransactionId: UUID? = nil
	) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.potentiel = potentiel
		self.date = date
		self.category = category
		self.recurringTransactionId = recurringTransactionId
	}
	
	/// Retourne une copie validée de la transaction (non potentielle avec une date)
	/// - Parameter date: La date de validation
	/// - Returns: Une nouvelle instance de Transaction validée
	func validated(at date: Date) -> Transaction {
		Transaction(
			id: self.id,
			amount: self.amount,
			comment: self.comment,
			potentiel: false,
			date: date,
			category: self.category,
			recurringTransactionId: self.recurringTransactionId
		)
	}
	
	/// Retourne une copie modifiée de la transaction
	/// - Parameters:
	///   - amount: Nouveau montant (optionnel)
	///   - comment: Nouveau commentaire (optionnel)
	///   - potentiel: Nouveau statut potentiel (optionnel)
	///   - date: Nouvelle date (optionnel)
	///   - category: Nouvelle catégorie (optionnel)
	/// - Returns: Une nouvelle instance de Transaction avec les modifications
	func modified(
		amount: Double? = nil,
		comment: String? = nil,
		potentiel: Bool? = nil,
		date: Date?? = nil,
		category: TransactionCategory? = nil
	) -> Transaction {
		Transaction(
			id: self.id,
			amount: amount ?? self.amount,
			comment: comment ?? self.comment,
			potentiel: potentiel ?? self.potentiel,
			date: date ?? self.date,
			category: category ?? self.category,
			recurringTransactionId: self.recurringTransactionId
		)
	}
}
