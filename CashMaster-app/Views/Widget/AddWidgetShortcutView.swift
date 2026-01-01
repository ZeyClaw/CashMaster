//
//  AddWidgetShortcutView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import SwiftUI

struct AddWidgetShortcutView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var amount: Double?
	@State private var comment = ""
	@State private var type: TransactionType = .income
	@State private var showError = false
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Montant", value: $amount, format: .number)
					.keyboardType(.decimalPad)
				
				TextField("Commentaire", text: $comment)
				
				Picker("Type", selection: $type) {
					ForEach(TransactionType.allCases) { t in
						Text(t.label).tag(t)
					}
				}
				.pickerStyle(.segmented)
			}
			.navigationTitle("Nouveau widget")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Ajouter") {
						guard let amount = amount, amount > 0 else {
							showError = true
							return
						}
						let shortcut = WidgetShortcut(amount: amount, comment: comment, type: type)
						accountsManager.addWidgetShortcut(shortcut)
						dismiss()
					}
				}
			}
			.alert("Montant invalide", isPresented: $showError) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("Veuillez entrer un montant positif valide.")
			}
		}
	}
}
