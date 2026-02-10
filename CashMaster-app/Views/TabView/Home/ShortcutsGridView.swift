//
//  ShortcutsGridView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI
import UIKit  // Pour le retour haptique

/// Section affichant la grille de raccourcis (widgets) avec possibilité d'ajout
struct ShortcutsGridView: View {
	let shortcuts: [WidgetShortcut]
	let onShortcutTap: (WidgetShortcut) -> Void
	let onShortcutEdit: (WidgetShortcut) -> Void
	let onShortcutDelete: (WidgetShortcut) -> Void
	let onAddTap: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			// Header avec bouton d'ajout
			ShortcutsHeader(onAddTap: onAddTap)
			
			// Grille de raccourcis
			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
				ForEach(shortcuts) { shortcut in
					ShortcutCard(
						shortcut: shortcut,
						onTap: { onShortcutTap(shortcut) },
						onEdit: { onShortcutEdit(shortcut) },
						onDelete: { onShortcutDelete(shortcut) }
					)
				}
			}
		}
		.padding(.horizontal, 20)
	}
}

// MARK: - Header

private struct ShortcutsHeader: View {
	let onAddTap: () -> Void
	
	var body: some View {
		HStack {
			Text("Raccourcis")
				.font(.system(size: 18, weight: .bold))
			
			Spacer()
			
			Button(action: onAddTap) {
				HStack(spacing: 4) {
					Image(systemName: "plus")
						.font(.system(size: 12, weight: .bold))
					Text("Ajouter Widget")
						.font(.system(size: 11, weight: .bold))
				}
				.foregroundStyle(.blue)
				.padding(.horizontal, 12)
				.padding(.vertical, 6)
				.background(Color.blue.opacity(0.1))
				.clipShape(Capsule())
			}
		}
	}
}

// MARK: - Formatage compact des montants

/// Formate un montant de manière compacte pour tenir dans un espace restreint.
/// Réduit progressivement la précision : 2 850,00 € → 2 850 € → 2,85k € → 2,9k € → 3k €
private func compactAmount(_ value: Double) -> String {
	let thresholds: [(limit: Double, divisor: Double, suffix: String)] = [
		(1_000_000_000, 1_000_000_000, "G"),
		(1_000_000, 1_000_000, "M"),
		(1_000, 1_000, "k")
	]
	
	// Pour les grands nombres, utiliser les suffixes
	for t in thresholds where value >= t.limit {
		let reduced = value / t.divisor
		if reduced == reduced.rounded(.down) {
			return String(format: "%.0f%@", reduced, t.suffix)
		} else if (reduced * 10).rounded() == (reduced * 10) {
			return String(format: "%.1f%@", reduced, t.suffix)
		} else {
			return String(format: "%.2f%@", reduced, t.suffix)
		}
	}
	
	// Nombres < 1000 : supprimer les décimales inutiles
	if value == value.rounded(.down) {
		return String(format: "%.0f", value)
	} else if (value * 10).rounded() == (value * 10) {
		return String(format: "%.1f", value)
	} else {
		return String(format: "%.2f", value)
	}
}

// MARK: - Carte de raccourci

private struct ShortcutCard: View {
	let shortcut: WidgetShortcut
	let onTap: () -> Void
	let onEdit: () -> Void
	let onDelete: () -> Void
	
	var body: some View {
		Button {
			// Feedback haptique
			let feedback = UIImpactFeedbackGenerator(style: .medium)
			feedback.impactOccurred()
			onTap()
		} label: {
			HStack(spacing: 12) {
				// Icône colorée
				ZStack {
					Circle()
						.fill(shortcut.style.color.opacity(0.15))
						.frame(width: 40, height: 40)
					Image(systemName: shortcut.style.icon)
						.font(.system(size: 18))
						.foregroundStyle(shortcut.style.color)
				}
				
				// Texte
				VStack(alignment: .leading, spacing: 2) {
					Text(shortcut.comment)
						.font(.system(size: 12, weight: .medium))
						.foregroundStyle(.secondary)
						.lineLimit(1)
					
					HStack(spacing: 2) {
						Text(shortcut.type == .income ? "+" : "−")
							.font(.system(size: 14, weight: .bold))
							.foregroundStyle(shortcut.type == .income ? .green : .red)
						Text("\(compactAmount(shortcut.amount)) €")
							.font(.system(size: 14, weight: .bold))
							.foregroundStyle(.primary)
							.lineLimit(1)
							.minimumScaleFactor(0.8)
					}
				}
				
				Spacer(minLength: 1)
			}
			.padding(12)
			.background(Color(UIColor.secondarySystemGroupedBackground))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
		}
		.buttonStyle(PlainButtonStyle())
		.contextMenu {
			Button(action: onEdit) {
				Label("Modifier", systemImage: "pencil")
			}
			
			Button(role: .destructive, action: onDelete) {
				Label("Supprimer", systemImage: "trash")
			}
		}
	}
}

#Preview {
	ShortcutsGridView(
		shortcuts: [
			WidgetShortcut(amount: 50, comment: "Courses", type: .expense, style: .shopping),
			WidgetShortcut(amount: 30, comment: "Essence", type: .expense, style: .fuel)
		],
		onShortcutTap: { _ in },
		onShortcutEdit: { _ in },
		onShortcutDelete: { _ in },
		onAddTap: {}
	)
	.padding()
	.background(Color(UIColor.systemGroupedBackground))
}
