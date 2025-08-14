//
//  CalendrierTabView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 14/08/2025.
//

import SwiftUI

struct CalendrierTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var path: [CalendrierRoute] = []
	
	var body: some View {
		NavigationStack(path: $path) {
			if accountsManager.transactions().isEmpty {
				List {
					Text("Aucune transaction")
						.foregroundStyle(.secondary)
				}
				.navigationTitle("Calendrier")
			} else {
				YearsView(accountsManager: accountsManager)
					.navigationTitle("Calendrier")
					.navigationDestination(for: CalendrierRoute.self) { route in
						switch route {
						case .months(let year):
							MonthsView(accountsManager: accountsManager, year: year)
						case .transactions(let month, let year):
							TransactionsListView(accountsManager: accountsManager, month: month, year: year)
						}
					}
			}
		}
	}
}
