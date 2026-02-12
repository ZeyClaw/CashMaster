//
//  AllTransactionsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/02/2026.
//

import SwiftUI

struct AllTransactionsView: View {
	@ObservedObject var accountsManager: AccountsManager
	var embedded: Bool = false // Si true, pas de titre ni toolbar (utilisé dans CalendrierTabView)
	
	@State private var showingAccountPicker = false
	@State private var transactionToEdit: Transaction? = nil
	
	/// Toutes les transactions validées, triées par date décroissante
	private var allTransactions: [Transaction] {
		accountsManager.validatedTransactions(year: nil, month: nil)
			.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
	}
	
	/// Regroupe les transactions par jour
	private var transactionsGroupedByDay: [(date: Date, transactions: [Transaction])] {
		let calendar = Calendar.current
		let grouped = Dictionary(grouping: allTransactions) { transaction -> Date in
			guard let date = transaction.date else { return Date.distantPast }
			return calendar.startOfDay(for: date)
		}
		return grouped.sorted { $0.key > $1.key }
			.map { (date: $0.key, transactions: $0.value) }
	}
	
	var body: some View {
		List {
			ForEach(transactionsGroupedByDay, id: \.date) { group in
				Section {
					ForEach(group.transactions) { transaction in
						TransactionRow(transaction: transaction)
							.contentShape(Rectangle())
							.onTapGesture {
								transactionToEdit = transaction
							}
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button(role: .destructive) {
									withAnimation {
										accountsManager.deleteTransaction(transaction)
									}
								} label: {
									Label("Supprimer", systemImage: "trash")
								}
							}
					}
				} header: {
					Text(group.date.dayHeaderFormatted())
						.font(.subheadline)
						.fontWeight(.semibold)
						.foregroundStyle(.secondary)
				}
			}
		}
		.scrollContentBackground(embedded ? .hidden : .visible)
		.if(!embedded) { view in
			view
				.navigationTitle("Toutes les transactions")
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
		}
		.sheet(isPresented: $showingAccountPicker) {
			AccountPickerView(accountsManager: accountsManager)
		}
		.sheet(item: $transactionToEdit) { transaction in
			AddTransactionView(accountsManager: accountsManager, transactionToEdit: transaction)
		}
	}
	
}

