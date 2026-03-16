//
//  AddCustomTransactionCategorySheet.swift
//  Finoria
//
//  Created by GitHub Copilot on 16/03/2026.
//

import SwiftUI

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
	@State private var showingErrorAlert = false
	@State private var errorMessage = ""

	private let symbolOptions: [String] = [
		"plus", "tag.fill", "briefcase.fill", "arrow.down.circle.fill", "arrow.up.circle.fill",
		"house.fill", "bolt.fill", "cart.fill", "fork.knife", "cup.and.saucer.fill",
		"car.fill", "bus.fill", "fuelpump.fill", "banknote.fill", "chart.line.uptrend.xyaxis",
		"doc.text.fill", "bag.fill", "airplane", "theatermasks.fill", "figure.run",
		"cross.case.fill", "gift.fill", "graduationcap.fill", "pawprint.fill", "heart.fill",
		"person.2.fill", "gamecontroller.fill", "sparkles", "phone.fill", "wifi"
	]

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
					ColorPicker("Choisir une couleur", selection: $selectedColor, supportsOpacity: false)
				} header: {
					Text("Couleur")
				}

				Section {
					LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
						ForEach(symbolOptions, id: \.self) { symbol in
							Button {
								selectedSymbol = symbol
							} label: {
								ZStack {
									Circle()
										.fill(selectedColor.opacity(selectedSymbol == symbol ? 0.28 : 0.12))
										.frame(width: 42, height: 42)
									Image(systemName: symbol)
										.font(.system(size: 16, weight: .semibold))
										.foregroundStyle(selectedColor)
								}
								.overlay(
									Circle()
										.stroke(selectedColor, lineWidth: selectedSymbol == symbol ? 2 : 0)
								)
							}
							.buttonStyle(.plain)
						}
					}
					.padding(.vertical, 4)
				} header: {
					Text("Symbole")
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
