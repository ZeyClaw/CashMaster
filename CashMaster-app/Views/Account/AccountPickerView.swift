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
	@State private var newAccountDetail = ""
	@State private var selectedStyle: AccountStyle = .bank
	
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
			.background(Color(.systemGroupedBackground))
			.navigationTitle("Mes comptes")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Fermer") {
						dismiss()
					}
				}
			}
			.sheet(isPresented: $showingAddAccount) {
				AddAccountSheet(
					accountsManager: accountsManager,
					name: $newAccountName,
					detail: $newAccountDetail,
					style: $selectedStyle,
					onDismiss: {
						newAccountName = ""
						newAccountDetail = ""
						selectedStyle = .bank
						showingAddAccount = false
					},
					onSave: {
						let trimmed = newAccountName.trimmingCharacters(in: .whitespacesAndNewlines)
						if !trimmed.isEmpty {
							let account = Account(name: trimmed, detail: newAccountDetail, style: selectedStyle)
							accountsManager.ajouterCompte(account)
							accountsManager.selectedAccountId = account.id
							newAccountName = ""
							newAccountDetail = ""
							selectedStyle = .bank
							showingAddAccount = false
							dismiss()
						}
					}
				)
			}
		}
	}
}

// MARK: - Sheet d'ajout de compte

struct AddAccountSheet: View {
	@ObservedObject var accountsManager: AccountsManager
	@Binding var name: String
	@Binding var detail: String
	@Binding var style: AccountStyle
	var onDismiss: () -> Void
	var onSave: () -> Void
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Informations") {
					TextField("Nom du compte", text: $name)
						.onChange(of: name) { _, newValue in
							style = AccountStyle.guessFrom(name: newValue)
						}
					TextField("Détail (optionnel)", text: $detail)
				}
				
				Section("Icône") {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
						ForEach(AccountStyle.allCases) { s in
							Button {
								style = s
							} label: {
								VStack(spacing: 6) {
									ZStack {
										Circle()
											.fill(s.color.opacity(style == s ? 0.3 : 0.1))
											.frame(width: 52, height: 52)
										Image(systemName: s.icon)
											.font(.system(size: 22))
											.foregroundStyle(s.color)
									}
									.overlay(
										Circle()
											.stroke(s.color, lineWidth: style == s ? 2 : 0)
									)
									
									Text(s.label)
										.font(.caption2)
										.foregroundStyle(style == s ? s.color : .secondary)
										.lineLimit(1)
								}
							}
							.buttonStyle(PlainButtonStyle())
						}
					}
					.padding(.vertical, 8)
				}
				
				// Aperçu
				Section("Aperçu") {
					AccountCardView(
						account: Account(name: name.isEmpty ? "Nouveau compte" : name, detail: detail, style: style),
						solde: 0,
						futur: 0
					)
					.listRowInsets(EdgeInsets())
					.listRowBackground(Color.clear)
				}
			}
			.navigationTitle("Nouveau compte")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						onDismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Créer") {
						onSave()
					}
					.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
		}
	}
}
