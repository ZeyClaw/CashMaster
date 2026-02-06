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
	
	// Raccourci à éditer (nil = nouveau raccourci)
	var shortcutToEdit: WidgetShortcut? = nil
	
	// MARK: - Limites
	private let maxCommentLength = 15
	
	@State private var amount: Double?
	@State private var comment = ""
	@State private var type: TransactionType = .income
	@State private var selectedStyle: ShortcutStyle = .income
	@State private var showError = false
	@State private var hasManuallySelectedStyle = false
	
	private var isEditMode: Bool { shortcutToEdit != nil }
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					CurrencyTextField("Montant", amount: $amount)

					TextField("Commentaire", text: $comment)
						.onChange(of: comment) { _, newValue in
							if newValue.count > maxCommentLength {
								comment = String(newValue.prefix(maxCommentLength))
							}
							// Ne pas auto-deviner le style si mode édition ou sélection manuelle
							if !isEditMode && !hasManuallySelectedStyle {
								selectedStyle = ShortcutStyle.guessFrom(comment: newValue, type: type)
							}
						}
				} footer: {
					HStack {
						Spacer()
						Text("\(comment.count)/\(maxCommentLength)")
					}
				}
				
				Picker("Type", selection: $type) {
					ForEach(TransactionType.allCases) { t in
						Text(t.label).tag(t)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: type) { _, newValue in
					// Met à jour le style si c'est le style par défaut (seulement si pas en mode édition et pas de sélection manuelle)
					if !isEditMode && !hasManuallySelectedStyle && (selectedStyle == .income || selectedStyle == .expense) {
						selectedStyle = newValue == .income ? .income : .expense
					}
				}
				
				// MARK: - Sélecteur d'icône
				Section("Icône") {
					StylePickerGrid(selectedStyle: $selectedStyle, columns: 5) {
						hasManuallySelectedStyle = true
					}
				}
				
				// Bouton supprimer en mode édition
				if isEditMode {
					Section {
						Button(role: .destructive) {
							if let shortcut = shortcutToEdit {
								accountsManager.deleteWidgetShortcut(shortcut)
								dismiss()
							}
						} label: {
							HStack {
								Spacer()
								Label("Supprimer le raccourci", systemImage: "trash")
								Spacer()
							}
						}
					}
				}
			}
			.navigationTitle(isEditMode ? "Modifier le raccourci" : "Nouveau widget")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(isEditMode ? "OK" : "Ajouter") {
						saveShortcut()
					}
				}
			}
			.alert("Montant invalide", isPresented: $showError) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("Veuillez entrer un montant positif valide.")
			}
			.onAppear {
				if let shortcut = shortcutToEdit {
					amount = shortcut.amount
					comment = shortcut.comment
					type = shortcut.type
					selectedStyle = shortcut.style
				}
			}
		}
	}
	
	private func saveShortcut() {
		guard let amount = amount, amount > 0 else {
			showError = true
			return
		}
		
		if let existingShortcut = shortcutToEdit {
			// Mode édition: créer un raccourci modifié avec le même ID
			let updatedShortcut = WidgetShortcut(
				id: existingShortcut.id,
				amount: amount,
				comment: comment,
				type: type,
				style: selectedStyle
			)
			accountsManager.updateWidgetShortcut(updatedShortcut)
		} else {
			// Mode création: nouveau raccourci
			let shortcut = WidgetShortcut(
				amount: amount,
				comment: comment,
				type: type,
				style: selectedStyle
			)
			accountsManager.addWidgetShortcut(shortcut)
		}
		dismiss()
	}
}
