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
	var months: [Month]  // Liste des mois contenant les transactions
	
	var body: some View {
		List {
			// Boucle à travers chaque mois
			ForEach(months) { month in
				// Créer une section pour chaque mois avec son nom comme en-tête
				Section(header: Text(month.name)) {
					// Boucle à travers les transactions de ce mois
					ForEach(month.transactions) { transaction in
						// Affichage de chaque transaction
						HStack {
							// Afficher le montant de la transaction
							Text("\(transaction.amount, specifier: "%.2f") €")
								.foregroundColor(transaction.amount >= 0 ? .green : .red)  // Couleur basée sur le montant
							Spacer()  // Espace flexible entre le montant et la date
							// Afficher la date de la transaction
							Text(transaction.date, style: .date)
							Spacer()  // Espace flexible entre la date et le commentaire
							// Afficher le commentaire de la transaction
							Text(transaction.comment)
						}
					}
				}
			}
		}
		.navigationTitle("Toutes les Transactions")  // Titre de la vue
	}
}
