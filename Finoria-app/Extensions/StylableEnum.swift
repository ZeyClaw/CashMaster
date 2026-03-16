//
//  StylableEnum.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI

/// Protocole unifiant les enums qui ont une représentation visuelle (icône, couleur, label)
/// Utilisé par AccountStyle et TransactionCategory pour factoriser le code
protocol StylableEnum: RawRepresentable, CaseIterable, Identifiable, Codable where RawValue == String {
	/// Nom de l'icône SF Symbol
	var icon: String { get }
	/// Couleur associée au style
	var color: Color { get }
	/// Label localisé pour l'affichage
	var label: String { get }
}

// MARK: - Extension par défaut pour Identifiable

extension StylableEnum {
	var id: String { rawValue }
}

// MARK: - Vue réutilisable pour sélectionner un style

/// Grille de sélection de style réutilisable pour tout enum conforme à StylableEnum.
/// Supporte un mode replié (`collapsedRows`) qui n'affiche que les N premières lignes
/// avec un bouton pour déplier et voir toutes les options.
struct AccountCategoryPicker<Style: StylableEnum>: View {
	@Binding var selectedStyle: Style
	let columns: Int
	let collapsedRows: Int?
	var onManualSelection: (() -> Void)? = nil
	
	@State private var isExpanded = false
	
	init(selectedStyle: Binding<Style>, columns: Int = 4, collapsedRows: Int? = nil, onManualSelection: (() -> Void)? = nil) {
		self._selectedStyle = selectedStyle
		self.columns = columns
		self.collapsedRows = collapsedRows
		self.onManualSelection = onManualSelection
	}
	
	private var allItems: [Style] { Array(Style.allCases) }
	
	private var visibleItems: [Style] {
		guard let collapsedRows, !isExpanded else { return allItems }
		let maxVisible = columns * collapsedRows
		// Always show the selected item in the visible set
		let truncated = Array(allItems.prefix(maxVisible))
		if truncated.contains(where: { $0.id == selectedStyle.id }) {
			return truncated
		}
		// Replace last visible with selectedStyle so it's always visible
		var items = truncated
		if !items.isEmpty {
			items[items.count - 1] = selectedStyle
		}
		return items
	}
	
	private var needsExpandButton: Bool {
		guard let collapsedRows else { return false }
		return allItems.count > columns * collapsedRows
	}
	
	var body: some View {
		VStack(spacing: 8) {
			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 16) {
				ForEach(visibleItems, id: \.id) { style in
					Button {
						selectedStyle = style
						onManualSelection?()
					} label: {
						VStack(spacing: 6) {
							ZStack {
								Circle()
									.fill(style.color.opacity(selectedStyle.id == style.id ? 0.3 : 0.1))
									.frame(width: 52, height: 52)
								Image(systemName: style.icon)
									.font(.system(size: 22))
									.foregroundStyle(style.color)
							}
							.overlay(
								Circle()
									.stroke(style.color, lineWidth: selectedStyle.id == style.id ? 2 : 0)
							)
							
							Text(style.label)
								.font(.caption2)
								.foregroundStyle(selectedStyle.id == style.id ? style.color : .secondary)
								.lineLimit(1)
						}
					}
					.buttonStyle(PlainButtonStyle())
				}
			}
			
			if needsExpandButton {
				Button {
					withAnimation(.easeInOut(duration: 0.25)) {
						isExpanded.toggle()
					}
				} label: {
					HStack(spacing: 4) {
						Text(isExpanded ? "Voir moins" : "Voir tout")
							.font(.subheadline.weight(.medium))
						Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
							.font(.caption.weight(.semibold))
					}
					.foregroundStyle(.secondary)
					.padding(.top, 4)
				}
				.buttonStyle(PlainButtonStyle())
			}
		}
		.padding(.vertical, 8)
	}
}

// MARK: - Paginated Style Picker Grid

/// Grille paginée de sélection de style utilisant TabView natif.
/// Affiche 5 colonnes × 2 lignes par page (10 items/page) avec :
/// - Swipe horizontal natif iOS (physique réaliste, snap automatique)
/// - Indicateur de page (points) intégré
struct TransactionCategoryPicker<Style: StylableEnum>: View {
	@Binding var selectedStyle: Style
	var onManualSelection: (() -> Void)? = nil
	
	private let columns = 5
	private let rowsPerPage = 2
	private var itemsPerPage: Int { columns * rowsPerPage }
	
	@State private var currentPage = 0
	
	private var allItems: [Style] { Array(Style.allCases) }
	private var totalPages: Int {
		max(1, (allItems.count + itemsPerPage - 1) / itemsPerPage)
	}

	private func pageIndex(for style: Style) -> Int {
		guard let index = allItems.firstIndex(where: { $0.id == style.id }) else { return 0 }
		return allItems.distance(from: allItems.startIndex, to: index) / itemsPerPage
	}
	
	private func itemsForPage(_ page: Int) -> [Style] {
		let start = page * itemsPerPage
		let end = min(start + itemsPerPage, allItems.count)
		guard start < allItems.count else { return [] }
		return Array(allItems[start..<end])
	}
	
	var body: some View {
		VStack(spacing: 4) {
			TabView(selection: $currentPage) {
				ForEach(0..<totalPages, id: \.self) { page in
					pageView(items: itemsForPage(page))
						.tag(page)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .automatic))
			.indexViewStyle(.page(backgroundDisplayMode: .always))
			.frame(height: 160)
		}
		.padding(.vertical, 8)
		.onAppear {
			currentPage = pageIndex(for: selectedStyle)
		}
		.onChange(of: selectedStyle.id) { _, _ in
			let targetPage = pageIndex(for: selectedStyle)
			guard targetPage != currentPage else { return }
			withAnimation(.easeInOut(duration: 0.2)) {
				currentPage = targetPage
			}
		}
	}
	
	@ViewBuilder
	private func pageView(items: [Style]) -> some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 16) {
			ForEach(0..<itemsPerPage, id: \.self) { index in
				if index < items.count {
					let style = items[index]
					VStack(spacing: 6) {
						ZStack {
							Circle()
								.fill(style.color.opacity(selectedStyle.id == style.id ? 0.3 : 0.1))
								.frame(width: 52, height: 52)
							Image(systemName: style.icon)
								.font(.system(size: 22))
								.foregroundStyle(style.color)
						}
						.overlay(
							Circle()
								.stroke(style.color, lineWidth: selectedStyle.id == style.id ? 2 : 0)
						)
						
						Text(style.label)
							.font(.caption2)
							.foregroundStyle(selectedStyle.id == style.id ? style.color : .secondary)
							.lineLimit(1)
					}
					.contentShape(Rectangle())
					.onTapGesture {
						selectedStyle = style
						onManualSelection?()
					}
				} else {
					// Espace invisible pour maintenir la grille 5×2
					Color.clear
						.frame(width: 52, height: 70)
				}
			}
		}
		.padding(.horizontal, 4)
	}
}

// MARK: - Vue icône de style (réutilisable)

/// Affiche une icône de style avec son cercle coloré
struct StyleIconView<Style: StylableEnum>: View {
	let style: Style
	let size: CGFloat
	
	init(style: Style, size: CGFloat = 40) {
		self.style = style
		self.size = size
	}
	
	var body: some View {
		ZStack {
			Circle()
				.fill(style.color.opacity(0.15))
				.frame(width: size, height: size)
			Image(systemName: style.icon)
				.font(.system(size: size * 0.45))
				.foregroundStyle(style.color)
		}
	}
}

// MARK: - Formatage compact des montants

/// Formate un montant de manière compacte pour tenir dans un espace restreint.
/// Utilise la locale du système (virgule pour les français, point pour les anglophones, etc.)
/// Réduit progressivement la précision : 2 850,00 € → 2 850 € → 2,85k € → 2,9k € → 3k €
func compactAmount(_ value: Double) -> String {
	let formatter = NumberFormatter()
	formatter.locale = Locale.current
	formatter.numberStyle = .decimal
	formatter.usesGroupingSeparator = false
	
	let thresholds: [(limit: Double, divisor: Double, suffix: String)] = [
		(1_000_000_000, 1_000_000_000, "G"),
		(1_000_000, 1_000_000, "M"),
		(1_000, 1_000, "k")
	]
	
	for t in thresholds where value >= t.limit {
		let reduced = value / t.divisor
		if reduced == reduced.rounded(.down) {
			formatter.minimumFractionDigits = 0
			formatter.maximumFractionDigits = 0
		} else if (reduced * 10).rounded() == (reduced * 10) {
			formatter.minimumFractionDigits = 1
			formatter.maximumFractionDigits = 1
		} else {
			formatter.minimumFractionDigits = 2
			formatter.maximumFractionDigits = 2
		}
		return "\(formatter.string(from: NSNumber(value: reduced)) ?? "\(reduced)")\(t.suffix)"
	}
	
	if value == value.rounded(.down) {
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 0
	} else if (value * 10).rounded() == (value * 10) {
		formatter.minimumFractionDigits = 1
		formatter.maximumFractionDigits = 1
	} else {
		formatter.minimumFractionDigits = 2
		formatter.maximumFractionDigits = 2
	}
	return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
