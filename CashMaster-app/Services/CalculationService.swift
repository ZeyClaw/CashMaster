//
//  CalculationService.swift
//  CashMaster
//
//  Created by Godefroy REYNAUD on 05/02/2026.
//

import Foundation

/// Service responsable de tous les calculs financiers.
/// Prend des données en entrée et retourne des résultats calculés.
/// Ne modifie jamais les données sources.
struct CalculationService {
	
	// MARK: - Totaux par compte
	
	/// Calcule le total des transactions non potentielles (validées)
	static func totalNonPotentiel(transactions: [Transaction]) -> Double {
		transactions
			.filter { !$0.potentiel }
			.map { $0.amount }
			.reduce(0, +)
	}
	
	/// Calcule le total des transactions potentielles (futures)
	static func totalPotentiel(transactions: [Transaction]) -> Double {
		transactions
			.filter { $0.potentiel }
			.map { $0.amount }
			.reduce(0, +)
	}
	
	// MARK: - Regroupements temporels
	
	/// Retourne les années distinctes présentes dans les transactions validées
	static func anneesDisponibles(transactions: [Transaction]) -> [Int] {
		let validatedTransactions = transactions.filter { !$0.potentiel }
		let years = validatedTransactions.compactMap { tx -> Int? in
			guard let date = tx.date else { return nil }
			return Calendar.current.component(.year, from: date)
		}
		return Array(Set(years)).sorted()
	}
	
	/// Calcule le total pour une année donnée
	static func totalPourAnnee(_ year: Int, transactions: [Transaction]) -> Double {
		transactions
			.filter { !$0.potentiel && Calendar.current.component(.year, from: $0.date ?? Date()) == year }
			.map { $0.amount }
			.reduce(0, +)
	}
	
	/// Calcule le total pour un mois et une année donnés
	static func totalPourMois(_ month: Int, year: Int, transactions: [Transaction]) -> Double {
		transactions
			.filter {
				guard !$0.potentiel, let date = $0.date else { return false }
				let components = Calendar.current.dateComponents([.year, .month], from: date)
				return components.year == year && components.month == month
			}
			.map { $0.amount }
			.reduce(0, +)
	}
	
	// MARK: - Pourcentages
	
	/// Calcule le pourcentage de changement entre le mois actuel et le mois précédent
	/// - Parameter transactions: Liste des transactions à analyser
	/// - Returns: Le pourcentage de changement, ou nil si pas assez de données
	static func pourcentageChangementMois(transactions: [Transaction]) -> Double? {
		let calendar = Calendar.current
		let now = Date()
		
		let currentMonth = calendar.component(.month, from: now)
		let currentYear = calendar.component(.year, from: now)
		
		// Calcul du mois précédent
		let previousMonth: Int
		let previousYear: Int
		if currentMonth == 1 {
			previousMonth = 12
			previousYear = currentYear - 1
		} else {
			previousMonth = currentMonth - 1
			previousYear = currentYear
		}
		
		let currentTotal = totalPourMois(currentMonth, year: currentYear, transactions: transactions)
		let previousTotal = totalPourMois(previousMonth, year: previousYear, transactions: transactions)
		
		// Si le mois précédent est à 0, on ne peut pas calculer de pourcentage
		guard previousTotal != 0 else { return nil }
		return ((currentTotal - previousTotal) / abs(previousTotal)) * 100
	}
	
	// MARK: - Filtres de transactions
	
	/// Retourne toutes les transactions potentielles
	static func potentialTransactions(from transactions: [Transaction]) -> [Transaction] {
		transactions.filter { $0.potentiel }
	}
	
	/// Retourne toutes les transactions validées, optionnellement filtrées par année et/ou mois
	static func validatedTransactions(
		from transactions: [Transaction],
		year: Int? = nil,
		month: Int? = nil
	) -> [Transaction] {
		var result = transactions.filter { !$0.potentiel }
		
		if let year = year {
			result = result.filter {
				Calendar.current.component(.year, from: $0.date ?? Date()) == year
			}
		}
		
		if let month = month {
			result = result.filter {
				Calendar.current.component(.month, from: $0.date ?? Date()) == month
			}
		}
		
		return result
	}
}
