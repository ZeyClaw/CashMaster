//
//  PotentialTransactionsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct PotentialTransactionsView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	var body: some View {
		List {
			if accountsManager.potentialTransactions().isEmpty {
				Text("Aucune transaction potentielle")
					.foregroundStyle(.secondary)
			} else {
				ForEach(accountsManager.potentialTransactions()) { transaction in
					TransactionRow(transaction: transaction)
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								accountsManager.supprimerTransaction(transaction)
							} label: {
								Label("Supprimer", systemImage: "trash")
							}
						}
						.swipeActions(edge: .leading, allowsFullSwipe: true) {
							Button {
								accountsManager.validerTransaction(transaction)
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
