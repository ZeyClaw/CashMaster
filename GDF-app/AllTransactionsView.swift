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
	@Binding var months: [Month]  // Utilisation de @State pour rendre la liste mutable
	
	var body: some View {
		List {
			// Boucle à travers chaque mois
			ForEach(months.indices, id: \.self) { monthIndex in
				let month = months[monthIndex]
				
				// Créer une section pour chaque mois avec son nom comme en-tête
				Section(header: Text(month.name)) {
					// Boucle à travers les transactions de ce mois
					ForEach(month.transactions.indices, id: \.self) { transactionIndex in
						let transaction = month.transactions[transactionIndex]
						
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
								// Appeler la fonction de suppression définie dans TransactionHelper.swift
								deleteTransaction(from: &months, in: monthIndex, at: transactionIndex)
							} label: {
								Label("Supprimer", systemImage: "trash")
							}
							.tint(.red)
						}
					}
				}
			}
		}
		.navigationTitle("Toutes les Transactions")  // Titre de la vue
	}
}
