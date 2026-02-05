//
//  CalendrierTabView.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 14/08/2025.
//

import SwiftUI

enum CalendrierViewMode: String, CaseIterable {
	case jour = "Jour"
	case mois = "Mois"
	case annee = "Année"
}

/// Vue de contenu du calendrier (sans navigation wrapping)
struct CalendrierTabView: View {
	@ObservedObject var accountsManager: AccountsManager
	@State private var selectedMode: CalendrierViewMode = .jour
	
	var body: some View {
		VStack(spacing: 0) {
			// Picker en haut
			Picker("Mode", selection: $selectedMode) {
				ForEach(CalendrierViewMode.allCases, id: \.self) { mode in
					Text(mode.rawValue).tag(mode)
				}
			}
			.pickerStyle(.segmented)
			.padding(.horizontal, 16)
			.padding(.vertical, 8)
			
			// Contenu selon le mode sélectionné
			if accountsManager.transactions().isEmpty {
				List {
					Text("Aucune transaction")
						.foregroundStyle(.secondary)
				}
			} else {
				switch selectedMode {
				case .jour:
					AllTransactionsView(accountsManager: accountsManager, embedded: true)
				case .mois:
					CalendrierMonthsContentView(accountsManager: accountsManager)
				case .annee:
					CalendrierYearsContentView(accountsManager: accountsManager)
				}
			}
		}
		.navigationTitle("Calendrier")
		.navigationDestination(for: CalendrierRoute.self) { route in
			switch route {
			case .months(let year):
				MonthsView(accountsManager: accountsManager, year: year)
			case .transactions(let month, let year):
				TransactionsListView(accountsManager: accountsManager, month: month, year: year)
			}
		}
	}
}

// MARK: - Vue Années (contenu uniquement)
private struct CalendrierYearsContentView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	var body: some View {
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

// MARK: - Vue Mois (contenu uniquement, tous les mois de toutes les années)
private struct CalendrierMonthsContentView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	private var monthsWithData: [(year: Int, month: Int, total: Double)] {
		var result: [(year: Int, month: Int, total: Double)] = []
		for year in accountsManager.anneesDisponibles().reversed() {
			for month in (1...12).reversed() {
				let total = accountsManager.totalPourMois(month, year: year)
				if total != 0 {
					result.append((year: year, month: month, total: total))
				}
			}
		}
		return result
	}
	
	var body: some View {
		List {
			ForEach(monthsWithData, id: \.month) { item in
				NavigationLink(value: CalendrierRoute.transactions(month: item.month, year: item.year)) {
					HStack {
						Text("\(nomDuMois(item.month)) \(item.year)")
						Spacer()
						Text("\(item.total, specifier: "%.2f") €")
							.foregroundStyle(item.total >= 0 ? .green : .red)
					}
				}
			}
		}
	}
	
	private func nomDuMois(_ mois: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		return formatter.monthSymbols[mois - 1].capitalized
	}
}
