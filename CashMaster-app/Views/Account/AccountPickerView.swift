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
	@State private var newAccountName = ""
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(accountsManager.getAllAccounts(), id: \.self) { account in
					Button {
						accountsManager.selectedAccount = account
						dismiss()
					} label: {
						AccountCardView(
							account: account,
							solde: accountsManager.totalNonPotentiel(for: account),
							futur: accountsManager.totalNonPotentiel(for: account) + accountsManager.totalPotentiel(for: account)
						)
					}
					.swipeActions(edge: .trailing, allowsFullSwipe: true) {
						Button(role: .destructive) {
							accountsManager.deleteAccount(account)
						} label: {
							Label("Supprimer", systemImage: "trash")
						}
					}
				}
				
				Section {
					Button {
						showingAddAccount = true
					} label: {
						HStack {
							Spacer()
							Label("Ajouter un compte", systemImage: "plus.circle.fill")
								.font(.headline)
								.foregroundStyle(.blue)
							Spacer()
						}
					}
					.padding(.vertical, 8)
				}
			}
			.navigationTitle("Choisir un compte")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
			}
			.sheet(isPresented: $showingAddAccount) {
				NavigationStack {
					Form {
						Section("Nom du compte") {
							TextField("Ex: Alice", text: $newAccountName)
						}
					}
					.navigationTitle("Nouveau Compte")
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Annuler") {
								newAccountName = ""
								showingAddAccount = false
							}
						}
						ToolbarItem(placement: .confirmationAction) {
							Button("Créer") {
								let trimmed = newAccountName.trimmingCharacters(in: .whitespacesAndNewlines)
								if !trimmed.isEmpty {
									accountsManager.ajouterCompte(trimmed)
									accountsManager.selectedAccount = trimmed
									newAccountName = ""
									showingAddAccount = false
									dismiss() // ferme tout
								}
							}
						}
					}
				}
			}
		}
	}
}
