//
//  AnalysesModels.swift
//  Finoria
//

import Foundation

// MARK: - Modèle de données pour le graphique

/// Représente une catégorie avec son montant total et le nombre de transactions
struct CategoryData: Identifiable {
	let id = UUID()
	let category: TransactionCategory
	let total: Double
	let count: Int
}

// MARK: - Type d'analyse

/// Dépenses ou Revenus — utilisé par le Picker segmenté dans AnalysesView
enum AnalysisType: String, CaseIterable {
	case expenses = "Dépenses"
	case income = "Revenus"
}

// MARK: - Route de navigation

/// Route Hashable vers le détail des transactions d'une catégorie pour un mois donné
struct CategoryDetailRoute: Hashable {
	let category: TransactionCategory
	let month: Int
	let year: Int
}
