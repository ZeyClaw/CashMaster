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
	@Binding var selectedAccount: String?
	
	var body: some View {
		NavigationStack {
			List {
				ForEach(accountsManager.getAllAccounts(), id: \.self) { account in
					Button {
						selectedAccount = account
						dismiss()
					} label: {
						HStack {
							Text(account)
							Spacer()
							Text("\(accountsManager.totalNonPotentiel(for: account), specifier: "%.2f") €")
								.foregroundStyle(.green)
							Text("+\(accountsManager.totalPotentiel(for: account), specifier: "%.2f") €")
								.foregroundStyle(.blue)
						}
						.padding(.vertical, 8)
					}
				}
				
				Button {
					// Ajouter un compte
					// Utiliser sheet ou autre si souhaité
				} label: {
					Label("Ajouter un compte", systemImage: "plus.circle.fill")
						.font(.headline)
						.foregroundStyle(.blue)
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
		}
	}
}
