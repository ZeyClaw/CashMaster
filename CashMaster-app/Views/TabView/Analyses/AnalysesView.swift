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

// MARK: - Route de navigation vers le détail d'une catégorie

struct CategoryDetailRoute: Hashable {
	let category: TransactionCategory
	let month: Int
	let year: Int
}

// MARK: - Vue principale Analyses

/// Vue affichant la répartition des dépenses ou revenus par catégorie
/// avec un graphique camembert et une liste détaillée par mois
struct AnalysesView: View {
	@ObservedObject var accountsManager: AccountsManager
	
	@State private var analysisType: AnalysisType = .expenses
	@State private var selectedSlice: TransactionCategory?
	
	/// Mois et année actuellement sélectionnés
	@State private var selectedMonth: Int
	@State private var selectedYear: Int
	
	/// Mois/année courants (pour limiter la navigation au présent)
	private let currentMonth: Int
	private let currentYear: Int
	
	init(accountsManager: AccountsManager) {
		self.accountsManager = accountsManager
		let now = Date()
		let calendar = Calendar.current
		let m = calendar.component(.month, from: now)
		let y = calendar.component(.year, from: now)
		self.currentMonth = m
		self.currentYear = y
		self._selectedMonth = State(initialValue: m)
		self._selectedYear = State(initialValue: y)
	}
	
	// MARK: - Navigation mensuelle
	
	/// Indique si on peut avancer au mois suivant (pas au-delà du mois courant)
	private var canGoNext: Bool {
		!(selectedMonth == currentMonth && selectedYear == currentYear)
	}
	
	/// Recule d'un mois
	private func goToPreviousMonth() {
		if selectedMonth == 1 {
			selectedMonth = 12
			selectedYear -= 1
		} else {
			selectedMonth -= 1
		}
	}
	
	/// Avance d'un mois (limité au mois courant)
	private func goToNextMonth() {
		guard canGoNext else { return }
		if selectedMonth == 12 {
			selectedMonth = 1
			selectedYear += 1
		} else {
			selectedMonth += 1
		}
	}
	
	// MARK: - Données calculées
	
	/// Transactions validées filtrées par mois/année et type (dépense ou revenu)
	private func filteredTransactions(month: Int, year: Int) -> [Transaction] {
		let validated = accountsManager.validatedTransactions(year: year, month: month)
		switch analysisType {
		case .expenses:
			return validated.filter { $0.amount < 0 }
		case .income:
			return validated.filter { $0.amount > 0 }
		}
	}
	
	/// Données agrégées par catégorie, triées par montant décroissant
	private func categoryData(month: Int, year: Int) -> [CategoryData] {
		var grouped: [TransactionCategory: (total: Double, count: Int)] = [:]
		
		for transaction in filteredTransactions(month: month, year: year) {
			let category = transaction.category ?? .other
			let absAmount = abs(transaction.amount)
			let existing = grouped[category] ?? (total: 0, count: 0)
			grouped[category] = (total: existing.total + absAmount, count: existing.count + 1)
		}
		
		return grouped.map { CategoryData(category: $0.key, total: $0.value.total, count: $0.value.count) }
			.sorted { $0.total > $1.total }
	}
	
	/// Montant total pour la période
	private func totalAmount(month: Int, year: Int) -> Double {
		categoryData(month: month, year: year).reduce(0) { $0 + $1.total }
	}
	
	/// Données avec taille minimale pour l'affichage du graphique (1% minimum)
	private func chartDisplayData(month: Int, year: Int) -> [CategoryData] {
		let total = totalAmount(month: month, year: year)
		let data = categoryData(month: month, year: year)
		guard total > 0 else { return data }
		let minValue = total * 0.01
		return data.map {
			CategoryData(category: $0.category, total: max($0.total, minValue), count: $0.count)
		}
	}
	
	/// Total des données d'affichage (pour le calcul des angles)
	private func displayTotal(month: Int, year: Int) -> Double {
		chartDisplayData(month: month, year: year).reduce(0) { $0 + $1.total }
	}
	
	/// Nom du mois formaté
	private func monthName(month: Int, year: Int) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "LLLL"
		var components = DateComponents()
		components.month = month
		components.year = year
		let date = Calendar.current.date(from: components) ?? Date()
		return formatter.string(from: date).capitalized
	}
	
	// MARK: - Body
	
	var body: some View {
		let catData = categoryData(month: selectedMonth, year: selectedYear)
		let total = totalAmount(month: selectedMonth, year: selectedYear)
		let chartData = chartDisplayData(month: selectedMonth, year: selectedYear)
		let dispTotal = displayTotal(month: selectedMonth, year: selectedYear)
		
		List {
			// Section contrôles + navigation mois
			Section {
				segmentedControl
				monthNavigator
			}
			
			if catData.isEmpty {
				Section {
					emptyStateView
				}
			} else {
				// Section graphique
				Section {
					pieChart(chartData: chartData, catData: catData, total: total, dispTotal: dispTotal)
				}
				
				// Section détail par catégorie
				Section {
					ForEach(catData) { item in
						NavigationLink(value: CategoryDetailRoute(category: item.category, month: selectedMonth, year: selectedYear)) {
							CategoryBreakdownRow(item: item, totalAmount: total, isSelected: selectedSlice == item.category)
						}
						.listRowBackground(
							selectedSlice == item.category
								? item.category.color.opacity(0.12)
								: Color(UIColor.secondarySystemGroupedBackground)
						)
					}
				}
			}
		}
		.listStyle(.insetGrouped)
		.onChange(of: analysisType) { _ in
			selectedSlice = nil
		}
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
	
	/// Navigateur de mois (< Mois Année >) avec boutons chevron
	private var monthNavigator: some View {
		HStack {
			Button {
				withAnimation(.easeInOut(duration: 0.2)) {
					goToPreviousMonth()
					selectedSlice = nil
				}
			} label: {
				Image(systemName: "chevron.left")
					.font(.body.weight(.semibold))
					.foregroundStyle(.blue)
					.frame(width: 44, height: 44)
					.contentShape(Rectangle())
			}
			.buttonStyle(PlainButtonStyle())
			
			Spacer()
			
			Text("\(monthName(month: selectedMonth, year: selectedYear)) \(String(selectedYear))")
				.font(.title3.weight(.semibold))
				.contentTransition(.numericText())
			
			Spacer()
			
			Button {
				withAnimation(.easeInOut(duration: 0.2)) {
					goToNextMonth()
					selectedSlice = nil
				}
			} label: {
				Image(systemName: "chevron.right")
					.font(.body.weight(.semibold))
					.foregroundStyle(canGoNext ? .blue : .gray.opacity(0.3))
					.frame(width: 44, height: 44)
					.contentShape(Rectangle())
			}
			.buttonStyle(PlainButtonStyle())
			.disabled(!canGoNext)
		}
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
	
	/// Graphique camembert avec Swift Charts et interaction tap
	private func pieChart(chartData: [CategoryData], catData: [CategoryData], total: Double, dispTotal: Double) -> some View {
		Chart(chartData) { item in
			SectorMark(
				angle: .value("Montant", item.total),
				innerRadius: .ratio(0.6),
				angularInset: 1.5
			)
			.foregroundStyle(item.category.color)
			.opacity(selectedSlice == nil || selectedSlice == item.category ? 1 : 0.4)
		}
		.chartBackground { _ in
			VStack(spacing: 2) {
				if let selected = selectedSlice,
				   let data = catData.first(where: { $0.category == selected }) {
					StyleIconView(style: selected, size: 28)
					Text(data.total, format: .currency(code: "EUR"))
						.font(.title3.weight(.bold))
						.minimumScaleFactor(0.6)
					Text(selected.label)
						.font(.caption)
						.foregroundStyle(.secondary)
				} else {
					Text(total, format: .currency(code: "EUR"))
						.font(.title2.weight(.bold))
						.minimumScaleFactor(0.6)
					Text(analysisType == .expenses ? "dépensés" : "gagnés")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
		.frame(height: 240)
		.chartOverlay { _ in
			GeometryReader { geometry in
				Rectangle().fill(.clear).contentShape(Rectangle())
					.onTapGesture { location in
						handleChartTap(at: location, in: geometry.size, chartData: chartData, dispTotal: dispTotal)
					}
			}
		}
	}
	
	// MARK: - Interaction graphique
	
	/// Gère le tap sur le graphique : sélectionne une tranche si le tap est sur l'anneau,
	/// désélectionne sinon
	private func handleChartTap(at location: CGPoint, in size: CGSize, chartData: [CategoryData], dispTotal: Double) {
		let center = CGPoint(x: size.width / 2, y: size.height / 2)
		let dx = location.x - center.x
		let dy = location.y - center.y
		let distance = sqrt(dx * dx + dy * dy)
		let outerRadius = min(size.width, size.height) / 2
		let innerRadius = outerRadius * 0.6
		
		guard distance >= innerRadius && distance <= outerRadius else {
			withAnimation(.easeInOut(duration: 0.2)) {
				selectedSlice = nil
			}
			return
		}
		
		// Angle depuis le haut (12h), sens horaire
		var angle = atan2(dx, -dy)
		if angle < 0 { angle += 2 * .pi }
		let fraction = angle / (2 * .pi)
		let angleValue = fraction * dispTotal
		
		let found = findCategory(for: angleValue, in: chartData)
		withAnimation(.easeInOut(duration: 0.2)) {
			selectedSlice = (selectedSlice == found) ? nil : found
		}
	}
	
	/// Trouve la catégorie correspondant à une valeur cumulée dans le graphique
	private func findCategory(for value: Double, in chartData: [CategoryData]) -> TransactionCategory? {
		var cumulative: Double = 0
		for item in chartData {
			cumulative += item.total
			if value <= cumulative {
				return item.category
			}
		}
		return nil
	}
}

#Preview {
	NavigationStack {
		AnalysesView(accountsManager: AccountsManager())
	}
}
