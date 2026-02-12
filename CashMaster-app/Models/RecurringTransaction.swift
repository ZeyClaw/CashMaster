//
//  RecurringTransaction.swift
//  Finoria
//
//  Created by Godefroy REYNAUD on 10/02/2026.
//

import Foundation
import SwiftUI

// MARK: - Fréquence de récurrence

enum RecurrenceFrequency: String, Codable, CaseIterable, Identifiable {
	case daily    = "daily"
	case weekly   = "weekly"
	case monthly  = "monthly"
	case yearly   = "yearly"
	
	var id: String { rawValue }
	
	var label: String {
		switch self {
		case .daily:   return "Tous les jours"
		case .weekly:  return "Toutes les semaines"
		case .monthly: return "Tous les mois"
		case .yearly:  return "Tous les ans"
		}
	}
	
	var shortLabel: String {
		switch self {
		case .daily:   return "Quotidien"
		case .weekly:  return "Hebdo"
		case .monthly: return "Mensuel"
		case .yearly:  return "Annuel"
		}
	}
}

// MARK: - Modèle RecurringTransaction

struct RecurringTransaction: Identifiable, Codable, Equatable {
	let id: UUID
	let amount: Double
	let comment: String
	let type: TransactionType
	let category: TransactionCategory
	let frequency: RecurrenceFrequency
	let startDate: Date
	/// Date de la dernière transaction générée (pour éviter les doublons)
	var lastGeneratedDate: Date?
	/// Indique si la récurrence est en pause (aucune transaction générée tant que c'est true)
	var isPaused: Bool
	
	init(
		id: UUID = UUID(),
		amount: Double,
		comment: String,
		type: TransactionType,
		category: TransactionCategory? = nil,
		frequency: RecurrenceFrequency = .monthly,
		startDate: Date = Date(),
		lastGeneratedDate: Date? = nil,
		isPaused: Bool = false
	) {
		self.id = id
		self.amount = amount
		self.comment = comment
		self.type = type
		self.category = category ?? TransactionCategory.guessFrom(comment: comment, type: type)
		self.frequency = frequency
		self.startDate = startDate
		self.lastGeneratedDate = lastGeneratedDate
		self.isPaused = isPaused
	}
	
	// MARK: - Calcul des prochaines occurrences
	
	/// Retourne toutes les dates d'occurrence entre deux dates
	func occurrences(from startRange: Date, to endRange: Date) -> [Date] {
		let calendar = Calendar.current
		var dates: [Date] = []
		var current = startDate
		
		// Avancer jusqu'au début de la plage
		while current < startRange {
			guard let next = nextDate(after: current, calendar: calendar) else { break }
			current = next
		}
		
		// Collecter les dates dans la plage
		while current <= endRange {
			dates.append(current)
			guard let next = nextDate(after: current, calendar: calendar) else { break }
			current = next
		}
		
		return dates
	}
	
	/// Retourne la prochaine date après une date donnée selon la fréquence
	private func nextDate(after date: Date, calendar: Calendar) -> Date? {
		switch frequency {
		case .daily:
			return calendar.date(byAdding: .day, value: 1, to: date)
		case .weekly:
			return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
		case .monthly:
			return calendar.date(byAdding: .month, value: 1, to: date)
		case .yearly:
			return calendar.date(byAdding: .year, value: 1, to: date)
		}
	}
	
	/// Retourne les transactions potentielles à générer (occurrences dans le mois à venir non encore générées)
	func pendingTransactions() -> [(date: Date, transaction: Transaction)] {
		let calendar = Calendar.current
		let now = Date()
		let startOfToday = calendar.startOfDay(for: now)
		
		guard let oneMonthLater = calendar.date(byAdding: .month, value: 1, to: startOfToday) else {
			return []
		}
		
		let upcoming = occurrences(from: startOfToday, to: oneMonthLater)
		
		return upcoming
			.filter { date in
				// Ne pas regénérer si déjà généré pour cette date
				if let lastGenerated = lastGeneratedDate {
					return date > lastGenerated
				}
				return true
			}
			.map { date in
				let finalAmount = type == .income ? amount : -amount
				let isToday = calendar.isDate(date, inSameDayAs: now)
				// Les transactions du jour sont directement validées
				// Les futures sont potentielles avec une date prévue (pour auto-validation ultérieure)
				let transaction = Transaction(
					amount: finalAmount,
					comment: comment,
					potentiel: !isToday,
					date: date,
					category: category,
					recurringTransactionId: self.id
				)
				return (date: date, transaction: transaction)
			}
	}
}
