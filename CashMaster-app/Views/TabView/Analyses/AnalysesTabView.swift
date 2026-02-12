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
	@State private var analysisMonth: Int = Calendar.current.component(.month, from: Date())
	@State private var analysisYear: Int = Calendar.current.component(.year, from: Date())
	
	var body: some View {
		NavigationStack {
			if accountsManager.selectedAccountId != nil {
				AnalysesView(accountsManager: accountsManager)
					.navigationTitle("Analyses")
					.navigationBarTitleDisplayMode(.large)
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.imageScale(.large)
							}
						}
					}
					.sheet(isPresented: $showingAccountPicker) {
						AccountPickerView(accountsManager: accountsManager)
					}
					.navigationDestination(for: TransactionCategory.self) { category in
						CategoryTransactionsView(
							accountsManager: accountsManager,
							category: category
						)
					}
			} else {
				NoAccountView(accountsManager: accountsManager)
					.navigationTitle("Analyses")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {
								showingAccountPicker = true
							} label: {
								Image(systemName: "person.crop.circle")
									.imageScale(.large)
							}
						}
					}
					.sheet(isPresented: $showingAccountPicker) {
						AccountPickerView(accountsManager: accountsManager)
					}
			}
		}
	}
}

#Preview {
	AnalysesTabView(accountsManager: AccountsManager())
}
