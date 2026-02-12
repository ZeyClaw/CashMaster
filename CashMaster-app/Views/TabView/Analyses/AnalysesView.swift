//
//  AnalysesView.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 12/02/2026.
//

import SwiftUI
import Charts

// MARK: - Modèle de données pour le graphique

/// Représente une catégorie avec son montant total et le nombre de transactions
struct CategoryData: Identifiable {
	let id = UUID()
	let category: TransactionCategory
	let total: Double
	let count: Int
}

// MARK: - Type d'analyse (Dépenses / Revenus)

enum AnalysisType: String, CaseIterable {
	case expenses = "Dépenses"
	case income = "Revenus"
}

// MARK: - Vue principale Analyses

/// Vue affichant la répartition des dépenses ou revenus par catégorie
/// avec un graphique camembert et une liste détaillée par mois
struct AnalysesView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var analysisType: AnalysisType = .expenses
	@State private var selectedMonth: Int
	@State private var selectedYear: Int
	@State private var selectedSlice: TransactionCategory?
	
	init(accountsManager: AccountsManager) {
		self.accountsManager = accountsManager
		let now = Date()
		let calendar = Calendar.current
		_selectedMonth = State(initialValue: calendar.component(.month, from: now))
		_selectedYear = State(initialValue: calendar.component(.year, from: now))
	}
	
	// MARK: - Données calculées
	
	/// Transactions validées filtrées par mois/année et type (dépense ou revenu)
	private var filteredTransactions: [Transaction] {
		let validated = accountsManager.validatedTransactions(year: selectedYear, month: selectedMonth)
		switch analysisType {
		case .expenses:
			return validated.filter { $0.amount < 0 }
		case .income:
			return validated.filter { $0.amount > 0 }
		}
	}
	
	/// Données agrégées par catégorie, triées par montant décroissant
	private var categoryData: [CategoryData] {
		var grouped: [TransactionCategory: (total: Double, count: Int)] = [:]
		
		for transaction in filteredTransactions {
			let category = transaction.category ?? .other
			let absAmount = abs(transaction.amount)
			let existing = grouped[category] ?? (total: 0, count: 0)
			grouped[category] = (total: existing.total + absAmount, count: existing.count + 1)
		}
		
		return grouped.map { CategoryData(category: $0.key, total: $0.value.total, count: $0.value.count) }
			.sorted { $0.total > $1.total }
	}
	
	/// Montant total pour la période
	private var totalAmount: Double {
		categoryData.reduce(0) { $0 + $1.total }
	}
	
	/// Nom du mois formaté
	private var monthName: String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "LLLL"
		var components = DateComponents()
		components.month = selectedMonth
		components.year = selectedYear
		let date = Calendar.current.date(from: components) ?? Date()
		return formatter.string(from: date).capitalized
	}
	
	// MARK: - Body
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				// Sélecteur Dépenses / Revenus
				segmentedControl
				
				// Navigation mensuelle
				monthNavigator
				
				if categoryData.isEmpty {
					emptyStateView
				} else {
					// Graphique camembert
					pieChart
					
					// Détail par catégorie
					categoryList
				}
			}
			.padding()
		}
		.background(Color(.systemGroupedBackground))
	}
	
	// MARK: - Composants
	
	/// Picker segmenté Dépenses/Revenus
	private var segmentedControl: some View {
		Picker("Type", selection: $analysisType) {
			ForEach(AnalysisType.allCases, id: \.self) { type in
				Text(type.rawValue).tag(type)
			}
		}
		.pickerStyle(.segmented)
	}
	
	/// Navigateur de mois avec flèches
	private var monthNavigator: some View {
		HStack {
			Button {
				goToPreviousMonth()
			} label: {
				Image(systemName: "chevron.left")
					.font(.title3.weight(.semibold))
					.foregroundStyle(.primary)
			}
			
			Spacer()
			
			Text("\(monthName) \(String(selectedYear))")
				.font(.title3.weight(.semibold))
			
			Spacer()
			
			Button {
				goToNextMonth()
			} label: {
				Image(systemName: "chevron.right")
					.font(.title3.weight(.semibold))
					.foregroundStyle(isCurrentMonth ? .tertiary : .primary)
			}
			.disabled(isCurrentMonth)
		}
		.padding(.horizontal, 4)
	}
	
	/// État vide quand aucune transaction
	private var emptyStateView: some View {
		VStack(spacing: 12) {
			Image(systemName: analysisType == .expenses ? "cart" : "banknote")
				.font(.system(size: 48))
				.foregroundStyle(.tertiary)
			Text("Aucune \(analysisType == .expenses ? "dépense" : "revenu") ce mois")
				.font(.headline)
				.foregroundStyle(.secondary)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 60)
	}
	
	/// Graphique camembert avec Swift Charts
	private var pieChart: some View {
		VStack(spacing: 12) {
			Chart(categoryData) { item in
				SectorMark(
					angle: .value("Montant", item.total),
					innerRadius: .ratio(0.6),
					angularInset: 1.5
				)
				.foregroundStyle(item.category.color)
				.opacity(selectedSlice == nil || selectedSlice == item.category ? 1 : 0.4)
			}
			.chartBackground { _ in
				// Montant total au centre du donut
				VStack(spacing: 2) {
					Text(totalAmount, format: .currency(code: "EUR"))
						.font(.title2.weight(.bold))
						.minimumScaleFactor(0.6)
					Text(analysisType == .expenses ? "dépensés" : "gagnés")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.frame(height: 240)
		}
		.padding()
		.background(Color(.secondarySystemGroupedBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
	
	/// Liste détaillée par catégorie
	private var categoryList: some View {
		VStack(spacing: 0) {
			ForEach(categoryData) { item in
				CategoryBreakdownRow(
					item: item,
					totalAmount: totalAmount,
					isSelected: selectedSlice == item.category
				)
				.contentShape(Rectangle())
				.onTapGesture {
					withAnimation(.easeInOut(duration: 0.2)) {
						if selectedSlice == item.category {
							selectedSlice = nil
						} else {
							selectedSlice = item.category
						}
					}
				}
				
				if item.id != categoryData.last?.id {
					Divider()
						.padding(.leading, 56)
				}
			}
		}
		.padding(.vertical, 8)
		.background(Color(.secondarySystemGroupedBackground))
		.clipShape(RoundedRectangle(cornerRadius: 16))
	}
	
	// MARK: - Navigation temporelle
	
	private var isCurrentMonth: Bool {
		let calendar = Calendar.current
		let now = Date()
		return selectedMonth == calendar.component(.month, from: now)
			&& selectedYear == calendar.component(.year, from: now)
	}
	
	private func goToPreviousMonth() {
		if selectedMonth == 1 {
			selectedMonth = 12
			selectedYear -= 1
		} else {
			selectedMonth -= 1
		}
	}
	
	private func goToNextMonth() {
		guard !isCurrentMonth else { return }
		if selectedMonth == 12 {
			selectedMonth = 1
			selectedYear += 1
		} else {
			selectedMonth += 1
		}
	}
}

#Preview {
	NavigationStack {
		AnalysesView(accountsManager: AccountsManager())
	}
}
