//
//  RecurringTransactionsGridView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 10/02/2026.
//

import SwiftUI
import UIKit  // Pour le retour haptique

/// Section affichant la grille de transactions récurrentes avec possibilité d'ajout
struct RecurringTransactionsGridView: View {
	let recurringTransactions: [RecurringTransaction]
	let onEdit: (RecurringTransaction) -> Void
	let onDelete: (RecurringTransaction) -> Void
	let onAddTap: () -> Void
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			// Header avec bouton d'ajout
			RecurringHeader(onAddTap: onAddTap)
			
			// Grille de récurrences
			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
				ForEach(recurringTransactions) { recurring in
					RecurringCard(
						recurring: recurring,
						onEdit: { onEdit(recurring) },
						onDelete: { onDelete(recurring) }
					)
				}
			}
		}
		.padding(.horizontal, 20)
	}
}

// MARK: - Header

private struct RecurringHeader: View {
	let onAddTap: () -> Void
	
	var body: some View {
		HStack {
			Text("Récurrences")
				.font(.system(size: 18, weight: .bold))
			
			Spacer()
			
			Button(action: onAddTap) {
				HStack(spacing: 4) {
					Image(systemName: "plus")
						.font(.system(size: 12, weight: .bold))
					Text("Ajouter")
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

// MARK: - Carte de récurrence

private struct RecurringCard: View {
	let recurring: RecurringTransaction
	let onEdit: () -> Void
	let onDelete: () -> Void
	
	var body: some View {
		Button {
			let feedback = UIImpactFeedbackGenerator(style: .medium)
			feedback.impactOccurred()
			onEdit()
		} label: {
			HStack(spacing: 12) {
				// Icône colorée
				ZStack {
					Circle()
						.fill(recurring.style.color.opacity(0.15))
						.frame(width: 40, height: 40)
					Image(systemName: recurring.style.icon)
						.font(.system(size: 18))
						.foregroundStyle(recurring.style.color)
				}
				
				// Texte
				VStack(alignment: .leading, spacing: 2) {
					Text(recurring.comment)
						.font(.system(size: 12, weight: .medium))
						.foregroundStyle(.secondary)
						.lineLimit(1)
					
					HStack(spacing: 2) {
						Text(recurring.type == .income ? "+" : "−")
							.font(.system(size: 14, weight: .bold))
							.foregroundStyle(recurring.type == .income ? .green : .red)
						Text("\(compactAmount(recurring.amount)) €")
							.font(.system(size: 14, weight: .bold))
							.foregroundStyle(.primary)
							.lineLimit(1)
							.minimumScaleFactor(0.8)
					}
					
					Text(recurring.frequency.shortLabel)
						.font(.system(size: 10, weight: .medium))
						.foregroundStyle(.tertiary)
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

// MARK: - Formatage compact (réutilisé depuis ShortcutsGridView)

private func compactAmount(_ value: Double) -> String {
	let thresholds: [(limit: Double, divisor: Double, suffix: String)] = [
		(1_000_000_000, 1_000_000_000, "G"),
		(1_000_000, 1_000_000, "M"),
		(1_000, 1_000, "k")
	]
	
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
	
	if value == value.rounded(.down) {
		return String(format: "%.0f", value)
	} else if (value * 10).rounded() == (value * 10) {
		return String(format: "%.1f", value)
	} else {
		return String(format: "%.2f", value)
	}
}

// MARK: - Preview

#Preview {
	RecurringTransactionsGridView(
		recurringTransactions: [
			RecurringTransaction(amount: 750, comment: "Loyer", type: .expense, style: .rent, frequency: .monthly),
			RecurringTransaction(amount: 2500, comment: "Salaire", type: .income, style: .salary, frequency: .monthly)
		],
		onEdit: { _ in },
		onDelete: { _ in },
		onAddTap: {}
	)
	.padding()
	.background(Color(UIColor.systemGroupedBackground))
}
