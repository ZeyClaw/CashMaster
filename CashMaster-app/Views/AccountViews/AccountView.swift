//
//  AccountView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import SwiftUI

enum AccountMainMode {
	case annees, mois, potentielles
}

struct AccountView: View {
	@ObservedObject var accountsManager: AccountsManager
	let account: String
	
	@State private var mode: AccountMainMode = .annees
	@State private var showingAddSheet = false
	
	var body: some View {
		VStack {
			content
		}
		.navigationTitle(account)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Menu {
					Button("Années") { mode = .annees }
					Button("Mois")   { mode = .mois }
					Button("Potentielles") { mode = .potentielles }
				} label: {
					Label("Vue", systemImage: "line.3.horizontal.decrease.circle")
				}
			}
		}
		.sheet(isPresented: $showingAddSheet) {
			AddTransactionView(accountsManager: accountsManager, accountName: account)
		}
	}
	
	@ViewBuilder
	private var content: some View {
		switch mode {
		case .annees:
			YearsView(account: account, accountsManager: accountsManager)
		case .mois:
			MonthsView(account: account, accountsManager: accountsManager, year: Calendar.current.component(.year, from: Date()))
		case .potentielles:
			PotentialTransactionsView(account: account, accountsManager: accountsManager)
		}
	}
}
