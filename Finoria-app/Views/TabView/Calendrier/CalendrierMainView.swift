//
//  CalendrierMainView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 01/01/2026.
//

import SwiftUI

/// Vue principale de l'onglet Calendrier avec toolbar
struct CalendrierMainView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var showingAccountPicker = false
	
	var body: some View {
		NavigationStack {
			Group {
				if accountsManager.selectedAccountId != nil {
					CalendrierTabView(accountsManager: accountsManager)
				} else {
					NoAccountView(accountsManager: accountsManager)
						.navigationTitle("Calendrier")
				}
			}
			.accountPickerToolbar(isPresented: $showingAccountPicker, accountsManager: accountsManager)
		}
	}
}

#Preview {
	CalendrierMainView(accountsManager: AccountsManager())
}
