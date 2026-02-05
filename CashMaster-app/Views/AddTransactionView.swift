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
	private let maxCommentLength = 50
	
	// MARK: - State
	@State private var montant: Double? = nil
	@State private var transactionComment: String = ""
	@State private var transactionType: TransactionType = .expense
	@State private var transactionDate: Date = Date()
	@State private var isPotentiel: Bool = false
	@State private var showingErrorAlert = false
	
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
					TextField("Montant", value: $montant, format: .currency(code: "EUR"))
						.keyboardType(.decimalPad)
					
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
			.alert("Montant invalide", isPresented: $showingErrorAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("Veuillez entrer un montant positif.")
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
			showingErrorAlert = true
			return
		}
		
		let montantArrondi = (m * 100).rounded() / 100
		let finalAmount = transactionType == .income ? montantArrondi : -montantArrondi
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
