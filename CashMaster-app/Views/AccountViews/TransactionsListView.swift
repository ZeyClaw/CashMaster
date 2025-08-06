//
//  TransactionsListView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct TransactionsListView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	var month: Int? = nil
	var year: Int? = nil
	
	@Binding var mode: AccountMainMode
	@Binding var showingAddTransactionSheet: Bool
	@Binding var showingResetAlert: Bool
	
	var body: some View {
		List {
			ForEach(accountsManager.validatedTransactions(for: account, year: year, month: month)) { transaction in
				TransactionRow(transaction: transaction)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							accountsManager.supprimerTransaction(transaction, from: account)
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
					}
			}
		}
		.navigationTitle(titleText)
		.toolbar {
			AccountToolbar(
				mode: $mode,
				account: account,
				accountsManager: accountsManager,
				showingAddTransactionSheet: $showingAddTransactionSheet,
				showingResetAlert: $showingResetAlert
			)
		}
	}
	
	private var titleText: String {
		if let year = year, let month = month {
			return "\(nomDuMois(month)) \(year)"
		} else if let year = year {
			return "\(year)"
		} else {
			return "Transactions"
		}
	}
	
	private func nomDuMois(_ mois: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		return formatter.monthSymbols[mois - 1].capitalized
	}
}
