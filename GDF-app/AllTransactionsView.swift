//
//  AllTransactionsView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// AllTransactionsView.swift
import SwiftUI

// Vue pour afficher toutes les transactions de tous les mois
struct AllTransactionsView: View {
	@State var months: [Month]  // Utilisation de @State pour rendre la liste mutable
	
	var body: some View {
		List {
			// Boucle à travers chaque mois
			ForEach(months.indices, id: \.self) { monthIndex in
				let month = months[monthIndex]
				// Créer une section pour chaque mois avec son nom comme en-tête
				Section(header: Text(month.name)) {
					// Boucle à travers les transactions de ce mois
					ForEach(month.transactions) { transaction in
						HStack {
							// Afficher le montant de la transaction
							Text("\(transaction.amount, specifier: "%.2f") €")
								.foregroundColor(transaction.amount >= 0 ? .green : .red)
							Spacer()
							// Afficher la date de la transaction
							Text(transaction.date, style: .date)
							Spacer()
							// Afficher le commentaire de la transaction
							Text(transaction.comment)
						}
						.swipeActions {
							Button {
								// Action de suppression ici
								if let index = months[monthIndex].transactions.firstIndex(where: { $0.id == transaction.id }) {
									months[monthIndex].solde -= months[monthIndex].transactions[index].amount  // Soustraire le montant du solde
									months[monthIndex].transactions.remove(at: index)  // Supprimer la transaction
								}
							} label: {
								Label("Supprimer", systemImage: "trash")
							}
							.tint(.red)  // Change la couleur de la zone de swipe
						}
					}
				}
			}
		}
		.navigationTitle("Toutes les Transactions")  // Titre de la vue
	}
	// Méthode pour supprimer une transaction
	private func deleteTransaction(at offsets: IndexSet, for monthIndex: Int) {
		for index in offsets {
			let transaction = months[monthIndex].transactions[index]
			months[monthIndex].solde -= transaction.amount  // Ajuste le solde en retirant le montant de la transaction
			months[monthIndex].transactions.remove(at: index)  // Supprime la transaction
		}
		
		// Sauvegarde des mois mis à jour dans UserDefaults
		saveMonths()
	}
	
	// Fonction pour sauvegarder les mois dans UserDefaults (ou tout autre mécanisme de stockage)
	func saveMonths() {
		if let encoded = try? JSONEncoder().encode(months) {
			UserDefaults.standard.set(encoded, forKey: "months")  // Sauvegarde les données
		}
	}
}

