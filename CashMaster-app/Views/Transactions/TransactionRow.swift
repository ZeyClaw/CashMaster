//
//  TransactionRow.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import SwiftUI

struct TransactionRow: View {
	let transaction: Transaction
	
	/// Catégorie affichée : celle de la transaction, ou une par défaut basée sur le montant
	private var displayCategory: TransactionCategory {
		transaction.category ?? (transaction.amount >= 0 ? .income : .expense)
	}
	
	var body: some View {
		HStack(spacing: 12) {
			// Icône catégorie à gauche
			StyleIconView(style: displayCategory, size: 36)
			
			VStack(alignment: .leading) {
				Text(transaction.comment)
					.font(.body)
				if let date = transaction.date {
					Text(date.formatted(date: .abbreviated, time: .omitted))
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			Spacer()
			Text("\(transaction.amount, specifier: "%.2f") €")
				.foregroundStyle(transaction.amount >= 0 ? .green : .red)
		}
	}
}
