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
	@State private var transactionToEdit: Transaction? = nil
	
	var body: some View {
		List {
			ForEach(accountsManager.validatedTransactions(year: year, month: month).sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }) { transaction in
				TransactionRow(transaction: transaction)
					.contentShape(Rectangle())
					.onTapGesture {
						transactionToEdit = transaction
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
								accountsManager.deleteTransaction(transaction)
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
		.sheet(item: $transactionToEdit) { transaction in
			AddTransactionView(accountsManager: accountsManager, transactionToEdit: transaction)
		}
	}
	
	private var titleText: String {
		if let year = year, let month = month {
			return "\(Date.monthName(month)) \(year)"
		} else if let year = year {
			return "\(year)"
		} else {
			return "Transactions"
		}
	}
}
