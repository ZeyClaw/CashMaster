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

/// Grille de sélection de style réutilisable pour tout enum conforme à StylableEnum
struct StylePickerGrid<Style: StylableEnum>: View {
	@Binding var selectedStyle: Style
	let columns: Int
	var onManualSelection: (() -> Void)? = nil
	
	init(selectedStyle: Binding<Style>, columns: Int = 4, onManualSelection: (() -> Void)? = nil) {
		self._selectedStyle = selectedStyle
		self.columns = columns
		self.onManualSelection = onManualSelection
	}
	
	var body: some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 16) {
			ForEach(Array(Style.allCases), id: \.id) { style in
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
		.padding(.vertical, 8)
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
