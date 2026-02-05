//
//  AccountPickerView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 07/08/2025.
//

import SwiftUI

struct AccountPickerView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var showingAddAccount = false
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(accountsManager.getAllAccounts()) { account in
					AccountCardView(
						account: account,
						solde: accountsManager.totalNonPotentiel(for: account),
						futur: accountsManager.totalNonPotentiel(for: account) + accountsManager.totalPotentiel(for: account)
					)
					.listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
					.listRowBackground(Color.clear)
					.contentShape(Rectangle())
					.onTapGesture {
						accountsManager.selectedAccountId = account.id
						dismiss()
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							accountsManager.deleteAccount(account)
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
					}
				}
				
				// Bouton Ajouter
				Button {
					showingAddAccount = true
				} label: {
					HStack {
						Image(systemName: "plus.circle.fill")
							.font(.title2)
						Text("Ajouter un compte")
							.font(.headline)
					}
					.frame(maxWidth: .infinity)
				}
				.listRowBackground(Color.clear)
			}
			.listStyle(.plain)
			.scrollContentBackground(.hidden)
			.background(
				Color(UIColor { traitCollection in
					traitCollection.userInterfaceStyle == .dark ? .black : .systemGroupedBackground
				})
				.ignoresSafeArea()
			)
			.navigationTitle("Mes comptes")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Fermer") {
						dismiss()
					}
				}
			}
			.sheet(isPresented: $showingAddAccount) {
				AddAccountSheet(accountsManager: accountsManager) {
					dismiss()
				}
			}
		}
	}
}
