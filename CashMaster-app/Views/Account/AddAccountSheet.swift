//
//  AddAccountSheet.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/02/2026.
//

import SwiftUI

struct AddAccountSheet: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	var onAccountCreated: (() -> Void)?
	
	@State private var name = ""
	@State private var detail = ""
	@State private var style: AccountStyle = .bank
	
	init(accountsManager: AccountsManager, onAccountCreated: (() -> Void)? = nil) {
		self.accountsManager = accountsManager
		self.onAccountCreated = onAccountCreated
	}
	
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
			.scrollContentBackground(.hidden)
			.background(
				Color(UIColor { traitCollection in
					traitCollection.userInterfaceStyle == .dark ? .black : .systemGroupedBackground
				})
				.ignoresSafeArea()
			)
			.navigationTitle("Nouveau compte")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Créer") {
						createAccount()
					}
					.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
		}
	}
	
	private func createAccount() {
		let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }
		
		let account = Account(name: trimmed, detail: detail, style: style)
		accountsManager.ajouterCompte(account)
		accountsManager.selectedAccountId = account.id
		dismiss()
		onAccountCreated?()
	}
}
		}
	}
}
