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
	
	// Compte à éditer (nil = nouveau compte)
	var accountToEdit: Account? = nil
	
	@State private var name = ""
	@State private var detail = ""
	@State private var style: AccountStyle = .bank
	
	private var isEditMode: Bool { accountToEdit != nil }
	
	init(accountsManager: AccountsManager, accountToEdit: Account? = nil, onAccountCreated: (() -> Void)? = nil) {
		self.accountsManager = accountsManager
		self.accountToEdit = accountToEdit
		self.onAccountCreated = onAccountCreated
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section("Informations") {
					TextField("Nom du compte", text: $name)
						.onChange(of: name) { _, newValue in
							// Ne pas auto-deviner le style en mode édition si l'utilisateur a déjà un style personnalisé
							if !isEditMode {
								style = AccountStyle.guessFrom(name: newValue)
							}
						}
					TextField("Détail (optionnel)", text: $detail)
				}
				
				Section("Icône") {
					StylePickerGrid(selectedStyle: $style, columns: 4)
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
				
				// Bouton supprimer en mode édition
				if isEditMode {
					Section {
						Button(role: .destructive) {
							if let account = accountToEdit {
								accountsManager.deleteAccount(account)
								dismiss()
							}
						} label: {
							HStack {
								Spacer()
								Label("Supprimer le compte", systemImage: "trash")
								Spacer()
							}
						}
					}
				}
			}
			.scrollContentBackground(.hidden)
			.background(
				Color(UIColor { traitCollection in
					traitCollection.userInterfaceStyle == .dark ? .black : .systemGroupedBackground
				})
				.ignoresSafeArea()
			)
			.navigationTitle(isEditMode ? "Modifier le compte" : "Nouveau compte")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(isEditMode ? "OK" : "Créer") {
						saveAccount()
					}
					.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				}
			}
			.onAppear {
				if let account = accountToEdit {
					name = account.name
					detail = account.detail
					style = account.style
				}
			}
		}
	}
	
	private func saveAccount() {
		let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return }
		
		if let existingAccount = accountToEdit {
			// Mode édition: créer un compte modifié avec le même ID
			let updatedAccount = Account(id: existingAccount.id, name: trimmed, detail: detail, style: style)
			accountsManager.updateAccount(updatedAccount)
		} else {
			// Mode création: nouveau compte
			let account = Account(name: trimmed, detail: detail, style: style)
			accountsManager.addAccount(account)
			accountsManager.selectedAccountId = account.id
			onAccountCreated?()
		}
		dismiss()
	}
}