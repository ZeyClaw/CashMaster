//
//  YearsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct YearsView: View {
	let account: String
	@ObservedObject var accountsManager: AccountsManager
	
	var body: some View {
		List {
			ForEach(accountsManager.anneesDisponibles(for: account), id: \.self) { year in
				NavigationLink(destination: MonthsView(account: account, accountsManager: accountsManager, year: year)) {
					HStack {
						Text("\(year)")
						Spacer()
						Text("\(accountsManager.totalPourAnnee(year, account: account), specifier: "%.2f") €")
							.foregroundStyle(accountsManager.totalPourAnnee(year, account: account) >= 0 ? .green : .red)
					}
				}
			}
		}
	}
}
