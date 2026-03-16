//
//  AddCustomTransactionCategorySheet.swift
//  Finoria
//
//  Created by GitHub Copilot on 16/03/2026.
//

import SwiftUI
#if canImport(SymbolPicker)
import SymbolPicker
#endif

struct AddCustomTransactionCategorySheet: View {
	@Environment(\.dismiss) private var dismiss

	let title: String
	let initialName: String
	let initialSymbol: String
	let initialColorHex: String
	let maxNameLength: Int
	let onValidateName: (String) -> String?
	let onSave: (_ name: String, _ symbol: String, _ colorHex: String) -> Void

	@State private var name: String
	@State private var selectedSymbol: String
	@State private var selectedColor: Color
	@State private var showingSymbolPicker = false
	@State private var showingErrorAlert = false
	@State private var errorMessage = ""

	init(
		title: String,
		initialName: String,
		initialSymbol: String,
		initialColorHex: String,
		maxNameLength: Int = 15,
		onValidateName: @escaping (String) -> String?,
		onSave: @escaping (_ name: String, _ symbol: String, _ colorHex: String) -> Void
	) {
		self.title = title
		self.initialName = initialName
		self.initialSymbol = initialSymbol
		self.initialColorHex = initialColorHex
		self.maxNameLength = maxNameLength
		self.onValidateName = onValidateName
		self.onSave = onSave

		_name = State(initialValue: initialName)
		_selectedSymbol = State(initialValue: initialSymbol)
		_selectedColor = State(initialValue: Color(finoriaHex: initialColorHex))
	}

	var body: some View {
		NavigationStack {
			Form {
				Section {
					TextField("Nom de catégorie", text: $name)
						.textInputAutocapitalization(.words)
						.disableAutocorrection(true)
						.onChange(of: name) { _, newValue in
							if newValue.count > maxNameLength {
								name = String(newValue.prefix(maxNameLength))
							}
						}
				} header: {
					Text("Nom")
				} footer: {
					HStack {
						Spacer()
						Text("\(name.count)/\(maxNameLength)")
					}
				}

				Section {
					Button {
						showingSymbolPicker = true
					} label: {
						HStack(spacing: 12) {
							ZStack {
								Circle()
									.fill(selectedColor.opacity(0.16))
									.frame(width: 40, height: 40)
								Image(systemName: selectedSymbol)
									.font(.system(size: 17, weight: .semibold))
									.foregroundStyle(selectedColor)
							}

							VStack(alignment: .leading, spacing: 2) {
								Text("Choisir le symbole")
								Text(selectedSymbol)
									.font(.caption)
									.foregroundStyle(.secondary)
							}

							Spacer()
							Image(systemName: "chevron.right")
								.font(.footnote.weight(.semibold))
								.foregroundStyle(.tertiary)
						}
					}
					.buttonStyle(.plain)
					#if canImport(SymbolPicker)
					.symbolPicker(
						isPresented: $showingSymbolPicker,
						symbolName: $selectedSymbol,
						color: $selectedColor
					)
					.symbolPickerSymbolsStyle(.filled)
					.symbolPickerDismiss(type: .onSymbolSelect)
					#endif

					#if !canImport(SymbolPicker)
					ColorPicker("Choisir une couleur", selection: $selectedColor, supportsOpacity: false)
						.padding(.top, 8)

					Text("Ajoute le package SymbolPicker pour activer le sélecteur natif (recherche + couleurs).")
						.font(.caption)
						.foregroundStyle(.secondary)
					#endif
				} header: {
					Text("Symbole et couleur")
				} footer: {
					Text("Le sélecteur natif propose la recherche et la personnalisation de couleur.")
				}
			}
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Annuler") { dismiss() }
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Valider") {
						save()
					}
				}
			}
			.alert("Erreur", isPresented: $showingErrorAlert) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage)
			}
		}
	}

	private func save() {
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else {
			errorMessage = "Le nom est obligatoire."
			showingErrorAlert = true
			return
		}

		if let validationError = onValidateName(trimmedName) {
			errorMessage = validationError
			showingErrorAlert = true
			return
		}

		onSave(trimmedName, selectedSymbol, selectedColor.finoriaHex)
		dismiss()
	}
}
