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
	@Binding var transactionDate: Date  // Ajouter la date ici
	@Binding var months: [Month]
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
					TextField("Montant", value: $transactionAmount, format: .number)
						.keyboardType(.decimalPad)
				}
				
				Section(header: Text("Commentaire")) {
					TextField("Commentaire", text: $transactionComment)
				}
				// Sélecteur de date pour la transaction
				Section(header: Text("Date")) {
					DatePicker("Date de la Transaction", selection: $transactionDate, displayedComponents: [.date])
						.datePickerStyle(GraphicalDatePickerStyle())
				}
			}
			.navigationTitle("Ajouter une transaction")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Ajouter") {
						if let amountValue = transactionAmount {
							let amount = transactionType == "+" ? amountValue : -amountValue
							let transaction = Transaction(amount: amount, date: transactionDate, comment: transactionComment)
							
							// Ajouter la transaction dans le bon mois
							if let monthIndex = findMonthIndex(for: transactionDate) {
								months[monthIndex].solde += amount
								months[monthIndex].transactions.append(transaction)
								dismiss()  // Ferme la feuille
							} else {
								showingErrorAlert = true  // Si le mois n'est pas trouvé, afficher une erreur
							}
						} else {
							showingErrorAlert = true
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
	// Trouver l'indice du mois correspondant à la date de la transaction
	func findMonthIndex(for date: Date) -> Int? {
		let calendar = Calendar.current
		let transactionMonth = calendar.component(.month, from: date)  // Obtenir le numéro du mois de la date
		
		// Chercher le mois correspondant par son numéro
		return months.firstIndex(where: { $0.monthNumber == transactionMonth })
	}
}
