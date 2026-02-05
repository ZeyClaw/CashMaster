//
//  BalanceHeaderView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI

/// En-tête affichant le solde total du compte avec le pourcentage de changement mensuel
struct BalanceHeaderView: View {
	let accountName: String?
	let totalCurrent: Double?
	let percentageChange: Double?
	let onTap: () -> Void
	
	var body: some View {
		Button(action: onTap) {
			VStack(spacing: 4) {
				// Nom du compte
				if let accountName = accountName {
					Text(accountName)
						.font(.system(size: 17, weight: .semibold))
						.foregroundStyle(.primary)
						.padding(.bottom, 8)
				}
				
				Text("Solde total")
					.font(.system(size: 12, weight: .bold))
					.foregroundStyle(.secondary)
					.textCase(.uppercase)
					.tracking(2)
				
				if let totalCurrent = totalCurrent {
					Text("\(totalCurrent, specifier: "%.2f") €")
						.font(.system(size: 48, weight: .bold))
						.tracking(-1)
				}
				
				// Pourcentage de changement
				PercentageChangeView(percentage: percentageChange)
			}
			.padding(.top, 16)
			.padding(.bottom, 16)
		}
		.buttonStyle(PlainButtonStyle())
	}
}

// MARK: - Sous-composant pour le pourcentage

private struct PercentageChangeView: View {
	let percentage: Double?
	
	var body: some View {
		if let pourcentage = percentage {
			HStack(spacing: 4) {
				Image(systemName: iconName(for: pourcentage))
					.font(.system(size: 12, weight: .semibold))
				Text("\(pourcentage > 0 ? "+" : "")\(pourcentage, specifier: "%.1f")% ce mois-ci")
					.font(.system(size: 14, weight: .semibold))
			}
			.foregroundStyle(color(for: pourcentage))
		} else {
			HStack(spacing: 4) {
				Image(systemName: "arrow.forward")
					.font(.system(size: 12, weight: .semibold))
				Text("+\(0.0, specifier: "%.1f")% ce mois-ci")
					.font(.system(size: 14, weight: .semibold))
			}
			.foregroundStyle(.secondary)
		}
	}
	
	private func iconName(for value: Double) -> String {
		if value > 0 {
			return "arrow.up.right"
		} else if value < 0 {
			return "arrow.down.right"
		} else {
			return "arrow.forward"
		}
	}
	
	private func color(for value: Double) -> Color {
		if value > 0 {
			return .green
		} else if value < 0 {
			return .red
		} else {
			return .secondary
		}
	}
}

#Preview {
	BalanceHeaderView(
		accountName: "Compte Courant",
		totalCurrent: 1234.56,
		percentageChange: 5.2,
		onTap: {}
	)
}
