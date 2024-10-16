//
//  MonthView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

import SwiftUI

// Vue pour chaque mois avec gestion des transactions
struct MonthView: View {
	@Binding var month: Month
	@State private var showingErrorAlert = false  // Gérer l'affichage de l'alerte d'erreur
	@State private var transactionAmount: Double? // Montant de la transaction
	@State private var transactionComment = ""  // Commentaire de la transaction
	@State private var transactionType = ""  // "+" ou "-"
	@State private var showingAddTransactionSheet = false

	
	// Création d'un NumberFormatter personnalisé
	private var decimalFormatter: NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = 2 // Nombre minimum de décimales
		formatter.maximumFractionDigits = 2 // Nombre maximum de décimales
		formatter.decimalSeparator = ","
		return formatter
	}
	
	var body: some View {
		VStack {
			Text("Solde de \(month.name): \(month.solde, specifier: "%.2f") €")
				.font(.largeTitle)
				.padding()
				.foregroundColor(month.solde >= 0 ? .green : .red)
			
			

			
			// Liste des transactions avec la fonctionnalité de suppression
			List {
				ForEach(month.transactions) { transaction in
					HStack {
						Text("\(transaction.amount, specifier: "%.2f") €")
							.foregroundColor(transaction.amount >= 0 ? .green : .red)
						Spacer()
						Text(transaction.date, style: .date)  // Affiche la date
						Spacer()
						Text(transaction.comment)  // Affiche le commentaire
					}
					.swipeActions {
						Button {
							// Action de suppression ici
							if let index = month.transactions.firstIndex(where: { $0.id == transaction.id }) {
								month.solde -= month.transactions[index].amount  // Soustraire le montant du solde
								month.transactions.remove(at: index)  // Supprimer la transaction
							}
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
						.tint(.red) // Change la couleur de la zone de swipe
					}
				}
				.onDelete(perform: deleteTransaction) // Ajoute le support pour supprimer
			}
			Spacer()  // Pousse le contenu vers le haut
		}
	}
	
	// Méthode pour supprimer une transaction
	private func deleteTransaction(at offsets: IndexSet) {
		for index in offsets {
			let transaction = month.transactions[index]
			month.solde -= transaction.amount // Ajuste le solde en retirant le montant de la transaction
			month.transactions.remove(at: index) // Supprime la transaction
		}
	}
}
