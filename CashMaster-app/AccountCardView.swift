//
//  AccountCardView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/08/2025.
//

import SwiftUI

struct AccountCardView: View {
	let account: String
	let solde: Double
	let futur: Double
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(account)
				.font(.headline)
			
			HStack {
				VStack(alignment: .leading) {
					Text("Solde actuel")
						.font(.caption)
					Text("\(solde, specifier: "%.2f") €")
						.font(.title3)
						.foregroundStyle(solde >= 0 ? .green : .red)
				}
				
				Spacer()
				
				VStack(alignment: .leading) {
					Text("Futur")
						.font(.caption)
					Text("\(futur, specifier: "%.2f") €")
						.font(.title3)
						.foregroundStyle(futur >= 0 ? .green : .red)
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color(UIColor.secondarySystemGroupedBackground))
		.cornerRadius(12)
	}
}

