//
//  MonthsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct MonthsView: View {
	@ObservedObject var accountsManager: AccountsManager
	var year: Int
	
	var body: some View {
		List {
			ForEach(1...12, id: \.self) { month in
				let total = accountsManager.totalPourMois(month, year: year)
				if total != 0 {
					NavigationLink(value: CalendrierRoute.transactions(month: month, year: year)) {
						HStack {
							Text(nomDuMois(month))
							Spacer()
							Text("\(total, specifier: "%.2f") €")
								.foregroundStyle(total >= 0 ? .green : .red)
						}
					}
				}
			}

		}
		.navigationTitle("\(year)")
	}
	
	private func nomDuMois(_ mois: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		return formatter.monthSymbols[mois - 1].capitalized
	}
}
