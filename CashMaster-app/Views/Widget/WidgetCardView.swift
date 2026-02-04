//
//  WidgetCardView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 08/08/2025.
//

import SwiftUI

struct WidgetCardView: View {
	let shortcut: WidgetShortcut
	let action: () -> Void
	
	/// Retourne une icône appropriée selon le commentaire du raccourci
	private var iconName: String {
		let comment = shortcut.comment.lowercased()
		if comment.contains("carburant") || comment.contains("essence") || comment.contains("gasoil") {
			return "fuelpump.fill"
		} else if comment.contains("course") || comment.contains("supermarché") || comment.contains("magasin") {
			return "cart.fill"
		} else if comment.contains("maman") || comment.contains("papa") || comment.contains("famille") {
			return "person.fill"
		} else if comment.contains("soirée") || comment.contains("resto") || comment.contains("bar") {
			return "heart.fill"
		} else if shortcut.type == .income {
			return "arrow.down.circle.fill"
		} else {
			return "arrow.up.circle.fill"
		}
	}
	
	/// Retourne une couleur appropriée selon le commentaire du raccourci
	private var iconColor: Color {
		let comment = shortcut.comment.lowercased()
		if comment.contains("carburant") || comment.contains("essence") || comment.contains("gasoil") {
			return .orange
		} else if comment.contains("course") || comment.contains("supermarché") || comment.contains("magasin") {
			return .blue
		} else if comment.contains("maman") || comment.contains("papa") || comment.contains("famille") {
			return .purple
		} else if comment.contains("soirée") || comment.contains("resto") || comment.contains("bar") {
			return .pink
		} else if shortcut.type == .income {
			return .green
		} else {
			return .red
		}
	}
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				// Icône colorée avec cercle de fond
				ZStack {
					Circle()
						.fill(iconColor.opacity(0.15))
						.frame(width: 40, height: 40)
					Image(systemName: iconName)
						.font(.system(size: 18))
						.foregroundStyle(iconColor)
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(shortcut.comment)
						.font(.system(size: 12, weight: .medium))
						.foregroundStyle(.secondary)
						.lineLimit(1)
					Text("\(shortcut.amount, specifier: "%.2f") €")
						.font(.system(size: 14, weight: .bold))
						.foregroundStyle(.primary)
				}
				
				Spacer()
			}
			.padding(12)
			.background(Color(UIColor.secondarySystemGroupedBackground))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
		}
		.buttonStyle(PlainButtonStyle())
	}
}
