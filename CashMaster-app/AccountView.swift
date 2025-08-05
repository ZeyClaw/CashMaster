//
//  AccountView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import SwiftUI

struct AccountView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var showingAddTransactionSheet = false
	@State private var showingResetAlert = false
	
	var body: some View {
		List {
			Section("Transactions Validées") {
				ForEach(accountsManager.transactions(for: account).filter { !$0.potentiel }) { transaction in
					TransactionRow(transaction: transaction)
				}
				.onDelete { indexSet in
					indexSet.forEach { idx in
						let tx = accountsManager.transactions(for: account).filter { !$0.potentiel }[idx]
						accountsManager.supprimerTransaction(tx, from: account)
					}
				}
			}
			
			Section("Transactions Potentielles") {
				ForEach(accountsManager.transactions(for: account).filter { $0.potentiel }) { transaction in
					TransactionRow(transaction: transaction)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								accountsManager.supprimerTransaction(transaction, from: account)
							} label: {
								Label("Supprimer", systemImage: "trash")
							}
						}
						.swipeActions(edge: .leading, allowsFullSwipe: true) {
							Button {
								accountsManager.validerTransaction(transaction, in: account)
							} label: {
								Label("Valider", systemImage: "checkmark.circle")
							}
							.tint(.green)
						}
				}
			}
		}
		.navigationTitle(account)
		.toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Button {
					showingAddTransactionSheet = true
				} label: {
					Label("Ajouter", systemImage: "plus.circle.fill")
				}
				
				Spacer()
				
				Button(role: .destructive) {
					showingResetAlert = true
				} label: {
					Label("Reset", systemImage: "trash")
				}
			}
		}
		.sheet(isPresented: $showingAddTransactionSheet) {
			AddTransactionView(accountsManager: accountsManager, accountName: account)
		}
		.alert("Réinitialiser ce compte ?", isPresented: $showingResetAlert) {
			Button("Reset", role: .destructive) {
				accountsManager.resetAccount(account)
			}
			Button("Annuler", role: .cancel) {}
		}
	}
}
