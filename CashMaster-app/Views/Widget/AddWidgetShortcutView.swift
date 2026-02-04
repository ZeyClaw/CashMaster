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
	@State private var selectedStyle: ShortcutStyle = .income
	@State private var showError = false
	
	var body: some View {
		NavigationStack {
			Form {
				TextField("Montant", value: $amount, format: .number)
					.keyboardType(.decimalPad)
				
				TextField("Commentaire", text: $comment)
					.onChange(of: comment) { _, newValue in
						// Met à jour automatiquement le style selon le commentaire
						selectedStyle = ShortcutStyle.guessFrom(comment: newValue, type: type)
					}
				
				Picker("Type", selection: $type) {
					ForEach(TransactionType.allCases) { t in
						Text(t.label).tag(t)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: type) { _, newValue in
					// Met à jour le style si c'est le style par défaut
					if selectedStyle == .income || selectedStyle == .expense {
						selectedStyle = newValue == .income ? .income : .expense
					}
				}
				
				// MARK: - Sélecteur d'icône
				Section("Icône") {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
						ForEach(ShortcutStyle.allCases) { style in
							Button {
								selectedStyle = style
							} label: {
								ZStack {
									Circle()
										.fill(style.color.opacity(selectedStyle == style ? 0.3 : 0.1))
										.frame(width: 44, height: 44)
									Image(systemName: style.icon)
										.font(.system(size: 18))
										.foregroundStyle(style.color)
								}
								.overlay(
									Circle()
										.stroke(style.color, lineWidth: selectedStyle == style ? 2 : 0)
								)
							}
							.buttonStyle(PlainButtonStyle())
						}
					}
					.padding(.vertical, 8)
				}
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
						let shortcut = WidgetShortcut(
							amount: amount,
							comment: comment,
							type: type,
							style: selectedStyle
						)
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
