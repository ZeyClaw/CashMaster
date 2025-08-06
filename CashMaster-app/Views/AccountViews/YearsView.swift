//
//  YearsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct YearsView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	
	@Binding var mode: AccountMainMode
	@Binding var showingAddTransactionSheet: Bool
	@Binding var showingResetAlert: Bool
	
	var body: some View {
		List {
			ForEach(accountsManager.anneesDisponibles(for: account), id: \.self) { year in
				NavigationLink(destination: MonthsView(account: account, accountsManager: accountsManager, year: year, mode: $mode, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)) {
					HStack {
						Text("\(year)")
						Spacer()
						Text("\(accountsManager.totalPourAnnee(year, account: account), specifier: "%.2f") €")
							.foregroundStyle(accountsManager.totalPourAnnee(year, account: account) >= 0 ? .green : .red)
					}
				}
			}
		}
		.toolbar {
			AccountToolbar(mode: $mode, account: account, accountsManager: accountsManager, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)
		}
	}
}
