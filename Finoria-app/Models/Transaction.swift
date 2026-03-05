//
//  Transaction.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

import Foundation
import SwiftData


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


/// Modèle persistant représentant une transaction financière.
///
/// **Potentielle** (`potentiel = true`) : planifiée, sans date ou avec date future.
/// **Validée** (`potentiel = false`) : confirmée, avec date.
///
/// Modifications via `validate(at:)` ou `modify(...)` (mutation en place, trackée par SwiftData).
@Model
final class Transaction {
	
	// MARK: - Propriétés persistées
	
	@Attribute(.unique) var id: UUID
	var amount: Double
	var comment: String
	var potentiel: Bool
	var date: Date?
	var category: TransactionCategory
	
	// MARK: - Relations
	
	/// Compte propriétaire de cette transaction
	var account: Account?
	
	/// Récurrence source ayant généré cette transaction (nil si manuelle)
	var sourceRecurringTransaction: RecurringTransaction?
	
	// MARK: - Init
	
	/// Initialise une nouvelle transaction.
	/// - Parameters:
	///   - id: Identifiant unique (généré automatiquement si non fourni)
	///   - amount: Le montant de la transaction (positif = revenu, négatif = dépense)
	///   - comment: Un commentaire associé à la transaction
	///   - potentiel: Indique si la transaction est potentielle (par défaut, `true`)
	///   - date: Date de la transaction, `nil` si la transaction est potentielle
	///   - category: Catégorie de la transaction (défaut: `.other`)
	///   - sourceRecurringTransaction: Récurrence source (optionnel)
	init(
		id: UUID = UUID(),
		amount: Double,
		comment: String,
		potentiel: Bool = true,
		date: Date? = nil,
		category: TransactionCategory = .other,
		sourceRecurringTransaction: RecurringTransaction? = nil
	) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.potentiel = potentiel
		self.date = date
		self.category = category
		self.sourceRecurringTransaction = sourceRecurringTransaction
	}
	
	// MARK: - Mutations
	
	/// Valide la transaction en place (non potentielle avec une date)
	/// - Parameter date: La date de validation
	func validate(at date: Date) {
		self.potentiel = false
		self.date = date
	}
	
	/// Modifie les propriétés de la transaction en place
	/// - Parameters:
	///   - amount: Nouveau montant (optionnel)
	///   - comment: Nouveau commentaire (optionnel)
	///   - potentiel: Nouveau statut potentiel (optionnel)
	///   - date: Nouvelle date (optionnel)
	///   - category: Nouvelle catégorie (optionnel)
	func modify(
		amount: Double? = nil,
		comment: String? = nil,
		potentiel: Bool? = nil,
		date: Date?? = nil,
		category: TransactionCategory? = nil
	) {
		if let amount { self.amount = amount }
		if let comment { self.comment = comment }
		if let potentiel { self.potentiel = potentiel }
		if let date { self.date = date }
		if let category { self.category = category }
	}
}
