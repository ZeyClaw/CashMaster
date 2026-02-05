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
	
	// Transaction à éditer (nil = nouvelle transaction)
	var transactionToEdit: Transaction? = nil
	
	// MARK: - Limites
	private let maxCommentLength = 200
	private let maxAmountValue: Double = 999_999_999.99
	
	// MARK: - State
	@State private var amountText: String = ""
	@State private var transactionComment: String = ""
	@State private var transactionType: TransactionType = .expense
	@State private var transactionDate: Date = Date()
	@State private var isPotentiel: Bool = false
	@State private var showingErrorAlert = false
	@State private var errorMessage = ""
	
	// Mode édition ou ajout
	private var isEditMode: Bool { transactionToEdit != nil }
	
	// Montant formaté pour affichage
	private var formattedAmount: String {
		guard let amount = parseAmount(amountText), amount > 0 else {
			return "0,00 €"
		}
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = "EUR"
		formatter.locale = Locale(identifier: "fr_FR")
		return formatter.string(from: NSNumber(value: amount)) ?? "0,00 €"
	}
	
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
				
				Section {
					HStack {
						TextField("Montant", text: $amountText)
							.keyboardType(.decimalPad)
							.onChange(of: amountText) { _, newValue in
								amountText = sanitizeAmountInput(newValue)
							}
						
						// Affichage du montant formaté
						Text(formattedAmount)
							.foregroundStyle(.secondary)
							.font(.subheadline)
					}
					
					TextField("Commentaire", text: $transactionComment)
						.onChange(of: transactionComment) { _, newValue in
							if newValue.count > maxCommentLength {
								transactionComment = String(newValue.prefix(maxCommentLength))
							}
						}
					
					if !transactionComment.isEmpty {
						Text("\(transactionComment.count)/\(maxCommentLength)")
							.font(.caption)
							.foregroundStyle(transactionComment.count > maxCommentLength - 20 ? .orange : .secondary)
					}
				} header: {
					Text("Détails de la transaction")
				} footer: {
					Text("Montant max: \(Int(maxAmountValue).formatted()) € • 2 décimales max")
						.font(.caption2)
				}
				
				Section("Date et statut") {
					Toggle("Transaction potentielle", isOn: $isPotentiel)
					if !isPotentiel {
						DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
							.datePickerStyle(.graphical)
					}
				}
				
				// Bouton supprimer en mode édition
				if isEditMode {
					Section {
						Button(role: .destructive) {
							if let transaction = transactionToEdit {
								accountsManager.supprimerTransaction(transaction)
								dismiss()
							}
						} label: {
							HStack {
								Spacer()
								Label("Supprimer cette transaction", systemImage: "trash")
								Spacer()
							}
						}
					}
				}
			}
			.navigationTitle(isEditMode ? "Modifier" : "Nouvelle transaction")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(isEditMode ? "Enregistrer" : "Ajouter") {
						sauvegarderTransaction()
					}
				}
			}
			.alert("Erreur", isPresented: $showingErrorAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage)
			}
			.onAppear {
				setupForEditing()
			}
		}
	}
	
	// MARK: - Setup pour édition
	private func setupForEditing() {
		guard let transaction = transactionToEdit else { return }
		
		let absAmount = abs(transaction.amount)
		// Formater le montant pour l'affichage dans le TextField
		if absAmount == floor(absAmount) {
			amountText = String(format: "%.0f", absAmount)
		} else {
			amountText = String(format: "%.2f", absAmount).replacingOccurrences(of: ".", with: ",")
		}
		
		transactionComment = transaction.comment
		transactionType = transaction.amount >= 0 ? .income : .expense
		isPotentiel = transaction.potentiel
		transactionDate = transaction.date ?? Date()
	}
	
	// MARK: - Validation et nettoyage du montant
	private func sanitizeAmountInput(_ input: String) -> String {
		var cleaned = input
		
		// Remplacer le point par une virgule
		cleaned = cleaned.replacingOccurrences(of: ".", with: ",")
		
		// Ne garder que les chiffres et une seule virgule
		var hasComma = false
		cleaned = cleaned.filter { char in
			if char == "," {
				if hasComma { return false }
				hasComma = true
				return true
			}
			return char.isNumber
		}
		
		// Limiter à 2 décimales après la virgule
		if let commaIndex = cleaned.firstIndex(of: ",") {
			let afterComma = cleaned[cleaned.index(after: commaIndex)...]
			if afterComma.count > 2 {
				let endIndex = cleaned.index(commaIndex, offsetBy: 3)
				cleaned = String(cleaned[..<endIndex])
			}
		}
		
		// Limiter la partie entière (éviter des nombres trop grands)
		if let commaIndex = cleaned.firstIndex(of: ",") {
			let beforeComma = String(cleaned[..<commaIndex])
			if beforeComma.count > 9 {
				cleaned = String(beforeComma.prefix(9)) + String(cleaned[commaIndex...])
			}
		} else if cleaned.count > 9 {
			cleaned = String(cleaned.prefix(9))
		}
		
		return cleaned
	}
	
	private func parseAmount(_ text: String) -> Double? {
		let normalized = text.replacingOccurrences(of: ",", with: ".")
		return Double(normalized)
	}
	
	// MARK: - Sauvegarde
	private func sauvegarderTransaction() {
		guard let montant = parseAmount(amountText), montant > 0 else {
			errorMessage = "Veuillez entrer un montant positif valide."
			showingErrorAlert = true
			return
		}
		
		if montant > maxAmountValue {
			errorMessage = "Le montant ne peut pas dépasser \(Int(maxAmountValue).formatted()) €."
			showingErrorAlert = true
			return
		}
		
		// Arrondir à 2 décimales
		let montantArrondi = (montant * 100).rounded() / 100
		let finalAmount = transactionType == .income ? montantArrondi : -montantArrondi
		
		// Tronquer le commentaire si nécessaire
		let finalComment = String(transactionComment.prefix(maxCommentLength))
		
		if let existingTransaction = transactionToEdit {
			// Mode édition : mettre à jour
			existingTransaction.amount = finalAmount
			existingTransaction.comment = finalComment
			existingTransaction.potentiel = isPotentiel
			existingTransaction.date = isPotentiel ? nil : transactionDate
			accountsManager.sauvegarder()
		} else {
			// Mode ajout : créer nouvelle transaction
			let transaction = Transaction(
				amount: finalAmount,
				comment: finalComment,
				potentiel: isPotentiel,
				date: isPotentiel ? nil : transactionDate
			)
			accountsManager.ajouterTransaction(transaction)
		}
		dismiss()
	}
}
