//
//  AddTransactionView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 16/10/2024.
//

import SwiftUI

struct AddTransactionView: View {
	@Binding var transactionAmount: Double?
	@Binding var transactionComment: String
	@Binding var transactionType: String
	@Binding var month: Month
	@Binding var showingAddTransactionSheet: Bool  // Ajoute cette liaison pour rouvrir la sheet
	@State private var showingErrorAlert = false  // Gérer l'affichage de l'alerte d'erreur
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Type de Transaction")) {
					Picker("Type", selection: $transactionType) {
						Text("+").tag("+")
						Text("-").tag("-")
					}
					.pickerStyle(SegmentedPickerStyle())
				}
				
				Section(header: Text("Montant")) {
					TextField("Montant", value: $transactionAmount, formatter: NumberFormatter())
						.keyboardType(.decimalPad)
				}
				
				Section(header: Text("Commentaire")) {
					TextField("Commentaire", text: $transactionComment)
				}
			}
			.navigationTitle("Ajouter une transaction")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Ajouter") {
						if let amountValue = transactionAmount {
							let amount = transactionType == "+" ? amountValue : -amountValue
							let transaction = Transaction(amount: amount, date: Date(), comment: transactionComment)
							month.solde += amount
							month.transactions.append(transaction)
							dismiss() // Ferme la feuille
						}
						else {
							showingErrorAlert = true // Affiche l'alerte d'erreur si le montant est vide
						}
					}
				}
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
			}
		}
		.alert("Le montant est invalide", isPresented: $showingErrorAlert) {
			Button("OK") {
				// Réinitialise les champs pour recommencer
				transactionAmount = nil
				showingAddTransactionSheet = true // Rouvre la feuille après la fermeture de l'alerte
			}
		} message: {
			Text("Veuillez entrer un montant valide.")
		}
	}
}
