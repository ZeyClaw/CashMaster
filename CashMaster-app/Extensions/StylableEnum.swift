//
//  StylableEnum.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI

/// Protocole unifiant les enums qui ont une représentation visuelle (icône, couleur, label)
/// Utilisé par AccountStyle et ShortcutStyle pour factoriser le code
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
	
	init(selectedStyle: Binding<Style>, columns: Int = 4) {
		self._selectedStyle = selectedStyle
		self.columns = columns
	}
	
	var body: some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 16) {
			ForEach(Array(Style.allCases), id: \.id) { style in
				Button {
					selectedStyle = style
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
