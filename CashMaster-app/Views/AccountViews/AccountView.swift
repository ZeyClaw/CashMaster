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
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var showingAddTransactionSheet = false
	@State private var showingResetAlert = false
	@State private var mode: AccountMainMode = .annees
	
	var body: some View {
		Group {
			switch mode {
			case .annees:
				YearsView(account: account, accountsManager: accountsManager, mode: $mode, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)
			case .mois:
				MonthsView(account: account, accountsManager: accountsManager, year: Calendar.current.component(.year, from: Date()), mode: $mode, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)
			case .potentielles:
				PotentialTransactionsView(account: account, accountsManager: accountsManager, mode: $mode, showingAddTransactionSheet: $showingAddTransactionSheet, showingResetAlert: $showingResetAlert)
			}
		}
		.navigationTitle(account)
		.sheet(isPresented: $showingAddTransactionSheet) {
			AddTransactionView(accountsManager: accountsManager, accountName: account)
		}
		.alert("Réinitialiser ce compte ?", isPresented: $showingResetAlert) {
			Button("Reset", role: .destructive) {
				accountsManager.resetAccount(account)
			}
			Button("Annuler", role: .cancel) {}
		}
	}
}
