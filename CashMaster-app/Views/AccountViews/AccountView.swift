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
	@State private var showingResetAlert = false
	
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
			ToolbarItemGroup(placement: .bottomBar) {
				Button { showingAddSheet = true } label: {
					Label("Ajouter", systemImage: "plus.circle.fill")
				}
				Spacer()
				Button(role: .destructive) { showingResetAlert = true } label: {
					Label("Reset", systemImage: "trash")
				}
			}
		}
		.sheet(isPresented: $showingAddSheet) {
			AddTransactionView(accountsManager: accountsManager, accountName: account)
		}
		.alert("Réinitialiser ce compte ?", isPresented: $showingResetAlert) {
			Button("Reset", role: .destructive) {
				accountsManager.resetAccount(account)
			}
			Button("Annuler", role: .cancel) {}
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
