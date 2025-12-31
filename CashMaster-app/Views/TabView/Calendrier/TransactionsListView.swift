//
//  TransactionsListView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct TransactionsListView: View {
	@ObservedObject var accountsManager: AccountsManager
	var month: Int? = nil
	var year: Int? = nil
	@State private var showingAccountPicker = false
	
	var body: some View {
		List {
			ForEach(accountsManager.validatedTransactions(year: year, month: month)) { transaction in
				TransactionRow(transaction: transaction)
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							accountsManager.supprimerTransaction(transaction)
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
					}
			}
		}
		.navigationTitle(titleText)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					showingAccountPicker = true
				} label: {
					Image(systemName: "person.crop.circle")
						.font(.title2)
				}
			}
		}
		.sheet(isPresented: $showingAccountPicker) {
			AccountPickerView(accountsManager: accountsManager)
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
