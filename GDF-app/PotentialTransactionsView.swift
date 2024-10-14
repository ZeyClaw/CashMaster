//
//  PotentialTransactionsView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// PotentialTransactionsView.swift
import SwiftUI

struct PotentialTransactionsView: View {
	@State private var potentialTransactions: [Transaction] = []  // Liste des transactions potentielles
	@State private var showingTransactionAlert = false  // Gérer l'affichage de l'alerte
	@State private var transactionAmount: Double?  // Montant de la transaction potentielle
	@State private var transactionComment = ""  // Commentaire de la transaction
	@State private var transactionType = ""  // "+" ou "-"
	
	var totalPotential: Double {
		// Calcule le solde total des transactions potentielles
		potentialTransactions.map { $0.amount }.reduce(0, +)
	}
	
	var body: some View {
		VStack {
			Text("Transactions Potentielles")
				.font(.largeTitle)
				.padding()
			
			// Affichage du solde total des transactions potentielles
			Text("Solde Potentiel: \(totalPotential, specifier: "%.2f") €")
				.font(.title)
				.foregroundColor(totalPotential >= 0 ? .green : .red)
			
			// Boutons pour ajouter ou soustraire un montant potentiel
			HStack {
				TransactionButton(action: {
					transactionType = "+"
					transactionAmount = nil
					transactionComment = ""
					showingTransactionAlert = true
				}, title: "+", color: .green)
				
				TransactionButton(action: {
					transactionType = "-"
					transactionAmount = nil
					transactionComment = ""
					showingTransactionAlert = true
				}, title: "-", color: .red)
			}

			.padding()
			
			// Liste des transactions potentielles
			List {
				ForEach(potentialTransactions) { transaction in
					HStack {
						Text("\(transaction.amount, specifier: "%.2f") €")
							.foregroundColor(transaction.amount >= 0 ? .green : .red)
						Spacer()
						Text(transaction.comment)
					}
					.swipeActions {
						Button {
							// Action de suppression
							if let index = potentialTransactions.firstIndex(where: { $0.id == transaction.id }) {
								potentialTransactions.remove(at: index)  // Supprimer la transaction
								savePotentialTransactions()  // Sauvegarder les transactions mises à jour
							}
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
						.tint(.red) // Change la couleur de la zone de swipe
					}
				}
			}
		}
		.alert("Nouvelle Transaction Potentielle", isPresented: $showingTransactionAlert) {
			TextField("Montant", value: $transactionAmount, formatter: NumberFormatter())
				.keyboardType(.decimalPad) // Clavier numérique
			TextField("Commentaire", text: $transactionComment)
			Button("Ajouter") {
				if let amountValue = transactionAmount {
					let amount = transactionType == "+" ? amountValue : -amountValue
					let transaction = Transaction(amount: amount, date: Date(), comment: transactionComment)
					potentialTransactions.append(transaction)  // Ajouter la transaction potentielle
					savePotentialTransactions()  // Sauvegarder les transactions mises à jour
				}
			}
			Button("Annuler", role: .cancel) {}
		} message: {
			Text("Ajoutez un montant et un commentaire")
		}
		.onAppear {
			loadPotentialTransactions()  // Charger les transactions potentielles au démarrage de la vue
		}
	}
	
	// Fonction pour charger les transactions potentielles
	private func loadPotentialTransactions() {
		if let data = UserDefaults.standard.data(forKey: "potentialTransactions") {
			let decoder = JSONDecoder()
			if let decoded = try? decoder.decode([Transaction].self, from: data) {
				potentialTransactions = decoded
			}
		}
	}
	
	// Fonction pour sauvegarder les transactions potentielles
	private func savePotentialTransactions() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(potentialTransactions) {
			UserDefaults.standard.set(encoded, forKey: "potentialTransactions")
		}
	}
}
