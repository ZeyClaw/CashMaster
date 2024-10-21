//
//  PotentialTransaction.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 18/10/2024.
//


// PotentialTransaction.swift
import Foundation

// Structure représentant une transaction potentielle
struct PotentialTransaction: Identifiable, Codable, Equatable {
	var id = UUID()
	var amount: Double
	var comment: String
	
	static func == (lhs: PotentialTransaction, rhs: PotentialTransaction) -> Bool {
		return lhs.id == rhs.id &&
		lhs.amount == rhs.amount &&
		lhs.comment == rhs.comment
	}
}

// Structure représentant l'ensemble des transactions potentielles
struct TotalPotentialTransactions: Codable {
	var transactions: [PotentialTransaction]
	
	// Calcul du solde total des transactions potentielles
	var totalBalance: Double {
		transactions.map { $0.amount }.reduce(0, +)
	}
	
	// Fonction pour ajouter une transaction potentielle
	mutating func addTransaction(_ transaction: PotentialTransaction) {
		transactions.append(transaction)
	}
	
	// Fonction pour supprimer une transaction potentielle
	mutating func removeTransaction(at index: Int) {
		guard transactions.indices.contains(index) else { return }
		transactions.remove(at: index)
	}
}

// Fonction pour charger les transactions potentielles depuis UserDefaults
func loadPotentialTransactions() -> TotalPotentialTransactions {
	if let data = UserDefaults.standard.data(forKey: "potentialTransactions") {
		if let decoded = try? JSONDecoder().decode(TotalPotentialTransactions.self, from: data) {
			return decoded
		}
	}
	return TotalPotentialTransactions(transactions: [])
}

// Fonction pour obtenir le solde total des transactions potentielles
func getTotalPotentialBalance() -> Double {
	let totalPotentialTransactions = loadPotentialTransactions()
	return totalPotentialTransactions.totalBalance
}
