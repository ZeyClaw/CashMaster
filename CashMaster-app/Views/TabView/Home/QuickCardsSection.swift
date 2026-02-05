//
//  QuickCardsSection.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI

/// Section affichant les deux cartes rapides : Solde du mois et À venir
struct QuickCardsSection: View {
	let currentMonthSolde: Double
	let totalPotentiel: Double?
	let onMonthTap: () -> Void
	let onFutureTap: () -> Void
	
	var body: some View {
		HStack(spacing: 16) {
			// Carte Solde du mois
			QuickCard(
				icon: "banknote",
				iconColor: .blue,
				title: "Solde du mois",
				value: currentMonthSolde,
				onTap: onMonthTap
			)
			
			// Carte Achats Futurs
			QuickCard(
				icon: "cart",
				iconColor: .orange,
				title: "À venir",
				value: totalPotentiel,
				onTap: onFutureTap
			)
		}
		.padding(.horizontal, 16)
	}
}

// MARK: - Composant Carte Réutilisable

private struct QuickCard: View {
	let icon: String
	let iconColor: Color
	let title: String
	let value: Double?
	let onTap: () -> Void
	
	var body: some View {
		Button(action: onTap) {
			VStack(alignment: .leading, spacing: 16) {
				// Icône avec fond coloré
				ZStack {
					Circle()
						.fill(iconColor.opacity(0.1))
						.frame(width: 40, height: 40)
					Image(systemName: icon)
						.font(.system(size: 18))
						.foregroundStyle(iconColor)
				}
				
				// Texte
				VStack(alignment: .leading, spacing: 4) {
					Text(title)
						.font(.system(size: 15, weight: .bold))
						.foregroundStyle(.primary)
					
					if let value = value {
						Text("\(value, specifier: "%.2f") €")
							.font(.system(size: 14, weight: .medium))
							.foregroundStyle(.secondary)
					}
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(16)
			.background(Color(UIColor.secondarySystemGroupedBackground))
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 2)
		}
		.buttonStyle(PlainButtonStyle())
	}
}

#Preview {
	QuickCardsSection(
		currentMonthSolde: -245.50,
		totalPotentiel: -120.00,
		onMonthTap: {},
		onFutureTap: {}
	)
	.padding()
	.background(Color(UIColor.systemGroupedBackground))
}
