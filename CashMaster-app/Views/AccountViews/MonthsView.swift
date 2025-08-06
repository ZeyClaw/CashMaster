//
//  MonthsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct MonthsView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	var year: Int
	
	@Binding var mode: AccountMainMode
	@Binding var showingAddTransactionSheet: Bool
	@Binding var showingResetAlert: Bool
	
	var body: some View {
		List {
			ForEach(1...12, id: \.self) { month in
				let total = accountsManager.totalPourMois(month, year: year, account: account)
				if total != 0 {
					NavigationLink(destination: TransactionsListView(
						account: account,
						accountsManager: accountsManager,
						month: month,
						year: year,
						mode: $mode,
						showingAddTransactionSheet: $showingAddTransactionSheet,
						showingResetAlert: $showingResetAlert
					)) {
						HStack {
							Text(nomDuMois(month))
							Spacer()
							Text("\(total, specifier: "%.2f") €")
								.foregroundStyle(total >= 0 ? .green : .red)
						}
					}
				}
			}

		}
		.navigationTitle("\(year)")
		.toolbar {
			AccountToolbar(mode: $mode, account: account, accountsManager: accountsManager, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)
		}
	}
	
	private func nomDuMois(_ mois: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		return formatter.monthSymbols[mois - 1].capitalized
	}
}
