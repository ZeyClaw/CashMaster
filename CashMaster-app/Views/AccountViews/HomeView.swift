//
//  HomeView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 07/08/2025.
//

import SwiftUI

struct HomeView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	private var totalCurrent: Double {
		accountsManager.totalNonPotentiel(for: accountsManager.selectedAccount!)
	}
	
	private var totalPotentiel: Double {
		accountsManager.totalPotentiel(for: accountsManager.selectedAccount!)
	}
	
	private var totalFuture: Double {
		totalCurrent + totalPotentiel
	}
	
	private var currentMonthName: String {
		let date = Date()
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "LLLL"
		return formatter.string(from: date).capitalized
	}
	
	private var currentMonthSolde: Double {
		let month = Calendar.current.component(.month, from: Date())
		let year = Calendar.current.component(.year, from: Date())
		return accountsManager.totalPourMois(month, year: year)
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				// Carte solde
				VStack(alignment: .leading, spacing: 8) {
					Text("Solde total")
						.font(.headline)
					
					HStack {
						VStack(alignment: .leading) {
							Text("Actuel")
								.font(.caption)
							Text("\(totalCurrent, specifier: "%.2f") €")
								.font(.title3)
								.foregroundStyle(totalCurrent >= 0 ? .green : .red)
						}
						Spacer()
						VStack(alignment: .leading) {
							Text("Futur")
								.font(.caption)
							Text("\(totalFuture, specifier: "%.2f") €")
								.font(.title3)
								.foregroundStyle(totalFuture >= 0 ? .green : .red)
						}
					}
				}
				.padding()
				.background(Color(UIColor.secondarySystemGroupedBackground))
				.cornerRadius(12)
				.padding(.horizontal)
				
				// Solde du mois actuel
				VStack(alignment: .leading, spacing: 8) {
					Text("Solde de ce mois")
						.font(.headline)
						.padding(.horizontal)
					
					HStack {
						Text(currentMonthName)
						Spacer()
						Text("\(currentMonthSolde, specifier: "%.2f") €")
							.foregroundStyle(currentMonthSolde >= 0 ? .green : .red)
					}
					.padding()
					.background(Color(UIColor.secondarySystemGroupedBackground))
					.cornerRadius(8)
					.padding(.horizontal)
				}
			}
			.padding(.vertical)
		}
		.background(Color(UIColor.systemGroupedBackground))
	}
}
