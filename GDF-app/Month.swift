//
//  Month.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// Month.swift
import Foundation

// Structure représentant un mois
struct Month: Identifiable, Codable, Equatable {
	var id = UUID()
	var name: String
	var solde: Double
	var transactions: [Transaction] = []  // Liste des transactions pour chaque mois
	var monthNumber: Int  // Numéro du mois de 1 à 12
	
	// Conformité à Equatable
	static func == (lhs: Month, rhs: Month) -> Bool {
		return lhs.id == rhs.id &&
		lhs.name == rhs.name &&
		lhs.solde == rhs.solde &&
		lhs.transactions == rhs.transactions
	}
}
