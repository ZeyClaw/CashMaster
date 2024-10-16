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


// Fonction pour supprimer une transaction d'un mois donné
func deleteTransaction(from month: inout Month, at offsets: IndexSet) {
	for index in offsets {
		let transaction = month.transactions[index]
		month.solde -= transaction.amount  // Ajuste le solde en retirant le montant de la transaction
		month.transactions.remove(at: index)  // Supprime la transaction
	}
}

// Fonction pour supprimer une transaction d'un tableau de mois donné
func deleteTransaction(from months: inout [Month], in monthIndex: Int, at transactionIndex: Int) {
	let transaction = months[monthIndex].transactions[transactionIndex]
	months[monthIndex].solde -= transaction.amount  // Ajuste le solde du mois en retirant le montant de la transaction
	months[monthIndex].transactions.remove(at: transactionIndex)  // Supprime la transaction
}
