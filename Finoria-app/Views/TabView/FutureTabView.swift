//
//  FutureTabView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 01/01/2026.
//

import SwiftUI

/// Main view for the Future/Potential transactions tab with toolbar
struct FutureTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	
	var body: some View {
		NavigationStack {
			Group {
				if accountsManager.selectedAccountId != nil {
					PotentialTransactionsView(accountsManager: accountsManager)
				} else {
					NoAccountView(accountsManager: accountsManager)
				}
			}
			.navigationTitle("Futur")
			.accountPickerToolbar(isPresented: $showingAccountPicker, accountsManager: accountsManager)
		}
	}
}

#Preview {
	FutureTabView(accountsManager: AccountsManager())
}
