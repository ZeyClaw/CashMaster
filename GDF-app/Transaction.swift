//
//  Transaction.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// Transaction.swift
import Foundation

// Structure représentant une transaction
struct Transaction: Identifiable, Codable, Equatable {
	var id = UUID()  // Identifiant unique pour chaque transaction
	var amount: Double  // Montant ajouté ou soustrait
	var date: Date   // Date de la transaction
	var comment: String  // Commentaire lié à la transaction
}
