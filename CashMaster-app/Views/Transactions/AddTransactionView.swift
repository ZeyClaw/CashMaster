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
	private let maxCommentLength = 30
	private let maxMontant: Double = 999_999_999.99
	
	// MARK: - State
	@State private var montant: Double? = nil
	@State private var transactionComment: String = ""
	@State private var transactionType: TransactionType = .expense
	@State private var transactionDate: Date = Date()
	@State private var isPotentiel: Bool = false
	@State private var selectedCategory: TransactionCategory = .expense
	@State private var hasManuallySelectedCategory = false
	@State private var showingErrorAlert = false
	@State private var errorMessage = ""
	
	private var isEditMode: Bool { transactionToEdit != nil }
	
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
					.onChange(of: transactionType) { _, newValue in
						if !isEditMode && !hasManuallySelectedCategory && (selectedCategory == .income || selectedCategory == .expense) {
							selectedCategory = newValue == .income ? .income : .expense
						}
					}
				}
				
				Section {
					CurrencyTextField("Montant", amount: $montant)

					TextField("Commentaire", text: $transactionComment)
						.onChange(of: transactionComment) { _, newValue in
							if newValue.count > maxCommentLength {
								transactionComment = String(newValue.prefix(maxCommentLength))
							}
							if !isEditMode && !hasManuallySelectedCategory {
								selectedCategory = TransactionCategory.guessFrom(comment: newValue, type: transactionType)
							}
						}
				} header: {
					Text("Détails")
				} footer: {
					HStack {
						Spacer()
						Text("\(transactionComment.count)/\(maxCommentLength)")
					}
				}
				
				Section("Catégorie") {
					StylePickerGrid(selectedStyle: $selectedCategory, columns: 5) {
						hasManuallySelectedCategory = true
					}
				}
				
				Section("Date et statut") {
					Toggle("Transaction potentielle", isOn: $isPotentiel)
					if !isPotentiel {
						DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
							.datePickerStyle(.graphical)
					}
				}
				
				if isEditMode {
					Section {
						Button(role: .destructive) {
							if let transaction = transactionToEdit {
								accountsManager.deleteTransaction(transaction)
								dismiss()
							}
						} label: {
							HStack {
								Spacer()
								Label("Supprimer", systemImage: "trash")
								Spacer()
							}
						}
					}
				}
			}
			.navigationTitle(isEditMode ? "Modifier" : "Nouvelle transaction")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(isEditMode ? "OK" : "Ajouter") {
						saveTransaction()
					}
				}
			}
			.alert("Erreur", isPresented: $showingErrorAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage)
			}
			.onAppear {
				if let t = transactionToEdit {
					montant = abs(t.amount)
					transactionComment = t.comment
					transactionType = t.amount >= 0 ? .income : .expense
					isPotentiel = t.potentiel
					transactionDate = t.date ?? Date()
					selectedCategory = t.category
				}
			}
		}
	}
	
	private func saveTransaction() {
		guard let m = montant, m > 0 else {
			errorMessage = "Veuillez entrer un montant positif."
			showingErrorAlert = true
			return
		}
		
		if m > maxMontant {
			errorMessage = "Montant maximum: \(maxMontant.formatted()) €"
			showingErrorAlert = true
			return
		}
		
		let finalAmount = transactionType == .income ? m : -m
		let finalComment = String(transactionComment.prefix(maxCommentLength))
		let finalDate: Date? = isPotentiel ? nil : transactionDate
		
		if let existingTransaction = transactionToEdit {
			// Edit mode: create a modified copy (immutable struct)
			let updatedTransaction = existingTransaction.modified(
				amount: finalAmount,
				comment: finalComment,
				potentiel: isPotentiel,
				date: finalDate,
				category: selectedCategory
			)
			accountsManager.updateTransaction(updatedTransaction)
		} else {
			// Creation mode: new transaction
			accountsManager.addTransaction(Transaction(
				amount: finalAmount,
				comment: finalComment,
				potentiel: isPotentiel,
				date: finalDate,
				category: selectedCategory
			))
		}
		dismiss()
	}
}
