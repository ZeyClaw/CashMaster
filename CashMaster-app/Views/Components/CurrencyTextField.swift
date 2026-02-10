//
//  CurrencyTextField.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/02/2026.
//

import SwiftUI

/// Champ de saisie de montant avec symbole € intégré
/// Réutilisable dans AddTransactionView, AddWidgetShortcutView, etc.
struct CurrencyTextField: View {
	let placeholder: String
	@Binding var amount: Double?
	
	init(_ placeholder: String = "Montant", amount: Binding<Double?>) {
		self.placeholder = placeholder
		self._amount = amount
	}
	
	var body: some View {
		TextField(placeholder, value: $amount, format: .number.precision(.fractionLength(0...2)))
			.keyboardType(.decimalPad)
			.overlay(
				Text("€")
					.foregroundColor(.gray),
				alignment: .trailing
			)
	}
}

// MARK: - Preview

#Preview {
	Form {
		Section("Test CurrencyTextField") {
			CurrencyTextField(amount: .constant(123.45))
			CurrencyTextField("Prix", amount: .constant(nil))
		}
	}
}
