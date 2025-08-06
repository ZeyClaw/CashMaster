//
//  AccountToolbar.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct AccountToolbar: ToolbarContent {
	@Binding var mode: AccountMainMode
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	@Binding var showingAddTransactionSheet: Bool
	@Binding var showingResetAlert: Bool
	
	var body: some ToolbarContent {
		// Menu déroulant en haut
		ToolbarItemGroup(placement: .navigationBarTrailing) {
			Menu {
				Button("Années") { mode = .annees }
				Button("Mois (année courante)") { mode = .mois }
				Button("Transactions Potentielles") { mode = .potentielles }
			} label: {
				Label("Vue", systemImage: "line.3.horizontal.decrease.circle")
			}
		}
		
		// Toolbar bas : ajouter + reset
		ToolbarItemGroup(placement: .bottomBar) {
			Button {
				showingAddTransactionSheet = true
			} label: {
				Label("Ajouter", systemImage: "plus.circle.fill")
			}
			
			Spacer()
			
			Button(role: .destructive) {
				showingResetAlert = true
			} label: {
				Label("Reset", systemImage: "trash")
			}
		}
	}
}

