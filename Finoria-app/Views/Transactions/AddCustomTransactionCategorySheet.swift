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
		"tag.fill", "questionmark.circle.fill", "cart.fill", "basket.fill", "fork.knife", "cup.and.saucer.fill",
		"takeoutbag.and.cup.and.straw.fill", "birthday.cake.fill", "wineglass.fill", "house.fill", "building.2.fill", "bed.double.fill",
		"bolt.fill", "drop.fill", "flame.fill", "wifi", "phone.fill", "car.fill",
		"bus.fill", "bicycle", "tram.fill", "fuelpump.fill", "airplane", "banknote.fill",
		"creditcard.fill", "eurosign.circle.fill", "dollarsign.circle.fill", "sterlingsign.circle.fill", "yensign.circle.fill", "chart.line.uptrend.xyaxis",
		"chart.bar.fill", "chart.pie.fill", "briefcase.fill", "doc.text.fill", "folder.fill", "archivebox.fill",
		"hammer.fill", "wrench.and.screwdriver.fill", "cross.case.fill", "pills.fill", "stethoscope", "heart.fill",
		"bandage.fill", "gift.fill", "graduationcap.fill", "book.fill", "books.vertical.fill", "figure.run",
		"figure.walk", "gamecontroller.fill", "film.fill", "music.note", "tv.fill", "camera.fill",
		"pawprint.fill", "dog.fill", "cat.fill", "sparkles", "leaf.fill", "tree.fill",
		"carrot.fill", "fish.fill", "clock.fill", "calendar", "alarm.fill", "timer",
		"shield.fill", "lock.fill", "mappin.and.ellipse", "location.fill", "suitcase.fill", "bag.fill"
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
							Text("Symbole sélectionné")
							Text(selectedSymbol)
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						Spacer()
					}

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
				} footer: {
					Text("Choisissez un symbole parmi la liste pour représenter votre catégorie.")
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
