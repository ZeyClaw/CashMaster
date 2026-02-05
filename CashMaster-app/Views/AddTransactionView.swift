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
				}
				
				Section {
					HStack {
						TextField(
							"Montant",
							value: $montant,
							format: .number.precision(.fractionLength(0...2))
						)
						.keyboardType(.decimalPad)
						
						Text("€")
							.foregroundStyle(.secondary)
					}
					.listRowSeparator(.hidden) // Masque le séparateur par défaut

					Rectangle()
						.fill(Color.clear)
						.frame(height: 0.01)
					
					TextField("Commentaire", text: $transactionComment)
						.onChange(of: transactionComment) { _, newValue in
							if newValue.count > maxCommentLength {
								transactionComment = String(newValue.prefix(maxCommentLength))
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
								accountsManager.supprimerTransaction(transaction)
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
						sauvegarder()
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
				}
			}
		}
	}
	
	private func sauvegarder() {
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
		
		if let t = transactionToEdit {
			t.amount = finalAmount
			t.comment = finalComment
			t.potentiel = isPotentiel
			t.date = isPotentiel ? nil : transactionDate
			accountsManager.sauvegarder()
		} else {
			accountsManager.ajouterTransaction(Transaction(
				amount: finalAmount,
				comment: finalComment,
				potentiel: isPotentiel,
				date: isPotentiel ? nil : transactionDate
			))
		}
		dismiss()
	}
}
