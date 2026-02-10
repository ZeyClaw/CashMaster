//
//  AccountCardView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import SwiftUI

struct AccountCardView: View {
	let account: Account
	let solde: Double
	let futur: Double
	
	var body: some View {
		HStack(spacing: 16) {
			// Icône avec fond coloré
			ZStack {
				RoundedRectangle(cornerRadius: 12)
					.fill(account.style.color.opacity(0.15))
					.frame(width: 48, height: 48)
				Image(systemName: account.style.icon)
					.font(.system(size: 20))
					.foregroundStyle(account.style.color)
			}
			
			// Nom et détail
			VStack(alignment: .leading, spacing: 2) {
				Text(account.name)
					.font(.headline)
					.foregroundStyle(.primary)
					.lineLimit(1)
				if !account.detail.isEmpty {
					Text(account.detail)
						.font(.caption)
						.foregroundStyle(.secondary)
						.textCase(.uppercase)
						.lineLimit(1)
				}
			}
			.layoutPriority(1)
			
			Spacer(minLength: 0)
			
			// Solde
			VStack(alignment: .trailing, spacing: 2) {
				Text("\(solde, specifier: "%.2f") €")
					.font(.title3.bold())
					.foregroundColor(solde >= 0 ? .primary : .red)
					.lineLimit(1)
				if futur != solde {
					Text("→ \(futur, specifier: "%.2f") €")
						.font(.caption)
						.foregroundColor(futur >= 0 ? .secondary : .red.opacity(0.7))
						.lineLimit(1)
				}
			}
			.layoutPriority(2)
		}
		.padding(16)
		.background(Color(.systemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 20))
		.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
	}
}

