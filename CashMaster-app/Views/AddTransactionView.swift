//
//  AddTransactionView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 16/10/2024.
//

import SwiftUI

struct AddTransactionView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var transactionAmount: Double? = nil
	@State private var transactionComment: String = ""
	@State private var transactionType: String = "-" // + ou -
	@State private var transactionDate: Date = Date()
	@State private var isPotentiel: Bool = true
	@State private var showingErrorAlert = false
	
	
	var body: some View {
		NavigationView {
			Form {
				Section("Type de Transaction") {
					Picker("Type", selection: $transactionType) {
						Text("+").tag("+")
						Text("-").tag("-")
					}
					.pickerStyle(.segmented)
				}
				
				Section("Montant") {
					TextField("Montant", value: $transactionAmount, format: .number)
						.keyboardType(.decimalPad)
				}
				
				Section("Commentaire") {
					TextField("Commentaire", text: $transactionComment)
				}
				
				Section("Date") {
					DatePicker("Date de la Transaction", selection: $transactionDate, displayedComponents: [.date])
						.datePickerStyle(.graphical)
				}
				
				Section("Potentielle") {
					Toggle("Transaction Potentielle", isOn: $isPotentiel)
				}
			}
			.navigationTitle("Ajouter")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Ajouter") { ajouterTransaction() }
				}
			}
		}
		.alert("Montant invalide", isPresented: $showingErrorAlert) {
			Button("OK") {}
		} message: {
			Text("Veuillez entrer un montant valide.")
		}
	}
	
	private func ajouterTransaction() {
		guard let montant = transactionAmount else {
			showingErrorAlert = true
			return
		}
		let finalAmount = transactionType == "+" ? montant : -montant
		let transaction = Transaction(
			amount: finalAmount,
			comment: transactionComment,
			potentiel: isPotentiel,
			date: isPotentiel ? nil : transactionDate
		)
		accountsManager.ajouterTransaction(transaction)
		dismiss()
	}
}
