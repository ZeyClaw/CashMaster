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
	
	/// Données avec taille minimale pour l'affichage du graphique (3% minimum)
	private var chartDisplayData: [CategoryData] {
		guard totalAmount > 0 else { return categoryData }
		let minValue = totalAmount * 0.008
		return categoryData.map {
			CategoryData(category: $0.category, total: max($0.total, minValue), count: $0.count)
		}
	}
	
	/// Total des données d'affichage (pour le calcul des angles)
	private var displayTotal: Double {
		chartDisplayData.reduce(0) { $0 + $1.total }
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
		List {
			// Section contrôles
			Section {
				segmentedControl
				monthNavigator
			}
			
			if categoryData.isEmpty {
				Section {
					emptyStateView
				}
			} else {
				// Section graphique
				Section {
					pieChart
				}
				
				// Section détail par catégorie
				Section {
					ForEach(categoryData) { item in
						NavigationLink(value: CategoryDetailRoute(category: item.category, month: selectedMonth, year: selectedYear)) {
							CategoryBreakdownRow(item: item, totalAmount: totalAmount, isSelected: selectedSlice == item.category)
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
	
	/// Navigateur de mois avec flèches
	private var monthNavigator: some View {
		HStack {
			Button {
				withAnimation { goToPreviousMonth() }
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
				withAnimation { goToNextMonth() }
			} label: {
				Image(systemName: "chevron.right")
					.font(.title3.weight(.semibold))
					.foregroundStyle(isCurrentMonth ? .tertiary : .primary)
			}
			.disabled(isCurrentMonth)
		}
		.contentShape(Rectangle())
		.gesture(
			DragGesture(minimumDistance: 30)
				.onEnded { value in
					guard abs(value.translation.width) > abs(value.translation.height) else { return }
					if value.translation.width > 0 {
						withAnimation { goToPreviousMonth() }
					} else if !isCurrentMonth {
						withAnimation { goToNextMonth() }
					}
				}
		)
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
	private var pieChart: some View {
		Chart(chartDisplayData) { item in
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
				   let data = categoryData.first(where: { $0.category == selected }) {
					StyleIconView(style: selected, size: 28)
					Text(data.total, format: .currency(code: "EUR"))
						.font(.title3.weight(.bold))
						.minimumScaleFactor(0.6)
					Text(selected.label)
						.font(.caption)
						.foregroundStyle(.secondary)
				} else {
					Text(totalAmount, format: .currency(code: "EUR"))
						.font(.title2.weight(.bold))
						.minimumScaleFactor(0.6)
					Text(analysisType == .expenses ? "dépensés" : "gagnés")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.id(selectedSlice)
			.transition(.opacity)
		}
		.frame(height: 240)
		.chartOverlay { _ in
			GeometryReader { geometry in
				Rectangle().fill(.clear).contentShape(Rectangle())
					.onTapGesture { location in
						handleChartTap(at: location, in: geometry.size)
					}
			}
		}
	}
	
	// MARK: - Interaction graphique
	
	/// Gère le tap sur le graphique : sélectionne une tranche si le tap est sur l'anneau,
	/// désélectionne sinon
	private func handleChartTap(at location: CGPoint, in size: CGSize) {
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
		let angleValue = fraction * displayTotal
		
		let found = findCategory(for: angleValue)
		withAnimation(.easeInOut(duration: 0.2)) {
			selectedSlice = (selectedSlice == found) ? nil : found
		}
	}
	
	/// Trouve la catégorie correspondant à une valeur cumulée dans le graphique
	private func findCategory(for value: Double) -> TransactionCategory? {
		var cumulative: Double = 0
		for item in chartDisplayData {
			cumulative += item.total
			if value <= cumulative {
				return item.category
			}
		}
		return nil
	}
	
	// MARK: - Navigation temporelle
	
	private var isCurrentMonth: Bool {
		let calendar = Calendar.current
		let now = Date()
		return selectedMonth == calendar.component(.month, from: now)
			&& selectedYear == calendar.component(.year, from: now)
	}
	
	private func goToPreviousMonth() {
		selectedSlice = nil
		if selectedMonth == 1 {
			selectedMonth = 12
			selectedYear -= 1
		} else {
			selectedMonth -= 1
		}
	}
	
	private func goToNextMonth() {
		guard !isCurrentMonth else { return }
		selectedSlice = nil
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
