//
//  PotentialTransactionsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct PotentialTransactionsView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var transactionToEdit: Transaction? = nil
	@State private var transactionToDelete: Transaction? = nil
	@State private var transactionToValidate: Transaction? = nil
	@State private var showDeleteConfirmation = false
	@State private var showValidateConfirmation = false
	
	var body: some View {
		List {
			if accountsManager.potentialTransactions().isEmpty {
				Text("Aucune transaction potentielle")
					.foregroundStyle(.secondary)
			} else {
				ForEach(accountsManager.potentialTransactions()) { transaction in
					TransactionRow(transaction: transaction)
						.contentShape(Rectangle())
						.onTapGesture {
							transactionToEdit = transaction
						}
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								if transaction.recurringTransactionId != nil {
									transactionToDelete = transaction
									showDeleteConfirmation = true
								} else {
									accountsManager.deleteTransaction(transaction)
								}
							} label: {
								Label("Supprimer", systemImage: "trash")
							}
						}
						.swipeActions(edge: .leading, allowsFullSwipe: true) {
							Button {
								if transaction.recurringTransactionId != nil {
									transactionToValidate = transaction
									showValidateConfirmation = true
								} else {
									accountsManager.validateTransaction(transaction)
								}
							} label: {
								Label("Valider", systemImage: "checkmark.circle")
							}
							.tint(.green)
						}
				}
			}
		}
		.navigationTitle("Futur")
		.sheet(item: $transactionToEdit) { transaction in
			AddTransactionView(accountsManager: accountsManager, transactionToEdit: transaction)
		}
		.alert("Supprimer cette transaction ?", isPresented: $showDeleteConfirmation) {
			Button("Annuler", role: .cancel) {
				transactionToDelete = nil
			}
			Button("Supprimer", role: .destructive) {
				if let transaction = transactionToDelete {
					accountsManager.deleteTransaction(transaction)
				}
				transactionToDelete = nil
			}
		} message: {
			Text("Cette transaction a été générée par une récurrence. Elle sera recréée automatiquement au prochain traitement.")
		}
		.alert("Valider cette transaction ?", isPresented: $showValidateConfirmation) {
			Button("Annuler", role: .cancel) {
				transactionToValidate = nil
			}
			Button("Valider") {
				if let transaction = transactionToValidate {
					accountsManager.validateTransaction(transaction)
				}
				transactionToValidate = nil
			}
		} message: {
			Text("Cette transaction a été générée par une récurrence. La valider maintenant l'ajoutera à votre solde actuel.")
		}
	}
}
