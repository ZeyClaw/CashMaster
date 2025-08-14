//
//  YearsView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 06/08/2025.
//

import SwiftUI

struct YearsView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	var body: some View {
		if accountsManager.transactions().isEmpty {
			CalendrierTabView(accountsManager: accountsManager)
		} else {
			List {
				ForEach(accountsManager.anneesDisponibles(), id: \.self) { year in
					NavigationLink(value: CalendrierRoute.months(year: year)) {
						HStack {
							Text("\(year)")
							Spacer()
							Text("\(accountsManager.totalPourAnnee(year), specifier: "%.2f") €")
								.foregroundStyle(accountsManager.totalPourAnnee(year) >= 0 ? .green : .red)
						}
					}
				}
			}
		}
	}
}
