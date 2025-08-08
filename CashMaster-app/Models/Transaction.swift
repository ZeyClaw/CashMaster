//
//  Transaction.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// Transaction.swift
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



/// Une classe représentant une transaction financière.
/// Il existe deux types de transactions : potentielles et non potentielles.
/// Les transactions potentielles sont indiquées par l'attribut `potentiel`.
/// Une transaction potentielle n'a pas de date, alors qu'une transaction non potentielle devrait en avoir une.
/// Cependant, il est techniquement possible de créer une transaction non potentielle sans date, donc soyez prudent.
/// Si vous créez directement une transaction non potentielle, assurez-vous de donner une valeur à l'attribut `date`.
/// Pour valider une transaction potentielle, utilisez la méthode `valider` plutôt que de le faire manuellement.
class Transaction: Identifiable, Codable, Equatable {
	var id: UUID
	var amount: Double
	var comment: String
	var potentiel: Bool
	var date: Date?  // nil si transaction potentielle
	
	/// Initialise une nouvelle transaction.
	/// - Parameters:
	///   - amount: Le montant de la transaction.
	///   - comment: Un commentaire associé à la transaction.
	///   - potentiel: Indique si la transaction est potentielle (par défaut, `true`).
	///   - date: Date de la transaction, `nil` si la transaction est potentielle.
	init(amount: Double, comment: String, potentiel: Bool = true, date: Date? = nil) {
		self.id = UUID()
		self.amount = amount
		self.comment = comment
		self.potentiel = potentiel
		self.date = date
	}
	
	/// Valider une transaction potentielle
	func valider(date: Date) {
		self.potentiel = false
		self.date = date
	}
	
	// MARK: - Equatable
	static func == (lhs: Transaction, rhs: Transaction) -> Bool {
		lhs.id == rhs.id
	}
}
