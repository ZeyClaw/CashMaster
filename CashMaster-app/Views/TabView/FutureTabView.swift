//
//  FutureTabView.swift
//  CashMaster
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
			if accountsManager.selectedAccountId != nil {
				PotentialTransactionsView(accountsManager: accountsManager)
					.navigationTitle("À venir")
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
			} else {
				NoAccountView(accountsManager: accountsManager)
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
	FutureTabView(accountsManager: AccountsManager())
}
