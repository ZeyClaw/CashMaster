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


/// Une structure représentant une transaction financière.
/// Il existe deux types de transactions : potentielles et non potentielles.
/// Les transactions potentielles sont indiquées par l'attribut `potentiel`.
/// Une transaction potentielle n'a pas de date, alors qu'une transaction non potentielle devrait en avoir une.
///
/// Pour valider une transaction potentielle, utilisez la méthode `validated(at:)` qui retourne une nouvelle
/// instance avec `potentiel = false` et la date fournie.
struct Transaction: Identifiable, Codable, Equatable {
	let id: UUID
	var amount: Double
	var comment: String
	var potentiel: Bool
	var date: Date?  // nil si transaction potentielle
	
	/// Initialise une nouvelle transaction.
	/// - Parameters:
	///   - id: Identifiant unique (généré automatiquement si non fourni)
	///   - amount: Le montant de la transaction.
	///   - comment: Un commentaire associé à la transaction.
	///   - potentiel: Indique si la transaction est potentielle (par défaut, `true`).
	///   - date: Date de la transaction, `nil` si la transaction est potentielle.
	init(id: UUID = UUID(), amount: Double, comment: String, potentiel: Bool = true, date: Date? = nil) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.potentiel = potentiel
		self.date = date
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
			date: date
		)
	}
	
	/// Retourne une copie modifiée de la transaction
	/// - Parameters:
	///   - amount: Nouveau montant (optionnel)
	///   - comment: Nouveau commentaire (optionnel)
	///   - potentiel: Nouveau statut potentiel (optionnel)
	///   - date: Nouvelle date (optionnel)
	/// - Returns: Une nouvelle instance de Transaction avec les modifications
	func modified(
		amount: Double? = nil,
		comment: String? = nil,
		potentiel: Bool? = nil,
		date: Date?? = nil
	) -> Transaction {
		Transaction(
			id: self.id,
			amount: amount ?? self.amount,
			comment: comment ?? self.comment,
			potentiel: potentiel ?? self.potentiel,
			date: date ?? self.date
		)
	}
}
