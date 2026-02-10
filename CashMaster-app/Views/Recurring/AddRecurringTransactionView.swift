//
//  AddRecurringTransactionView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 10/02/2026.
//

import SwiftUI

struct AddRecurringTransactionView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var accountsManager: AccountsManager
	
	// Récurrence à éditer (nil = nouvelle récurrence)
	var recurringToEdit: RecurringTransaction? = nil
	
	// MARK: - Limites
	private let maxCommentLength = 20
	
	// MARK: - State
	@State private var amount: Double?
	@State private var comment = ""
	@State private var type: TransactionType = .expense
	@State private var selectedStyle: RecurringStyle = .other
	@State private var frequency: RecurrenceFrequency = .monthly
	@State private var startDate: Date = Date()
	@State private var showError = false
	@State private var hasManuallySelectedStyle = false
	
	private var isEditMode: Bool { recurringToEdit != nil }
	
	// MARK: - Body
	
	var body: some View {
		NavigationStack {
			Form {
				// MARK: - Montant et commentaire
				Section {
					CurrencyTextField("Montant", amount: $amount)
					
					TextField("Commentaire", text: $comment)
						.onChange(of: comment) { _, newValue in
							if newValue.count > maxCommentLength {
								comment = String(newValue.prefix(maxCommentLength))
							}
							if !isEditMode && !hasManuallySelectedStyle {
								selectedStyle = RecurringStyle.guessFrom(comment: newValue, type: type)
							}
						}
				} footer: {
					HStack {
						Spacer()
						Text("\(comment.count)/\(maxCommentLength)")
					}
				}
				
				// MARK: - Type
				Picker("Type", selection: $type) {
					ForEach(TransactionType.allCases) { t in
						Text(t.label).tag(t)
					}
				}
				.pickerStyle(.segmented)
				.onChange(of: type) { _, newValue in
					if !isEditMode && !hasManuallySelectedStyle && (selectedStyle == .salary || selectedStyle == .other) {
						selectedStyle = newValue == .income ? .salary : .other
					}
				}
				
				// MARK: - Fréquence
				Section("Récurrence") {
					Picker("Fréquence", selection: $frequency) {
						ForEach(RecurrenceFrequency.allCases) { freq in
							Text(freq.label).tag(freq)
						}
					}
					
					DatePicker("À partir du", selection: $startDate, displayedComponents: .date)
						.datePickerStyle(.compact)
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
							if let recurring = recurringToEdit {
								accountsManager.deleteRecurringTransaction(recurring)
								dismiss()
							}
						} label: {
							HStack {
								Spacer()
								Label("Supprimer la récurrence", systemImage: "trash")
								Spacer()
							}
						}
					}
				}
			}
			.navigationTitle(isEditMode ? "Modifier la récurrence" : "Nouvelle récurrence")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(isEditMode ? "OK" : "Ajouter") {
						saveRecurring()
					}
				}
			}
			.alert("Montant invalide", isPresented: $showError) {
				Button("OK", role: .cancel) {}
			} message: {
				Text("Veuillez entrer un montant positif valide.")
			}
			.onAppear {
				if let recurring = recurringToEdit {
					amount = recurring.amount
					comment = recurring.comment
					type = recurring.type
					selectedStyle = recurring.style
					frequency = recurring.frequency
					startDate = recurring.startDate
				}
			}
		}
	}
	
	// MARK: - Save
	
	private func saveRecurring() {
		guard let amount = amount, amount > 0 else {
			showError = true
			return
		}
		
		if let existing = recurringToEdit {
			let updated = RecurringTransaction(
				id: existing.id,
				amount: amount,
				comment: comment,
				type: type,
				style: selectedStyle,
				frequency: frequency,
				startDate: startDate,
				lastGeneratedDate: existing.lastGeneratedDate
			)
			accountsManager.updateRecurringTransaction(updated)
		} else {
			let recurring = RecurringTransaction(
				amount: amount,
				comment: comment,
				type: type,
				style: selectedStyle,
				frequency: frequency,
				startDate: startDate
			)
			accountsManager.addRecurringTransaction(recurring)
		}
		dismiss()
	}
}

// MARK: - Preview

#Preview {
	AddRecurringTransactionView(accountsManager: AccountsManager())
}
