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
			ScrollView {
				LazyVStack(spacing: 12) {
					ForEach(accountsManager.getAllAccounts()) { account in
						AccountCardView(
							account: account,
							solde: accountsManager.totalNonPotentiel(for: account),
							futur: accountsManager.totalNonPotentiel(for: account) + accountsManager.totalPotentiel(for: account)
						)
						.contentShape(Rectangle())
						.onTapGesture {
							accountsManager.selectedAccountId = account.id
							dismiss()
						}
						.contextMenu {
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
						.foregroundStyle(.blue)
						.frame(maxWidth: .infinity)
						.padding(.vertical, 20)
						.background(Color(.systemBackground))
						.clipShape(RoundedRectangle(cornerRadius: 20))
						.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
					}
					.buttonStyle(PlainButtonStyle())
				}
				.padding()
			}
			.background(Color(UIColor.systemGroupedBackground))
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
