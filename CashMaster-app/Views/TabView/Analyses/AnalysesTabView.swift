//
//  AnalysesTabView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 12/02/2026.
//

import SwiftUI

/// Wrapper de l'onglet Analyses avec NavigationStack et toolbar
struct AnalysesTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	
	var body: some View {
		NavigationStack {
			Group {
				if accountsManager.selectedAccountId != nil {
					AnalysesView(accountsManager: accountsManager)
						.navigationBarTitleDisplayMode(.large)
						.navigationDestination(for: CategoryDetailRoute.self) { route in
							CategoryTransactionsView(
								accountsManager: accountsManager,
								category: route.category,
								month: route.month,
								year: route.year
							)
						}
				} else {
					NoAccountView(accountsManager: accountsManager)
				}
			}
			.navigationTitle("Analyses")
			.accountPickerToolbar(isPresented: $showingAccountPicker, accountsManager: accountsManager)
		}
	}
}

#Preview {
	AnalysesTabView(accountsManager: AccountsManager())
}
