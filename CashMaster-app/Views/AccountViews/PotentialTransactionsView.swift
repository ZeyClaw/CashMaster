//
//  PotentialTransactionsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct PotentialTransactionsView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	
	var body: some View {
		List {
			if accountsManager.potentialTransactions(for: account).isEmpty {
				Text("Aucune transaction potentielle")
					.foregroundStyle(.secondary)
			} else {
				ForEach(accountsManager.potentialTransactions(for: account)) { transaction in
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
		.navigationTitle("Futur")
	}
}
