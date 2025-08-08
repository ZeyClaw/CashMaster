//
//  AddTransactionView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 16/10/2024.
//

import SwiftUI


enum TransactionType: String, CaseIterable, Identifiable {
	case income = "+"
	case expense = "-"
	
	var id: String { self.rawValue }
	var label: String {
		switch self {
		case .income: return "+"
		case .expense: return "−"
		}
	}
}


struct AddTransactionView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var transactionAmount: Double? = nil
	@State private var transactionComment: String = ""
	@State private var transactionType: TransactionType = .expense // "-" par défaut
	@State private var transactionDate: Date = Date()
	@State private var isPotentiel: Bool = false
	@State private var showingErrorAlert = false
	
	var body: some View {
		NavigationView {
			Form {
				Section("Type de transaction") {
					Picker("Type", selection: $transactionType) {
						ForEach(TransactionType.allCases) { type in
							Text(type.label).tag(type)
						}
					}
					.pickerStyle(.segmented)
				}
				Section("Détails de la transaction") {
					TextField("Montant", value: $transactionAmount, format: .number)
						.keyboardType(.decimalPad)
					TextField("Commentaire", text: $transactionComment)
				}
				
				Section("Date et statut") {
					Toggle("Transaction potentielle", isOn: $isPotentiel)
					if !isPotentiel {
						DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
							.datePickerStyle(.graphical)
					}
				}
			}
			.navigationTitle("Nouvelle transaction")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Ajouter") {
						ajouterTransaction()
					}
				}
			}
			.alert("Montant invalide", isPresented: $showingErrorAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("Veuillez entrer un montant valide.")
			}
		}
	}
	
	private func ajouterTransaction() {
		guard let montant = transactionAmount else {
			showingErrorAlert = true
			return
		}
		let finalAmount = transactionType == .income ? montant : -montant
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
