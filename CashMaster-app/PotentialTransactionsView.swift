//
//  PotentialTransactionsView.swift
//  GDF-app
//
//  Created by Godefroy REYNAUD on 14/10/2024.
//

// PotentialTransactionsView.swift
import SwiftUI

struct PotentialTransactionsView: View {
	@State private var totalPotentialTransactions = loadPotentialTransactions()
	@State private var showingTransactionAlert = false
	@State private var showingErrorAlert = false
	@State private var potentialTransactionAmount: Double?  // Montant de la transaction potentielle
	@State private var potentialTransactionComment = ""      // Commentaire de la transaction potentielle
	@State private var potentialTransactionType: String = "+"  // Par défaut "+"
	
	// Calcul du solde total des transactions potentielles
	var totalPotentialBalance: Double {
		totalPotentialTransactions.totalBalance
	}
	
	var body: some View {
		VStack {
			Button("Tester Chargement") {
				totalPotentialTransactions = PotentialTransactionsView.loadPotentialTransactions()
				print("Transactions chargées : \(totalPotentialTransactions.transactions)")
			}
			// Affichage du solde total potentiel
			Text("Solde Potentiel : \(totalPotentialBalance, specifier: "%.2f") €")
				.font(.largeTitle)
				.foregroundColor(totalPotentialBalance >= 0 ? .green : .red)
				.padding()
			
			// Liste des transactions potentielles
			List {
				ForEach(totalPotentialTransactions.transactions) { transaction in
					HStack {
						Text("\(transaction.amount, specifier: "%.2f") €")
							.foregroundColor(transaction.amount >= 0 ? .green : .red)
						Spacer()
						Text(transaction.comment)
					}
					.swipeActions {
						Button {
							if let index = totalPotentialTransactions.transactions.firstIndex(where: { $0.id == transaction.id }) {
								deletePotentialTransaction(at: index)
							}
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
						.tint(.red)
					}
				}
			}
			.navigationTitle("Transactions Potentielles")
			
			// Boutons pour ajouter une nouvelle transaction potentielle (positive ou négative)
			HStack {
				Button(action: {
					potentialTransactionAmount = nil
					potentialTransactionComment = ""
					potentialTransactionType = "+"  // Pour les transactions positives
					showingTransactionAlert = true
				}) {
					HStack {
						Image(systemName: "plus.circle.fill")
							.foregroundColor(.white)
						Text("Ajouter")
							.foregroundColor(.white)
							.font(.headline)
					}
					.padding()
					.background(Color.green)
					.cornerRadius(10)
				}
				
				Button(action: {
					potentialTransactionAmount = nil
					potentialTransactionComment = ""
					potentialTransactionType = "-"  // Pour les transactions négatives
					showingTransactionAlert = true
				}) {
					HStack {
						Image(systemName: "minus.circle.fill")
							.foregroundColor(.white)
						Text("Ajouter")
							.foregroundColor(.white)
							.font(.headline)
					}
					.padding()
					.background(Color.red)
					.cornerRadius(10)
				}
			}
			.padding()
		}
		.alert("Nouvelle Transaction Potentielle", isPresented: $showingTransactionAlert) {
			// Alerte pour entrer les informations de la nouvelle transaction
			VStack {
				TextField("Montant", value: $potentialTransactionAmount, format: .number)
					.keyboardType(.decimalPad)
				TextField("Commentaire", text: $potentialTransactionComment)
			}
			
			Button("Ajouter") {
				if let amountValue = potentialTransactionAmount {
					let amount = potentialTransactionType == "+" ? amountValue : -amountValue
					let transaction = PotentialTransaction(amount: amount, comment: potentialTransactionComment)
					totalPotentialTransactions.addTransaction(transaction)
					savePotentialTransactions()
				} else {
					showingErrorAlert = true  // Si le montant est vide ou incorrect, afficher une erreur
				}
			}
			
			Button("Annuler", role: .cancel) {}
		}
		.alert("Le montant est invalide", isPresented: $showingErrorAlert) {
			Button("OK") {
				showingTransactionAlert = true  // Réouvrir l'alerte si l'utilisateur veut corriger son erreur
			}
		} message: {
			Text("Veuillez entrer un montant valide.")
		}
	}
	
	// Fonction pour supprimer une transaction potentielle
	func deletePotentialTransaction(at index: Int) {
		totalPotentialTransactions.removeTransaction(at: index)
		savePotentialTransactions()
	}
	
	// Fonction pour sauvegarder les transactions potentielles
	func savePotentialTransactions() {
		if let encoded = try? JSONEncoder().encode(totalPotentialTransactions) {
			UserDefaults.standard.set(encoded, forKey: "potentialTransactions")
		}
	}
	
	// Fonction pour charger les transactions potentielles depuis UserDefaults
	static func loadPotentialTransactions() -> TotalPotentialTransactions {
		if let data = UserDefaults.standard.data(forKey: "potentialTransactions") {
			if let decoded = try? JSONDecoder().decode(TotalPotentialTransactions.self, from: data) {
				return decoded
			}
		}
		return TotalPotentialTransactions(transactions: [])  // Si aucune transaction n'est trouvée, retourner une liste vide
	}
}
